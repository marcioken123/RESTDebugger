{*******************************************************}
{                                                       }
{             Delphi REST Client Framework              }
{                                                       }
{ Copyright(c) 2013-2020 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}
program RESTDebugger;

uses
  FMX.Forms,
  uMain_frm in 'uMain_frm.pas' {frm_Main},
  ufrmCustomHeaderDlg in 'src\ufrmCustomHeaderDlg.pas' {frm_CustomHeaderDlg},
  provider.Types in 'src\providers\provider.Types.pas',
  provider.MRUList in 'src\providers\provider.MRUList.pas',
  ufrmWait in 'src\ufrmWait.pas' {frmWait},
  ufrmoauth2 in 'src\ufrmoauth2.pas' {frm_OAuth2},
  provider.osutils in 'src\providers\provider.osutils.pas',
  ufrmoauth1 in 'src\ufrmoauth1.pas' {frm_OAuth1},
  uComponentToClipboard in 'src\providers\uComponentToClipboard.pas',
  provider.SettingsList in 'src\providers\provider.SettingsList.pas',
  provider.Consts in 'src\providers\provider.Consts.pas',
  untLog in 'src\providers\untLog.pas',
  AspJson in 'src\providers\AspJson.pas',
  ufrmListaAPIs in 'src\ufrmListaAPIs.pas' {frmListaAPIs},
  controller.MainForm in 'src\controllers\controller.MainForm.pas',
  controller.UI in 'src\controllers\controller.UI.pas',
  controller.Settings in 'src\controllers\controller.Settings.pas',
  controller.RESTRequest in 'src\controllers\controller.RESTRequest.pas',
  udmRESTDebugger in 'src\dao\udmRESTDebugger.pas' {dmRestDebugger: TDataModule};

{$R *.res}

begin
  TLog.MyLogTemp('', nil, 0, False, TCriticalLog.tlINFO);
  TLog.MyLogTemp('***********************************************', nil, 0, False, TCriticalLog.tlINFO);
  TLog.MyLogTemp('Inicialização do REST Debugger', nil, 0, False, TCriticalLog.tlINFO);

  Application.Initialize;

  Application.OnException := tLog.MyException;
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.CreateForm(TdmRestDebugger, dmRestDebugger);
  Application.Run;
end.
