
{**************************************************************************************}
{                                                                                      }
{                                   XML Data Binding                                   }
{                                                                                      }
{         Generated on: 2009/9/26 20:40:54                                             }
{       Generated from: F:\Projects\WAPMail..CC_Delphi2010_20090830\bin\cfg.xml   }
{   Settings stored in: F:\Projects\WAPMail..CC_Delphi2010_20090830\bin\cfg.xdb   }
{                                                                                      }
{**************************************************************************************}

unit cfg;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLConfigurationType = interface;
  IXMLAppSettingsType = interface;
  IXMLAddType = interface;
  IXMLSystemType = interface;
  IXMLDebugType = interface;
  IXMLDataSourceType = interface;
  IXMLSendMailType = interface;
  IXMLWhenErrorType = interface;
  IXMLSaveMailType = interface;
  IXMLSaveType = interface;

{ IXMLConfigurationType }

  IXMLConfigurationType = interface(IXMLNode)
    ['{1AA48B17-504E-4CC9-BDE3-0850FCB6F877}']
    { Property Accessors }
    function Get_AppSettings: IXMLAppSettingsType;
    function Get_System: IXMLSystemType;
    { Methods & Properties }
    property AppSettings: IXMLAppSettingsType read Get_AppSettings;
    property System: IXMLSystemType read Get_System;
  end;

{ IXMLAppSettingsType }

  IXMLAppSettingsType = interface(IXMLNodeCollection)
    ['{E94A9C7D-7F2D-4375-81EB-E7C590FB3454}']
    { Property Accessors }
    function Get_Add(Index: Integer): IXMLAddType;
    { Methods & Properties }
    function Add: IXMLAddType;
    function Insert(const Index: Integer): IXMLAddType;
    property Add[Index: Integer]: IXMLAddType read Get_Add; default;
  end;

{ IXMLAddType }

  IXMLAddType = interface(IXMLNode)
    ['{F63A9307-5038-4D17-BEC4-E593F642A6FC}']
    { Property Accessors }
    function Get_Key: UnicodeString;
    function Get_Value: UnicodeString;
    procedure Set_Key(Value: UnicodeString);
    procedure Set_Value(Value: UnicodeString);
    { Methods & Properties }
    property Key: UnicodeString read Get_Key write Set_Key;
    property Value: UnicodeString read Get_Value write Set_Value;
  end;

{ IXMLSystemType }

  IXMLSystemType = interface(IXMLNode)
    ['{1C5AA1D2-9899-4429-937A-E9DFADB8BA3D}']
    { Property Accessors }
    function Get_Debug: IXMLDebugType;
    { Methods & Properties }
    property Debug: IXMLDebugType read Get_Debug;
  end;

{ IXMLDebugType }

  IXMLDebugType = interface(IXMLNode)
    ['{637A327B-1DEA-43F5-8A35-47D173AE1FC2}']
    { Property Accessors }
    function Get_IsDebug: UnicodeString;
    function Get_DataSource: IXMLDataSourceType;
    function Get_SendMail: IXMLSendMailType;
    procedure Set_IsDebug(Value: UnicodeString);
    { Methods & Properties }
    property IsDebug: UnicodeString read Get_IsDebug write Set_IsDebug;
    property DataSource: IXMLDataSourceType read Get_DataSource;
    property SendMail: IXMLSendMailType read Get_SendMail;
  end;

{ IXMLDataSourceType }

  IXMLDataSourceType = interface(IXMLNode)
    ['{A49C5CC9-0438-4B50-AA72-0A712C6072DF}']
    { Property Accessors }
    function Get_Type_: UnicodeString;
    function Get_Name: UnicodeString;
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Name(Value: UnicodeString);
    { Methods & Properties }
    property Type_: UnicodeString read Get_Type_ write Set_Type_;
    property Name: UnicodeString read Get_Name write Set_Name;
  end;

{ IXMLSendMailType }

  IXMLSendMailType = interface(IXMLNode)
    ['{92C3B5C3-328C-49D2-82F9-C75785B0CD20}']
    { Property Accessors }
    function Get_WhenError: IXMLWhenErrorType;
    { Methods & Properties }
    property WhenError: IXMLWhenErrorType read Get_WhenError;
  end;

{ IXMLWhenErrorType }

  IXMLWhenErrorType = interface(IXMLNode)
    ['{0C807BC6-0935-4E72-9C5D-AE08C4894D89}']
    { Property Accessors }
    function Get_SaveMail: IXMLSaveMailType;
    { Methods & Properties }
    property SaveMail: IXMLSaveMailType read Get_SaveMail;
  end;

{ IXMLSaveMailType }

  IXMLSaveMailType = interface(IXMLNode)
    ['{635A0E56-18DE-43A8-B465-CF984125892C}']
    { Property Accessors }
    function Get_IsSave: UnicodeString;
    function Get_SaveType: IXMLSaveType;
    procedure Set_IsSave(Value: UnicodeString);
    { Methods & Properties }
    property IsSave: UnicodeString read Get_IsSave write Set_IsSave;
    property SaveType: IXMLSaveType read Get_SaveType;
  end;

{ IXMLSaveType }

  IXMLSaveType = interface(IXMLNode)
    ['{9B25E5E8-6BBD-438D-8B25-4DA8E974E6A6}']
    { Property Accessors }
    function Get_Type_: UnicodeString;
    function Get_Path: UnicodeString;
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Path(Value: UnicodeString);
    { Methods & Properties }
    property Type_: UnicodeString read Get_Type_ write Set_Type_;
    property Path: UnicodeString read Get_Path write Set_Path;
  end;

{ Forward Decls }

  TXMLConfigurationType = class;
  TXMLAppSettingsType = class;
  TXMLAddType = class;
  TXMLSystemType = class;
  TXMLDebugType = class;
  TXMLDataSourceType = class;
  TXMLSendMailType = class;
  TXMLWhenErrorType = class;
  TXMLSaveMailType = class;
  TXMLSaveType = class;

{ TXMLConfigurationType }

  TXMLConfigurationType = class(TXMLNode, IXMLConfigurationType)
  protected
    { IXMLConfigurationType }
    function Get_AppSettings: IXMLAppSettingsType;
    function Get_System: IXMLSystemType;
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
    function Get_Key: UnicodeString;
    function Get_Value: UnicodeString;
    procedure Set_Key(Value: UnicodeString);
    procedure Set_Value(Value: UnicodeString);
  end;

{ TXMLSystemType }

  TXMLSystemType = class(TXMLNode, IXMLSystemType)
  protected
    { IXMLSystemType }
    function Get_Debug: IXMLDebugType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLDebugType }

  TXMLDebugType = class(TXMLNode, IXMLDebugType)
  protected
    { IXMLDebugType }
    function Get_IsDebug: UnicodeString;
    function Get_DataSource: IXMLDataSourceType;
    function Get_SendMail: IXMLSendMailType;
    procedure Set_IsDebug(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLDataSourceType }

  TXMLDataSourceType = class(TXMLNode, IXMLDataSourceType)
  protected
    { IXMLDataSourceType }
    function Get_Type_: UnicodeString;
    function Get_Name: UnicodeString;
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Name(Value: UnicodeString);
  end;

{ TXMLSendMailType }

  TXMLSendMailType = class(TXMLNode, IXMLSendMailType)
  protected
    { IXMLSendMailType }
    function Get_WhenError: IXMLWhenErrorType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLWhenErrorType }

  TXMLWhenErrorType = class(TXMLNode, IXMLWhenErrorType)
  protected
    { IXMLWhenErrorType }
    function Get_SaveMail: IXMLSaveMailType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLSaveMailType }

  TXMLSaveMailType = class(TXMLNode, IXMLSaveMailType)
  protected
    { IXMLSaveMailType }
    function Get_IsSave: UnicodeString;
    function Get_SaveType: IXMLSaveType;
    procedure Set_IsSave(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLSaveType }

  TXMLSaveType = class(TXMLNode, IXMLSaveType)
  protected
    { IXMLSaveType }
    function Get_Type_: UnicodeString;
    function Get_Path: UnicodeString;
    procedure Set_Type_(Value: UnicodeString);
    procedure Set_Path(Value: UnicodeString);
  end;

{ Global Functions }

function Getconfiguration(Doc: IXMLDocument): IXMLConfigurationType;
function Loadconfiguration(const FileName: string): IXMLConfigurationType;
function Newconfiguration: IXMLConfigurationType;

const
  TargetNamespace = '';

implementation

{ Global Functions }

function Getconfiguration(Doc: IXMLDocument): IXMLConfigurationType;
begin
  Result := Doc.GetDocBinding('configuration', TXMLConfigurationType, TargetNamespace) as IXMLConfigurationType;
end;

function Loadconfiguration(const FileName: string): IXMLConfigurationType;
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
  RegisterChildNode('system', TXMLSystemType);
  inherited;
end;

function TXMLConfigurationType.Get_AppSettings: IXMLAppSettingsType;
begin
  Result := ChildNodes['appSettings'] as IXMLAppSettingsType;
end;

function TXMLConfigurationType.Get_System: IXMLSystemType;
begin
  Result := ChildNodes['system'] as IXMLSystemType;
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

function TXMLAddType.Get_Key: UnicodeString;
begin
  Result := AttributeNodes['key'].Text;
end;

procedure TXMLAddType.Set_Key(Value: UnicodeString);
begin
  SetAttribute('key', Value);
end;

function TXMLAddType.Get_Value: UnicodeString;
begin
  Result := AttributeNodes['value'].Text;
end;

procedure TXMLAddType.Set_Value(Value: UnicodeString);
begin
  SetAttribute('value', Value);
end;

{ TXMLSystemType }

procedure TXMLSystemType.AfterConstruction;
begin
  RegisterChildNode('debug', TXMLDebugType);
  inherited;
end;

function TXMLSystemType.Get_Debug: IXMLDebugType;
begin
  Result := ChildNodes['debug'] as IXMLDebugType;
end;

{ TXMLDebugType }

procedure TXMLDebugType.AfterConstruction;
begin
  RegisterChildNode('dataSource', TXMLDataSourceType);
  RegisterChildNode('sendMail', TXMLSendMailType);
  inherited;
end;

function TXMLDebugType.Get_IsDebug: UnicodeString;
begin
  Result := AttributeNodes['isDebug'].Text;
end;

procedure TXMLDebugType.Set_IsDebug(Value: UnicodeString);
begin
  SetAttribute('isDebug', Value);
end;

function TXMLDebugType.Get_DataSource: IXMLDataSourceType;
begin
  Result := ChildNodes['dataSource'] as IXMLDataSourceType;
end;

function TXMLDebugType.Get_SendMail: IXMLSendMailType;
begin
  Result := ChildNodes['sendMail'] as IXMLSendMailType;
end;

{ TXMLDataSourceType }

function TXMLDataSourceType.Get_Type_: UnicodeString;
begin
  Result := AttributeNodes['type'].Text;
end;

procedure TXMLDataSourceType.Set_Type_(Value: UnicodeString);
begin
  SetAttribute('type', Value);
end;

function TXMLDataSourceType.Get_Name: UnicodeString;
begin
  Result := AttributeNodes['name'].Text;
end;

procedure TXMLDataSourceType.Set_Name(Value: UnicodeString);
begin
  SetAttribute('name', Value);
end;

{ TXMLSendMailType }

procedure TXMLSendMailType.AfterConstruction;
begin
  RegisterChildNode('whenError', TXMLWhenErrorType);
  inherited;
end;

function TXMLSendMailType.Get_WhenError: IXMLWhenErrorType;
begin
  Result := ChildNodes['whenError'] as IXMLWhenErrorType;
end;

{ TXMLWhenErrorType }

procedure TXMLWhenErrorType.AfterConstruction;
begin
  RegisterChildNode('saveMail', TXMLSaveMailType);
  inherited;
end;

function TXMLWhenErrorType.Get_SaveMail: IXMLSaveMailType;
begin
  Result := ChildNodes['saveMail'] as IXMLSaveMailType;
end;

{ TXMLSaveMailType }

procedure TXMLSaveMailType.AfterConstruction;
begin
  RegisterChildNode('saveType', TXMLSaveType);
  inherited;
end;

function TXMLSaveMailType.Get_IsSave: UnicodeString;
begin
  Result := AttributeNodes['isSave'].Text;
end;

procedure TXMLSaveMailType.Set_IsSave(Value: UnicodeString);
begin
  SetAttribute('isSave', Value);
end;

function TXMLSaveMailType.Get_SaveType: IXMLSaveType;
begin
  Result := ChildNodes['saveType'] as IXMLSaveType;
end;

{ TXMLSaveType }

function TXMLSaveType.Get_Type_: UnicodeString;
begin
  Result := AttributeNodes['type'].Text;
end;

procedure TXMLSaveType.Set_Type_(Value: UnicodeString);
begin
  SetAttribute('type', Value);
end;

function TXMLSaveType.Get_Path: UnicodeString;
begin
  Result := ChildNodes['path'].Text;
end;

procedure TXMLSaveType.Set_Path(Value: UnicodeString);
begin
  ChildNodes['path'].NodeValue := Value;
end;

end.