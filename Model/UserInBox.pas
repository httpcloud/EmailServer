
{**************************************************************************}
{                                                                          }
{                             XML Data Binding                             }
{                                                                          }
{         Generated on: 2009/8/24 2:44:46                                  }
{       Generated from: F:\Projects\WAPMail..CC\Model\UserInBox.xml   }
{   Settings stored in: F:\Projects\WAPMail..CC\Model\UserInBox.xdb   }
{                                                                          }
{**************************************************************************}

unit UserInBox;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLDATAPACKETType = interface;
  IXMLMETADATAType = interface;
  IXMLFIELDSType = interface;
  IXMLFIELDType = interface;

{ IXMLDATAPACKETType }

  IXMLDATAPACKETType = interface(IXMLNode)
    ['{380C0876-A651-43AF-A57B-E5C6C9DE1C87}']
    { Property Accessors }
    function Get_Version: WideString;
    function Get_METADATA: IXMLMETADATAType;
    function Get_ROWDATA: WideString;
    procedure Set_Version(Value: WideString);
    procedure Set_ROWDATA(Value: WideString);
    { Methods & Properties }
    property Version: WideString read Get_Version write Set_Version;
    property METADATA: IXMLMETADATAType read Get_METADATA;
    property ROWDATA: WideString read Get_ROWDATA write Set_ROWDATA;
  end;

{ IXMLMETADATAType }

  IXMLMETADATAType = interface(IXMLNode)
    ['{8EAEE432-2784-4240-AF5B-6A80E2945BF8}']
    { Property Accessors }
    function Get_FIELDS: IXMLFIELDSType;
    function Get_PARAMS: WideString;
    procedure Set_PARAMS(Value: WideString);
    { Methods & Properties }
    property FIELDS: IXMLFIELDSType read Get_FIELDS;
    property PARAMS: WideString read Get_PARAMS write Set_PARAMS;
  end;

{ IXMLFIELDSType }

  IXMLFIELDSType = interface(IXMLNodeCollection)
    ['{CA8DA527-10BE-4FAB-A8BE-3DD6205CDED5}']
    { Property Accessors }
    function Get_FIELD(Index: Integer): IXMLFIELDType;
    { Methods & Properties }
    function Add: IXMLFIELDType;
    function Insert(const Index: Integer): IXMLFIELDType;
    property FIELD[Index: Integer]: IXMLFIELDType read Get_FIELD; default;
  end;

{ IXMLFIELDType }

  IXMLFIELDType = interface(IXMLNode)
    ['{6C2C0C93-937F-4CD8-BE99-7C57E30C091B}']
    { Property Accessors }
    function Get_Attrname: WideString;
    function Get_Fieldtype: WideString;
    function Get_WIDTH: Integer;
    procedure Set_Attrname(Value: WideString);
    procedure Set_Fieldtype(Value: WideString);
    procedure Set_WIDTH(Value: Integer);
    { Methods & Properties }
    property Attrname: WideString read Get_Attrname write Set_Attrname;
    property Fieldtype: WideString read Get_Fieldtype write Set_Fieldtype;
    property WIDTH: Integer read Get_WIDTH write Set_WIDTH;
  end;

{ Forward Decls }

  TXMLDATAPACKETType = class;
  TXMLMETADATAType = class;
  TXMLFIELDSType = class;
  TXMLFIELDType = class;

{ TXMLDATAPACKETType }

  TXMLDATAPACKETType = class(TXMLNode, IXMLDATAPACKETType)
  protected
    { IXMLDATAPACKETType }
    function Get_Version: WideString;
    function Get_METADATA: IXMLMETADATAType;
    function Get_ROWDATA: WideString;
    procedure Set_Version(Value: WideString);
    procedure Set_ROWDATA(Value: WideString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLMETADATAType }

  TXMLMETADATAType = class(TXMLNode, IXMLMETADATAType)
  protected
    { IXMLMETADATAType }
    function Get_FIELDS: IXMLFIELDSType;
    function Get_PARAMS: WideString;
    procedure Set_PARAMS(Value: WideString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLFIELDSType }

  TXMLFIELDSType = class(TXMLNodeCollection, IXMLFIELDSType)
  protected
    { IXMLFIELDSType }
    function Get_FIELD(Index: Integer): IXMLFIELDType;
    function Add: IXMLFIELDType;
    function Insert(const Index: Integer): IXMLFIELDType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLFIELDType }

  TXMLFIELDType = class(TXMLNode, IXMLFIELDType)
  protected
    { IXMLFIELDType }
    function Get_Attrname: WideString;
    function Get_Fieldtype: WideString;
    function Get_WIDTH: Integer;
    procedure Set_Attrname(Value: WideString);
    procedure Set_Fieldtype(Value: WideString);
    procedure Set_WIDTH(Value: Integer);
  end;

{ Global Functions }

function GetDATAPACKET(Doc: IXMLDocument): IXMLDATAPACKETType;
function LoadDATAPACKET(const FileName: WideString): IXMLDATAPACKETType;
function NewDATAPACKET: IXMLDATAPACKETType;

const
  TargetNamespace = '';

implementation

{ Global Functions }

function GetDATAPACKET(Doc: IXMLDocument): IXMLDATAPACKETType;
begin
  Result := Doc.GetDocBinding('DATAPACKET', TXMLDATAPACKETType, TargetNamespace) as IXMLDATAPACKETType;
end;

function LoadDATAPACKET(const FileName: WideString): IXMLDATAPACKETType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('DATAPACKET', TXMLDATAPACKETType, TargetNamespace) as IXMLDATAPACKETType;
end;

function NewDATAPACKET: IXMLDATAPACKETType;
begin
  Result := NewXMLDocument.GetDocBinding('DATAPACKET', TXMLDATAPACKETType, TargetNamespace) as IXMLDATAPACKETType;
end;

{ TXMLDATAPACKETType }

procedure TXMLDATAPACKETType.AfterConstruction;
begin
  RegisterChildNode('METADATA', TXMLMETADATAType);
  inherited;
end;

function TXMLDATAPACKETType.Get_Version: WideString;
begin
  Result := AttributeNodes['Version'].Text;
end;

procedure TXMLDATAPACKETType.Set_Version(Value: WideString);
begin
  SetAttribute('Version', Value);
end;

function TXMLDATAPACKETType.Get_METADATA: IXMLMETADATAType;
begin
  Result := ChildNodes['METADATA'] as IXMLMETADATAType;
end;

function TXMLDATAPACKETType.Get_ROWDATA: WideString;
begin
  Result := ChildNodes['ROWDATA'].Text;
end;

procedure TXMLDATAPACKETType.Set_ROWDATA(Value: WideString);
begin
  ChildNodes['ROWDATA'].NodeValue := Value;
end;

{ TXMLMETADATAType }

procedure TXMLMETADATAType.AfterConstruction;
begin
  RegisterChildNode('FIELDS', TXMLFIELDSType);
  inherited;
end;

function TXMLMETADATAType.Get_FIELDS: IXMLFIELDSType;
begin
  Result := ChildNodes['FIELDS'] as IXMLFIELDSType;
end;

function TXMLMETADATAType.Get_PARAMS: WideString;
begin
  Result := ChildNodes['PARAMS'].Text;
end;

procedure TXMLMETADATAType.Set_PARAMS(Value: WideString);
begin
  ChildNodes['PARAMS'].NodeValue := Value;
end;

{ TXMLFIELDSType }

procedure TXMLFIELDSType.AfterConstruction;
begin
  RegisterChildNode('FIELD', TXMLFIELDType);
  ItemTag := 'FIELD';
  ItemInterface := IXMLFIELDType;
  inherited;
end;

function TXMLFIELDSType.Get_FIELD(Index: Integer): IXMLFIELDType;
begin
  Result := List[Index] as IXMLFIELDType;
end;

function TXMLFIELDSType.Add: IXMLFIELDType;
begin
  Result := AddItem(-1) as IXMLFIELDType;
end;

function TXMLFIELDSType.Insert(const Index: Integer): IXMLFIELDType;
begin
  Result := AddItem(Index) as IXMLFIELDType;
end;

{ TXMLFIELDType }

function TXMLFIELDType.Get_Attrname: WideString;
begin
  Result := AttributeNodes['attrname'].Text;
end;

procedure TXMLFIELDType.Set_Attrname(Value: WideString);
begin
  SetAttribute('attrname', Value);
end;

function TXMLFIELDType.Get_Fieldtype: WideString;
begin
  Result := AttributeNodes['fieldtype'].Text;
end;

procedure TXMLFIELDType.Set_Fieldtype(Value: WideString);
begin
  SetAttribute('fieldtype', Value);
end;

function TXMLFIELDType.Get_WIDTH: Integer;
begin
  Result := AttributeNodes['WIDTH'].NodeValue;
end;

procedure TXMLFIELDType.Set_WIDTH(Value: Integer);
begin
  SetAttribute('WIDTH', Value);
end;

end.