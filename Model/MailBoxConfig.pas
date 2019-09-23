
{******************************************************************************}
{                                                                              }
{                               XML Data Binding                               }
{                                                                              }
{         Generated on: 2009/8/24 2:44:16                                      }
{       Generated from: F:\Projects\WAPMail..CC\Model\MailBoxConfig.xml   }
{   Settings stored in: F:\Projects\WAPMail..CC\Model\MailBoxConfig.xdb   }
{                                                                              }
{******************************************************************************}

unit MailBoxConfig;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLDATAPACKETType = interface;
  IXMLMETADATAType = interface;
  IXMLFIELDSType = interface;
  IXMLFIELDType = interface;
  IXMLROWDATAType = interface;
  IXMLROWType = interface;

{ IXMLDATAPACKETType }

  IXMLDATAPACKETType = interface(IXMLNode)
    ['{B054A506-1ED7-4777-AC6E-73DA2697DD94}']
    { Property Accessors }
    function Get_Version: WideString;
    function Get_METADATA: IXMLMETADATAType;
    function Get_ROWDATA: IXMLROWDATAType;
    procedure Set_Version(Value: WideString);
    { Methods & Properties }
    property Version: WideString read Get_Version write Set_Version;
    property METADATA: IXMLMETADATAType read Get_METADATA;
    property ROWDATA: IXMLROWDATAType read Get_ROWDATA;
  end;

{ IXMLMETADATAType }

  IXMLMETADATAType = interface(IXMLNode)
    ['{C9264709-23E3-4C6E-B975-100632B9157A}']
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
    ['{FB849398-C8C2-47F8-A40E-DC22A9D87B07}']
    { Property Accessors }
    function Get_FIELD(Index: Integer): IXMLFIELDType;
    { Methods & Properties }
    function Add: IXMLFIELDType;
    function Insert(const Index: Integer): IXMLFIELDType;
    property FIELD[Index: Integer]: IXMLFIELDType read Get_FIELD; default;
  end;

{ IXMLFIELDType }

  IXMLFIELDType = interface(IXMLNode)
    ['{581FD17E-AC47-44A5-8E46-AB90E06BC0C6}']
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

{ IXMLROWDATAType }

  IXMLROWDATAType = interface(IXMLNodeCollection)
    ['{05446CFA-C0BC-4B94-94E8-D377ED6C1D2B}']
    { Property Accessors }
    function Get_ROW(Index: Integer): IXMLROWType;
    { Methods & Properties }
    function Add: IXMLROWType;
    function Insert(const Index: Integer): IXMLROWType;
    property ROW[Index: Integer]: IXMLROWType read Get_ROW; default;
  end;

{ IXMLROWType }

  IXMLROWType = interface(IXMLNode)
    ['{1CA1B2EF-87A5-4CE9-86A7-98ED57FB6049}']
    { Property Accessors }
    function Get_MailDomain: Integer;
    function Get_SMTPServer: Integer;
    function Get_POP3Server: Integer;
    function Get_SMTPPort: Integer;
    function Get_POP3Port: Integer;
    function Get_SMTPSSL: Integer;
    function Get_POP3SSL: Integer;
    function Get_SMTPSSLPort: Integer;
    procedure Set_MailDomain(Value: Integer);
    procedure Set_SMTPServer(Value: Integer);
    procedure Set_POP3Server(Value: Integer);
    procedure Set_SMTPPort(Value: Integer);
    procedure Set_POP3Port(Value: Integer);
    procedure Set_SMTPSSL(Value: Integer);
    procedure Set_POP3SSL(Value: Integer);
    procedure Set_SMTPSSLPort(Value: Integer);
    { Methods & Properties }
    property MailDomain: Integer read Get_MailDomain write Set_MailDomain;
    property SMTPServer: Integer read Get_SMTPServer write Set_SMTPServer;
    property POP3Server: Integer read Get_POP3Server write Set_POP3Server;
    property SMTPPort: Integer read Get_SMTPPort write Set_SMTPPort;
    property POP3Port: Integer read Get_POP3Port write Set_POP3Port;
    property SMTPSSL: Integer read Get_SMTPSSL write Set_SMTPSSL;
    property POP3SSL: Integer read Get_POP3SSL write Set_POP3SSL;
    property SMTPSSLPort: Integer read Get_SMTPSSLPort write Set_SMTPSSLPort;
  end;

{ Forward Decls }

  TXMLDATAPACKETType = class;
  TXMLMETADATAType = class;
  TXMLFIELDSType = class;
  TXMLFIELDType = class;
  TXMLROWDATAType = class;
  TXMLROWType = class;

{ TXMLDATAPACKETType }

  TXMLDATAPACKETType = class(TXMLNode, IXMLDATAPACKETType)
  protected
    { IXMLDATAPACKETType }
    function Get_Version: WideString;
    function Get_METADATA: IXMLMETADATAType;
    function Get_ROWDATA: IXMLROWDATAType;
    procedure Set_Version(Value: WideString);
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

{ TXMLROWDATAType }

  TXMLROWDATAType = class(TXMLNodeCollection, IXMLROWDATAType)
  protected
    { IXMLROWDATAType }
    function Get_ROW(Index: Integer): IXMLROWType;
    function Add: IXMLROWType;
    function Insert(const Index: Integer): IXMLROWType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLROWType }

  TXMLROWType = class(TXMLNode, IXMLROWType)
  protected
    { IXMLROWType }
    function Get_MailDomain: Integer;
    function Get_SMTPServer: Integer;
    function Get_POP3Server: Integer;
    function Get_SMTPPort: Integer;
    function Get_POP3Port: Integer;
    function Get_SMTPSSL: Integer;
    function Get_POP3SSL: Integer;
    function Get_SMTPSSLPort: Integer;
    procedure Set_MailDomain(Value: Integer);
    procedure Set_SMTPServer(Value: Integer);
    procedure Set_POP3Server(Value: Integer);
    procedure Set_SMTPPort(Value: Integer);
    procedure Set_POP3Port(Value: Integer);
    procedure Set_SMTPSSL(Value: Integer);
    procedure Set_POP3SSL(Value: Integer);
    procedure Set_SMTPSSLPort(Value: Integer);
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
  RegisterChildNode('ROWDATA', TXMLROWDATAType);
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

function TXMLDATAPACKETType.Get_ROWDATA: IXMLROWDATAType;
begin
  Result := ChildNodes['ROWDATA'] as IXMLROWDATAType;
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

{ TXMLROWDATAType }

procedure TXMLROWDATAType.AfterConstruction;
begin
  RegisterChildNode('ROW', TXMLROWType);
  ItemTag := 'ROW';
  ItemInterface := IXMLROWType;
  inherited;
end;

function TXMLROWDATAType.Get_ROW(Index: Integer): IXMLROWType;
begin
  Result := List[Index] as IXMLROWType;
end;

function TXMLROWDATAType.Add: IXMLROWType;
begin
  Result := AddItem(-1) as IXMLROWType;
end;

function TXMLROWDATAType.Insert(const Index: Integer): IXMLROWType;
begin
  Result := AddItem(Index) as IXMLROWType;
end;

{ TXMLROWType }

function TXMLROWType.Get_MailDomain: Integer;
begin
  Result := AttributeNodes['MailDomain'].NodeValue;
end;

procedure TXMLROWType.Set_MailDomain(Value: Integer);
begin
  SetAttribute('MailDomain', Value);
end;

function TXMLROWType.Get_SMTPServer: Integer;
begin
  Result := AttributeNodes['SMTPServer'].NodeValue;
end;

procedure TXMLROWType.Set_SMTPServer(Value: Integer);
begin
  SetAttribute('SMTPServer', Value);
end;

function TXMLROWType.Get_POP3Server: Integer;
begin
  Result := AttributeNodes['POP3Server'].NodeValue;
end;

procedure TXMLROWType.Set_POP3Server(Value: Integer);
begin
  SetAttribute('POP3Server', Value);
end;

function TXMLROWType.Get_SMTPPort: Integer;
begin
  Result := AttributeNodes['SMTPPort'].NodeValue;
end;

procedure TXMLROWType.Set_SMTPPort(Value: Integer);
begin
  SetAttribute('SMTPPort', Value);
end;

function TXMLROWType.Get_POP3Port: Integer;
begin
  Result := AttributeNodes['POP3Port'].NodeValue;
end;

procedure TXMLROWType.Set_POP3Port(Value: Integer);
begin
  SetAttribute('POP3Port', Value);
end;

function TXMLROWType.Get_SMTPSSL: Integer;
begin
  Result := AttributeNodes['SMTPSSL'].NodeValue;
end;

procedure TXMLROWType.Set_SMTPSSL(Value: Integer);
begin
  SetAttribute('SMTPSSL', Value);
end;

function TXMLROWType.Get_POP3SSL: Integer;
begin
  Result := AttributeNodes['POP3SSL'].NodeValue;
end;

procedure TXMLROWType.Set_POP3SSL(Value: Integer);
begin
  SetAttribute('POP3SSL', Value);
end;

function TXMLROWType.Get_SMTPSSLPort: Integer;
begin
  Result := AttributeNodes['SMTPSSLPort'].NodeValue;
end;

procedure TXMLROWType.Set_SMTPSSLPort(Value: Integer);
begin
  SetAttribute('SMTPSSLPort', Value);
end;

end.