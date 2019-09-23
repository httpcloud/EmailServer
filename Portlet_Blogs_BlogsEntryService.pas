// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService?wsdl
//  >Import : http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService?wsdl>0
//  >Import : http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService?wsdl>1
// Encoding : UTF-8
// Version  : 1.0
// (2008-12-1 20:58:08 - - $Rev: 16699 $)
// ************************************************************************ //

unit Portlet_Blogs_BlogsEntryService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://schemas.xmlsoap.org/soap/encoding/"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[]

  BlogsEntrySoap       = class;                 { "http://model.blogs.portlet.liferay.com"[GblCplx] }



  // ************************************************************************ //
  // XML       : BlogsEntrySoap, global, <complexType>
  // Namespace : http://model.blogs.portlet.liferay.com
  // ************************************************************************ //
  BlogsEntrySoap = class(TRemotable)
  private
    FallowTrackbacks: Boolean;
    FcompanyId: Int64;
    Fcontent: string;
    FcreateDate: TXSDateTime;
    FdisplayDate: TXSDateTime;
    Fdraft: Boolean;
    FentryId: Int64;
    FgroupId: Int64;
    FmodifiedDate: TXSDateTime;
    FprimaryKey: Int64;
    Ftitle: string;
    Ftrackbacks: string;
    FurlTitle: string;
    FuserId: Int64;
    FuserName: string;
    Fuuid: string;
  public
    destructor Destroy; override;
  published
    property allowTrackbacks: Boolean      read FallowTrackbacks write FallowTrackbacks;
    property companyId:       Int64        read FcompanyId write FcompanyId;
    property content:         string       read Fcontent write Fcontent;
    property createDate:      TXSDateTime  read FcreateDate write FcreateDate;
    property displayDate:     TXSDateTime  read FdisplayDate write FdisplayDate;
    property draft:           Boolean      read Fdraft write Fdraft;
    property entryId:         Int64        read FentryId write FentryId;
    property groupId:         Int64        read FgroupId write FgroupId;
    property modifiedDate:    TXSDateTime  read FmodifiedDate write FmodifiedDate;
    property primaryKey:      Int64        read FprimaryKey write FprimaryKey;
    property title:           string       read Ftitle write Ftitle;
    property trackbacks:      string       read Ftrackbacks write Ftrackbacks;
    property urlTitle:        string       read FurlTitle write FurlTitle;
    property userId:          Int64        read FuserId write FuserId;
    property userName:        string       read FuserName write FuserName;
    property uuid:            string       read Fuuid write Fuuid;
  end;

  ArrayOf_tns2_BlogsEntrySoap = array of BlogsEntrySoap;   { "urn:http.service.blogs.portlet.liferay.com"[GblCplx] }

  // ************************************************************************ //
  // Namespace : urn:http.service.blogs.portlet.liferay.com
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // binding   : Portlet_Blogs_BlogsEntryServiceSoapBinding
  // service   : BlogsEntryServiceSoapService
  // port      : Portlet_Blogs_BlogsEntryService
  // URL       : http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService
  // ************************************************************************ //
  BlogsEntryServiceSoap = interface(IInvokable)
  ['{142CDAFF-A035-8D48-0271-5C2A394FC409}']
    function  getCompanyEntries(const companyId: Int64; const max: Integer): ArrayOf_tns2_BlogsEntrySoap; stdcall;
    function  getGroupEntries(const groupId: Int64; const max: Integer): ArrayOf_tns2_BlogsEntrySoap; stdcall;
    function  getOrganizationEntries(const organizationId: Int64; const max: Integer): ArrayOf_tns2_BlogsEntrySoap; stdcall;
    function  getEntry(const groupId: Int64; const urlTitle: string): BlogsEntrySoap; overload;  stdcall;
    function  getEntry(const entryId: Int64): BlogsEntrySoap; overload;  stdcall;
    procedure deleteEntry(const entryId: Int64); stdcall;
  end;

function GetBlogsEntryServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): BlogsEntryServiceSoap;


implementation
  uses SysUtils;

function GetBlogsEntryServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): BlogsEntryServiceSoap;
const
  defWSDL = 'http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService?wsdl';
  defURL  = 'http://118.126.3.67/tunnel-web/axis/Portlet_Blogs_BlogsEntryService';
  defSvc  = 'BlogsEntryServiceSoapService';
  defPrt  = 'Portlet_Blogs_BlogsEntryService';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as BlogsEntryServiceSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


destructor BlogsEntrySoap.Destroy;
begin
  SysUtils.FreeAndNil(FcreateDate);
  SysUtils.FreeAndNil(FdisplayDate);
  SysUtils.FreeAndNil(FmodifiedDate);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(BlogsEntryServiceSoap), 'urn:http.service.blogs.portlet.liferay.com', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(BlogsEntryServiceSoap), '');
  RemClassRegistry.RegisterXSClass(BlogsEntrySoap, 'http://model.blogs.portlet.liferay.com', 'BlogsEntrySoap');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOf_tns2_BlogsEntrySoap), 'urn:http.service.blogs.portlet.liferay.com', 'ArrayOf_tns2_BlogsEntrySoap');

end.