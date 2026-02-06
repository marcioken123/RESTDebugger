unit controller.RESTRequest;

interface

procedure DoExecuteRequest;

implementation

uses
  untLog, REST.Client, ufrmWait, FMX.Dialogs, REST.Consts, System.UITypes,
  uMain_frm, System.SysUtils, System.Classes, REST.Response.Adapter, MMSystem,
  controller.UI;

procedure DoExecuteRequest;
begin
  TLog.MyLogTemp('Consumindo API ' + frm_Main.RESTClient.BaseURL, nil, 0, False, TCriticalLog.tlINFO);

  TWait.Start;
  frm_Main.RESTClient.ResetToDefaults;
  frm_Main.DoFetchRequestParamsFromControls;
  ConfigureHTTPConnection;

  // Fielddefs are recreated with every request. If FieldDefs already exist,
  // then RestResponseDatasetadpater will try to re-use them - which means that
  // we would end up with no-matching Responses and FieldDefs for different requests
  frm_Main.SaveGridColumnWidths;
  frm_Main.RESTResponseDataSetAdapter.FieldDefs.Clear;

  frm_Main.RESTRequest.ResetToDefaults;
  frm_Main.RESTResponse.ResetToDefaults;
  frm_Main.UpdateComponentProperties(False);

  if Trim(frm_Main.RESTClient.BaseURL) = '' then
  begin
    TWait.Done;
    MessageDlg(sRESTErrorEmptyURL, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  frm_Main.memo_ResponseHeader.Lines.Clear;
  frm_Main.memo_ResponseBody.Lines.Clear;

  TThread.CreateAnonymousThread(
  procedure
  var
    LCont: Integer;
  begin
    for LCont := 0 to Trunc(frm_Main.edt_Tentativas.Value) do
    begin
      TLog.MyLogTemp('IntegracaoAPI (Enviando). ' +
                     'Tentativa: "' + IntToStr(1) + '" | ' +
                     'Url: "'       + frm_Main.RESTClient.BaseURL + '" | ' +
                     'Metodo: "'    + frm_Main.cmb_RequestMethod.Items[frm_Main.cmb_RequestMethod.ItemIndex] + '"'+
                     'ConteudoEnviado: "' + frm_Main.memo_RequestBody.Text + '"',
                     nil, 0, False, TCriticalLog.tlINFO);
      try
        try
          frm_Main.RESTRequest.Execute;

          TLog.MyLogTemp('IntegracaoAPI (Resultado Ok). ' +
                         'Tentativa: "'        + IntToStr(1) + '" | ' +
                         'Url: "'              + frm_Main.cmb_RequestURL.Text       + '" | ' +
                         'Metodo: "'           + frm_Main.cmb_RequestMethod.Items[frm_Main.cmb_RequestMethod.ItemIndex] + '" | ' +
                         'ConteudoRecebido: "' + frm_Main.memo_ResponseBody.Text    + '" | ' ,
                         //'HttpStatusCode: "'   + LStatusCode               + '" | ' +
                         //'TempoDecorrido: "'   + LTempoDecorrido.ToString  + '"',
                         nil, 0, False, TCriticalLog.tlINFO);

          frm_Main.DoDisplayHTTPResponse(frm_Main.RESTRequest, frm_Main.RESTClient, frm_Main.RESTResponse);

          /// add the current request to the MRU-list
          frm_Main.DoAddToMRUList(frm_Main.FRESTParams);
          frm_Main.RestoreGridColumnWidths;
        except
//          on E: TRESTResponseDataSetAdapter.EJSONValueError do
//          begin
//            // Ignore
//          end;
//          on E: TRESTResponse.EJSONValueError do
//          begin
//            // Ignore
//          end;
          on E: Exception do
          begin
            TThread.Synchronize(nil,
            procedure
            begin
              frm_Main.memo_ResponseBody.Text := E.Message;
              TWait.Done;
              frm_Main.tc_Response.ActiveTab := frm_Main.ti_Response_Body;
            end);
          end;
        end;
      finally
        TThread.Synchronize(nil,
        procedure
        begin
          PlaySound('notification', 0, SND_ASYNC);
          TWait.Done;
          frm_Main.tc_Response.ActiveTab := frm_Main.ti_Response_Body;
        end);
      end;
    end;
  end).Start;
end;

end.
