unit untLog;

interface
uses
  System.SyncObjs, System.Math, SysUtils,

  {$IFDEF FIREMONKEY}Fmx.Controls, FMX.Types, FMX.Forms, FMX.Dialogs,
  {$ELSE}Vcl.Controls, VCL.Forms, Vcl.Dialogs, {$ENDIF}
  Classes;

type
  TCriticalLog = (
    tlASSERT,//	Priority constant for the println method.
    tlDEBUG,//	Priority constant for the println method; use Log.d.
    tlERROR,//	Priority constant for the println method; use Log.e.
    tlINFO,//	Priority constant for the println method; use Log.i.
    tlVERBOSE,//	Priority constant for the println method; use Log.v.
    tlWARN,//	Priority constant for the println method; use Log.w.
    tlFATALERROR
    );

    /// <summary>
    ///   Utilizado para retorna informações do módulo atual
	///  Exemplo: Para SICS PA grava no log o ID da PA.
    /// </summary>
  TFuncGetDescModulo = function (): String of object;
    /// <summary>
    ///   Utilizado para retorna informações do controle
    /// </summary>
  TFuncGetDescControl = function (const aCOntrol: TObject): String of object;


  TLog = class
  private
    class function GetDescModulo(const aControler: TObject): String;
    class function FileSize(const FileName: String): LongInt;
    class procedure VerificaQuantidadeDiasNoLog(const AFileName: String; const ALimiteDias: Integer);
  public
    class var OnGetDescModulo: TFuncGetDescModulo;
    class var OnGetDescControl: TFuncGetDescControl;
    class var FUltimaMessagem: String;
    class var FTimeUltimaMensagem: TDateTime;
    class constructor Create;
    /// <summary>
    ///   Retorna a mensagem da última exceção.
    /// </summary>
    class function GetMessageException: String;
    class procedure TreatException(aControler: Tobject); Overload;
    class procedure TreatException(const psMessage: string; aControler: Tobject; E: Exception); Overload;
    class procedure TreatException(const psMessage: string; aControler: Tobject; const ACapturaExceptionMessage: Boolean = True); Overload;

    /// <summary>
    ///   Está executando o abort
    /// </summary>
    class function Aborting: Boolean;
    /// <summary>
    ///   Cria log no arquivo text com a mensagem, horário, exceção e controles ativo.
    /// </summary>
    class procedure MyLog(const psMessage: string; aControler: Tobject;
      const aIDErro: Integer;
     const pbShowError: Boolean = False; const ACriticalLog: TCriticalLog = tlERROR; const psName: String = 'log'); Overload;

    /// <summary>
    ///   Procedure temporária enquanto estamos movendo todos os logs para o Kibana.
    /// </summary>
    class procedure MyLogTemp(const psMessage: string; aControler: Tobject;
      const aIDErro: Integer;
     const pbShowError: Boolean = False; const ACriticalLog: TCriticalLog = tlERROR; const psName: String = 'log'); Overload;

    class function getFileLogName(pDateTime: TDateTime): String;
    class procedure MyLog(const psMessage: string; aControler: Tobject); Overload;
    class procedure MyException(Sender: TObject; E: Exception);
    class function GetDescCriticalLog(const ACriticalLog: TCriticalLog): String;
  end;

const
  ID_ERRO_VAZIO = 0;
  ID_ERRO = ID_ERRO_VAZIO + 1;
  ID_ERRO_Sender = ID_ERRO + 1;

implementation

var
  LCriticalSection: TCriticalSection;

class function TLog.Aborting: Boolean;
begin
  Result := (ExceptObject <> nil) and (ExceptObject is EAbort);
end;

class constructor TLog.Create;
begin
  OnGetDescModulo := nil;
  OnGetDescControl := nil;
  FUltimaMessagem := '';
  FTimeUltimaMensagem := 0;
end;

class function TLog.FileSize(const FileName: String): LongInt;
var SearchRec : TSearchRec;
begin
  if FindFirst(FileName,faAnyFile,SearchRec) = 0 then
    Result := SearchRec.Size
  else
    Result := 0;
  FindClose(SearchRec);
end;

class function TLog.GetDescCriticalLog(
  const ACriticalLog: TCriticalLog): String;
begin
  case ACriticalLog of
    tlASSERT: Result := 'Assert';//	Priority constant for the println method.
    tlDEBUG: Result := 'Debug';//	Priority constant for the println method; use Log.d.
    tlERROR: Result := 'Error';//	Priority constant for the println method; use Log.e.
    tlINFO: Result := 'Info';//	Priority constant for the println method; use Log.i.
    tlVERBOSE: Result := 'Verbose';//	Priority constant for the println method; use Log.v.
    tlWARN: Result := 'Warning';//
  end;
end;

class function TLog.GetMessageException: String;
begin
  Result := '';
  if (ExceptObject <> nil) and (ExceptObject is Exception) then
    Result := Exception(ExceptObject).Message;
end;

class procedure TLog.TreatException(aControler: Tobject);
begin
  TreatException(GetMessageException, aControler);
end;

class procedure TLog.TreatException(const psMessage: string; aControler: Tobject; const ACapturaExceptionMessage: Boolean);
var
  LException: Exception;
begin
  LException := nil;
  if (ExceptObject <> nil) and (ExceptObject is Exception) then
    LException := Exception(ExceptObject);

  TLog.TreatException(psMessage, aControler, LException);
end;

class procedure TLog.MyException(Sender: TObject; E: Exception);
begin
  TLog.MyLog('Erro na aplicação', nil, 0, false);
end;

class procedure TLog.MyLog(const psMessage: string; aControler: Tobject);
begin
  TLog.MyLog(psMessage, aControler, ID_ERRO_VAZIO);
end;

class function TLog.GetDescModulo(const aControler: TObject): String;
type
  {$IFDEF FIREMONKEY}
  TTypeParent = TFmxObject;
  {$ELSE}
  TTypeParent = TControl;
  {$ENDIF FIREMONKEY}

  function GetUniqueControlName(const aControl: TObject): String;
  begin
    result := '';
    if Assigned(aControl) then
    begin
      if (aControl is TTypeParent) and Assigned(TTypeParent(aControl).Parent) then
        Result := GetUniqueCOntrolName(TTypeParent(aControl).Parent)
      else
      if (aControl is TComponent) then
        Result := GetUniqueCOntrolName(TComponent(aControl).Owner);

      if (aControl is TControl) then
      begin
        if Result <> '' then
          Result := Result + '.';
        Result := Result + TControl(aControl).Name;
      end;
    end;
  end;

var
  {$IFDEF FIREMONKEY}
  vForm   : FMX.Forms.TForm;
  {$ELSE}
  vForm   : VCl.Forms.TForm;
  {$ENDIF FIREMONKEY}
  vControl: TControl;
begin
  if Assigned(OnGetDescModulo) then
    Result := OnGetDescModulo
  else
    Result := '';
  if Assigned(aControler) then
  begin
    if Assigned(OnGetDescControl) then
    begin
      if Result <> '' then
        Result := Result + ' - ';
      Result := Result + OnGetDescControl(aControler);
    end;

    Result := Result + ' Objeto info: ' + aControler.ClassName;
    Result := Result + ' Name: ' + GetUniqueCOntrolName(aControler);
  end;
  {$IFDEF FIREMONKEY}
  //vForm    := ActiveForm;
  //vControl := ActiveControl;
  {$ELSE}
  vForm    := nil;
  vControl := nil;
  {$ENDIF FIREMONKEY}
  if Assigned(vForm) then
    Result := Result + ' Form: ' + vForm.Name;

  if Assigned(vControl) then
    Result := Result + ' Controle: ' + vControl.Name;

  Result := Trim(Result);
end;

class procedure TLog.MyLogTemp(const psMessage: string; aControler: Tobject; const aIDErro: Integer;
  const pbShowError: Boolean; const ACriticalLog: TCriticalLog; const psName: String);
begin
  TLog.MyLog(psMessage, aControler, aIDErro, pbShowError, ACriticalLog, psName);
end;

class function TLog.getFileLogName(pDateTime: TDateTime): String;
begin
  result := StringReplace(Application.ExeName, '.exe', '',[rfReplaceAll])+ FormatDateTime('_DDMMYYYY', pDateTime) + '.log';
end;

class procedure TLog.MyLog(const psMessage: string; aControler: Tobject; const aIDErro: Integer;
  const pbShowError: Boolean; const ACriticalLog: TCriticalLog; const psName: String);
var
  vArq: TextFile;
  sDescModulo, sMessage, sFileName, sException: string;
begin
  try
//    {$IFNDEF SuportaDLL}
    ////// sFileName := GetDiretorioAsp + ApplicationName(False) + psName + FormatDateTime('_DDMMYYYY', Now) + '.log';

    sFileName := TLog.getFileLogName(now);

//    {$ELSE}
//    sFileName := ChangeFileExt(GetAppIniFileName, psName + FormatDateTime('_DDMMYYYY', Now) + '.log');
//    {$ENDIF SuportaDLL}

    { RAP Removido a pedido do LBC - Será gerado um arquivo por dia
    if TLog.FileSize(sFileName) >= 5000000 then
    begin
      sLogFileCopia := TPath.GetFileNameWithoutExtension(sFileName) + '_'+ FormatDateTime('ddmmyyyyhhmmss',Now)+'.txt';
      RenameFile(sFileName,sLogFileCopia);
    end;
    }

    sMessage := psMessage;
    sException := TLog.GetMessageException;
    if (sException <> '') then
    begin
      if sMessage <> '' then
        sMessage := sMessage + ' // ';

      sMessage := sMessage + 'Erro: ' + sException;
      if (ExceptObject <> nil) and (ExceptObject is Exception) then
        sMessage := sMessage + ' // ' + 'Classe Exceção: ' + Exception(ExceptObject).ClassName;
    end;

    if sMessage <> '' then
      sMessage := sMessage + ' // ';
    sMessage := sMessage + 'Tipo: ' + GetDescCriticalLog(ACriticalLog);

    if aControler<>nil then
      sDescModulo := GetDescModulo(aControler);

    if (sDescModulo <> '') then
      sMessage := sMessage + ' // ' + sDescModulo;

    if (aIDErro <> 0) then
      sMessage := sMessage + ' // ID Erro: ' + IntToStr(aIDErro);

    if ((FUltimaMessagem = sMessage) and (FTimeUltimaMensagem > 0) and
      (FTimeUltimaMensagem <= Now + EncodeTime(0, 0, 10, 0))) then
      Exit;

    sMessage := StringReplace(sMessage, #10, ''    , [rfReplaceAll]);
    sMessage := StringReplace(sMessage, #13, ' // ', [rfReplaceAll]);

    LCriticalSection.Acquire;
    try
      AssignFile(vArq, sFileName, TEncoding.Default.CodePage);
      try
        if FileExists(sFileName) then
           begin
           Append(vArq);
           end
        else
           begin
           ReWrite(vArq);
           WriteLn(vArq, 'Log aplicação');
           end;

        WriteLn (vArq, FormatDateTime('dd/mm/yyyy hh:mm:ss', now) + ' - ' + sMessage);
      finally
        CloseFile(vArq);
      end;

      VerificaQuantidadeDiasNoLog(sFileName, 30);
    finally
      LCriticalSection.Release;
    end;

    if pbShowError then
    begin
//      {$IFDEF Debug}
//      ErrorMessage(sMessage);
//      {$ELSE}
//      if (ACriticalLog <> TCriticalLog.tlDEBUG) then
//        ErrorMessage(sMessage);
//      {$ENDIF}
    end;

    {$IFDEF ANDROID} //***IOS
    case ACriticalLog of
      tlASSERT: LOGI(@sMessage);
      tlDEBUG: LOGI(@sMessage);
      tlERROR: LOGE(@sMessage);
      tlINFO: LOGI(@sMessage);
      tlVERBOSE: LOGI(@sMessage);
      tlWARN: LOGW(@sMessage);
      tlFATALERROR: LOGF(@sMessage);
    end
    {$ENDIF}
  except
    Exit;
  end;
end;

class procedure TLog.VerificaQuantidadeDiasNoLog(const AFileName: String; const ALimiteDias: Integer);
var
  I, iLinhaExcluir: Integer;
  DataHoje: TDateTime;
  F, vArq2 : textfile;
  sAux: string;
  vStringList : TStringList;
  aFileName2 : String;

  function VerDataPassouLimite: Boolean;
  var
    DataAux: TDate;
  begin
    ReadLn(F, sAux);
    try
      DataAux := EncodeDate(StrToIntDef(Copy(sAux, 7, 4), 0), StrToIntDef(Copy(sAux, 4, 2), 0), StrToIntDef(Copy(sAux, 1, 2), 0));
      Result :=  Trunc(DataHoje - DataAux) > ALimiteDias;
    except
      Result := True;
    end;
  end;
begin
    AssignFile(F, AFileName, TEncoding.Default.CodePage);
  try
    if FileExists(AFileName) then
      Reset(F)
    else
      Rewrite(F);
  except
    CloseFile(F);
    raise;
  end;

  iLinhaExcluir := 0;
  if ((FileExists(AFileName)) and (ALimiteDias > 0)) then
  try
    Reset(F);
    DataHoje := Date;

    while not Eof(F) do
    begin
      if VerDataPassouLimite then
        Inc(iLinhaExcluir)
      else
        break;
    end;
  finally
    CloseFile(f);
  end;

  if iLinhaExcluir > 0 then
  begin
    aFileName2 := AFileName+'.tmp';
    AssignFile(vArq2, aFileName2, TEncoding.Default.CodePage);
    Rewrite(vArq2);

    vStringList := TStringList.Create;

    try
      vStringList.LoadFromFile(aFileName, TEncoding.Default);

      For I := iLinhaExcluir To vStringList.Count - 1 Do
      Begin
        WriteLn (vArq2, vStringList[i]);
      End;
    finally
      CloseFile(vArq2);
      FreeAndNil(vStringList);
    end;

    DeleteFile(aFileName);
    RenameFile(aFileName2, aFileName);
  end;
end;

class procedure TLog.TreatException(const psMessage: string; aControler: Tobject; E: Exception);
begin
  MyLog(psMessage, aControler);
end;

function WriteFile(const psFilePath: string;
  var poText: TStringList; const pbClearFile: Boolean): Boolean;
var
  vArq: TextFile;
  vIndex: Integer;
  sDirectory: string;
begin
  try
    Result := true;   
    sDirectory := ExtractFilePath(psFilePath);
    if (not DirectoryExists(sDirectory)) then
      ForceDirectories(sDirectory);

    try
    AssignFile(vArq, psFilePath, TEncoding.Default.CodePage);
    if FileExists(psFilePath) and (not pbClearFile) then
        Append(vArq)
      else
        ReWrite(vArq);

      for vIndex := 0 to poText.Count - 1 do
      begin
        WriteLn(vArq, poText[vIndex]);
      end;
    except
      Result := False;
      Exit;
    end;
  finally
    CloseFile(vArq);
  end;
end;

initialization

  LCriticalSection := TCriticalSection.Create;
  TLog.FUltimaMessagem := '';
  TLog.FTimeUltimaMensagem := 0;
  TLog.OnGetDescModulo := nil;
  TLog.OnGetDescControl := nil;
//Rodrigo   TAspException.FLogExcecao := TLog.MyLog;

finalization

  LCriticalSection.Free;

end.
