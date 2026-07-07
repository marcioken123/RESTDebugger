unit ufrmListaAPIs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, Data.DB, Datasnap.DBClient, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, FMX.Objects;

type
  TfrmListaAPIs = class(TForm)
    Grid1: TGrid;
    cdsRequestAPI: TClientDataSet;
    cdsRequestAPIID: TIntegerField;
    cdsRequestAPIMETODO: TStringField;
    cdsRequestAPIURL: TStringField;
    cdsRequestAPIBODY_REQUEST: TMemoField;
    cdsRequestAPICONTENT_TYPE: TStringField;
    dtsRequestAPI: TDataSource;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    Rectangle1: TRectangle;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListaAPIs: TfrmListaAPIs;

implementation

uses
  provider.Types, uMain_frm, REST.Types;

{$R *.fmx}

procedure TfrmListaAPIs.FormCreate(Sender: TObject);
var
  LItem: TRESTRequestParams;
begin
  cdsRequestAPI.CreateDataSet;

  for LItem IN frm_main.FMRUList.Items do
  begin
    cdsRequestAPI.Append;
    cdsRequestAPIID.AsInteger := LItem.ID;
    cdsRequestAPIMETODO.AsString := RESTRequestMethodToString(LItem.Method);
    cdsRequestAPIURL.AsString := LItem.URL;
    cdsRequestAPIBODY_REQUEST.LoadFromStream(LItem.CustomBody);
    cdsRequestAPICONTENT_TYPE.AsString := LItem.ContentType;
    cdsRequestAPI.Post;
  end;

  cdsRequestAPI.First;
end;

end.
