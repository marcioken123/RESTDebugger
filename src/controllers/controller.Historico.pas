unit controller.Historico;

interface

function CarregarHistorico: Boolean;
function SalvarHistorico: Boolean; overload;
function SalvarHistorico(ID: Integer; Header, Response: string; StatusCode: Integer): Boolean; overload;

implementation

uses
  untLog,
  System.SysUtils,
  uMain_frm,
  FireDAC.Stan.Intf;

function CarregarHistorico: Boolean;
begin
  try
    try
      if FileExists(StringReplace(ParamStr(0), '.exe', '.history.log', [])) then
        frm_Main.fmtHistorico.LoadFromFile(StringReplace(ParamStr(0), '.exe', '.history.log', []), sfJSON);

      TLog.MyLog('Histórico carregado com sucesso.', nil, 0, False, TCriticalLog.tlINFO);
    except
      on E: Exception do
        TLog.MyLog('Erro ao carregar histórico.' + E.Message, nil, 0, False, TCriticalLog.tlERROR);
    end;
  finally

  end;
end;

function SalvarHistorico: Boolean;
begin
  try
    try
      frm_Main.fmtHistorico.SaveToFile(StringReplace(ParamStr(0), '.exe', '.history.log', []), sfJSON);

      TLog.MyLog('Histórico salvo com sucesso.', nil, 0, False, TCriticalLog.tlINFO);
    except
      on E: Exception do
        TLog.MyLog('Erro ao salvar histórico.' + E.Message, nil, 0, False, TCriticalLog.tlERROR);
    end;
  finally

  end;
end;

function SalvarHistorico(ID: Integer; Header, Response: string; StatusCode: Integer): Boolean;
begin
  try
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

      TLog.MyLog('Histórico salvo com sucesso.', nil, 0, False, TCriticalLog.tlINFO);
    except
      on E: Exception do
        TLog.MyLog('Erro ao salvar histórico.' + E.Message, nil, 0, False, TCriticalLog.tlERROR);
    end;
  finally

  end;
end;

end.
