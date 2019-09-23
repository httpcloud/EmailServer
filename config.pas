unit config;

interface

uses
  HTTPApp,IniFiles,Windows,Sysutils,Classes,
  IdPOP3,IdSSLOpenSSL, idURI,IdExplicitTLSClientServerBase,IdGlobal,idStrings,
  StrUtils,
  WebCntxt,
  XXTEA,Encoder,
  DCPdes,DCPsha1,DCPbase64,

  XMLIntf,
  XMLDoc,
  Variants,
  hashmap,
  IdTelnet,
  .Application.XMLConfig
  //WebConfig
  ;

type

  TConfig = class(TComponent)
  const
    cUserName = 'UID';  //username
    cPassword = 'PWD';  //password
    cPOP3Server = 'POP';
    cSMTPServer = 'SMTP';
    cPOP3Port = 'POPPort';
    cSMTPPort = 'SMTPPort';
    cMailAddress = 'MailBox'; //���������ַ

    UserMailConfig = 'UMCFG'; //�û���������

    SendMailStateCode = 'SndSteCode';  //���ʼ�ʱ������״̬��Ϣ������ݴ���Session�е�SessionName,������Ϣ��ʾ��
    SendMailStateInfo = 'SndSteInfo';  //���ʼ�ʱ��������ϸ״̬��Ϣ���ݴ���Session�е�SessionName,�������ϸ����Ϣ��

    userLogPath = 'userLog\';            //�û���־·��
    userInBoxPath = 'userData\inBox\';   //�û��ռ���·��
    userOutBoxPath = 'userData\outBox\'; //�û�������·��
    //MailAppendContent = #13#10#13#10#13#10#13#10'-------------------------------------------------------------------------------------------'#13#10'(���ʼ����ֻ���������,��Ҳ���Լ������ֻ���½ http://Wap..CC ��ʱ�������շ����������ʼ�)'#13#10#13#10'.CC(��)������ʱ�������Mo����Ȥ��'#13#10#13#10'�ֻ�����: http://wap..cc ���Ե�½: http://www..cc ';
    MailAppendContent = #13#10#13#10#13#10#13#10'-------------------------------------------------------------------------------------------'#13#10'���ʼ��������ҵ��ֻ�����,��Ҳ���Լ������ֻ���½ http://Wap..CC ��ʱ�������շ����������ʼ�'#13#10'.CC - ������ʱ������� Mo ����Ȥ��' ;


    pageWordNum = 300; //ÿҳ��ʾ������
    StartWord = 1 ;    //�ӵڼ����ֿ�ʼ��ʾ
    EndSignSet = ',.���� ';

    currentUserSession = 'UserSession';  //��ǰ�û���Session���֡�
    inBoxCount = 'inBoxCount';   //�û��ռ����ж��ٷ���
    mailBoxName = 'mailBoxName'; //�û���ǰ�ռ���ȫ��(��:xxx@.cc)
    outBoxCount = 'outBoxCount';   //�û��������ж��ٷ���
    draftBoxCount = 'draftBoxCount';   //�û��ݸ����ж��ٷ���

    addMailBoxStatus = 'addMailBoxStatus';  //�û������������ʱ�ɹ�����״̬

    commonActionTagName = 'commonActionTagName'; //ͨ�ö�����Tag����
    commonActionTagParagramName = 'code'; //����ͨ�ö�����Tag�����ݵĲ������֣����ڸ�����ֵ��info.ini�м��������Ӧ����ϸ��Ϣ��

    SYS_State_Code='SSCODE'; //
    //SYS_INFO = 'SYSINFO';
    SYS_MSG = 'SYSMSG';
    ERROR404 = 'ERR404';     //�Ҳ����ļ�

    //SQLite_DB_Name = 'F:\Projects\WAPMail..CC_Delphi2010_20090830\bin\data\db.db';//'Encrypted.db3';

    pageItemCount = 5;  //�ʼ��б��ҳ:ÿҳ��ʾ����Ŀ��
  End;

  TCurrentUserSession = class(TComponent)
    private
      _userName:string;
      _userId:integer;
      _userMail:string;
      _password:string;
    public
      constructor create(AOwner:TComponent);
      destructor Destory;
    published
      property userName:string read _userName write _userName;
      property userId:integer read _userId write _userId;
      property userMail:string read _userMail write _userMail;
      property password:string read _password write _password;
  end;



  TMailConfig = class(TComponent)
    private
      _pop3Server:string;
      _smtpServer:string;
      _pop3Port:integer;
      _smtpPort:integer;
      _smtpAuthencation:boolean;
      _pop3SSL:boolean;
      _smtpSSL:boolean;
      _mailAddress:string;
      _mailUserName:string;
      _mailPassword:string;
      _isDefault:boolean;
    public
      constructor create(AOwner:TComponent);
      destructor Destroy; override;
    published
      property pop3Server:string read _pop3Server write _pop3Server;
      property smtpServer:string read _smtpServer write _smtpServer;
      property pop3Port:integer read _pop3Port write _pop3Port default 110;
      property smtpPort:integer read _smtpPort write _smtpPort default 25;
      property smtpAuthencation:boolean read _smtpAuthencation write _smtpAuthencation default true;
      property pop3SSL:boolean read _pop3SSL write _pop3SSL default false;
      property smtpSSL:boolean read _smtpSSL write _smtpSSL default false;
      property mailAddress:string read _mailAddress write _mailAddress;
      property mailUserName:string read _mailUserName write _mailUserName;
      property mailPassword:string read _mailPassword write _mailPassword;
      property isDefault:boolean read _isDefault write _isDefault;
  end;

  TMailConfigArray = array of TMailConfig;



  TMailList = class(TComponent)
    private
      //_mailConfigCount:integer;
      _MailConfigList:TMailConfigArray;
    public
      //property MailConfigCount:integer read _mailConfigCount write _mailConfigCount;
      property MailConfigList: TMailConfigArray read _MailConfigList write _MailConfigList;
  end;

  //ö����
  TUserLoginMode = class            //�û���½ģʽ
    const
      userId = 'userId';
      userName = 'screenName';
      emailAddress = 'emailAddress';
      guest = 'guest'; //�ο͵�¼

      userIdMapValue = 1;         //��userID��½ʱ�����½������ӳ���ֵ
      userNameMapValue = 2;       //��screenName��½ʱ�����½������ӳ���ֵ
      emailAddressMapValue = 3;   //��emailAddress��½ʱ�����½������ӳ���ֵ
      guestUserMapVlaue = 0;      //���ο�����������ʱ�����½������ӳ���ֵ
  end;

  TUser = class(TComponent)
  private
    _userName:string;
    _userId:integer;
    _userMail:string;
    _password:string;
    _currentSelectMail:string;
    _userLoginMode:string;
    _mailConfigArray:TMailConfigArray;

    function getMailConfig(i: Integer): TMailConfig;
    procedure setMailConfig(i: Integer; const Value: TMailConfig);
    //function getMailConfigArray:TMailConfigArray;
  public
    mailConfigArrayLength:integer;
    constructor Create(AOwner: TComponent;MailConfigArrayItemCount:Integer);overload;
    destructor Destroy; override;
    function getLoginModeMapValue:string;
    property mailConfigArray[i: Integer]:TMailConfig read getMailConfig write setMailConfig;
  published
    property userName:string read _userName write _userName;
    property userId:integer read _userId write _userId;
    property userMail:string read _userMail write _userMail;
    property password:string read _password write _password;
    property currentSelectMail:string read _currentSelectMail write _currentSelectMail;
    property loginMode:string read _userLoginMode write _userLoginMode;    //��½ģʽ����ʽ
    //property mailConfigArray:TMailConfigArray read _mailConfigArray write _mailConfigArray;

  end;

  //TCharSet = (GBK,GB2312,BIG5,UTF_8,otheCharSet);
  //TEncoder = (base64,QuotedPrintable,bit8,otherEncoder);
  TCharSet = class
    const
      GB2312 = 'GB2312';
      GBK = 'GBK';
      GB18030 = 'GB18030';
      BIG5 = 'BIG5';
      UTF8 = 'UTF-8';
      other = '';  //δ֪����
  End;

  TEncoder = class
    const
      base64 = 'base64';
      QuotedPrintable = 'quoted-printable' ;
      bit8 = 'bit8';
      other = '';  //δ֪����
  end;

  TContentType = class
    const
      common = 'commonContent'; //ͨ�����ݣ�Ҫ��ͨ�ý��뷽������ġ�
      mailSubject = 'MailSubject';
      mailBody = 'MailBody';    //IndyĬ���ѽ���룬�����˱�־�����ٽ��н��룬�������ַ�����ת����
      mailRecipients = 'mailRecipients';
      mailSender = 'MailSender';
  end;

  TLoginModeEnum = (ByUserNameAndPassword,ById,ByEmail,ByGuest);

  TXMLConfigDebugDataSource = class
  public
  var
    DataSourceName:AnsiString;
    DataSourceType:Integer;
    DataSourceValue:AnsiString;
  end;

  TXMLConfig = class
  private class var FXMLConfigFileName:string;
  public class function GetXMLConfigDoc: IXMLConfigurationType; static;

  private class var FWebConfigFileName:string;

  private class var FXMLConfig:IXMLConfigurationType;
  //public class function LoadXMLFile(fileName:string):IXMLDocument; overload;static;
  public class function LoadXMLFile(fileName:string):IXMLConfigurationType;overload; static;
//  private class var _WebConfig:IXMLConfigurationType;
//  private class function GetWebConfig: IXMLConfigurationType; static;
//  private class procedure SetWebConfig(const Value: IXMLConfigurationType); static;

  var
    DebugDataSouce:TXMLConfigDebugDataSource;
    constructor Create;

    private class function LoadXMLConfigFile: IXMLConfigurationType;overload;
    class function GetWebConfigFileName: String; static;
    class function GetDataBaseFullPath: String; static;
    public class function GetDebugDataSource: TXMLConfigDebugDataSource;
    public class function IsDebug:boolean;overload;
    public class function IsDebug(request:TWebRequest):boolean;overload;
    public class function IsServer(request:TWebRequest):boolean;

    public class function GetServerConfig(var MailServerConfig:TMailConfig):Boolean;
    public class function GetAppSettingValueByKey(key:string):string;
    public class function GetAppSettingTitle():string;
    public class function GetPWD:string;

  strict private
    class function GetXMLConfigFileName : String;static;
    class procedure SetXMLConfigFileName(val : String);static;
  public
    class property XMLConfigFileName : String read GetXMLConfigFileName write SetXMLConfigFileName;
    class property WebConfigFileName : String read GetWebConfigFileName;
    class property DataBaseFullPath : String read GetDataBaseFullPath;

    class property XMLConfigDoc:IXMLConfigurationType read GetXMLConfigDoc;
   // class property XMLWebConfig:IXMLConfigurationType read GetWebConfig write SetWebConfig;
  end;

  TContext = class
  strict private
    function GetUserList : THashMap;
    procedure SetUserList(val : THashMap);
  public
    ///<alias>
    ///  </alias>
    property UserList : THashMap read GetUserList write SetUserList;
  end;
  //function UTF8:TUTF8Codec;
  ///<summary>
  ///  ss
  ///  </summary>
  function GetCurrentPath:string;
  function GetCurrentPath2:string;
  function GetInfo(request:TWebRequest;parameterName:string = 'i'):string;overload;
  function GetInfo(parameterValue:string):string;overload;


  function POP3Test(mailConfig: TMailConfig; var errorMsg:string):boolean; //�����û��ṩ������������Ϣ����POP3���ʼ��Ƿ�����
  function SMTPTest(mailConfig: TmailConfig; var errorMsg:string):boolean; //�����û��ṩ������������Ϣ����SMTP���ʼ��Ƿ�����

  {
  //��ֲ�� .Common.SysUtils.pas ��
  // TODO -olwgboy -c�ַ������� : //ȥ���ַ���ĩβ�İ�����ֵȷǷ��ַ�����ȥ���ַ���:'abcdefghijklmn'#$A1 ����#$A1
  function FilterHalfUnicode(var srcStr:string):boolean;

  function encryptUserInfo(userName,password:AnsiString):AnsiString;
  function decryptUserInfo(encryptStr:AnsiString; var UserName:AnsiString;var Password:AnsiString):Boolean;

  function FilterSpecialCharacter(src:string):string;   //����WML�����ַ�
  function FilterSightlessCharacter(s:string):string; //���˲��ɼ��ַ���ASCIIֵС��32��Ϊ���ɼ��ַ�
  }
  function FormatSystemMessage(SystemMessage:string;MessageClassName:string='';MessageCode:integer=65535):string;

  //��ֲ�� .Common.WebUtils.pas ��
  //procedure SafeRedirectTo(AResponse: TWebResponse; AURL: string; isNewLoad:boolean=true; Title:string='���Ժ�...');

  function logToFile(userName,logText:string):string;
  function GetMIMEType(FileExt: string): string;
  {
var
  UTF:TUTF8Codec;
  }
implementation

uses
  IdSMTP;

{
function UTF8:TUTF8Codec;
begin
  if UTF=nil then
    UTF := TUTF8Codec.Create;
  Result := UTF;
end;
}

function GetCurrentPath:string;
var
  fname:pchar;
  ISAPIFileName:string;
begin
  getmem(fname,256);
  ISAPIFileName := Copy(WebContext.Request.URL,LastDelimiter('/',WebContext.Request.URL)+1,Length(WebContext.Request.URL)-LastDelimiter('/',WebContext.Request.URL)+1);
  GetModuleFileName(GetModuleHandle(PChar(ISAPIFileName)),fname,256);
  Result := ExtractFilePath(fname);
  if(LeftStr(Result,4)='\\?\')then
    Result := RightStr(Result,Length(Result)-4);
  Freemem(fname);
end;

function GetCurrentPath2:string;
var
  fname:pchar;
  ISAPIFileName:string;
begin
  getmem(fname,256);
  ISAPIFileName := 'MobileMail.dll';// Copy(WebContext.Request.URL,LastDelimiter('/',WebContext.Request.URL)+1,Length(WebContext.Request.URL)-LastDelimiter('/',WebContext.Request.URL)+1);
  GetModuleFileName(GetModuleHandle(PChar(ISAPIFileName)),fname,256);
  Result := ExtractFilePath(fname);
  if(LeftStr(Result,4)='\\?\')then
    Result := RightStr(Result,Length(Result)-4);
  Freemem(fname);
end;

function GetInfo(request:TWebRequest;parameterName:string = 'i'):string;
var
  info:string;
  ini:TIniFile;
  fname:pchar;
begin
  info := Request.ContentFields.Values[parameterName];
  if info='' then info := Request.QueryFields.Values[parameterName];
  if info<>'' then
  begin
    ini := TIniFile.Create(GetCurrentPath+'info.ini');
    {
    case StrToInt(info) of
      -1: info := '��¼ʧ��,����Գ��Ը߼����,���������ֶ��,�����������ʼ�������û�п��Ż�֧�ֱ�׼�ӿ�,��Ҳ����ϵ����Э�����.'; //Exchange2007
      -2: info := '��¼ʧ��.';
    end;
    }
    //Result := UTF8.EncodeStr(ini.ReadString('error',info,''));
    Result := ini.ReadString('error',info,'');
    ini.Free;
  end
  else
    Result := '';
end;

function GetInfo(parameterValue:string):string;
var
  info,path:string;
  ini:TIniFile;
begin
  if parameterValue<>'' then
  begin
    ini := TIniFile.Create(GetCurrentPath+'info.ini');
    {
    case StrToInt(info) of
      -1: info := '��¼ʧ��,����Գ��Ը߼����,���������ֶ��,�����������ʼ�������û�п��Ż�֧�ֱ�׼�ӿ�,��Ҳ����ϵ����Э�����.'; //Exchange2007
      -2: info := '��¼ʧ��.';
    end;
    }
    //Result := UTF8.EncodeStr(ini.ReadString('error',parameterValue,''));
    Result := ini.ReadString('error',parameterValue,'');
    ini.Free;
  end
  else
    Result := '';
end;

constructor TMailConfig.create(AOwner: TComponent);
begin
  inherited;
end;

destructor TMailConfig.Destroy;
begin
  inherited;
end;

constructor TUser.Create(AOwner: TComponent;MailConfigArrayItemCount:Integer);
var
  I:integer;
begin
  if MailConfigArrayItemCount=0 then MailConfigArrayItemCount := 1;
  SetLength(_mailConfigArray,MailConfigArrayItemCount);
  for I := 0 to MailConfigArrayItemCount - 1 do
    _mailConfigArray[I] := TMailConfig.Create(AOwner);
  mailConfigArrayLength := MailConfigArrayItemCount;
end;

destructor TUser.Destroy;
var
  I,MailConfigArrayItemCount:integer;
begin
  MailConfigArrayItemCount := Length(_mailConfigArray);
  for I := 0 to MailConfigArrayItemCount - 1 do
    _mailConfigArray[I].FreeOnRelease;
  mailConfigArrayLength := 0;
  inherited;
end;

//��õ�½��ʽ��Ӧ��ӳ��ֵ���Ա��ڵ�½URL������URL?loginType=X����ʽ����ʾ����ʲô��ʽ��½�ġ�
function TUser.getLoginModeMapValue: string;
begin
  if self.loginMode = TUserLoginMode.userId then
     Result := IntToStr(TUserLoginMode.userIdMapValue)
  else
  if self.loginMode = TUserLoginMode.userName then
     Result := IntToStr(TUserLoginMode.userNameMapValue)
  else
    if self.loginMode = TUserLoginMode.emailAddress then
     Result := IntToStr(TUserLoginMode.emailAddressMapValue)
  else
    if self.loginMode = TUserLoginMode.guest then
     Result := IntToStr(TUserLoginMode.guestUserMapVlaue)
  else
     Result := '-1';
end;

function TUser.getMailConfig(i: Integer): TMailConfig;
begin
  if i>Length(_mailConfigArray)-1 then
  begin
    SetLength(_mailConfigArray,Length(_mailConfigArray)+1);
    _mailConfigArray[Length(_mailConfigArray)-1] := TMailConfig.Create(self);
  end;
  mailConfigArrayLength := length(_mailConfigArray);
  Result := _mailConfigArray[i];
end;


procedure TUser.setMailConfig(i: Integer; const Value: TMailConfig);
begin
//  if i>Length(_mailConfigArray)-1 then
//  begin
//    SetLength(_mailConfigArray,Length(_mailConfigArray)+1);
//    _mailConfigArray[Length(_mailConfigArray)-1] := TMailConfig.Create(self);
//  end;
  _mailConfigArray[i] := Value;
end;

{ TCurrentUserSession }

constructor TCurrentUserSession.create(AOwner: TComponent);
begin
  inherited;
end;

destructor TCurrentUserSession.Destory;
begin
  inherited;
end;

{ TODO -olwgboy -c�ַ������� : //ȥ���ַ���ĩβ�İ�����ֵȷǷ��ַ�����ȥ���ַ���:'abcdefghijklmn'#$A1 ����#$A1 }
function FilterHalfUnicode(var srcStr:string):boolean;
var
  lastChar:string;
begin
  Result := false;
  lastChar := AnsiLastChar(srcStr); //AnsiLastChar�������ڻ����һ���ַ���������ַ���λ��,��֧��˫�ֽ��ַ�
    if (length(lastChar)=1) and (ord(lastChar[1])>127) then
    begin
      delete(srcStr,length(srcStr),1);
      Result := true;
    end;
end;

{ TODO -o lwgboy -c����POP3 :
�����û��ṩ������������Ϣ����POP3���ʼ��Ƿ�����
�ο� Tlogin.LoginMailServer������ʵ��
}
function POP3Test(mailConfig: TMailConfig; var errorMsg:string):boolean;
var
  POP3Client:TIdPOP3;
  sslIOHandler:TIdSSLIOHandlerSocketOpenSSL;

  telnet:TIdTelnet;
  pop3server,smtpServer:string;
begin
  Result := false;
  POP3Client := TIdPOP3.Create(nil);
  POP3Client.Host := mailConfig.pop3Server;
  POP3Client.Port := mailConfig.pop3Port;
  POP3Client.Username := mailConfig.mailAddress; //�����ʼ���ַ���û��������ڸ����ʼ������ṩ�̶��������������ַ���û�����
  POP3Client.Password := mailConfig.mailPassword;
  if mailConfig.pop3SSL then
  begin
    POP3Client.Username := mailConfig.mailAddress;
    sslIOHandler:= TIdSSLIOHandlerSocketOpenSSL.Create(POP3Client);
    sslIOHandler.SSLOptions.Method := sslvTLSv1;
    sslIOHandler.SSLOptions.Mode := sslmUnassigned;
    sslIOHandler.SSLOptions.VerifyMode := [];
    sslIOHandler.SSLOptions.VerifyDepth := 0;
    POP3Client.IOHandler := sslIOHandler;
    POP3Client.UseTLS := utUseImplicitTLS;
    POP3Client.Port := mailConfig.pop3Port;
  end
  else
    sslIOHandler := nil;

  try
    try
      POP3Client.ConnectTimeout := 1500;
      POP3Client.Connect;
      if POP3Client.Connected then
      begin
        if POP3Client.CheckMessages>=0 then
          Result := true;
      end
    except on E:Exception do
      begin
//        if Pos('10038',E.Message)>0 then
        begin
//          telnet := TIdTelnet.Create(self);
//          telnet.ConnectTimeout := 1500;
//          pop3server := 'pop'+RightStr(mailConfig.pop3Server,length(mailConfig.pop3Server)-pos('.',mailConfig.pop3Server));
//          telnet.Connect(pop3Server,110);
//          if(not telnet.Connected) then
//          begin
//            pop3server := 'mail'+RightStr(mailConfig.pop3Server,length(mailConfig.pop3Server)-pos('.',mailConfig.pop3Server));
//            telnet.Connect(pop3Server,110);
//          end;
//
//          if telnet.Connected then
//          begin
//             telnet.Disconnect(true);
//             POP3Client.Host := POP3Server;
//             POP3Client.Connect;
//          end;


          errorMsg := StringReplace(E.Message,#13#10,' ',[rfReplaceAll]);
          if (Pos('@',POP3Client.Username)>0)and((Pos('username',errorMsg)>0) or (Pos('password',errorMsg)>0)) then   //�������ַ�е��û���ȡ����Ϊ��¼ POP3 Server���û������������ӡ�
          begin
            POP3Client.Username := mailConfig.mailUserName;   //����ʱ�����ʼ���ַ@ǰ���û������û���,Exchange Ĭ�Ͻ�����@����ǰ�Ĳ������û�����
            POP3Client.Disconnect;
            try
              POP3Client.Connect;
              Result := true
            except on E:Exception do
              errorMsg := StringReplace(E.Message,#13#10,' ',[rfReplaceAll]);
            end;
          end
          else
            errorMsg := StringReplace(E.Message,#13#10,' ',[rfReplaceAll]);
        end;
      end;
    end;
 finally
      POP3Client.Disconnect;
      {
      if sslIOHandler<>nil then
      ���Է��ֵ�����дʱ�����������Զ��Ż��ɣ�����ǰ���Ƿ���Ҫ������ʹû�д�������
      Ҳ���Զ�Ԥ�ȴ���(�����������),�������ط����ж���Ϊtrue,���Ե�ִ����sslIOHandler.Free��
      ��������øú��������ͷ�����������mailConfig.Freeʱ�ᱨ����Ч��ָ�����
      ����ĳ�������ж���ʽ�������POP3TestҲ��ͬ���Ĵ���취��
      }
      if POP3Client.IOHandler<>nil then
      begin
        if sslIOHandler<>nil then
        begin
          sslIOHandler.Close;
          sslIOHandler.Free;
        end;
      end;
      POP3Client.Free;
 end;

end;


function SMTPTest(mailConfig: TMailConfig; var errorMsg:string):boolean;
var
  SMTPClient:TIdSMTP;
  sslIOHandler:TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := false;
  SMTPClient := TIdSMTP.Create(nil);
  SMTPClient.Host := mailConfig.smtpServer;
  SMTPClient.Port := mailConfig.smtpPort;
  SMTPClient.Username := mailConfig.mailAddress;
  SMTPClient.Password := mailConfig.mailPassword;
  SMTPClient.MailAgent := 'OutLook 6.0';
  if mailConfig.smtpSSL then
  begin
    sslIOHandler:= TIdSSLIOHandlerSocketOpenSSL.Create(SMTPClient);
    sslIOHandler.SSLOptions.Method := sslvTLSv1;
    //sslIOHandler.SSLOptions.Mode := sslmUnassigned;
    //sslIOHandler.SSLOptions.VerifyMode := [];
    //sslIOHandler.SSLOptions.VerifyDepth := 0;
    SMTPClient.IOHandler := sslIOHandler;
    SMTPClient.UseTLS := TIdUseTLS.utUseRequireTLS;
    SMTPClient.Port := mailConfig.smtpPort;
  end;

  try
    try
      SMTPClient.ConnectTimeout := 1500;
      SMTPClient.Connect;
      if SMTPClient.Connected then
        {
        if SMTPClient.Authenticate then
        �������ж���֤�ɹ��󼴿�����SMTPServer��������������
        �������ʵ�ķ��Ź���SMTPClient.Send(msg)����ʡʱ�䡣
        ����ЩSMTPServer����������֤�����ע�͵��þ��жϡ�
        }
        Result := true;
    except on E:Exception do
      begin
        errorMsg := StringReplace(E.Message,#13#10,' ',[rfReplaceAll]);
        if (Pos('@',SMTPClient.Username)>0)and((Pos('username',errorMsg)>0) or (Pos('password',errorMsg)>0)) then   //�������ַ�е��û���ȡ����Ϊ��¼ POP3 Server���û������������ӡ�
        begin
          SMTPClient.Username := mailConfig.mailUserName;   //����ʱ�����ʼ���ַ@ǰ���û������û���,Exchange Ĭ�Ͻ�����@����ǰ�Ĳ������û�����
          SMTPClient.Disconnect;
          try
            SMTPClient.Connect;
            Result := true
          except on E:Exception do
            errorMsg := StringReplace(E.Message,#13#10,' ',[rfReplaceAll]);
          end;
        end;
      end;
    end;
  finally
    SMTPClient.Disconnect;
    {
    if sslIOHandler<>nil then
    ���Է��ֵ�����дʱ�����������Զ��Ż��ɣ�����ǰ���Ƿ���Ҫ������ʹû�д�������
    Ҳ���Զ�Ԥ�ȴ���(�����������),�������ط����ж���Ϊtrue,���Ե�ִ����sslIOHandler.Free��
    ��������øú��������ͷ�����������mailConfig.Freeʱ�ᱨ����Ч��ָ�����
    ����ĳ�������ж���ʽ�������POP3TestҲ��ͬ���Ĵ���취��
    }
    if SMTPClient.IOHandler<>nil then
    begin
      if sslIOHandler<>nil then
      begin
        try
          sslIOHandler.Close;
          sslIOHandler.Free;
        except on E:Exception do
          begin
            sslIOHandler := nil;
          end;
        end;
      end;
    end;
    SMTPClient.Free;
  end;
end;



procedure RedirectTo;
begin
  //          self.PageProducer.OnHTMLTag := Main.PageProducer.OnHTMLTag;
  //          temp := Main.PageProducer.HTMLFile;
  //          PageProducer.HTMLDoc.LoadFromFile(config.GetCurrentPath+Main.UnitName+'.wml');
  //          Response.Content := PageProducer.Content;
  //          Response.SendResponse;
  //        Handled := true;
end;

{ TODO -olwgboy -c����URL : ����URL�Ĳ��� }
function decodeURL(AURL:String):TStringList;
var
  sLeft,sRight:string;
  StrLst:Tstringlist;
begin
  StrLst:=Tstringlist.Create;
  SplitString(AURL,'?',sLeft,sRight);
  if(AURL<>sLeft)then begin
    strLst.Delimiter := '&';
    StrLst.DelimitedText := sRight;
  end;
  Result := StrLst;
end;

procedure SafeRedirectTo(AResponse: TWebResponse; AURL: string; isNewload:boolean=true; Title:string='���Ժ�...');
var
  URL:TIdURI;
  strLst:TStringList;
  rd:string; //��������Է�ֹ�ӻ������ҳ�棬�������������������롣
begin
  AURL := ReplaceText(AURL,'&amp;','&');   //��ֹ��Щ�Ѿ���ǰת����,�����Ȼ�ԭ��ת�룬�Է�ֹ&amp;�ٴα�ת���&amp;amp;
  AURL := ReplaceText(AURL,'&','&amp;');   //��&����ת�룻
  if(isNewLoad)then begin
    Randomize;
    rd := 'rd='+IntToStr(Random(36500));
    URL := TIdURI.Create(AURL);
    if(URL.Params<>'')then
      URL.Params := rd+'&amp;'+URL.Params
    else
      URL.Params := rd;

    //AURL := URL.Document+'#'+URL.Bookmark+'?'+URL.Params;
    AURL := URL.GetPathAndParams+iif(URL.Bookmark<>'','#'+URL.Bookmark,'');
    URL.Free;
  end;
  AResponse.Content := Format(
'<wml>'+                                                                { do not localize }
'<card id="Redirect" title="'+Title+'" newcontext="true">'+
'<onevent type="ontimer">'+
'<go href="%0:s"/>' +
'</onevent>'+
'<timer value="1"/>'+
'</card>'+
'</wml>', [AURL]);                                                             { do not localize }
end;

function FormatSystemMessage(SystemMessage:string;MessageClassName:string='';MessageCode:integer=65535):string;
begin
  Result := SystemMessage+'<!--'+MessageClassName+IntToStr(MessageCode)+'--><br/>';
  {
  if MessageClasseName<>'' then
    Result := Result+'<!--'+SystemMessage;
  if MessageCode<>65535 then
    Result := Result+  '-->';
  }
end;

function logToFile(userName,logText:string):string;
var
  logFileName,s:string;
  log:TStringList;
begin
  logFileName := FormatDateTime('yyyymmdd-hhmmss',now)+userName+'.log';
  log := TStringList.Create;
  s := FormatDateTime('yyyy-mm-dd hh:mm:ss',now);
  log.Add(s);
  log.Add(logText);
  log.SaveToFile(GetCurrentPath+TConfig.userLogPath+logFileName);
  Result := logFileName;
end;

{
This code is useful if you are creating a webserver program.
It's very simple, just input the extension of a file and the
function returns the MIME type of that file.

mimetypes.RES is the compiled resource file that contains a string
table with 641 different MIME types.
http://modelingman.freeprohost.com/Downloads/Delphi/MIME/mimetypes.RES

mimetypes.rc is the source file of mimetypes.RES, you can add more
types to this and compile it using brcc32
http://modelingman.freeprohost.com/Downloads/Delphi/MIME/mimetypes.rc
}

{$R mimetypes.RES}

function GetMIMEType(FileExt: string): string;
var
  I: Integer;
  S: array[0..255] of Char;
const
  MIMEStart = 101;
  // ID of first MIME Type string (IDs are set in the .rc file
  // before compiling with brcc32)
  MIMEEnd = 742; //ID of last MIME Type string
begin
  Result := 'text/plain';
  // If the file extenstion is not found then the result is plain text
  for I := MIMEStart to MIMEEnd do
  begin
    LoadString(hInstance, I, @S, 255);
    // Loads a string from mimetypes.res which is embedded into the
    // compiled exe
    if Copy(S, 1, Length(FileExt)) = FileExt then
    // "If the string that was loaded contains FileExt then"
    begin
      Result := Copy(S, Length(FileExt) + 2, 255);
      // Copies the MIME Type from the string that was loaded
      Break;
      // Breaks the for loop so that it won't go through every
      // MIME Type after it found the correct one.
    end;
  end;
end;

constructor TXMLConfig.Create;
begin
  inherited Create;
end;

{$Region 'ע�͵�,������һ��ͬ�����滻��'}
{
class function TXMLConfig.LoadXMLFile(fileName:string):IXMLDocument;
var
  XMLConfigFile:TXMLDocument;
begin
  XMLConfigFile :=  TXMLDocument.Create(nil);
  XMLConfigFile.LoadFromFile(fileName);
  Result := XMLConfigFile;
end;
}
{$ENDRegion}

class function TXMLConfig.LoadXMLFile(fileName: string): IXMLConfigurationType;
begin
  Result := Loadconfiguration(fileName)
end;

class function TXMLConfig.LoadXMLConfigFile: IXMLConfigurationType;
begin
  Result := LoadXMLFile(XMLConfigFileName);
end;



//class function TXMLConfig.GetWebConfig: IXMLConfigurationType;
//begin
//  Result := nil;//WebConfig.Loadconfiguration(WebConfigFileName);
//end;

class function TXMLConfig.GetXMLConfigDoc: IXMLConfigurationType;
begin
  if FXMLConfig=nil then
  begin
    FXMLConfig := LoadXMLConfigFile;
  end;
  Result := FXMLConfig;
end;

class function TXMLConfig.GetXMLConfigFileName: String;
begin
  //Result :=  GetCurrentDir()+'\cfg.xml';
  //Result := FXMLConfigFileName;
  Result :=GetCurrentPath+'cfg.xml';
end;

class function TXMLConfig.GetWebConfigFileName: String;
begin
  Result :=GetCurrentPath+'WebConfig.xml';
end;

{$REGION 'dereliction method,�ɵı������ķ���,2009-8-23'}
{
class function TXMLConfig.IsDebug: boolean;
var
  DebugXMLNode:IXMLNode;
begin
  DebugXMLNode := XMLConfigDoc.ChildNodes.FindNode('debug');
  if(VarToStr(DebugXMLNode.Attributes['IsDebug'])='true') then
    Result := true
  else
    Result := false;
end;
}

{
class function TXMLConfig.GetDebugDataSource: TXMLConfigDebugDataSource;
var
  XMLConfigFile:IXMLDocument;
  DebugXMLNode,DebugDataSourceXMLNode:IXMLNode;
  ds:TXMLConfigDebugDataSource;
begin
  XMLConfigFile := LoadXMLConfigFile;
  DebugXMLNode := XMLConfigFile.ChildNodes.FindNode('debug');
  DebugDataSourceXMLNode := DebugXMLNode.ChildNodes.FindNode('DataSource');
  ds := TXMLConfigDebugDataSource.Create;
  ds.DataSourceName := DebugDataSourceXMLNode.GetAttributeNS('name','');
  ds.DataSourceType := DebugDataSourceXMLNode.GetAttributeNS('type','');
  ds.DataSourceValue := iif(VarIsNull(DebugDataSourceXMLNode.NodeValue),'',Variants.VarToStr(DebugDataSourceXMLNode.NodeValue));
  DebugDataSourceXMLNode._Release;
  DebugXMLNode._Release;
  XMLConfigFile._Release;
  Result := ds;
end;
}
{$ENDREGION}

class function TXMLConfig.IsDebug: boolean;
begin
  Result := false;
  if(self.XMLConfigDoc.System<>nil)then
  begin
    if(self.XMLConfigDoc.System.Debug<>nil) and (self.XMLConfigDoc.System.Debug.HasAttribute('isDebug')) then
    begin
      if(self.XMLConfigDoc.System.Debug.IsDebug = 'true') then
        Result := true
      else
        Result := false;
    end;
  end;
end;

class function TXMLConfig.IsDebug(request:TWebRequest): boolean;
begin
  Result := false;
  if(self.XMLConfigDoc.System<>nil)then
  begin
    if(self.XMLConfigDoc.System.Debug<>nil) and (self.XMLConfigDoc.System.Debug.HasAttribute('isDebug')) then
    begin
      if(self.XMLConfigDoc.System.Debug.IsDebug = 'true') and IsServer(request) then
        Result := true
      else
        Result := false;
    end;
  end;
end;

class function TXMLConfig.IsServer(request: TWebRequest): boolean;
begin
  if((pos('.cc',lowercase(request.Host))>0) or (pos('.vicp.',lowercase(request.Host))>0)) then
    Result := true
  else
    Result := false;
end;


class function TXMLConfig.GetAppSettingTitle: string;
var
  title:string;
begin
  title := GetAppSettingValueByKey('Title');
  if trim(title)='' then
     title := '�ֻ�����ƽ̨';
  Result := title;
end;

class function TXMLConfig.GetAppSettingValueByKey(key: string): string;
var
  I: integer;
begin
  try
    for I := 0 to config.TXMLConfig.XMLConfigDoc.AppSettings.Count - 1 do
    begin
      if lowercase(config.TXMLConfig.XMLConfigDoc.AppSettings.Add[i].Key)=LowerCase(key) then
      begin
        Result := config.TXMLConfig.XMLConfigDoc.AppSettings.Add[i].Value;
        exit;
      end;
    end;
  Except on E:Exception do

  end;
  Result := '';
end;

class function TXMLConfig.GetServerConfig(var MailServerConfig:TMailConfig):boolean;
var
  Domain:string;
begin
  Result := false;
  if MailServerConfig<>nil then
  begin
    Domain := trim(GetAppSettingValueByKey('Domain'));
    MailServerConfig.pop3Server := trim(GetAppSettingValueByKey('POP3Server'));
    MailServerConfig.smtpServer := trim(GetAppSettingValueByKey('SMTPServer'));
    MailServerConfig.pop3SSL := iif(trim(GetAppSettingValueByKey('POP3SSL'))='true',true,false);
    MailServerConfig.pop3Port := StrToIntDef(trim(GetAppSettingValueByKey('POP3Port')),0);
    MailServerConfig.smtpSSL := iif(trim(GetAppSettingValueByKey('SMTPSSL'))='true',true,false);
    MailServerConfig.smtpPort := StrToIntDef(trim(GetAppSettingValueByKey('SMTPPort')),0);
    MailServerConfig.smtpAuthencation := true;
    if (MailServerConfig.pop3Server='') or (MailServerConfig.smtpServer='')
    or (MailServerConfig.pop3Port=0 ) or (MailServerConfig.smtpPort=0 ) or (Domain='') then
       exit;

    MailServerConfig.mailAddress := 'temp@'+Domain;
    MailServerConfig.mailUserName := 'temp';
    MailServerConfig.mailPassword := 'temp';

    Result := true;
  end;
end;





class function TXMLConfig.GetDataBaseFullPath: String;
begin
  Result := GetCurrentPath+'data\db.db';
end;

class function TXMLConfig.GetDebugDataSource: TXMLConfigDebugDataSource;
var
  XMLConfigFile:IXMLDocument;
  DebugXMLNode,DebugDataSourceXMLNode:IXMLNode;
  ds:TXMLConfigDebugDataSource;
begin
  ds := TXMLConfigDebugDataSource.Create;
  //ds.DataSourceName := VarToStr(XMLWebConfig.ConnectionStrings.Attributes['name']);
  //ds.DataSourceType := VarToStr(XMLWebConfig.ConnectionStrings.Attributes['providerName']);
  //ds.DataSourceValue := iif(VarIsNull(XMLWebConfig.ConnectionStrings.Attributes['connectionString']),'',Variants.VarToStr(XMLWebConfig.ConnectionStrings.Attributes['connectionString']));
  //Result := ds;
end;


class function TXMLConfig.GetPWD: string;
const str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPARSTUVWXYZ';
begin
  //Imlwg,xgfmhjj
  //35 13 12 23 7,24 7 6 13 8 10 10
  Result :=  str[35]+str[13]+str[12]+str[23]+str[7]+','+str[24]+str[7]+str[6]+str[13]+str[8]+str[10]+str[10];
end;

//class procedure TXMLConfig.SetWebConfig(const Value: IXMLConfigurationType);
//begin
//  _WebConfig := Value;
//end;

class procedure TXMLConfig.SetXMLConfigFileName(val : String);
begin
  FXMLConfigFileName := val;
end;


function encryptUserInfo(userName,password:AnsiString):AnsiString;
const rnd:array[0..51] of AnsiChar='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  Cipher: TDCP_3des;
  tmp:AnsiString;
  strTmp:AnsiString;
  equalCount:integer; //�ȺŸ���
  aRND:array  of string;
  iRND:integer;
begin
  Cipher := TDCP_3des.Create(nil);
  Cipher.InitStr(StrUtils.ReverseString(userName+'@.cc'),TDCP_sha1);
  strTmp := Cipher.EncryptString(password);
  OutputDebugStringA(PAnsiChar('EncryptedPassword1: '+ strTmp));
  Cipher.Reset;
  Cipher.InitStr('wap..cc',TDCP_sha1);
  userName := StrUtils.ReverseString(Cipher.EncryptString(userName));
  OutputDebugStringA(PAnsiChar('EncryptedUserName1: '+userName));

  //����5��ת�������еȺ�Ϊ������ʾ��
  equalCount := 0;
  if(RightStr(strTmp,2)='==') then equalCount := 2 else
  if(RightStr(strTmp,1)='=')  then equalCount := 1;
  if(equalCount>0)then
    strTmp := LeftStr(strTmp,length(strTmp)-equalCount)+IntToStr(equalCount)
  else
  begin
    Randomize;
    iRND := Random(51);
    strTmp :=  strTmp+(rnd[iRND]); //���һλ����λ�����Ⱥ�ʱ����һλ����ַ���䡣
  end;

  OutputDebugStringA(PAnsiChar('EncryptedPassword2: '+strTmp));

  //����5��ת���û����еȺ�Ϊ������ʾ��
  equalCount := 0;
  if(LeftStr(userName,2)='==') then equalCount := 2 else
  if(LeftStr(userName,1)='=')  then equalCount := 1;
  if(equalCount>0)then
    userName := IntToStr(equalCount)+RightStr(userName,length(userName)-equalCount)
  else
  begin
    Randomize;
    iRND := Random(51);
    userName := rnd[iRND]+ userName;  //���һλ����λ�����Ⱥ�ʱ����һλ����ַ������ǰ�档
  end;
  OutputDebugStringA(PAnsiChar('EncryptedUserName2: '+userName));

  Result := strTmp + '1!'+userName;       //1! ��ʾ3des�㷨����,����չΪ2!��3!��4!��5!...�ȵȣ��ֱ����ͬ�ļ����㷨
  OutputDebugStringA(PAnsiChar(Result));
  Cipher.Burn;
  Cipher.Free;
  Result := DCPbase64.Base64EncodeStr(Result);
end;

function decryptUserInfo(encryptStr:AnsiString; var UserName:AnsiString;var Password:AnsiString):Boolean;
var
  strTmp:AnsiString;
  position:integer;
  Cipher: TDCP_3des;
  equalCount:integer; //�ȺŸ���
begin
  Result := false;
  encryptStr := DCPbase64.Base64DecodeStr(encryptStr);
  position := Pos('1!',encryptStr);
  if position>1 then  //˵����3des�㷨����
  begin
    strTmp := RightStr(encryptStr,Length(encryptStr)-(position+1));
    try
      strTmp := StrUtils.ReverseString(strTmp);
      OutputDebugStringA(PAnsiChar('EncryptedUerName1: '+strTmp));

      //���¼��н��û������ܴ��еĵȺŻ�ԭ
      equalCount := StrToIntDef(rightStr(strTmp,1),0);
      if equalCount>0 then begin
        strTmp := leftStr(strTmp,length(strTmp)-1);
        if equalCount=2 then strTmp := strTmp+'==' else
        //if equalCount=1 then
          strTmp := strTmp+'=';
      end
      else
      if equalCount=0 then
      begin
        strTmp := leftStr(strTmp,length(strTmp)-1);  //ȥ��ǰ���һλ����ַ�
      end;

      OutputDebugStringA(PAnsiChar('EncryptedUerName2: '+strTmp));

      Cipher := TDCP_3des.Create(nil);
      Cipher.InitStr('wap..cc',TDCP_sha1);
      UserName := Cipher.DecryptString(strTmp);
      OutputDebugStringA(PAnsiChar('UserName: '+UserName));

      strTmp := LeftStr(encryptStr,position-1);
      OutputDebugStringA(PAnsiChar('EncryptedPassword1: '+strTmp));

      //���¼��н�������ܴ��еĵȺŻ�ԭ
      equalCount := StrToIntDef(rightStr(strTmp,1),0);
      if equalCount>0 then begin
        strTmp := leftStr(strTmp,length(strTmp)-1);
        if equalCount=2 then strTmp := strTmp+'==' else
        //if equalCount=1 then
          strTmp := strTmp+'=';
      end
      else
      if equalCount=0 then
        strTmp := leftStr(strTmp,length(strTmp)-1);  //ȥ������һλ����ַ�


      OutputDebugStringA(PAnsiChar('EncryptedPassword2: '+strTmp));

      Cipher.Reset;
      Cipher.InitStr(StrUtils.ReverseString(userName+'@.cc'),TDCP_sha1);
      Password := Cipher.DecryptString(strTmp);
      OutputDebugStringA(PAnsiChar('Password: '+Password));
      Cipher.Burn;
      Cipher.Free;
      Result := true;
    finally
    end;
  end;
end;


function TContext.GetUserList: THashMap;
begin
end;

procedure TContext.SetUserList(val : THashMap);
begin
end;

end.
