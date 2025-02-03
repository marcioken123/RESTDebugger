unit provider.RESTRequest;

interface

uses
  REST.Client;

type
  TRESTRequestNew = class(TRESTRequest)
  public
    procedure Execute;
  end;

implementation

uses
  System.Classes, REST.Types, System.SysUtils, System.Net.Mime;

{ TRESTRequestNew }

procedure TRESTRequestNew.Execute;
var
  LParamsList: TRESTRequestParameterArray;
  LURL: string;
  LResponseStream: TMemoryStream;
  LContentType: TRESTContentType;
  LBodyStream: TStream;
  LBodyStreamOwner: Boolean;
  LContent: string;
  LCharSet: string;
  LParam: TRESTRequestParameter;
  LContentIsString: Boolean;
  LEncoding: TEncoding;
  LLowerContentType: string;
  LMimeKind: TMimeTypes.TKind;
  LExt: string;
begin
  FExecutionPerformance.Start;

  DoBeforeExecute;

  // If no client then raise an exception
  if FClient = nil then
    raise ERESTException.CreateRes(@sNoClientAttached);

  // If a response-object was attached to this response we will use it
  // If no response exists yet, then one is created on the fly and will be managed
  // otherwise we do create a new response-object and return a reference
  // to it.
  if FResponse = nil then
  begin
    FResponse := TCustomRESTResponse.Create(Self);
    DoResponseChanged;
  end;

  FResponse.BeginUpdate;
  try

    if FClient.Authenticator <> nil then
      FClient.Authenticator.Authenticate(Self);

    if FBody.FParams.Count > 0 then
      for LParam in FBody.FParams do

        if LParam.Stream <> nil then
          FParams.AddItem(LParam.FName, LParam.Stream, LParam.FKind,
            LParam.Options, LParam.ContentType, ooApp)
        else
          FParams.AddItem(LParam.FName, LParam.Value, LParam.FKind,
            LParam.Options, LParam.ContentType);

    if FBody.FJSONTextWriter <> nil then
      FBody.FJSONTextWriter.Close;

    if (FBody.FJSONStream <> nil) and (FBody.FJSONStream.Size > 0) then
      FParams.AddItem(sBody, FBody.FJSONStream, TRESTRequestParameterKind.pkREQUESTBODY,
        [], TRESTContentType.ctAPPLICATION_JSON);

    LParamsList := CreateUnionParameterList;
    LContentType := ContentType(LParamsList);
    FRequestContentType := ContentTypeToString(LContentType);

    // Build the full request URL
    LURL := GetFullURL;
    DoApplyURLSegments(LParamsList, LURL);
    // URL encoding BEFORE parameters are attached, which may bring their own encoding
    if not URLAlreadyEncoded then
      LURL := TURI.Create(LURL).Encode;

    DoApplyCookieParams(LParamsList, LURL);
    FClient.HTTPClient.Request.CustomHeaders.Clear;
    DoApplyHeaderParams(LParamsList);
    DoPrepareQueryString(LParamsList, LContentType, LURL);

    // Set several default headers for handling content-types, encoding, acceptance etc.
    FClient.Accept := Accept;
    FClient.HandleRedirects := HandleRedirects;
    FClient.AllowCookies := AllowCookies;
    FClient.AcceptCharset := AcceptCharset;
    FClient.AcceptEncoding := AcceptEncoding;
    FClient.ConnectTimeout := ConnectTimeout;
    FClient.ReadTimeout := ReadTimeout;

    LBodyStream := nil;
    LBodyStreamOwner := True;
    LResponseStream := nil;
    try
      if LContentType <> ctNone then
      begin
        // POST, PUT and PATCH requests typically include a body, so all relevant params
        // go into a body stream. The body stream has to consider the actual content-type
        // (wwwform vs. multipart).
        DoPrepareRequestBody(LParamsList, LContentType, LBodyStream, LBodyStreamOwner);
        FClient.ContentType := FRequestContentType;
      end;

      LResponseStream := TMemoryStream.Create;
      FExecutionPerformance.PreProcessingDone;
      try
        case Method of
          TRESTRequestMethod.rmGET:
            FClient.HTTPClient.Get(LURL, LBodyStream, LResponseStream);
          TRESTRequestMethod.rmPOST:
            FClient.HTTPClient.Post(LURL, LBodyStream, LResponseStream);
          TRESTRequestMethod.rmPUT:
            FClient.HTTPClient.Put(LURL, LBodyStream, LResponseStream);
          TRESTRequestMethod.rmDELETE:
            FClient.HTTPClient.Delete(LURL, LBodyStream, LResponseStream);
          TRESTRequestMethod.rmPATCH:
            FClient.HTTPClient.Patch(LURL, LBodyStream, LResponseStream);
        else
          raise EInvalidOperation.CreateRes(@sUnknownRequestMethod);
        end;
        FExecutionPerformance.ExecutionDone;

        LContentIsString := False;
        LEncoding := nil;
        try
          LLowerContentType := LowerCase(Client.HTTPClient.Response.ContentType);
          LCharSet := Client.HTTPClient.Response.CharSet;
          if LCharSet <> '' then
            LContentIsString := True
          else
          begin
            TMimeTypes.Default.GetTypeInfo(LLowerContentType, LExt, LMimeKind);
            // Skip if blank or 'raw'
            if (FClient.FallbackCharsetEncoding <> '') and
               not SameText(REST_NO_FALLBACK_CHARSET, FClient.FallbackCharsetEncoding) then
            begin
              // Skip some obvious binary types
              if LMimeKind <> TMimeTypes.TKind.Binary then
              begin
                LEncoding := TEncoding.GetEncoding(FClient.FallbackCharsetEncoding);
                LContentIsString := True;
              end;
            end
            else
            begin
              // Even if no fallback, handle some obvious string types
              if LMimeKind = TMimeTypes.TKind.Text then
                LContentIsString := True;
            end;
          end;
          if LContentIsString then
            LContent := FClient.HTTPClient.Response.ContentAsString(LEncoding);
        finally
          LEncoding.Free;
        end;

      except
        // any kind of server/protocol error
        on E: EHTTPProtocolException do
        begin
          FExecutionPerformance.ExecutionDone;
          // we keep measuring only for protocal errors, i.e. where
          // the server actually answered, not for other exceptions.
          LContent := E.ErrorMessage; // Full error description

          // Fill RESTResponse with actual response data - error handler might want to access it
          ProcessResponse(LURL, LResponseStream, LContent);

          if (E.ErrorCode >= 500) and Client.RaiseExceptionOn500 then
            Exception.RaiseOuterException(ERESTException.Create(E.Message));
          HandleEvent(DoHTTPProtocolError);
        end;
        // Unknown error, might even be on the client side. raise it!
        on E: Exception do
        begin
          // If Execute raises an Exception, then the developer should have look into the actual BaseException
          Exception.RaiseOuterException(ERESTException.CreateFmt(sRESTRequestFailed, [E.Message]));
        end;
      end;

      // Fill RESTResponse with actual response data
      ProcessResponse(LURL, LResponseStream, LContent);

      // Performance timers do not care about events or observers
      FExecutionPerformance.PostProcessingDone;

      // Eventhandlers AFTER Observers
      HandleEvent(DoAfterExecute);

    finally
      FClient.Disconnect;

      LResponseStream.Free;
      if LBodyStreamOwner then
        LBodyStream.Free;
    end;
  finally
    FResponse.EndUpdate;
  end;
end;

end.
