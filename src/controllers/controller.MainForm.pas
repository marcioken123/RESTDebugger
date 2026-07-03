unit controller.MainForm;

interface

uses
  // Importe a unit onde o Tfrm_Main original está declarado
  uMain_frm, System.SysUtils, System.Classes, Winapi.Windows,
  provider.MRUList, provider.SettingsList, provider.Types, REST.Client,
  FMX.Edit;

type
  // Declaração do Class Helper
  TfrmMainHelper = class helper for Tfrm_Main
  public
    { Private declarations }
    procedure DoClearRequest;
    procedure FillReponseContentMemo;
    procedure ConfigureHTTPConnection;
    procedure InitRequestMethodCombo;
    procedure InitAuthMethodCombo;

    procedure DoResetControls;
    procedure DoFetchRequestParamsFromControls;
    procedure DoPushRequestParamsToControls;
    procedure DoUpdateProxyStateLabel;

    procedure DoAddCustomParameter;
    procedure DoEditCustomParameter;
    procedure DoDeleteCustomParameter;

    procedure DoUpdateAuthEditFields;

    procedure DoAddToMRUList(const AParams: TRESTRequestParams);
    procedure DoClearMRUList;
    procedure DoUpdateMRUList;
//    procedure DoClearRequest;

    procedure DoCallOAuthAssistant;

    procedure DoDisplayHTTPResponse(ARequest: TRESTRequest; AClient: TRESTClient; AResponse: TRESTResponse);

    procedure SynchEditCaret(AEdit1, AEdit2: TCustomEdit);
    procedure UpdateRootElement;
    procedure UpdateComponentProperties(ABodyAsValue: Boolean);

    procedure SaveGridColumnWidths;
    procedure RestoreGridColumnWidths;
    function MakeWidthKey(const AHeader: string): string;
  end;

implementation

uses
  System.JSON, provider.Consts, REST.Types, ufrmCustomHeaderDlg,
  System.UITypes, ufrmoauth1, ufrmoauth2, FMX.Dialogs, REST.Consts,
  System.Net.URLClient, System.UIConsts, System.Types, ufrmWait, FMX.Grid,
  untLog;

procedure TfrmMainHelper.DoClearRequest;
begin
  frm_Main.EditRootElement.Text := EmptyStr;
  frm_Main.FRESTParams.ResetToDefaults;
  frm_Main.DoPushRequestParamsToControls;
end;

procedure TfrmMainHelper.FillReponseContentMemo;
begin
  // Json or not?
  TThread.Synchronize(nil, procedure
    procedure SetLabel(const AValue: string);
    begin
      frm_Main.LabelJson.Text := AValue;
      frm_Main.LabelJsonTab.Text := AValue;
    end;
  var
    LJson: TJSONValue;
    LIntf: IRESTResponseJSON;
    S: string;
  begin
    LJson := frm_Main.RESTResponse.JSONValue;

    if Assigned(LJson) then
    begin
      // it's Json
      S := LJson.Format;
      if Length(S) > 200000 then
        S := Copy(S, 1, 200000) + ' ...';

      //memo_ResponseBody.Lines.Text := S;
      frm_Main.memo_ResponseBody.Lines.Add(S);

      SetLabel(RSContentIsValidJSON);
    end
    else
    begin
      LIntf := frm_Main.RESTREsponse;
      // pure text
      //memo_ResponseBody.Lines.Text := RESTResponse.Content;
      frm_Main.memo_ResponseBody.Lines.Add(S);

      if LIntf.HasJSONResponse then
        SetLabel(RSInvalidRootElement)
      else
        SetLabel(RSContentIsNotJSON);
      // EditRootElement.Enabled := false;
      // ButtonRootElement.Enabled := false;
    end;

    frm_Main.memo_ResponseBody.Repaint;
  end);
end;

procedure TfrmMainHelper.ConfigureHTTPConnection;
begin
  if frm_Main.cbProxy.IsChecked then
  begin
    frm_Main.RESTClient.ProxyServer   := frm_Main.edt_ProxyServer.Text;
    frm_Main.RESTClient.ProxyPort     := Trunc(frm_Main.edt_ProxyPort.Value);
    frm_Main.RESTClient.ProxyUsername := frm_Main.edt_ProxyUser.Text;
    frm_Main.RESTClient.ProxyPassword := frm_Main.edt_ProxyPass.Text;
  end
  else
  begin
    frm_Main.RESTClient.ProxyServer   := EmptyStr;
    frm_Main.RESTClient.ProxyPort     := 0;
    frm_Main.RESTClient.ProxyUsername := EmptyStr;
    frm_Main.RESTClient.ProxyPassword := EmptyStr;
  end;

  if frm_Main.cbTimeout.IsChecked then
    frm_Main.RESTRequest.Timeout := Trunc(frm_Main.edt_Timeout.Value)
  else
    frm_Main.RESTRequest.Timeout := 0;
end;

procedure TfrmMainHelper.InitRequestMethodCombo;
var
  LRequestMethod: TRESTRequestMethod;
begin
  cmb_RequestMethod.BeginUpdate;
  TRY
    cmb_RequestMethod.Clear;
    for LRequestMethod IN [Low(TRESTRequestMethod) .. High(TRESTRequestMethod)] do
      cmb_RequestMethod.Items.Add(RESTRequestMethodToString(LRequestMethod));
  FINALLY
    cmb_RequestMethod.EndUpdate;
  END;

  /// try to set the itemindex to the default-value
  if (cmb_RequestMethod.Items.IndexOf(RESTRequestMethodToString(DefaultRESTRequestMethod)) > -1) then
    cmb_RequestMethod.ItemIndex := cmb_RequestMethod.Items.IndexOf(RESTRequestMethodToString(DefaultRESTRequestMethod));
end;

procedure TfrmMainHelper.InitAuthMethodCombo;
var
  LAuthMethod: TRESTAuthMethod;
begin
  cmb_AuthMethod.BeginUpdate;
  TRY
    cmb_AuthMethod.Clear;
    for LAuthMethod IN [Low(TRESTAuthMethod) .. High(TRESTAuthMethod)] do
      cmb_AuthMethod.Items.Add(RESTAuthMethodToString(LAuthMethod));
  FINALLY
    cmb_AuthMethod.EndUpdate;
  END;

  /// try to set the itemindex to the default-value
  if (cmb_AuthMethod.Items.IndexOf(RESTAuthMethodToString(DefaultRESTAuthMethod)) > -1) then
    cmb_AuthMethod.ItemIndex := cmb_AuthMethod.Items.IndexOf(RESTAuthMethodToString(DefaultRESTAuthMethod));
end;

procedure TfrmMainHelper.DoResetControls;
begin
  lbl_LastRequestStats.Text := EmptyStr;

  memo_RequestBody.Lines.Clear;
  memo_ResponseHeader.Lines.Clear;
  memo_ResponseBody.Lines.Clear;

  cmb_RequestMethod.ItemIndex := cmb_RequestMethod.Items.IndexOf(RESTRequestMethodToString(DefaultRESTRequestMethod));

  /// try to set the itemindex to the default-value
  cmb_AuthMethod.ItemIndex := cmb_AuthMethod.Items.IndexOf(RESTAuthMethodToString(DefaultRESTAuthMethod));
  edt_AuthUsername.Text := EmptyStr;
  edt_AuthPassword.Text := EmptyStr;

  DoUpdateAuthEditFields;

  cbProxy.IsChecked := false;
  edt_ProxyServer.Text := EmptyStr;
  edt_ProxyUser.Text := EmptyStr;
  edt_ProxyPass.Text := EmptyStr;
  edt_ProxyPort.Value := 1000;

  cbTimeout.IsChecked := True;
  edt_Timeout.Value := 30000;

  lb_CustomParameters.Clear;
end;

procedure TfrmMainHelper.DoUpdateAuthEditFields;
var
  LSelectedMethod: TRESTAuthMethod;
begin
  if (cmb_AuthMethod.ItemIndex > -1) then
    LSelectedMethod := RESTAuthMethodFromString(cmb_AuthMethod.Items[cmb_AuthMethod.ItemIndex])
  else
    LSelectedMethod := DefaultRESTAuthMethod;

  case LSelectedMethod of
    amNONE:
      begin
        edt_AuthUsername.Enabled := false;
        edt_AuthUsernameKey.Enabled := false;
        edt_AuthPassword.Enabled := false;
        edt_AuthPasswordKey.Enabled := false;
        edt_AuthClientID.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthAccessToken.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthRequestToken.Enabled := false;

        btn_OAuthAssistant.Enabled := false;
      end;
    amSIMPLE:
      begin
        edt_AuthUsername.Enabled := true;
        edt_AuthUsernameKey.Enabled := true;
        edt_AuthPassword.Enabled := true;
        edt_AuthPasswordKey.Enabled := true;
        edt_AuthClientID.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthAccessToken.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthRequestToken.Enabled := false;

        btn_OAuthAssistant.Enabled := false;
      end;
    amBASIC:
      begin
        edt_AuthUsername.Enabled := true;
        edt_AuthUsernameKey.Enabled := false;
        edt_AuthPassword.Enabled := true;
        edt_AuthPasswordKey.Enabled := false;
        edt_AuthClientID.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthAccessToken.Enabled := false;
        edt_AuthClientSecret.Enabled := false;
        edt_AuthRequestToken.Enabled := false;

        btn_OAuthAssistant.Enabled := false;
      end;
    amOAUTH:
      begin
        edt_AuthUsername.Enabled := false;
        edt_AuthUsernameKey.Enabled := false;
        edt_AuthPassword.Enabled := false;
        edt_AuthPasswordKey.Enabled := false;
        edt_AuthClientID.Enabled := true;
        edt_AuthClientSecret.Enabled := true;
        edt_AuthAccessToken.Enabled := true;
        edt_AuthClientSecret.Enabled := true;
        edt_AuthRequestToken.Enabled := true;

        btn_OAuthAssistant.Enabled := true;
      end;
    amOAUTH2:
      begin
        edt_AuthUsername.Enabled := false;
        edt_AuthUsernameKey.Enabled := false;
        edt_AuthPassword.Enabled := false;
        edt_AuthPasswordKey.Enabled := false;
        edt_AuthClientID.Enabled := true;
        edt_AuthClientSecret.Enabled := true;
        edt_AuthAccessToken.Enabled := true;
        edt_AuthClientSecret.Enabled := true;
        edt_AuthRequestToken.Enabled := true;

        btn_OAuthAssistant.Enabled := true;
      end;
  end;
end;

procedure TfrmMainHelper.DoUpdateMRUList;
var
  LItem: TRESTRequestParams;
begin
  TLog.MyLogTemp('DoUpdateMRUList. Atualizando lista de APIs. Total: ' + IntToStr(FMRUList.Items.Count), nil, 0, False, TCriticalLog.tlINFO);
  cmb_RequestURL.Items.BeginUpdate;
  cmb_RequestURL.Items.Clear;

  for LItem IN FMRUList.Items do
  begin
    cmb_RequestURL.Items.AddObject(LItem.ToString, LItem);

    if LItem.ID = 0 then
      LItem.ID := cmb_RequestURL.Items.Count + 1;
  end;

  cmb_RequestURL.Items.EndUpdate;

  /// we do know that the last executed request is on top of the
  /// mru-list. so the item-index of the dropdown must be set to
  /// zero.
  if (cmb_RequestURL.Items.Count > 0) AND (cmb_RequestURL.Text <> EmptyStr) then
    cmb_RequestURL.ItemIndex := 0
  else
    cmb_RequestURL.ItemIndex := -1;

  if (cmb_RequestURL.ItemIndex > -1) then
    cmb_RequestURL.Text := TRESTRequestParams(cmb_RequestURL.Items.Objects[cmb_RequestURL.ItemIndex]).URL;
end;

procedure TfrmMainHelper.DoUpdateProxyStateLabel;
begin
  if cbProxy.IsChecked then
  begin
    lbl_ProxyState.Text := RSProxyServerEnabled + edt_ProxyServer.Text;
    if (edt_ProxyPort.Value > 0.1) then
      lbl_ProxyState.Text := lbl_ProxyState.Text + ':' + IntToStr(Trunc(edt_ProxyPort.Value));
  end
  else
    lbl_ProxyState.Text := RSProxyServerDisabled;
end;

procedure TfrmMainHelper.DoAddCustomParameter;
var
  LParameter: TRESTRequestParameter;
  LDialog: Tfrm_CustomHeaderDlg;
  LKind: TRESTRequestParameterKind;
begin
  self.DoFetchRequestParamsFromControls;

  LDialog := Tfrm_CustomHeaderDlg.Create(self, NIL);
  try
    if (LDialog.ShowModal = mrOK) then
    begin
      if (LDialog.cmb_ParameterKind.ItemIndex > -1) then
        LKind := RESTRequestParameterKindFromString
          (LDialog.cmb_ParameterKind.Items[LDialog.cmb_ParameterKind.ItemIndex])
      else
        LKind := DefaultRESTRequestParameterKind;

      LParameter := FRESTParams.CustomParams.AddItem;
      LParameter.Name := LDialog.cmb_ParameterName.Text;
      LParameter.Value := LDialog.edt_ParameterValue.Text;
      LParameter.Kind := LKind;
      if LDialog.cbx_DoNotEncode.IsChecked then
        LParameter.Options := LParameter.Options + [poDoNotEncode]
      else
        LParameter.Options := LParameter.Options - [poDoNotEncode];

      DoPushRequestParamsToControls;
    end;
  finally
    LDialog.Release;
  end;
end;

procedure TfrmMainHelper.DoAddToMRUList(const AParams: TRESTRequestParams);
begin
  TLog.MyLogTemp('DoAddToMRUList. Adicionando API na lista. URL: ' + AParams.URL, nil, 0, False, TCriticalLog.tlINFO);
  Assert(Assigned(AParams));

  FMRUList.AddItem(FRESTParams);
  DoUpdateMRUList;
end;

procedure TfrmMainHelper.DoCallOAuthAssistant;
var
  frm1: Tfrm_OAuth1;
  frm2: Tfrm_OAuth2;
  res: Integer;
begin
  DoFetchRequestParamsFromControls;

  if (FRESTParams.AuthMethod = amOAUTH) then
  begin
    frm1 := Tfrm_OAuth1.Create(self);
    TRY
      frm1.PushParamsToControls(FRESTParams);
      res := frm1.ShowModal;

      if IsPositiveResult(res) then
      begin
        frm1.FetchParamsFromControls(FRESTParams);
        DoPushRequestParamsToControls;
      end;
    FINALLY
      frm1.Release;
    END;
  end
  else if (FRESTParams.AuthMethod = amOAUTH2) then
  begin
    frm2 := Tfrm_OAuth2.Create(self);
    TRY
      frm2.PushParamsToControls(FRESTParams);
      res := frm2.ShowModal;

      if IsPositiveResult(res) then
      begin
        frm2.FetchParamsFromControls(FRESTParams);
        DoPushRequestParamsToControls;
      end;
    FINALLY
      frm2.Release;
    END;
  end;
end;

procedure TfrmMainHelper.DoClearMRUList;
begin
  if (MessageDlg(RSConfirmClearRecentRequests, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0, TMsgDlgBtn.mbNo) = mrYes) then
  begin
    DoFetchRequestParamsFromControls;

    FMRUList.Clear;
    cmb_RequestURL.Items.Clear;

    DoPushRequestParamsToControls;
  end;
end;

procedure TfrmMainHelper.DoEditCustomParameter;
var
  LParameter: TRESTRequestParameter;
  LDialog: Tfrm_CustomHeaderDlg;
begin
  if (lb_CustomParameters.ItemIndex < 0) then
  begin
    MessageDlg(RSNoCustomParameterSelected, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    EXIT;
  end;

  DoFetchRequestParamsFromControls;

  LParameter := FRESTParams.CustomParams.ParameterByIndex(lb_CustomParameters.ItemIndex);

  LDialog := Tfrm_CustomHeaderDlg.Create(self, LParameter);
  try
    if (LDialog.ShowModal = mrOK) then
    begin
      LParameter.Name := LDialog.cmb_ParameterName.Text;
      LParameter.Value := LDialog.edt_ParameterValue.Text;

      if (LDialog.cmb_ParameterKind.ItemIndex > -1) then
        LParameter.Kind := RESTRequestParameterKindFromString(LDialog.cmb_ParameterKind.Items[LDialog.cmb_ParameterKind.ItemIndex])
      else
        LParameter.Kind := DefaultRESTRequestParameterKind;

      if LDialog.cbx_DoNotEncode.IsChecked then
        LParameter.Options := LParameter.Options + [poDoNotEncode]
      else
        LParameter.Options := LParameter.Options - [poDoNotEncode];

      self.DoPushRequestParamsToControls;
    end;
  finally
    LDialog.Release;
  end;
end;

procedure TfrmMainHelper.DoDeleteCustomParameter;
var
  LParameter: TRESTRequestParameter;
begin
  if (lb_CustomParameters.ItemIndex < 0) then
  begin
    MessageDlg(RSNoCustomParameterSelected, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  self.DoFetchRequestParamsFromControls;

  LParameter := FRESTParams.CustomParams.ParameterByIndex(lb_CustomParameters.ItemIndex);

  if (MessageDlg(RSConfirmDeleteCustomParameter + LineFeed + '"' + LParameter.ToString + '"?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0, TMsgDlgBtn.mbNo) = mrYes) then
  begin
    FRESTParams.CustomParams.Delete(LParameter);
    DoPushRequestParamsToControls;
  end;
end;

procedure TfrmMainHelper.DoDisplayHTTPResponse(ARequest: TRESTRequest; AClient: TRESTClient; AResponse: TRESTResponse);
begin
  TThread.Synchronize(nil, procedure
  var
    i: integer;
  begin
    if AResponse.StatusCode >= 300 then
    begin
      lbl_LastRequestStats.FontColor := claRed;
    end
    else
    begin
      lbl_LastRequestStats.FontColor := claBlack;
    end;

    /// we need to duplicate the ampersands to display them in a label ... ...
    lbl_LastRequestURL.Text := StringReplace( AResponse.FullRequestURI, '&', '&&', [rfReplaceAll] );

    lbl_LastRequestStats.Text := Format(RSBytesOfDataReturnedAndTiming,
                                        [AResponse.StatusCode, AResponse.StatusText, AResponse.ContentLength,
                                        ARequest.ExecutionPerformance.PreProcessingTime,
                                        ARequest.ExecutionPerformance.ExecutionTime,
                                        ARequest.ExecutionPerformance.PostProcessingTime,
                                        ARequest.ExecutionPerformance.TotalExecutionTime]);

    /// transfer http-headers into memo
    memo_ResponseHeader.Lines.Clear;
    for i := 0 to AResponse.Headers.Count - 1 do
      memo_ResponseHeader.Lines.Add(AResponse.Headers[i]);
  end);

  FillReponseContentMemo;
end;

procedure TfrmMainHelper.SynchEditCaret(AEdit1, AEdit2: TCustomEdit);
var
  LCaret: Integer;
begin
  if AEdit2.Text <> EmptyStr then
  begin
    AEdit2.SetFocus;
    AEdit2.SelLength := 0;
    LCaret := AEdit1.CaretPosition;
    AEdit2.CaretPosition := LCaret;
  end;
end;

procedure TfrmMainHelper.UpdateRootElement;
var
  LIntf: IRESTResponseJSON;
begin
  Assert(EditRootElement.Text = EditRootElementTab.Text);

  if (RESTResponse.RootElement <> EditRootElement.Text) or
     (cb_NestedFields.IsChecked <> RESTResponseDataSetAdapter.NestedElements){ or
     (cb_ViewAs.ItemIndex <> Integer(RESTResponseDataSetAdapter.TypesMode))} then
  begin
    SaveGridColumnWidths;
    try
     LIntf := RESTResponse;
      if not LIntf.HasJSONResponse then
        if RESTResponse.ContentLength > 0 then
          raise Exception.Create(Format(RSRootElementAppliesToJSON, [EditRootElement.Text]));
      RESTResponse.RootElement := EditRootElement.Text;
    except
      TWait.Done;
      RESTResponse.RootElement := FCurrentRootElement;
      if tc_Response.ActiveTab = ti_Response_TableView then
        EditRootElementTab.SetFocus
      else
      begin
        tc_Response.ActiveTab := ti_Response_Body;
        EditRootElement.SetFocus
      end;
      raise;
    end;

    RESTResponseDataSetAdapter.NestedElements := cb_NestedFields.IsChecked;
    //RESTResponseDataSetAdapter.TypesMode := TJSONTypesMode(cb_ViewAs.ItemIndex);
    RestoreGridColumnWidths;
    FillReponseContentMemo;
  end;
end;

procedure TfrmMainHelper.UpdateComponentProperties(ABodyAsValue: Boolean);
var
  LPrevPos: Int64;
  s: AnsiString;
begin
  //EditRootElement.Text := EmptyStr;
  DoFetchRequestParamsFromControls;
  ConfigureHTTPConnection;

  RESTClient.BaseURL := cmb_RequestURL.Text;
  RESTRequest.Resource := FRESTParams.Resource;

  RESTRequest.Params.Clear;
  RESTRequest.Params.Assign(FRESTParams.CustomParams);

  if FRESTParams.CustomBody.Size > 0 then
    if ABodyAsValue then
    begin
      LPrevPos := FRESTParams.CustomBody.Position;
      try
        FRESTParams.CustomBody.Position := 0;
        SetLength(s, FRESTParams.CustomBody.Size);
        FRESTParams.CustomBody.Read(s[1], FRESTParams.CustomBody.Size);
        RESTRequest.AddBody(s, ContentTypeFromString(FRESTParams.ContentType));
      finally
        FRESTParams.CustomBody.Position := LPrevPos;
      end;
    end
    else
      RESTRequest.AddBody(FRESTParams.CustomBody, ContentTypeFromString(FRESTParams.ContentType));

  RESTRequest.Method := FRESTParams.Method;

  case FRESTParams.AuthMethod of
    TRESTAuthMethod.amNONE:
      begin
        RESTClient.Authenticator := NIL;
      end;
    TRESTAuthMethod.amSIMPLE:
      begin
        RESTClient.Authenticator := SimpleAuthenticator;
        SimpleAuthenticator.Username := FRESTParams.AuthUsername;
        SimpleAuthenticator.UsernameKey := FRESTParams.AuthUsernameKey;
        SimpleAuthenticator.Password := FRESTParams.AuthPassword;
        SimpleAuthenticator.PasswordKey := FRESTParams.AuthPasswordKey;
      end;
    TRESTAuthMethod.amBASIC:
      begin
        RESTClient.Authenticator := HTTPBasicAuthenticator;
        HTTPBasicAuthenticator.Username := FRESTParams.AuthUsername;
        HTTPBasicAuthenticator.Password := FRESTParams.AuthPassword;
      end;
    TRESTAuthMethod.amOAUTH:
      begin
        RESTClient.Authenticator := OAuth1Authenticator;
        OAuth1Authenticator.ConsumerKey := FRESTParams.ClientID;
        OAuth1Authenticator.ConsumerSecret := FRESTParams.ClientSecret;
        OAuth1Authenticator.AccessToken := FRESTParams.AccessToken;
        OAuth1Authenticator.AccessTokenSecret := FRESTParams.AccessTokenSecret;
      end;
    TRESTAuthMethod.amOAUTH2:
      begin
        RESTClient.Authenticator := OAuth2Authenticator;
        OAuth2Authenticator.AccessToken := FRESTParams.AccessToken;
      end;
  else
    raise ERESTException.Create(sRESTUnsupportedAuthMethod);
  end;

  RESTRequest.Client := RESTClient;
end;

procedure TfrmMainHelper.DoFetchRequestParamsFromControls;
var
  LURL: string;
  I: Integer;
begin
  TLog.MyLogTemp('DoFetchRequestParamsFromControls. Adicionando API na lista. URL: ', nil, 0, False, TCriticalLog.tlINFO);
  /// workaround for a bug in FMX - the onchange-events are triggered too early.
  /// this is not a problem for our objects, but we get an AV while querying a
  /// tedit for it's text.
  TThread.Synchronize(nil, procedure begin
    if not Visible then
      Exit;

    if (cmb_RequestMethod.ItemIndex > -1) then
      FRESTParams.Method := RESTRequestMethodFromString(cmb_RequestMethod.Items[cmb_RequestMethod.ItemIndex])
    else
      FRESTParams.Method := DefaultRESTRequestMethod;

    LURL := Trim(cmb_RequestURL.Text);
    I := LURL.IndexOf('+ -->');
    if I > 0 then
      LURL := Trim(LURL.Substring(0, I));

    cmb_RequestURL.Text     := TURI.FixupForREST(LURL);
    FRESTParams.URL         := cmb_RequestURL.Text;
    FRESTParams.Resource    := edt_Resource.Text;
    FRESTParams.ContentType := edt_ContentType.Text;

    /// after fetching the resource, we try to re-create the parameter-list
    //FRESTParams.CustomParams.FromString(EmptyStr, FRESTParams.Resource);
    FRESTParams.CustomParams.CreateURLSegmentsFromString(FRESTParams.Resource);

    if (cmb_AuthMethod.ItemIndex > -1) then
      FRESTParams.AuthMethod := RESTAuthMethodFromString(cmb_AuthMethod.Items[cmb_AuthMethod.ItemIndex])
    else
      FRESTParams.AuthMethod := DefaultRESTAuthMethod;

    FRESTParams.AuthUsername    := edt_AuthUsername.Text;
    FRESTParams.AuthUsernameKey := edt_AuthUsernameKey.Text;
    FRESTParams.AuthPassword    := edt_AuthPassword.Text;
    FRESTParams.AuthPasswordKey := edt_AuthPasswordKey.Text;
    FRESTParams.ClientID        := edt_AuthClientID.Text;
    FRESTParams.ClientSecret    := edt_AuthClientSecret.Text;
    FRESTParams.AccessToken     := edt_AuthAccessToken.Text;
    FRESTParams.RequestToken    := edt_AuthRequestToken.Text;
    FRESTParams.ID              := FRESTParams.CustomParams.Count + 1;

    DoUpdateProxyStateLabel;

    FRESTParams.CustomBody.Clear;
    memo_RequestBody.Lines.WriteBOM := False;
    memo_RequestBody.Lines.SaveToStream(FRESTParams.CustomBody, TEncoding.UTF8);

    FRESTParams.DataSetView := cb_ViewAs.ItemIndex;
  end);
end;

procedure TfrmMainHelper.DoPushRequestParamsToControls;
var
  s: string;
  LParameter: TRESTRequestParameter;
begin
  s := RESTRequestMethodToString(FRESTParams.Method);
  if (cmb_RequestMethod.Items.IndexOf(s) > -1) then
    cmb_RequestMethod.ItemIndex := cmb_RequestMethod.Items.IndexOf(s)
  else
    cmb_RequestMethod.ItemIndex := -1;

  cmb_RequestURL.Text := FRESTParams.URL;
  edt_Resource.Text := FRESTParams.Resource;

  if (edt_ContentType.Items.IndexOf(FRESTParams.ContentType) > -1) then
  begin
    edt_ContentType.ItemIndex := edt_ContentType.Items.IndexOf(FRESTParams.ContentType);
    edt_ContentType.Text := FRESTParams.ContentType;
  end
  else
  begin
    edt_ContentType.ItemIndex := -1;
    edt_ContentType.Text := EmptyStr;
  end;

  s := RESTAuthMethodToString(FRESTParams.AuthMethod);
  if (cmb_AuthMethod.Items.IndexOf(s) > -1) then
    cmb_AuthMethod.ItemIndex := cmb_AuthMethod.Items.IndexOf(s)
  else
    cmb_RequestMethod.ItemIndex := -1;

  edt_AuthUsername.Text     := FRESTParams.AuthUsername;
  edt_AuthUsernameKey.Text  := FRESTParams.AuthUsernameKey;
  edt_AuthPassword.Text     := FRESTParams.AuthPassword;
  edt_AuthPasswordKey.Text  := FRESTParams.AuthPasswordKey;
  edt_AuthClientID.Text     := FRESTParams.ClientID;
  edt_AuthClientSecret.Text := FRESTParams.ClientSecret;
  edt_AuthAccessToken.Text  := FRESTParams.AccessToken;
  edt_AuthRequestToken.Text := FRESTParams.RequestToken;

  DoUpdateProxyStateLabel;

  lb_CustomParameters.BeginUpdate;
  lb_CustomParameters.Items.BeginUpdate;
  try
    lb_CustomParameters.Clear;
    for LParameter IN FRESTParams.CustomParams do
    begin
      lb_CustomParameters.Items.AddObject(LParameter.ToString, LParameter);
    end;
  finally
    lb_CustomParameters.Items.EndUpdate;
    lb_CustomParameters.EndUpdate;
  end;

  if (FRESTParams.CustomBody.Size > 0) then
  begin
    FRESTParams.CustomBody.Seek(0, soFromBeginning);
    memo_RequestBody.Lines.LoadFromStream(FRESTParams.CustomBody);
  end
  else
    memo_RequestBody.Lines.Clear;

  cb_ViewAs.ItemIndex := FRESTParams.DataSetView;
  UpdateRootElement;
end;

procedure TfrmMainHelper.SaveGridColumnWidths;
var
  I: Integer;
  LColumn: TColumn;
  LKey: string;
begin
  for I := 0 to StringGrid1.ColumnCount - 1 do
  begin
    LColumn := StringGrid1.Columns[I];
    LKey := MakeWidthKey(LColumn.Header);
    FSettingsList.AddWidth(LKey, Round(LColumn.Width));
  end;

  FSettingsList.SaveToFile;
end;

procedure TfrmMainHelper.RestoreGridColumnWidths;
var
  I: Integer;
  LColumn: TColumn;
  LKey: string;
  LWidth: Integer;
begin
  for I := 0 to StringGrid1.ColumnCount - 1 do
  begin
    LColumn := StringGrid1.Columns[I];
    LKey := MakeWidthKey(LColumn.Header);
    if FSettingsList.GetWidth(LKey, LWidth) then
      LColumn.Width := LWidth;
  end;
end;

function TfrmMainHelper.MakeWidthKey(const AHeader: string): string;
var
  I, J: Integer;
begin
  Result := AHeader;
  if RESTResponse.RootElement <> EmptyStr then
    if RESTResponse.JSONValue is TJSONObject then
      Result := RESTREsponse.RootElement + '.' + AHeader;
  // Normalize [0]
  repeat
    I := Result.IndexOf('[');
    if I >= 0 then
    begin
      J := Result.IndexOf(']', I);
      if J > 0 then
        Result := Result.Substring(0, I) + '||' + Result.Substring(J+1, Length(Result))
      else
        Result := Result.Substring(0, I) + '||';
    end;
  until I < 0;
  if Result.StartsWith('||.') then
    Result := Result.SubString(3);
end;

end.
