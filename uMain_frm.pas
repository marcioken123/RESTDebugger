{*******************************************************}
{                                                       }
{             Delphi REST Client Framework              }
{                                                       }
{ Copyright(c) 2013-2020 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}
unit uMain_frm;

                                                                               
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, System.IniFiles, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.ComboEdit, FMX.NumberBox,
  FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.ListBox, FMX.Layouts, FMX.Memo,
  FMX.TabControl, FMX.Grid, FMX.Bind.DBEngExt, FMX.Bind.Grid,
  provider.Types, provider.MRUList, provider.SettingsList,
  REST.Authenticator.OAuth,
  REST.Authenticator.Basic,
  REST.Authenticator.Simple,
  REST.Response.Adapter,
  REST.Client,
  REST.Consts,

  REST.Types,

  Data.DB, //Data.DBJson,
  Data.Bind.EngExt,
  System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, System.Generics.Collections, ufrmWait,
  Data.Bind.ObjectScope,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  //FireDAC.Phys.Intf, FireDAC.DApt.Intftype,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.EditBox,
  FMX.Controls.Presentation, System.Net.URLClient, FMX.ScrollBox, FMX.Grid.Style,
  FMX.Memo.Types, Winapi.Messages, Winapi.ShellAPI, FMX.Platform, WinApi.Windows,
  FMX.Platform.Win, FMX.Menus, FireDAC.Phys.Intf, FireDAC.DApt.Intf;

type
  Tfrm_Main = class(TForm)
    pnl_Header: TLayout;
    lbl_MainTitle: TLabel;
    img_Logo: TImage;
    gb_Request: TGroupBox;
    gb_Response: TGroupBox;
    Splitter1: TSplitter;
    tc_Response: TTabControl;
    ti_Response_Headers: TTabItem;
    ti_Response_Body: TTabItem;
    rect_header: TRectangle;
    memo_ResponseHeader: TMemo;
    memo_ResponseBody: TMemo;
    lbl_LastRequestStats: TLabel;
    dlg_LoadRequestSettings: TOpenDialog;
    dlg_SaveRequestSettings: TSaveDialog;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    RESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
    SimpleAuthenticator: TSimpleAuthenticator;
    HTTPBasicAuthenticator: THTTPBasicAuthenticator;
    OAuth1Authenticator: TOAuth1Authenticator;
    OAuth2Authenticator: TOAuth2Authenticator;
    ti_Response_TableView: TTabItem;
    StringGrid1: TGrid;
    BindSourceRESTResponse: TBindSourceDB;
    BindingsList1: TBindingsList;
    StatusBar: TStatusBar;
    lbl_ProxyState: TLabel;
    BindSourceDB1: TBindSourceDB;
    layout_Request: TLayout;
    lbl_LastRequestURL: TLabel;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    ToolBar1: TToolBar;
    LabelJson: TLabel;
    LabelRootElement: TLabel;
    ButtonRootElement: TButton;
    EditRootElement: TClearingEdit;
    Label15: TLabel;
    tc_Request: TTabControl;
    ti_Request_Basic: TTabItem;
    cmb_RequestMethod: TComboBox;
    lbl_RequestMethodCaption: TLabel;
    memo_RequestBody: TMemo;
    cmb_RequestURL: TComboEdit;
    lbl_RequestBodyCaption: TLabel;
    lbl_BaseURLCaption: TLabel;
    btn_ClearMRUList: TButton;
    edt_ContentType: TComboEdit;
    Label16: TLabel;
    ti_Request_Advanced: TTabItem;
    lb_CustomParameters: TListBox;
    btn_AddCustomParameter: TButton;
    btn_EditCustomParameter: TButton;
    btn_DeleteCustomParameter: TButton;
    edt_Resource: TEdit;
    Label10: TLabel;
    lbl_CustomHeadersCaption: TLabel;
    ti_Request_Auth: TTabItem;
    cmb_AuthMethod: TComboBox;
    Label5: TLabel;
    edt_AuthPassword: TEdit;
    Label4: TLabel;
    edt_AuthUsername: TEdit;
    Label1: TLabel;
    edt_AuthClientID: TEdit;
    Label2: TLabel;
    edt_AuthAccessToken: TEdit;
    Label3: TLabel;
    edt_AuthRequestToken: TEdit;
    Label6: TLabel;
    edt_AuthClientSecret: TEdit;
    Label7: TLabel;
    edt_AuthPasswordKey: TEdit;
    Label8: TLabel;
    edt_AuthUsernameKey: TEdit;
    Label9: TLabel;
    Connection: TTabItem;
    edt_ProxyServer: TEdit;
    lbl_ProxyServer: TLabel;
    edt_ProxyUser: TEdit;
    Label11: TLabel;
    edt_ProxyPass: TEdit;
    Label12: TLabel;
    cbProxy: TCheckBox;
    edt_ProxyPort: TNumberBox;
    Label13: TLabel;
    btn_OAuthAssistant: TButton;
    fmtHistorico: TFDMemTable;
    ToolBar2: TToolBar;
    LabelJSONTab: TLabel;
    LabelRootElementTab: TLabel;
    ButtonRootElementTab: TButton;
    EditRootElementTab: TClearingEdit;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    cbTimeout: TCheckBox;
    edt_Timeout: TNumberBox;
    Label17: TLabel;
    cb_NestedFields: TCheckBox;
    Label14: TLabel;
    cb_ViewAs: TComboBox;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    btn_CopyToClipboard: TButton;
    btn_SaveRequest: TButton;
    btn_Newrequest: TButton;
    btn_LoadRequest: TButton;
    btn_ExecuteRequest: TButton;
    Rectangle2: TRectangle;
    edt_Tentativas: TNumberBox;
    edt_Intervalo: TNumberBox;
    Label18: TLabel;
    Label19: TLabel;
    StyleBook1: TStyleBook;
    MainMenu1: TMainMenu;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem6: TMenuItem;
    layout_historico: TLayout;
    fmtHistoricoID: TAutoIncField;
    fmtHistoricoDATAHORA: TDateTimeField;
    FDMemTable1: TFDMemTable;
    fmtHistoricoID_REQUEST: TIntegerField;
    Grid1: TGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btn_ExecuteRequestClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_LoadRequestClick(Sender: TObject);
    procedure btn_SaveRequestClick(Sender: TObject);
    procedure btn_EditCustomParameterClick(Sender: TObject);
    procedure lb_CustomParametersDblClick(Sender: TObject);
    procedure btn_AddCustomParameterClick(Sender: TObject);
    procedure btn_DeleteCustomParameterClick(Sender: TObject);
    procedure cmb_AuthMethodChange(Sender: TObject);
    procedure cmb_RequestMethodChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tc_RequestChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn_NewrequestClick(Sender: TObject);
    procedure btn_ClearMRUListClick(Sender: TObject);
    procedure ButtonRootElementClick(Sender: TObject);
    procedure cmb_RequestURLClosePopup(Sender: TObject);
    procedure edt_ResourceExit(Sender: TObject);
    procedure btn_OAuthAssistantClick(Sender: TObject);
    procedure lbl_BaseURLCaptionClick(Sender: TObject);
    procedure cmb_RequestURLChange(Sender: TObject);
    procedure EditRootElementChangeTracking(Sender: TObject);
    procedure EditRootElementTabChangeTracking(Sender: TObject);
    procedure EditRootElementTabKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditRootElementKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ti_Response_BodyClick(Sender: TObject);
    procedure ti_Response_TableViewClick(Sender: TObject);
    procedure StringGrid1HeaderClick(Column: TColumn);
    procedure btn_CopyToClipboardClick(Sender: TObject);
    procedure RESTResponseDataSetAdapterBeforeOpenDataSet(Sender: TObject);
    procedure RESTClientValidateCertificate(const Sender: TObject; const ARequest: TURLRequest; const Certificate: TCertificate;
      var Accepted: Boolean);
    procedure RESTClientNeedClientCertificate(const Sender: TObject; const ARequest: TURLRequest;
      const ACertificateList: TCertificateList; var AnIndex: Integer);
    procedure cmb_RequestURLKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure cbProxyChange(Sender: TObject);
    procedure cbTimeoutChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tc_ResponseChange(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  public
    { Private declarations }
    TrayWnd: HWND;
    TrayIconData: TNotifyIconData;
    TrayIconAdded: Boolean;

    FMRUList: TMRUList;
    FSettingsList: TSettingsList;
    FRESTParams: provider.Types.TRESTRequestParams;
    FProxyINI: string;
    FCurrentRootElement: string;

    FPopupClosed : boolean;

    procedure TrayWndProc(var Message: TMessage);

    { Public declarations }
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
  end;

var
  frm_Main: Tfrm_Main;

implementation

uses
  controller.MainForm,
{$IFDEF MSWINDOWS}
  System.Net.HttpClient.Win,
{$ENDIF}
  System.UIConsts,
  uComponentToClipboard,
  untLog,
  provider.Consts,
  controller.Settings,
  controller.RESTRequest,
  ufrmListaAPIs;

{$R *.fmx}

procedure Tfrm_Main.btn_AddCustomParameterClick(Sender: TObject);
begin
  DoAddCustomParameter;
end;

procedure Tfrm_Main.btn_ClearMRUListClick(Sender: TObject);
begin
  DoClearMRUList;
end;

procedure Tfrm_Main.btn_CopyToClipboardClick(Sender: TObject);
var
  LList: TList<TComponent>;
  LNames: string;
  LComponent: TComponent;
  LDataSetActive: Boolean;
begin
  RESTClient.ResetToDefaults;
  DoFetchRequestParamsFromControls;
  ConfigureHTTPConnection;

  LDataSetActive := False;
  LList := TList<TComponent>.Create;
  RESTClient.OnValidateCertificate := nil;
  RESTClient.OnNeedClientCertificate := nil;
  try
    LList.AddRange([RESTClient, RESTRequest, RESTResponse]);
    if Self.tc_Response.ActiveTab = ti_Response_TableView then
    begin
      LDataSetActive := RESTResponseDataSetAdapter.Active;
      SaveGridColumnWidths;
      RESTResponseDataSetAdapter.Active := False;
      FDMemTable1.StoreDefs := False; // don't copy field defs to clipboard
      LList.AddRange([RESTResponseDataSetAdapter, FDMemTable1]);
    end;

    RESTRequest.ResetToDefaults;
    RESTResponse.ResetToDefaults;
    UpdateComponentProperties(True);

    if RESTClient.Authenticator <> nil then
      LList.Add(RESTClient.Authenticator);
    StreamToClipboard(LList.ToArray);
    if LDataSetActive then
    begin
      RESTResponseDataSetAdapter.Active := True;
      RestoreGridColumnWidths;
    end;
    for LComponent in LList do
    begin
      if LNames <> EmptyStr then
        LNames := LNames + ', ';
      LNames := LNames + LComponent.ClassName;
    end;
    MessageDlg(Format(RSComponentsCopied, [LNames]), TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
  finally
    RESTClient.OnValidateCertificate := RESTClientValidateCertificate;
    RESTClient.OnNeedClientCertificate := RESTClientNeedClientCertificate;
    LList.Free;
  end;
end;

procedure Tfrm_Main.btn_DeleteCustomParameterClick(Sender: TObject);
begin
  DoDeleteCustomParameter;
end;

procedure Tfrm_Main.btn_EditCustomParameterClick(Sender: TObject);
begin
  DoEditCustomParameter;
end;

procedure Tfrm_Main.btn_ExecuteRequestClick(Sender: TObject);
begin
  //TWait.Start;
  try
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

    if Trim(frm_Main.RESTClient.BaseURL) = EmptyStr then
    begin
      TWait.Done;
      MessageDlg(sRESTErrorEmptyURL, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      exit;
    end;

    frm_Main.memo_ResponseHeader.Lines.Clear;
    frm_Main.memo_ResponseBody.Lines.Clear;

    DoExecuteRequest(frm_Main.RESTRequest);
  finally
    //TWait.Done;
  end;
end;

procedure Tfrm_Main.btn_LoadRequestClick(Sender: TObject);
begin
  DoLoadRequestSettings;
end;

procedure Tfrm_Main.btn_NewrequestClick(Sender: TObject);
begin
  DoClearRequest;
end;

procedure Tfrm_Main.btn_OAuthAssistantClick(Sender: TObject);
begin
  DoCallOAuthAssistant;
end;

procedure Tfrm_Main.btn_SaveRequestClick(Sender: TObject);
begin
  DoSaveRequestSettings;
end;

procedure Tfrm_Main.ButtonRootElementClick(Sender: TObject);
begin
  UpdateRootElement;
end;

procedure Tfrm_Main.cbProxyChange(Sender: TObject);
begin
  edt_ProxyServer.Enabled := cbProxy.IsChecked;
  edt_ProxyPort.Enabled := cbProxy.IsChecked;
  edt_ProxyUser.Enabled := cbProxy.IsChecked;
  edt_ProxyPass.Enabled := cbProxy.IsChecked;
end;

procedure Tfrm_Main.cbTimeoutChange(Sender: TObject);
begin
  edt_Timeout.Enabled := cbTimeout.IsChecked;
end;

procedure Tfrm_Main.cmb_AuthMethodChange(Sender: TObject);
begin
  DoUpdateAuthEditFields;
end;

procedure Tfrm_Main.cmb_RequestMethodChange(Sender: TObject);
var
  LMethod: TRESTRequestMethod;
begin
  if (cmb_RequestMethod.ItemIndex > -1) then
  begin
    LMethod := RESTRequestMethodFromString(cmb_RequestMethod.Items[cmb_RequestMethod.ItemIndex]);
    memo_RequestBody.Enabled := LMethod in [TRESTRequestMethod.rmPOST, TRESTRequestMethod.rmPUT];
  end
  else
    memo_RequestBody.Enabled := false;
end;

procedure Tfrm_Main.cmb_RequestURLChange(Sender: TObject);
var
  LItem: TRESTRequestParams;
begin
  if (FPopupClosed) then
  begin
    FPopupClosed:= FALSE;

    if (cmb_RequestURL.ItemIndex > -1) then
    begin
      LItem := (cmb_RequestURL.Items.Objects[cmb_RequestURL.ItemIndex] AS TRESTRequestParams);
      FRESTParams.Assign(LItem);

      DoPushRequestParamsToControls;
    end;
  end;
end;

procedure Tfrm_Main.cmb_RequestURLClosePopup(Sender: TObject);
begin
  FPopupClosed:= TRUE;

  /// this is not optimal, we have to invoke the onchange-event again
  cmb_RequestURLChange( Sender );
end;

procedure Tfrm_Main.cmb_RequestURLKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if TComboEdit(Sender).Items.Count > 0 then
    if Key = vkReturn then
      btn_ExecuteRequestClick(nil);
end;

procedure Tfrm_Main.EditRootElementChangeTracking(Sender: TObject);
begin
  EditRootElementTab.Text := EditRootElement.Text;
end;

procedure Tfrm_Main.EditRootElementKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (KeyChar = #0) and (Key = 13) and (Shift = []) then
    UpdateRootElement;
end;

procedure Tfrm_Main.EditRootElementTabChangeTracking(Sender: TObject);
begin
  EditRootElement.Text := EditRootElementTab.Text;
end;

procedure Tfrm_Main.TrayWndProc(var Message: TMessage);
var
  P: TPoint;
begin
  if Message.MSG=WM_ICONTRAY then
  begin
     case Message.LParam of
       WM_RBUTTONDOWN:
       begin
         GetCursorPos(P);
         PopupMenu1.Popup(P.X,P.Y);
       end;
       WM_LBUTTONDOWN:
       begin
         Self.Show;
       end;
     else
       Message.Result:=DefWindowProc(TrayWnd, Message.MSG, Message.WParam, Message.LParam);
     end;
  end
  else
    Message.Result:=DefWindowProc(TrayWnd, Message.MSG, Message.WParam, Message.LParam);
end;

procedure Tfrm_Main.EditRootElementTabKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (KeyChar = #0) and (Key = 13) and (Shift = []) then
    UpdateRootElement;
end;

procedure Tfrm_Main.edt_ResourceExit(Sender: TObject);
begin
  DoFetchRequestParamsFromControls;
  //FRESTParams.CustomParams.FromString(EmptyStr, edt_Resource.Text);
  FRESTParams.CustomParams.CreateURLSegmentsFromString(edt_Resource.Text);
  DoPushRequestParamsToControls;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Hide;
  Action := TCloseAction.caNone;
end;

procedure Tfrm_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  TrayWnd := AllocateHWnd(TrayWndProc);
  with TrayIconData do
  begin
    cbSize := SizeOf();
    Wnd:= TrayWnd; // was before Wnd:= FmxHandleToHWND(self.Handle);
    uID:= 0;
    uFlags:= NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage:= WM_ICONTRAY;
    hIcon:= GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
    szTip:= 'Hearthspinner';
  end;

  if not TrayIconAdded then
    TrayIconAdded := Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  /// init the form
  tc_Request.ActiveTab := ti_Request_Basic;
  tc_Response.ActiveTab := ti_Response_Headers;

  InitRequestMethodCombo;
  InitAuthMethodCombo;
  DoResetControls;

  FPopupClosed:= False;

  DefaultStorageFolder := ExtractFilePath(ParamStr(0));

  dlg_LoadRequestSettings.InitialDir := DefaultStorageFolder;
  dlg_SaveRequestSettings.InitialDir := DefaultStorageFolder;

//  TWait.Start;

//  TThread.CreateAnonymousThread(
//  procedure
//  begin
    try
      FRESTParams := TRESTRequestParams.Create;
      FMRUList := TMRUList.Create(DefaultStorageFolder + MRUDBFILE);
      FSettingsList := TSettingsList.Create(DefaultStorageFolder + SETTINGSDBFILE);
      FSettingsList.LoadFromFile;

      FProxyINI := DefaultStorageFolder + PROXYDBFILE;
      LoadProxySettings(FProxyINI);
    finally
//      TThread.Synchronize(nil,
//      procedure
//      begin
        DoUpdateMRUList;
        DoPushRequestParamsToControls;
//        TWait.Done;
//      end);
    end;
//  end).Start;
  fmtHistorico.CreateDataSet;

  if FileExists(StringReplace(ParamStr(0), '.exe', '.history.log', [])) then
    fmtHistorico.LoadFromFile(StringReplace(ParamStr(0), '.exe', '.history.log', []), sfJSON);
end;

procedure Tfrm_Main.FormDestroy(Sender: TObject);
begin
  if TrayIconAdded then
    Shell_NotifyIcon(NIM_DELETE, @TrayIconData);

  DeallocateHWnd(TrayWnd);

  SaveProxySettings(FProxyINI);
  FSettingsList.SaveToFile;

  FreeAndNil(FRESTParams);
  FreeAndNil(FMRUList);
  FreeAndNil(FSettingsList);
end;

procedure Tfrm_Main.FormHide(Sender: TObject);
var
  appHandle: HWND;
  pid, current_pid: DWORD;
  name: String;
begin
  name := ChangeFileExt(ExtractFileName(ParamStr(0)), EmptyStr);

  appHandle := 0;
  pid := 0;
  current_pid := GetCurrentProcessId();
  repeat
  begin
    //appHandle := FindWindowExA(0, appHandle, 'TFMAppClass', nil);
    appHandle := FindWindowExA(0, appHandle, 'TFMAppClass', PAnsiChar(AnsiString(name)));
    if (appHandle>0) then
    begin
      GetWindowThreadProcessId(appHandle, pid);
      if (current_pid = pid) then break;
    end;
  end
  until (appHandle>0);

  //SetParent(FmxHandleToHWND(Handle), nil);
  ShowWindow(appHandle, SW_HIDE);

  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
end;

procedure Tfrm_Main.FormShow(Sender: TObject);
var
  appHandle: HWND;
  pid, current_pid: DWORD;
  name: String;
begin
  //ShowWindow(FindWindowA('TFMAppClass', nil), SW_HIDE);

  name := ChangeFileExt(ExtractFileName(ParamStr(0)), EmptyStr);

  appHandle := 0;
  pid := 0;
  current_pid := GetCurrentProcessId();
  repeat
  begin
    //appHandle := FindWindowExA(0, appHandle, 'TFMAppClass', nil);
    appHandle := FindWindowExA(0, appHandle, 'TFMAppClass', PAnsiChar(AnsiString(name)));
    if (appHandle>0) then
    begin
      GetWindowThreadProcessId(appHandle, pid);
      if (current_pid = pid) then break;
    end;
  end
  until (appHandle>0);

  //SetParent(FmxHandleToHWND(Handle), nil);
  ShowWindow(appHandle, SW_SHOW);
end;

procedure Tfrm_Main.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkF9) then
  begin
    Key := 0;
    DoExecuteRequest(RESTRequest);
  end;

  inherited;
end;

procedure Tfrm_Main.lbl_BaseURLCaptionClick(Sender: TObject);
begin
  DoFetchRequestParamsFromControls;
  DoAddToMRUList(FRESTParams);
end;

procedure Tfrm_Main.lb_CustomParametersDblClick(Sender: TObject);
begin
  DoEditCustomParameter;
end;

procedure Tfrm_Main.MenuItem1Click(Sender: TObject);
begin
  self.show;
end;

procedure Tfrm_Main.MenuItem2Click(Sender: TObject);
begin
  application.Terminate;
end;

procedure Tfrm_Main.MenuItem4Click(Sender: TObject);
begin
  try
    Application.CreateForm(TfrmListaAPIs, frmListaAPIs);
    frmListaAPIs.ShowModal;
  finally
     frmListaAPIs.Free;
  end;
end;

procedure Tfrm_Main.MenuItem5Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tfrm_Main.RESTClientNeedClientCertificate(const Sender: TObject;
  const ARequest: TURLRequest; const ACertificateList: TCertificateList;
  var AnIndex: Integer);
{$IFDEF MSWINDOWS}
var
  LCert: TCertificate;
  I: Integer;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  if ShowSelectCertificateDialog(GetForegroundWindow(), Caption, RSSelectClientCertificate, LCert) then
    for I := 0 to ACertificateList.Count - 1 do
      if LCert.SerialNum = ACertificateList[I].SerialNum then
      begin
        AnIndex := I;
        Exit;
      end;
{$ENDIF}
end;

procedure Tfrm_Main.RESTClientValidateCertificate(const Sender: TObject;
  const ARequest: TURLRequest; const Certificate: TCertificate;
  var Accepted: Boolean);
begin
  if not Accepted then
    if MessageDlg(RSUnableToValidateCertifcate, TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
      Accepted := True;
end;

procedure Tfrm_Main.RESTResponseDataSetAdapterBeforeOpenDataSet(Sender: TObject);
begin
  FCurrentRootElement := RESTResponse.RootElement;
end;

procedure Tfrm_Main.StringGrid1HeaderClick(Column: TColumn);
var
  LPath: string;
begin
  if (Column <> nil) and (not Column.Header.StartsWith('TJSON')) then
  begin
    LPath := FCurrentRootElement;
    if RESTResponse.JSONValue is TJSONArray then
    begin
      if TJSONArray(RESTResponse.JSONValue).Count > 0 then
        LPath := LPath + '[0].' + Column.Header;
    end
    else
    begin
      if LPath <> EmptyStr then
        LPath := LPath + '.';
      LPath := LPath + Column.Header;
    end;
  end;
  if LPath <> EmptyStr then
    EditRootElementTab.Text := LPath;
end;

procedure Tfrm_Main.tc_RequestChange(Sender: TObject);
begin
  DoFetchRequestParamsFromControls;
end;

procedure Tfrm_Main.tc_ResponseChange(Sender: TObject);
begin
  TLog.MyLog('Mudando TAB' + tc_Response.ActiveTab.Name, nil, 0, false, TCriticalLog.tlINFO);
end;

procedure Tfrm_Main.ti_Response_BodyClick(Sender: TObject);
begin
  SynchEditCaret(EditRootElementTab, EditRootElement);
end;

procedure Tfrm_Main.ti_Response_TableViewClick(Sender: TObject);
begin
  SynchEditCaret(EditRootElement, EditRootElementTab);
end;

end.
