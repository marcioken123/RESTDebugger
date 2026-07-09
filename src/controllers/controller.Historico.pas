unit controller.Historico;

interface

function SalvarHistorico(ID: Integer; Header, Response: string; StatusCode: Integer): Boolean;

implementation

uses
  System.SysUtils,
  uMain_frm,
  FireDAC.Stan.Intf;

function SalvarHistorico(ID: Integer; Header, Response: string; StatusCode: Integer): Boolean;
begin
  try
    if FileExists(StringReplace(ParamStr(0), '.exe', '.history.log', [])) then
      frm_Main.fmtHistorico.LoadFromFile(StringReplace(ParamStr(0), '.exe', '.history.log', []), sfJSON);

    frm_Main.fmtHistorico.Append;
    frm_Main.fmtHistoricoDATAHORA.AsDateTime := Now;
    frm_Main.fmtHistoricoID_REQUEST.AsInteger := ID;
    frm_Main.fmtHistoricoHEADER.AsString := Header;
    frm_Main.fmtHistoricoRESPONSE.AsString := Response;
    frm_Main.fmtHistoricoSTATUSCODE.AsInteger := StatusCode;
    frm_Main.fmtHistorico.Post;
    frm_Main.fmtHistorico.SaveToFile(StringReplace(ParamStr(0), '.exe', '.history.log', []), sfJSON);
  finally

  end;
end;

end.
