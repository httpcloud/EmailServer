
{************************************************************************}
{                                                                        }
{                            XML Data Binding                            }
{                                                                        }
{         Generated on: 2009/8/23 16:24:12                               }
{       Generated from: F:\Projects\WAPMail..CC\bin\WebConfig.xml   }
{   Settings stored in: F:\Projects\WAPMail..CC\bin\WebConfig.xdb   }
{                                                                        }
{************************************************************************}

unit WebConfig;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLConfigurationType = interface;
  IXMLAppSettingsType = interface;
  IXMLAddType = interface;
  IXMLConnectionStringsType = interface;
  IXMLSystemwebType = interface;
  IXMLCompilationType = interface;
  IXMLAssembliesType = interface;
  IXMLAuthenticationType = interface;
  IXMLCustomErrorsType = interface;
  IXMLSessionStateType = interface;

{ IXMLConfigurationType }

  IXMLConfigurationType = interface(IXMLNode)
    ['{C2EE29E8-0D57-42A7-AADF-9AB9B0B8E278}']
    { Property Accessors }
    function Get_AppSettings: IXMLAppSettingsType;
    function Get_ConnectionStrings: IXMLConnectionStringsType;
    function Get_Systemweb: IXMLSystemwebType;
    { Methods & Properties }
    property AppSettings: IXMLAppSettingsType read Get_AppSettings;
    property ConnectionStrings: IXMLConnectionStringsType read Get_ConnectionStrings;
    property Systemweb: IXMLSystemwebType read Get_Systemweb;
  end;

{ IXMLAppSettingsType }

  IXMLAppSettingsType = interface(IXMLNodeCollection)
    ['{5EC536BF-78DB-4ADB-8278-797A9F52F21A}']
    { Property Accessors }
    function Get_Add(Index: Integer): IXMLAddType;
    { Methods & Properties }
    function Add: IXMLAddType;
    function Insert(const Index: Integer): IXMLAddType;
    property Add[Index: Integer]: IXMLAddType read Get_Add; default;
  end;

{ IXMLAddType }

  IXMLAddType = interface(IXMLNode)
    ['{E9ED491C-084E-404E-BE3E-DED3DFEBF053}']
    { Property Accessors }
    function Get_Key: WideString;
    function Get_Value: WideString;
    function Get_Name: WideString;
    function Get_ConnectionString: WideString;
    function Get_ProviderName: WideString;
    function Get_Assembly: WideString;
    procedure Set_Key(Value: WideString);
    procedure Set_Value(Value: WideString);
    procedure Set_Name(Value: WideString);
    procedure Set_ConnectionString(Value: WideString);
    procedure Set_ProviderName(Value: WideString);
    procedure Set_Assembly(Value: WideString);
    { Methods & Properties }
    property Key: WideString read Get_Key write Set_Key;
    property Value: WideString read Get_Value write Set_Value;
    property Name: WideString read Get_Name write Set_Name;
    property ConnectionString: WideString read Get_ConnectionString write Set_ConnectionString;
    property ProviderName: WideString read Get_ProviderName write Set_ProviderName;
    property Assembly: WideString read Get_Assembly write Set_Assembly;
  end;

{ IXMLConnectionStringsType }

  IXMLConnectionStringsType = interface(IXMLNode)
    ['{077B8DCC-90DC-4392-ABEF-A39C5D066A14}']
    { Property Accessors }
    function Get_Add: IXMLAddType;
    { Methods & Properties }
    property Add: IXMLAddType read Get_Add;
  end;

{ IXMLSystemwebType }

  IXMLSystemwebType = interface(IXMLNode)
    ['{29EF1FB7-F650-4E0E-A24E-EE70916D0FCE}']
    { Property Accessors }
    function Get_Compilation: IXMLCompilationType;
    function Get_Authentication: IXMLAuthenticationType;
    function Get_CustomErrors: IXMLCustomErrorsType;
    function Get_SessionState: IXMLSessionStateType;
    { Methods & Properties }
    property Compilation: IXMLCompilationType read Get_Compilation;
    property Authentication: IXMLAuthenticationType read Get_Authentication;
    property CustomErrors: IXMLCustomErrorsType read Get_CustomErrors;
    property SessionState: IXMLSessionStateType read Get_SessionState;
  end;

{ IXMLCompilationType }

  IXMLCompilationType = interface(IXMLNode)
    ['{58D1D7D6-1F89-4A06-A2E7-184F164A5A1B}']
    { Property Accessors }
    function Get_Debug: WideString;
    function Get_Assemblies: IXMLAssembliesType;
    procedure Set_Debug(Value: WideString);
    { Methods & Properties }
    property Debug: WideString read Get_Debug write Set_Debug;
    property Assemblies: IXMLAssembliesType read Get_Assemblies;
  end;

{ IXMLAssembliesType }

  IXMLAssembliesType = interface(IXMLNodeCollection)
    ['{39BBE2C9-6B83-4B0C-98EC-C6D3282E2912}']
    { Property Accessors }
    function Get_Add(Index: Integer): IXMLAddType;
    { Methods & Properties }
    function Add: IXMLAddType;
    function Insert(const Index: Integer): IXMLAddType;
    property Add[Index: Integer]: IXMLAddType read Get_Add; default;
  end;

{ IXMLAuthenticationType }

  IXMLAuthenticationType = interface(IXMLNode)
    ['{17EF1923-EB11-45B4-AB73-93A78C101C8E}']
    { Property Accessors }
    function Get_Mode: WideString;
    procedure Set_Mode(Value: WideString);
    { Methods & Properties }
    property Mode: WideString read Get_Mode write Set_Mode;
  end;

{ IXMLCustomErrorsType }

  IXMLCustomErrorsType = interface(IXMLNode)
    ['{6DC96564-F03E-43D2-8164-696D9B639CF5}']
    { Property Accessors }
    function Get_Mode: WideString;
    function Get_DefaultRedirect: WideString;
    procedure Set_Mode(Value: WideString);
    procedure Set_DefaultRedirect(Value: WideString);
    { Methods & Properties }
    property Mode: WideString read Get_Mode write Set_Mode;
    property DefaultRedirect: WideString read Get_DefaultRedirect write Set_DefaultRedirect;
  end;

{ IXMLSessionStateType }

  IXMLSessionStateType = interface(IXMLNode)
    ['{7797E719-6658-4224-B6FE-FA6931010130}']
    { Property Accessors }
    function Get_Timeout: Integer;
    procedure Set_Timeout(Value: Integer);
    { Methods & Properties }
    property Timeout: Integer read Get_Timeout write Set_Timeout;
  end;

{ Forward Decls }

  TXMLConfigurationType = class;
  TXMLAppSettingsType = class;
  TXMLAddType = class;
  TXMLConnectionStringsType = class;
  TXMLSystemwebType = class;
  TXMLCompilationType = class;
  TXMLAssembliesType = class;
  TXMLAuthenticationType = class;
  TXMLCustomErrorsType = class;
  TXMLSessionStateType = class;

{ TXMLConfigurationType }

  TXMLConfigurationType = class(TXMLNode, IXMLConfigurationType)
  protected
    { IXMLConfigurationType }
    function Get_AppSettings: IXMLAppSettingsType;
    function Get_ConnectionStrings: IXMLConnectionStringsType;
    function Get_Systemweb: IXMLSystemwebType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLAppSettingsType }

  TXMLAppSettingsType = class(TXMLNodeCollection, IXMLAppSettingsType)
  protected
    { IXMLAppSettingsType }
    function Get_Add(Index: Integer): IXMLAddType;
    function Add: IXMLAddType;
    function Insert(const Index: Integer): IXMLAddType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLAddType }

  TXMLAddType = class(TXMLNode, IXMLAddType)
  protected
    { IXMLAddType }
    function Get_Key: WideString;
    function Get_Value: WideString;
    function Get_Name: WideString;
    function Get_ConnectionString: WideString;
    function Get_ProviderName: WideString;
    function Get_Assembly: WideString;
    procedure Set_Key(Value: WideString);
    procedure Set_Value(Value: WideString);
    procedure Set_Name(Value: WideString);
    procedure Set_ConnectionString(Value: WideString);
    procedure Set_ProviderName(Value: WideString);
    procedure Set_Assembly(Value: WideString);
  end;

{ TXMLConnectionStringsType }

  TXMLConnectionStringsType = class(TXMLNode, IXMLConnectionStringsType)
  protected
    { IXMLConnectionStringsType }
    function Get_Add: IXMLAddType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLSystemwebType }

  TXMLSystemwebType = class(TXMLNode, IXMLSystemwebType)
  protected
    { IXMLSystemwebType }
    function Get_Compilation: IXMLCompilationType;
    function Get_Authentication: IXMLAuthenticationType;
    function Get_CustomErrors: IXMLCustomErrorsType;
    function Get_SessionState: IXMLSessionStateType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLCompilationType }

  TXMLCompilationType = class(TXMLNode, IXMLCompilationType)
  protected
    { IXMLCompilationType }
    function Get_Debug: WideString;
    function Get_Assemblies: IXMLAssembliesType;
    procedure Set_Debug(Value: WideString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLAssembliesType }

  TXMLAssembliesType = class(TXMLNodeCollection, IXMLAssembliesType)
  protected
    { IXMLAssembliesType }
    function Get_Add(Index: Integer): IXMLAddType;
    function Add: IXMLAddType;
    function Insert(const Index: Integer): IXMLAddType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLAuthenticationType }

  TXMLAuthenticationType = class(TXMLNode, IXMLAuthenticationType)
  protected
    { IXMLAuthenticationType }
    function Get_Mode: WideString;
    procedure Set_Mode(Value: WideString);
  end;

{ TXMLCustomErrorsType }

  TXMLCustomErrorsType = class(TXMLNode, IXMLCustomErrorsType)
  protected
    { IXMLCustomErrorsType }
    function Get_Mode: WideString;
    function Get_DefaultRedirect: WideString;
    procedure Set_Mode(Value: WideString);
    procedure Set_DefaultRedirect(Value: WideString);
  end;

{ TXMLSessionStateType }

  TXMLSessionStateType = class(TXMLNode, IXMLSessionStateType)
  protected
    { IXMLSessionStateType }
    function Get_Timeout: Integer;
    procedure Set_Timeout(Value: Integer);
  end;

{ Global Functions }

function Getconfiguration(Doc: IXMLDocument): IXMLConfigurationType;
function Loadconfiguration(const FileName: WideString): IXMLConfigurationType;
function Newconfiguration: IXMLConfigurationType;

const
  TargetNamespace = '';

implementation

{ Global Functions }

function Getconfiguration(Doc: IXMLDocument): IXMLConfigurationType;
begin
  Result := Doc.GetDocBinding('configuration', TXMLConfigurationType, TargetNamespace) as IXMLConfigurationType;
end;

function Loadconfiguration(const FileName: WideString): IXMLConfigurationType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('configuration', TXMLConfigurationType, TargetNamespace) as IXMLConfigurationType;
end;

function Newconfiguration: IXMLConfigurationType;
begin
  Result := NewXMLDocument.GetDocBinding('configuration', TXMLConfigurationType, TargetNamespace) as IXMLConfigurationType;
end;

{ TXMLConfigurationType }

procedure TXMLConfigurationType.AfterConstruction;
begin
  RegisterChildNode('appSettings', TXMLAppSettingsType);
  RegisterChildNode('connectionStrings', TXMLConnectionStringsType);
  RegisterChildNode('system.web', TXMLSystemwebType);
  inherited;
end;

function TXMLConfigurationType.Get_AppSettings: IXMLAppSettingsType;
begin
  Result := ChildNodes['appSettings'] as IXMLAppSettingsType;
end;

function TXMLConfigurationType.Get_ConnectionStrings: IXMLConnectionStringsType;
begin
  Result := ChildNodes['connectionStrings'] as IXMLConnectionStringsType;
end;

function TXMLConfigurationType.Get_Systemweb: IXMLSystemwebType;
begin
  Result := ChildNodes['system.web'] as IXMLSystemwebType;
end;

{ TXMLAppSettingsType }

procedure TXMLAppSettingsType.AfterConstruction;
begin
  RegisterChildNode('add', TXMLAddType);
  ItemTag := 'add';
  ItemInterface := IXMLAddType;
  inherited;
end;

function TXMLAppSettingsType.Get_Add(Index: Integer): IXMLAddType;
begin
  Result := List[Index] as IXMLAddType;
end;

function TXMLAppSettingsType.Add: IXMLAddType;
begin
  Result := AddItem(-1) as IXMLAddType;
end;

function TXMLAppSettingsType.Insert(const Index: Integer): IXMLAddType;
begin
  Result := AddItem(Index) as IXMLAddType;
end;

{ TXMLAddType }

function TXMLAddType.Get_Key: WideString;
begin
  Result := AttributeNodes['key'].Text;
end;

procedure TXMLAddType.Set_Key(Value: WideString);
begin
  SetAttribute('key', Value);
end;

function TXMLAddType.Get_Value: WideString;
begin
  Result := AttributeNodes['value'].Text;
end;

procedure TXMLAddType.Set_Value(Value: WideString);
begin
  SetAttribute('value', Value);
end;

function TXMLAddType.Get_Name: WideString;
begin
  Result := AttributeNodes['name'].Text;
end;

procedure TXMLAddType.Set_Name(Value: WideString);
begin
  SetAttribute('name', Value);
end;

function TXMLAddType.Get_ConnectionString: WideString;
begin
  Result := AttributeNodes['connectionString'].Text;
end;

procedure TXMLAddType.Set_ConnectionString(Value: WideString);
begin
  SetAttribute('connectionString', Value);
end;

function TXMLAddType.Get_ProviderName: WideString;
begin
  Result := AttributeNodes['providerName'].Text;
end;

procedure TXMLAddType.Set_ProviderName(Value: WideString);
begin
  SetAttribute('providerName', Value);
end;

function TXMLAddType.Get_Assembly: WideString;
begin
  Result := AttributeNodes['assembly'].Text;
end;

procedure TXMLAddType.Set_Assembly(Value: WideString);
begin
  SetAttribute('assembly', Value);
end;

{ TXMLConnectionStringsType }

procedure TXMLConnectionStringsType.AfterConstruction;
begin
  RegisterChildNode('add', TXMLAddType);
  inherited;
end;

function TXMLConnectionStringsType.Get_Add: IXMLAddType;
begin
  Result := ChildNodes['add'] as IXMLAddType;
end;

{ TXMLSystemwebType }

procedure TXMLSystemwebType.AfterConstruction;
begin
  RegisterChildNode('compilation', TXMLCompilationType);
  RegisterChildNode('authentication', TXMLAuthenticationType);
  RegisterChildNode('customErrors', TXMLCustomErrorsType);
  RegisterChildNode('sessionState', TXMLSessionStateType);
  inherited;
end;

function TXMLSystemwebType.Get_Compilation: IXMLCompilationType;
begin
  Result := ChildNodes['compilation'] as IXMLCompilationType;
end;

function TXMLSystemwebType.Get_Authentication: IXMLAuthenticationType;
begin
  Result := ChildNodes['authentication'] as IXMLAuthenticationType;
end;

function TXMLSystemwebType.Get_CustomErrors: IXMLCustomErrorsType;
begin
  Result := ChildNodes['customErrors'] as IXMLCustomErrorsType;
end;

function TXMLSystemwebType.Get_SessionState: IXMLSessionStateType;
begin
  Result := ChildNodes['sessionState'] as IXMLSessionStateType;
end;

{ TXMLCompilationType }

procedure TXMLCompilationType.AfterConstruction;
begin
  RegisterChildNode('assemblies', TXMLAssembliesType);
  inherited;
end;

function TXMLCompilationType.Get_Debug: WideString;
begin
  Result := AttributeNodes['debug'].Text;
end;

procedure TXMLCompilationType.Set_Debug(Value: WideString);
begin
  SetAttribute('debug', Value);
end;

function TXMLCompilationType.Get_Assemblies: IXMLAssembliesType;
begin
  Result := ChildNodes['assemblies'] as IXMLAssembliesType;
end;

{ TXMLAssembliesType }

procedure TXMLAssembliesType.AfterConstruction;
begin
  RegisterChildNode('add', TXMLAddType);
  ItemTag := 'add';
  ItemInterface := IXMLAddType;
  inherited;
end;

function TXMLAssembliesType.Get_Add(Index: Integer): IXMLAddType;
begin
  Result := List[Index] as IXMLAddType;
end;

function TXMLAssembliesType.Add: IXMLAddType;
begin
  Result := AddItem(-1) as IXMLAddType;
end;

function TXMLAssembliesType.Insert(const Index: Integer): IXMLAddType;
begin
  Result := AddItem(Index) as IXMLAddType;
end;

{ TXMLAuthenticationType }

function TXMLAuthenticationType.Get_Mode: WideString;
begin
  Result := AttributeNodes['mode'].Text;
end;

procedure TXMLAuthenticationType.Set_Mode(Value: WideString);
begin
  SetAttribute('mode', Value);
end;

{ TXMLCustomErrorsType }

function TXMLCustomErrorsType.Get_Mode: WideString;
begin
  Result := AttributeNodes['mode'].Text;
end;

procedure TXMLCustomErrorsType.Set_Mode(Value: WideString);
begin
  SetAttribute('mode', Value);
end;

function TXMLCustomErrorsType.Get_DefaultRedirect: WideString;
begin
  Result := AttributeNodes['defaultRedirect'].Text;
end;

procedure TXMLCustomErrorsType.Set_DefaultRedirect(Value: WideString);
begin
  SetAttribute('defaultRedirect', Value);
end;

{ TXMLSessionStateType }

function TXMLSessionStateType.Get_Timeout: Integer;
begin
  Result := AttributeNodes['timeout'].NodeValue;
end;

procedure TXMLSessionStateType.Set_Timeout(Value: Integer);
begin
  SetAttribute('timeout', Value);
end;

end.