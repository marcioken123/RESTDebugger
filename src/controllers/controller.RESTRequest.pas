unit controller.RESTRequest;

interface

uses
  REST.Client, FMX.Dialogs, System.UITypes,
  System.SysUtils, System.Classes, MMSystem,
  controller.MainForm;

procedure DoExecuteRequest(RESTRequest: tRESTRequest);

implementation

uses
  controller.Historico,
  untLog,
  ufrmWait,
  uMain_frm,
  FireDAC.Stan.Intf;

procedure DoExecuteRequest(RESTRequest: tRESTRequest);
begin
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
          RESTRequest.Execute;

          TLog.MyLogTemp('IntegracaoAPI (Resultado Ok). ' +
                         'Tentativa: "'        + IntToStr(1) + '" | ' +
                         'Url: "'              + frm_Main.cmb_RequestURL.Text       + '" | ' +
                         'Metodo: "'           + frm_Main.cmb_RequestMethod.Items[frm_Main.cmb_RequestMethod.ItemIndex] + '" | ' +
                         'ConteudoRecebido: "' + frm_Main.memo_ResponseBody.Text    + '" | ' ,
                         //'HttpStatusCode: "'   + LStatusCode               + '" | ' +
                         //'TempoDecorrido: "'   + LTempoDecorrido.ToString  + '"',
                         nil, 0, False, TCriticalLog.tlINFO);

          frm_Main.DoDisplayHTTPResponse(RESTRequest, frm_Main.RESTClient, frm_Main.RESTResponse);

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

          SalvarHistorico(frm_Main.FRESTParams.Id,
                          frm_Main.memo_ResponseHeader.Text,
                          frm_Main.memo_ResponseBody.Text,
                          frm_Main.RESTResponse.StatusCode);
       end);
      end;
    end;
  end).Start;
end;

end.
