unit udmRESTDebugger;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.StorageJSON;

type
  TdmRestDebugger = class(TDataModule)
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmRestDebugger: TdmRestDebugger;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
