unit AspJson;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.JSON,
  DBClient, DB {$IFDEF FIREMONKEY},MyAspFuncoesUteis{$ENDIF};
  // FMX.StdCtrls, AspPanel,  AspLabelFMX, AspGroupBox,  AspButton, FMX.Layouts, FMX.Memo,
  //FMX.ScrollBox, FMX.Controls.Presentation;

type
  /// <summary>
  ///   Classe que transforma DataSet (Todos registro ou atual) em texto Json.
  ///   Texto json em DataSet
  ///   Captura valor de json pelo alias "Exe: Pegar valor da propriedade nome"
  ///  Exemplo JSON
  ///    {"widget": {
  ///       "debug": "on",
  ///       "window": {
  ///          "title": "Sample Konfabulator Widget",
  ///          "name": "main_window",
  ///          "width": 500,
  ///          "height": 500
  ///        },
  ///        "image": {
  ///          "src": "Images/Sun.png",
  ///          "name": "sun1",
  ///          "hOffset": 250,
  ///          "vOffset": 250,
  ///          "alignment": "center"
  ///        }
  ///      }
  ///    }
  /// </summary>
  TAspJson = class
  public
    /// <summary>
    ///   Converte o todos os registro do dataset no json text
    /// </summary>
    class function DataSetToJsonTxt(pDataSet: TDataSet; const aOnlyCurrentRegistry: Boolean = False): string; Overload; Virtual;

    /// <summary>
    ///   Converte todos ou atual registro do dataset em json objeto
    /// </summary>
    class function DataSetToJsonTxt(ArrayJSon: TJSONArray; pDataSet: TDataSet; const aOnlyCurrentRegistry: Boolean = False): string; Overload; Virtual;

    /// <summary>
    ///   Converte o registro atual do dataset para o json objeto
    /// </summary>
    class procedure DataSetRegToJsonObj(ObjJSon: TJSONObject; pDataSet: TDataSet); Virtual;

    /// <summary>
    ///   Converte o json texto para o dataset
    /// </summary>
    class procedure JsonTxtToDataSet(const aJson: String; pDataSet: TClientDataSet); Overload;

    /// <summary>
    ///   Converte o json objeto para o dataset
    /// </summary>
    class procedure JsonTxtToDataSet(const paJsonValue: TJSONValue; pDataSet: TDataSet); Overload;

    /// <summary>
    ///   Captura o valor de uma propriedade no json objeto
    /// </summary>
    class function GetValueOfJson(const paJsonValue: TJSONValue; const pKeyName: String): Variant; Overload;
    class function GetValueOfJsonInt(const paJsonValue: TJSONValue; const pKeyName: String): Integer; Overload;

    /// <summary>
    ///   Captura o valor de uma propriedade no json string
    /// </summary>
    class function GetValueOfJson(const aJson: String; const pKeyName: String): Variant; Overload;

    /// <summary>
    ///   Localiza o objeto (Contém várias propriedades) json dentro do json value
    /// </summary>
    class function GetJsonObjectOfJson(const paJsonValue: TJSONValue): TJSONObject; Overload;

    class function IsJsonBoolean(const aJsonValue: TJSONValue): BOolean;
    /// <summary>
    ///   Retorna o tipo do json value (String, Integer...)
    /// </summary>
    class function GetDataTypeJson(const aJsonValue: TJSONValue): TFieldType;
  end;

implementation

{ TAspJson }

class procedure TAspJson.DataSetRegToJsonObj(ObjJSon: TJSONObject; pDataSet: TDataSet);
var
  strJSon  : TJSONString;
  intJSon  : TJSONNumber;
  TrueJSon : TJSONTrue;
  FalseJSon: TJSONFalse;
  pField   : TField;

  procedure SetValue(aFieldType: TFieldType);
  begin
    case aFieldType of
      ftString:
        begin
          if (pfield is TStringField) and TStringField(pfield).FixedChar then
          begin
            if (pField.AsString = 'T') then
            begin
              TrueJSon := TJSONTrue.Create;
              ObjJSon.AddPair(pField.FieldName, TrueJSon);
              Exit;
            end
            else
            if ((pField.AsString = 'F') or (Trim(pField.AsString) = '')) then
            begin
              FalseJSon := TJSONFalse.Create;
              ObjJSon.AddPair(pField.FieldName, FalseJSon);
              Exit;
            end;
          end;
          strJSon := TJSONString.Create(pField.AsString);
          ObjJSon.AddPair(pField.FieldName, strJSon);
        end;
      ftInteger:
        begin
          intJSon := TJSONNumber.Create(pField.AsInteger);
          ObjJSon.AddPair(pField.FieldName, intJSon);
        end;
      ftBoolean:
        case pField.AsBoolean of
          False:
            begin
              TrueJSon := TJSONTrue.Create;
              ObjJSon.AddPair(pField.FieldName, TrueJSon);
            end;
          True:
            begin
              FalseJSon := TJSONFalse.Create;
              ObjJSon.AddPair(pField.FieldName, FalseJSon);
            end;
        end;
    else // casos gerais são tratados como string
      begin
        strJSon := TJSONString.Create(pField.AsString);
        ObjJSon.AddPair(pField.FieldName, strJSon);
      end;
    end;
  end;
begin
  if not (Assigned(ObjJSon) and Assigned(pDataSet) and (not pDataSet.IsEmpty)) then
    Exit;
  for pField in pDataSet.Fields do
  begin

    SetValue(pField.DataType);
  end;
end;

class function TAspJson.DataSetToJsonTxt(ArrayJSon: TJSONArray; pDataSet: TDataSet; const aOnlyCurrentRegistry: Boolean): string;

  procedure ExportRegistry;
  var
    ObjJSon  : TJSONObject;
  begin
    ObjJSon := TJSONObject.Create;
    try
      DataSetRegToJsonObj(ObjJSon, pDataSet);
      ArrayJSon.AddElement(ObjJSon);
    except
      ObjJSon.Free;
      raise;
    end;
  end;
begin
  Result := '';
  if not (Assigned(pDataSet) and (not pDataSet.IsEmpty)) then
    Exit;

  if aOnlyCurrentRegistry then
    ExportRegistry
  else
  begin
    pDataSet.First;
    while not pDataSet.Eof do
    begin
      ExportRegistry;
      pDataSet.next;
    end;
  end;
  result := ArrayJSon.ToString;
end;


class function TAspJson.IsJsonBoolean(const aJsonValue: TJSONValue): BOolean;
begin
  Result := (aJsonValue is TJSONTrue) or (aJsonValue is TJSONFalse);
end;

class function TAspJson.DataSetToJsonTxt(pDataSet: TDataSet; const aOnlyCurrentRegistry: Boolean): string;
var
  ArrayJSon: TJSONArray;
begin
  Result := '';
  if not (Assigned(pDataSet) and (not pDataSet.IsEmpty)) then
    Exit;

  ArrayJSon := TJSONArray.Create;
  try
    Result := DataSetToJsonTxt(ArrayJSon, pDataSet, aOnlyCurrentRegistry);
  finally
    ArrayJSon.Free;
  end;
end;

class function TAspJson.GetDataTypeJson(const aJsonValue: TJSONValue): TFieldType;
var
  LValueInt: Integer;
begin
  Result := ftUnknown;
  if IsJsonBoolean(aJsonValue) then
    Result := ftBoolean
  else
  if (aJsonValue is TJSONNumber) then
  begin
    if TryStrToInt(aJsonValue.Value, LValueInt) then
      Result := ftInteger
    else
      Result := ftExtended;
  end
  else
  if (aJsonValue is TJSONNull) then
    Result := ftUnknown
  else
  if (aJsonValue is TJSONString) then
    Result := ftString
  else
  if (aJsonValue is TJSONObject) then
    Result := ftObject
  else
  if (aJsonValue is TJSONArray) then
    Result := ftArray;
end;

class function TAspJson.GetJsonObjectOfJson(const paJsonValue: TJSONValue): TJSONObject;
var
  ArrayJSon  : TJSONArray;
  ObjJSon    : TJSONObject;
  aJSONPair  : TJSONPair;
  i          : integer;
  aType: TFieldType;
  nCount: Integer;
  aJsonValue : TJSONValue;
begin
  Result := nil;
  ObjJSon := nil;
  ArrayJSon := nil;
  nCount := 0;
  if (paJsonValue is TJSONObject) then
  begin
    ObjJSon := TJSONObject(paJsonValue);
    nCount := ObjJSon.Count;
  end;

  if (paJsonValue is TJSONArray) then
  begin
    ArrayJSon := paJsonValue as TJSONArray;
    nCount := ArrayJSon.Count;
  end;

  for i := 0 to Pred(nCount) do
  begin
    aJsonValue  := nil;
    if Assigned(ObjJSon) then
    begin
      aJSONPair   := ObjJSon.Pairs[i];
//      aJsonString := aJSONPair.JsonString;
      aJsonValue := aJSONPair.JsonValue;
    end;
    if Assigned(ArrayJSon) then
    begin
      aJsonValue  := ArrayJSon.Items[i];
    end;
    aType := GetDataTypeJson(aJsonValue);

    case aType of
      ftObject:
      begin
        Result := TJSONObject(aJsonValue);
        Exit;
      end;

//      ftArray:
//      begin
//        Result := GetValueOfJson(aJsonValue, pKeyName);
//      end;
    end;
  end;
end;

class function TAspJson.GetValueOfJson(const paJsonValue: TJSONValue; const pKeyName: String): Variant;
var
  ArrayJSon  : TJSONArray;
  ObjJSon    : TJSONObject;
  aJSONPair  : TJSONPair;
  i          : integer;
  aJsonString: TJSONString;
  aType: TFieldType;
  nCount: Integer;
  aJsonValue : TJSONValue;
begin
  ObjJSon := nil;
  ArrayJSon := nil;
  nCount := 0;
  if (paJsonValue is TJSONObject) then
  begin
    ObjJSon := TJSONObject(paJsonValue);
    nCount := ObjJSon.Count;
  end;

  if (paJsonValue is TJSONArray) then
  begin
    ArrayJSon := paJsonValue as TJSONArray;
    nCount := ArrayJSon.Count;
  end;

  for i := 0 to Pred(nCount) do
  begin
    aJsonValue  := nil;
    if Assigned(ObjJSon) then
    begin
      aJSONPair   := ObjJSon.Pairs[i];
      aJsonString := aJSONPair.JsonString;
      aJsonValue := aJSONPair.JsonValue;
      if (UpperCase(Trim(aJsonString.Value)) <> UpperCase(Trim(pKeyName))) then
        Continue;
    end;
    if Assigned(ArrayJSon) then
    begin
      aJsonValue  := ArrayJSon.Items[i];
    end;
    aType := GetDataTypeJson(aJsonValue);

    case aType of
      ftBoolean:
      begin
        Result := (aJsonValue is TJSONTrue);
      end;

      ftInteger:
      begin
        Result := TJSONNumber(aJsonValue).AsInt;
      end;

      ftExtended:
      begin
        Result := TJSONNumber(aJsonValue).AsDouble;
      end;

      ftString:
      begin
        Result := aJsonValue.Value;
      end;

      ftObject:
      begin
        Result := GetValueOfJson(aJsonValue, pKeyName);
      end;

      ftArray:
      begin
        Result := GetValueOfJson(aJsonValue, pKeyName);
      end;
    else
      Result := Null;
    end;
  end;
end;

class function TAspJson.GetValueOfJson(const aJson: String; const pKeyName: String): Variant;
var
  ObjJson: TJsonValue;
begin
  ObjJson := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(aJson), 0);
  TRY
    Result := GetValueOfJson(ObjJson, pKeyName);
  finally
    ObjJson.Free;
  end;
end;

class function TAspJson.GetValueOfJsonInt(const paJsonValue: TJSONValue; const pKeyName: String): Integer;
var
  LResult: Variant;
begin
  Result := 0;
  LResult := GetValueOfJson(paJsonValue, pKeyName);
  if VarIsEmpty(LResult) or VarIsNull(LResult) then
    Exit;

  Result := LResult;
end;

class procedure TAspJson.JsonTxtToDataSet(const paJsonValue: TJSONValue; pDataSet: TDataSet);
var
  ArrayJSon  : TJSONArray;
  ObjJSon    : TJSONObject;
  aJSONPair  : TJSONPair;
  i          : integer;
  pField: TField;
  aJsonString: TJSONString;
  aType: TFieldType;
  nCount: Integer;
  aJsonValue : TJSONValue;
  LEstavaEmEdicao: Boolean;

  function EstaEmEdicao: Boolean;
  begin
    REsult := pDataSet.State in[dsInsert, dsEdit];
  end;

  procedure Cadastrar;
  begin
    if not EstaEmEdicao then
      pDataSet.Insert;
  end;
begin
  ObjJSon := nil;
  ArrayJSon := nil;
  nCount := 0;
  if (paJsonValue is TJSONObject) then
  begin
    ObjJSon := TJSONObject(paJsonValue);
    nCount := ObjJSon.Count;
  end;

  if (paJsonValue is TJSONArray) then
  begin
    ArrayJSon := paJsonValue as TJSONArray;
    nCount := ArrayJSon.Count;
  end;

  for i := 0 to Pred(nCount) do
  begin
    aJsonValue  := nil;
    pField   := nil;
    if Assigned(ObjJSon) then
    begin
      aJSONPair   := ObjJSon.Pairs[i];
      aJsonString := aJSONPair.JsonString;
      aJsonValue := aJSONPair.JsonValue;
      pField   := pDataSet.FieldByName(aJsonString.Value);
    end;
    if Assigned(ArrayJSon) then
    begin
      aJsonValue  := ArrayJSon.Items[i];
    end;
    aType := GetDataTypeJson(aJsonValue);

    case aType of
      ftBoolean:
      begin
        Cadastrar;
        pField.AsBoolean := (aJsonValue is TJSONTrue);
      end;

      ftInteger:
      begin
        Cadastrar;
        pField.AsInteger := TJSONNumber(aJsonValue).AsInt;
      end;

      ftExtended:
      begin
        Cadastrar;
        pField.AsExtended := TJSONNumber(aJsonValue).AsDouble;
      end;

      ftString:
      begin
        Cadastrar;
        pField.AsString := aJsonValue.Value;
      end;

      ftObject:
      begin
        LEstavaEmEdicao := EstaEmEdicao;
        JsonTxtToDataSet(aJsonValue, pDataSet);
        if (not LEstavaEmEdicao) and EstaEmEdicao then
          pDataSet.Post;
      end;

      ftArray:
      begin
        LEstavaEmEdicao := EstaEmEdicao;
        JsonTxtToDataSet(aJsonValue, pDataSet);
        if (not LEstavaEmEdicao) and EstaEmEdicao then
          pDataSet.Post;
      end;
    end;
  end;
end;

class procedure TAspJson.JsonTxtToDataSet(const aJson: String; pDataSet: TClientDataSet);
var
  ObjJson: TJsonValue;
begin
  ObjJson := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(aJson), 0);
  TRY
    pDataSet.EmptyDataSet;
    JsonTxtToDataSet(ObjJson, pDataSet);
  finally
    ObjJson.Free;
  end;
end;

end.

