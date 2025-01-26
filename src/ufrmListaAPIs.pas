unit ufrmListaAPIs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, Data.DB, Datasnap.DBClient;

type
  TfrmListaAPIs = class(TForm)
    Grid1: TGrid;
    ClientDataSet1: TClientDataSet;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListaAPIs: TfrmListaAPIs;

implementation

{$R *.fmx}

end.
