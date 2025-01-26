unit controller.Settings;

interface

procedure DoLoadRequestSettings;
procedure DoSaveRequestSettings;
procedure LoadProxySettings(const AFilename: string);
procedure SaveProxySettings(const AFilename: string);

implementation

uses
  uMain_frm,
  untLog,
  System.IniFiles,
  provider.Types,
  provider.Consts,
  System.SysUtils,
  System.IOUtils,
  provider.MRUList,
  provider.SettingsList,
  Winapi.Windows;

procedure DoLoadRequestSettings;
begin
  try
    if frm_Main.dlg_LoadRequestSettings.Execute then
    begin
      frm_Main.FRESTParams.LoadFromFile(frm_Main.dlg_LoadRequestSettings.FileName);
      frm_Main.DoPushRequestParamsToControls;
    end;

    TLog.MyLog('Lista de URLs carregada com sucesso ' + frm_Main.dlg_LoadRequestSettings.FileName, nil, 0, false);
  finally
    frm_Main.dlg_LoadRequestSettings.InitialDir := '';
    frm_Main.dlg_SaveRequestSettings.InitialDir := '';
  end;
end;

procedure DoSaveRequestSettings;
begin
  try
    frm_Main.DoFetchRequestParamsFromControls;
    if frm_Main.dlg_SaveRequestSettings.Execute then
    begin
      frm_Main.FRESTParams.SaveToFile(frm_Main.dlg_SaveRequestSettings.FileName);
      TLog.MyLog('Lista de URLs salva com sucesso ' + frm_Main.dlg_SaveRequestSettings.FileName, nil, 0, false);
    end;
  finally
    frm_Main.dlg_LoadRequestSettings.InitialDir := '';
    frm_Main.dlg_SaveRequestSettings.InitialDir := '';
  end;
end;

procedure LoadProxySettings(const AFilename: string);
var
  LINI: TMemIniFile;
begin
  LINI := TMemIniFile.Create(AFilename);
  try
    frm_Main.cbProxy.IsChecked    := LINI.ReadBool    ('proxy'           , 'enabled', false);
    frm_Main.edt_ProxyServer.Text := LINI.ReadString  ('proxy'           , 'server'     , '');
    frm_Main.edt_ProxyPort.Value  := LINI.ReadInteger ('proxy'           , 'port'       , 0);
    frm_Main.edt_ProxyUser.Text   := SimpleDecryptStr(LINI.ReadString('proxy', 'username', SimpleEncryptStr('', AUTH_CRYPTO_VALUE)), AUTH_CRYPTO_VALUE);
    frm_Main.edt_ProxyPass.Text   := SimpleDecryptStr(LINI.ReadString('proxy', 'password', SimpleEncryptStr('', AUTH_CRYPTO_VALUE)), AUTH_CRYPTO_VALUE);

    DefaultStorageFolder := LINI.ReadString  ('FileInformation' , 'DefaultStorageFolder', IncludeTrailingPathDelimiter(System.IOUtils.TPath.GetDocumentsPath) + 'RESTDebugger' + PathDelim);

    //DefaultStorageFolder := IncludeTrailingPathDelimiter(System.IOUtils.TPath.GetDocumentsPath) + 'RESTDebugger' + PathDelim;

    if NOT TDirectory.Exists(DefaultStorageFolder) then
      TDirectory.CreateDirectory(DefaultStorageFolder);

    MRUDBFILE            := LINI.ReadString  ('FileInformation' , 'MruDbFile'           , MRUDBFILE);
    SETTINGSDBFILE       := LINI.ReadString  ('FileInformation' , 'SettingsDbFile'      , SETTINGSDBFILE);
    PROXYDBFILE          := LINI.ReadString  ('FileInformation' , 'ProxyDbFile'         , PROXYDBFILE);

    frm_Main.cbTimeout.IsChecked  := LINI.ReadBool    ('timeout', 'enabled', True);
    frm_Main.edt_Timeout.Value    := LINI.ReadInteger ('timeout', 'value', 30000);
  finally
    FreeAndNil(LINI);
  end;

  frm_Main.cbProxyChange(nil);
  frm_Main.cbTimeoutChange(nil);
end;

procedure SaveProxySettings(const AFilename: string);
var
  LINI: TMemIniFile;
begin
  TLog.MyLogTemp('Carregando arquivo de configuração: ' + AFilename, nil, 0, False, TCriticalLog.tlINFO);

  LINI := TMemIniFile.Create(AFilename);
  try
    LINI.WriteBool    ('proxy'           , 'enabled'             , frm_Main.cbProxy.IsChecked);
    LINI.WriteString  ('proxy'           , 'server'              , frm_Main.edt_ProxyServer.Text);
    LINI.WriteInteger ('proxy'           , 'port'                , Trunc(frm_Main.edt_ProxyPort.Value));
    LINI.WriteString  ('proxy'           , 'username'            , SimpleEncryptStr(frm_Main.edt_ProxyUser.Text, AUTH_CRYPTO_VALUE));
    LINI.WriteString  ('proxy'           , 'password'            , SimpleEncryptStr(frm_Main.edt_ProxyPass.Text, AUTH_CRYPTO_VALUE));

    LINI.WriteBool    ('timeout'         , 'enabled'             , frm_Main.cbTimeout.IsChecked);
    LINI.WriteInteger ('timeout'         , 'value'               , Trunc(frm_Main.edt_Timeout.Value));

    LINI.WriteString  ('FileInformation' , 'DefaultStorageFolder', DefaultStorageFolder);
    LINI.WriteString  ('FileInformation' , 'MruDbFile'           , MRUDBFILE);
    LINI.WriteString  ('FileInformation' , 'SettingsDbFile'      , SETTINGSDBFILE);
    LINI.WriteString  ('FileInformation' , 'ProxyDbFile'         , PROXYDBFILE);

    LINI.UpdateFile;

    CopyFile(pchar(AFilename), PChar(StringReplace(ParamStr(0), '.exe', '.ini', [])), False);
  finally
    FreeAndNil(LINI);
  end;
end;

end.
