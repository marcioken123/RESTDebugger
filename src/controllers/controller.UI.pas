unit controller.UI;

interface

uses
  uMain_frm,
  provider.Types,
  System.JSON,
  REST.Client,
  provider.Consts;

procedure DoClearRequest;
procedure FillReponseContentMemo;
procedure ConfigureHTTPConnection;

implementation

uses
  System.Classes;

procedure DoClearRequest;
begin
  frm_Main.EditRootElement.Text := '';
  frm_Main.FRESTParams.ResetToDefaults;
  frm_Main.DoPushRequestParamsToControls;
end;

procedure FillReponseContentMemo;
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

procedure ConfigureHTTPConnection;
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
    frm_Main.RESTClient.ProxyServer   := '';
    frm_Main.RESTClient.ProxyPort     := 0;
    frm_Main.RESTClient.ProxyUsername := '';
    frm_Main.RESTClient.ProxyPassword := '';
  end;

  if frm_Main.cbTimeout.IsChecked then
    frm_Main.RESTRequest.Timeout := Trunc(frm_Main.edt_Timeout.Value)
  else
    frm_Main.RESTRequest.Timeout := 0;
end;

end.
