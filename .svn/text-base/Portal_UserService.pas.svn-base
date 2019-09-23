// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService?wsdl
//  >Import : http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService?wsdl>0
//  >Import : http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService?wsdl>1
// Encoding : UTF-8
// Version  : 1.0
// (2008-11-25 1:51:17 - - $Rev: 16699 $)
// ************************************************************************ //

unit Portal_UserService;

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
  // !:string          - "http://schemas.xmlsoap.org/soap/encoding/"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[]
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[]

  UserSoap             = class;                 { "http://model.portal.liferay.com"[GblCplx] }



  // ************************************************************************ //
  // XML       : UserSoap, global, <complexType>
  // Namespace : http://model.portal.liferay.com
  // ************************************************************************ //
  UserSoap = class(TRemotable)
  private
    Factive: Boolean;
    FagreedToTermsOfUse: Boolean;
    Fcomments: string;
    FcompanyId: Int64;
    FcontactId: Int64;
    FcreateDate: TXSDateTime;
    FdefaultUser: Boolean;
    FemailAddress: string;
    FfailedLoginAttempts: Integer;
    FgraceLoginCount: Integer;
    Fgreeting: string;
    FlanguageId: string;
    FlastFailedLoginDate: TXSDateTime;
    FlastLoginDate: TXSDateTime;
    FlastLoginIP: string;
    Flockout: Boolean;
    FlockoutDate: TXSDateTime;
    FloginDate: TXSDateTime;
    FloginIP: string;
    FmodifiedDate: TXSDateTime;
    FopenId: string;
    Fpassword: string;
    FpasswordEncrypted: Boolean;
    FpasswordModifiedDate: TXSDateTime;
    FpasswordReset: Boolean;
    FportraitId: Int64;
    FprimaryKey: Int64;
    FscreenName: string;
    FtimeZoneId: string;
    FuserId: Int64;
    Fuuid: string;
  public
    destructor Destroy; override;
  published
    property active:               Boolean      read Factive write Factive;
    property agreedToTermsOfUse:   Boolean      read FagreedToTermsOfUse write FagreedToTermsOfUse;
    property comments:             string       read Fcomments write Fcomments;
    property companyId:            Int64        read FcompanyId write FcompanyId;
    property contactId:            Int64        read FcontactId write FcontactId;
    property createDate:           TXSDateTime  read FcreateDate write FcreateDate;
    property defaultUser:          Boolean      read FdefaultUser write FdefaultUser;
    property emailAddress:         string       read FemailAddress write FemailAddress;
    property failedLoginAttempts:  Integer      read FfailedLoginAttempts write FfailedLoginAttempts;
    property graceLoginCount:      Integer      read FgraceLoginCount write FgraceLoginCount;
    property greeting:             string       read Fgreeting write Fgreeting;
    property languageId:           string       read FlanguageId write FlanguageId;
    property lastFailedLoginDate:  TXSDateTime  read FlastFailedLoginDate write FlastFailedLoginDate;
    property lastLoginDate:        TXSDateTime  read FlastLoginDate write FlastLoginDate;
    property lastLoginIP:          string       read FlastLoginIP write FlastLoginIP;
    property lockout:              Boolean      read Flockout write Flockout;
    property lockoutDate:          TXSDateTime  read FlockoutDate write FlockoutDate;
    property loginDate:            TXSDateTime  read FloginDate write FloginDate;
    property loginIP:              string       read FloginIP write FloginIP;
    property modifiedDate:         TXSDateTime  read FmodifiedDate write FmodifiedDate;
    property openId:               string       read FopenId write FopenId;
    property password:             string       read Fpassword write Fpassword;
    property passwordEncrypted:    Boolean      read FpasswordEncrypted write FpasswordEncrypted;
    property passwordModifiedDate: TXSDateTime  read FpasswordModifiedDate write FpasswordModifiedDate;
    property passwordReset:        Boolean      read FpasswordReset write FpasswordReset;
    property portraitId:           Int64        read FportraitId write FportraitId;
    property primaryKey:           Int64        read FprimaryKey write FprimaryKey;
    property screenName:           string       read FscreenName write FscreenName;
    property timeZoneId:           string       read FtimeZoneId write FtimeZoneId;
    property userId:               Int64        read FuserId write FuserId;
    property uuid:                 string       read Fuuid write Fuuid;
  end;

  ArrayOf_xsd_long = array of Int64;            { "urn:http.service.portal.liferay.com"[GblCplx] }

  // ************************************************************************ //
  // Namespace : urn:http.service.portal.liferay.com
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // binding   : Portal_UserServiceSoapBinding
  // service   : UserServiceSoapService
  // port      : Portal_UserService
  // URL       : http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService
  // ************************************************************************ //
  UserServiceSoap = interface(IInvokable)
  ['{BFE28644-F7D3-E18D-CE1A-E6A28E9B731D}']
    function  getUserById(const userId: Int64): UserSoap; stdcall;
    function  getDefaultUserId(const companyId: Int64): Int64; stdcall;
    procedure addGroupUsers(const groupId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure addOrganizationUsers(const organizationId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure addPasswordPolicyUsers(const passwordPolicyId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure addRoleUsers(const roleId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure addUserGroupUsers(const userGroupId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    function  addUser(const companyId: Int64; const autoPassword: Boolean; const password1: string; const password2: string; const autoScreenName: Boolean; const screenName: string; 
                      const emailAddress: string; const locale: string; const firstName: string; const middleName: string; const lastName: string; 
                      const prefixId: Integer; const suffixId: Integer; const male: Boolean; const birthdayMonth: Integer; const birthdayDay: Integer; 
                      const birthdayYear: Integer; const jobTitle: string; const organizationIds: ArrayOf_xsd_long; const sendEmail: Boolean): UserSoap; stdcall;
    procedure deleteRoleUser(const roleId: Int64; const userId: Int64); stdcall;
    procedure deleteUser(const userId: Int64); stdcall;
    function  getUserByEmailAddress(const companyId: Int64; const emailAddress: string): UserSoap; stdcall;
    function  getUserByScreenName(const companyId: Int64; const screenName: string): UserSoap; stdcall;
    function  getUserIdByEmailAddress(const companyId: Int64; const emailAddress: string): Int64; stdcall;
    function  getUserIdByScreenName(const companyId: Int64; const screenName: string): Int64; stdcall;
    function  hasGroupUser(const groupId: Int64; const userId: Int64): Boolean; stdcall;
    function  hasRoleUser(const roleId: Int64; const userId: Int64): Boolean; stdcall;
    procedure setRoleUsers(const roleId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure setUserGroupUsers(const userGroupId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure unsetGroupUsers(const groupId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure unsetOrganizationUsers(const organizationId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure unsetPasswordPolicyUsers(const passwordPolicyId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure unsetRoleUsers(const roleId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    procedure unsetUserGroupUsers(const userGroupId: Int64; const userIds: ArrayOf_xsd_long); stdcall;
    function  updateActive(const userId: Int64; const active: Boolean): UserSoap; stdcall;
    function  updateAgreedToTermsOfUse(const userId: Int64; const agreedToTermsOfUse: Boolean): UserSoap; stdcall;
    function  updateLockout(const userId: Int64; const lockout: Boolean): UserSoap; stdcall;
    procedure updateOrganizations(const userId: Int64; const organizationIds: ArrayOf_xsd_long); stdcall;
    function  updatePassword(const userId: Int64; const password1: string; const password2: string; const passwordReset: Boolean): UserSoap; stdcall;
    procedure updatePortrait(const userId: Int64; const bytes: TByteDynArray); stdcall;
    procedure updateScreenName(const userId: Int64; const screenName: string); stdcall;
    procedure updateOpenId(const userId: Int64; const openId: string); stdcall;
    function  updateUser(const userId: Int64; const oldPassword: string; const newPassword1: string; const newPassword2: string; const passwordReset: Boolean; const screenName: string; 
                         const emailAddress: string; const languageId: string; const timeZoneId: string; const greeting: string; const comments: string; 
                         const firstName: string; const middleName: string; const lastName: string; const prefixId: Integer; const suffixId: Integer; 
                         const male: Boolean; const birthdayMonth: Integer; const birthdayDay: Integer; const birthdayYear: Integer; const smsSn: string; 
                         const aimSn: string; const facebookSn: string; const icqSn: string; const jabberSn: string; const msnSn: string; 
                         const mySpaceSn: string; const skypeSn: string; const twitterSn: string; const ymSn: string; const jobTitle: string; 
                         const organizationIds: ArrayOf_xsd_long): UserSoap; overload;  stdcall;
    function  updateUser(const userId: Int64; const oldPassword: string; const passwordReset: Boolean; const screenName: string; const emailAddress: string; const languageId: string; 
                         const timeZoneId: string; const greeting: string; const comments: string; const firstName: string; const middleName: string; 
                         const lastName: string; const prefixId: Integer; const suffixId: Integer; const male: Boolean; const birthdayMonth: Integer; 
                         const birthdayDay: Integer; const birthdayYear: Integer; const smsSn: string; const aimSn: string; const facebookSn: string; 
                         const icqSn: string; const jabberSn: string; const msnSn: string; const mySpaceSn: string; const skypeSn: string; 
                         const twitterSn: string; const ymSn: string; const jobTitle: string; const organizationIds: ArrayOf_xsd_long): UserSoap; overload;  stdcall;
  end;

function GetUserServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): UserServiceSoap;


implementation
  uses SysUtils;

function GetUserServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): UserServiceSoap;
const
  defWSDL = 'http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService?wsdl';
  defURL  = 'http://118.126.3.67/tunnel-web/secure/axis/Portal_UserService';
  defSvc  = 'UserServiceSoapService';
  defPrt  = 'Portal_UserService';
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
    Result := (RIO as UserServiceSoap);
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


destructor UserSoap.Destroy;
begin
  SysUtils.FreeAndNil(FcreateDate);
  SysUtils.FreeAndNil(FlastFailedLoginDate);
  SysUtils.FreeAndNil(FlastLoginDate);
  SysUtils.FreeAndNil(FlockoutDate);
  SysUtils.FreeAndNil(FloginDate);
  SysUtils.FreeAndNil(FmodifiedDate);
  SysUtils.FreeAndNil(FpasswordModifiedDate);
  inherited Destroy;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(UserServiceSoap), 'urn:http.service.portal.liferay.com', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(UserServiceSoap), '');
  RemClassRegistry.RegisterXSClass(UserSoap, 'http://model.portal.liferay.com', 'UserSoap');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOf_xsd_long), 'urn:http.service.portal.liferay.com', 'ArrayOf_xsd_long');

end.