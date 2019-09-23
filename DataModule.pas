unit DataModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, DB,Portal_UserService,Portlet_Blogs_BlogsEntryService,

  {
  DBAccess,
  MyAccess,
  MemDS,
  DAScript,
  MyScript,
  }
  config,idGlobal,IdSSLOpenSSL,IdPOP3,serialization,WebDisp,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdAntiFreezeBase, IdAntiFreeze,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  SOAPHTTPClient, ADODB,StrUtils,
  //WebSnapScriptObject,
  xmldom, XMLIntf, msxmldom, XMLDoc,
   OleServer, MSXML2_TLB,
    DBClient, SimpleDS, Provider,

  objAuto,TypInfo, WebSnapScriptObject,
  Encryption_DB,
  Domain.UserMailInBox,
  DAO.UserMailInBox,
  Common
  // WebSnapScriptObject
  ;

type
  TWebDataModuleShare = class(TWebDataModule)
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    ADOCommand1: TADOCommand;
    ScriptObject: TScriptObject;


    SimpleDataSet1: TSimpleDataSet;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;

    DataSetProvider1: TDataSetProvider;
    procedure WebDataModuleDestroy(Sender: TObject);
    procedure WebDataModuleCreate(Sender: TObject);
    function XMLTransformProvider2DataRequest(Sender: TObject;
      Input: OleVariant): OleVariant;
  public
    { Public declarations }
    function registerUser(emailAddress,password:string):integer;
    function login(emailAddress,password:string; var user:TUser):boolean; overload;
    function login(userId:integer; password:string;var user:TUser ):boolean; overload;
    function addMailBox(userId:integer; MCFG:TMailConfig):boolean;

    procedure LoginMailServer(user:TUser;mailConfig: TMailConfig;isFirstLogin:boolean=true);

    function ReadGuestMailServerConfigADO(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;
    function ReadGuestMailServerConfigSQLite(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;
    function ReadGuestMailServerConfig(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;

    function UpdateGuestMailServerConfig(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;
    function InsertGuestMailServerConfigADO(MailBoxAddress:string; MailServerConfig:TMailConfig):boolean;
    function InsertGuestMailServerConfigSQLite(MailBoxAddress:string; MailServerConfig:TMailConfig):boolean;
    function InsertGuestMailServerConfig(MailBoxAddress:string; MailServerConfig:TMailConfig):boolean;

    function InsertGuestUserMailInBox(UserMailInBoxRec:TUserMailInBoxRec):boolean;
  end;

  function WebDataModuleShare: TWebDataModuleShare;

implementation

{$R *.dfm}

uses WebReq, WebCntxt, WebFact, Variants, Common.Debug;

function WebDataModuleShare: TWebDataModuleShare;
begin
  Result := TWebDataModuleShare(WebContext.FindModuleClass(TWebDataModuleShare));
end;

procedure TWebDataModuleShare.LoginMailServer(user:TUser; mailConfig: TMailConfig;isFirstLogin:boolean=true);
var
  userPOP3:TIdPOP3;
  sslIOHandler:TIdSSLIOHandlerSocketOpenSSL;
//  currentUserSession :TCurrentUserSession;
begin
  userPOP3 := TIdPOP3.Create(self);
  userPOP3.Host := mailConfig.pop3Server;
  userPOP3.Port := mailConfig.pop3Port;
  userPOP3.Username := mailConfig.mailUserName;
  userPOP3.Password := mailConfig.mailPassword;
  if mailConfig.pop3SSL then
  begin
    sslIOHandler:= TIdSSLIOHandlerSocketOpenSSL.Create(userPOP3);
    userPOP3.IOHandler := sslIOHandler;
    userPOP3.UseTLS := utUseImplicitTLS;
    userPOP3.Port := mailConfig.pop3Port;
    sslIOHandler.SSLOptions.Method := sslvTLSv1;
  end;
  try
    userPOP3.ConnectTimeout := 1500;
    userPOP3.Connect;
  finally
  end;

  if userPOP3.Connected then
  begin
//    currentUserSession := TCurrentUserSession.create(self);
//    currentUserSession.userName := user.userName;
//    currentUserSession.password := user.password;
//    currentUserSession.userId := user.userId;
//    currentUserSession.userMail := user.userMail;
    user.currentSelectMail := mailConfig.mailAddress;
    Session.Values[TConfig.currentUserSession] := ComponentToStr(user);
//    User := TUser.Create(nil);
//    User.userName := userPOP3.UserName;
//    User.password := userPOP3.Password;
//    POP3List.PutValue(User,userPOP3);
  end else
  begin
    userPOP3.Disconnect;
    if sslIOHandler<>nil then
       sslIOHandler.FreeOnRelease;
    userPOP3.FreeOnRelease;
    SafeRedirect(Response,'main?i=-1');
  end;
end;

//没有直接兼容 Delphi2009 版的 MySQL Data Access Components 控件，所以暂时注释掉。
{$REGION MYSQL }
{
function TWebDataModuleShare.registerUser(emailAddress,password: string):integer;
var
  cmd:TMyCommand;
  query:TMyQuery;
  max_userId,          //新用户的userID,=user_用户表中最大userId+3
  contactId,           //新用户的属性索引ID,=max_userId+1
  groupId,             //新用户自己所创建的组的ID,=contactId+1 = max_userId+2
  resourceId,          //新用户的在resource_表中的resourceId.
  permissionId:integer;//新用户的在Permission_表中的permissionId,为自然增长字段，每次自动加1.
const
  greeting:string = 'Welcome!';//用户欢迎词.
begin
  query := TMyQuery.Create(nil);
  query.Connection := MyConnectionShare;

  //查找该邮箱是否已经注册过
  query.SQL.Text := 'select userId from user_ where emailAddress=:emailAddress';
  query.Params.ParamByName('emailAddress').AsString := emailAddress;
  query.Prepare;
  query.Open;
  if query.RecordCount>0 then
  begin
    Result := -1;
    query.Close;
    query.Free;
  end
  else
  begin

    //计算新用户的userId
    query.Close;
    query.SQL.Text := 'select max(userid)+3 as max_userid from user_';
    query.Prepare;
    query.Open;
    max_userid := query.FieldValues['max_userid'];
    contactId  := max_userId + 1;
    groupId    := max_userId + 2;
    query.Close;

    //计算新用户的ResourceId
    query.SQL.Text := 'select max(resourceId)+1 as resourceId from resource_';
    query.Prepare;
    query.Open;
    resourceId := query.FieldValues['resourceId'];
    query.Close;


    //计算新用户的PermissionId,=Max(permission_.permissionId)+1
    query.SQL.Text := 'select max(permissionId)+1 as permissionId from permission_';
    query.Prepare;
    query.Open;
    permissionId := query.FieldValues['permissionId'];
    query.Close; 
    query.Free;
    
    cmd := TMyCommand.Create(nil);
    cmd.Connection := MyConnectionShare;

    //在user_表中添加一条新用户记录
    cmd.SQL.Text := MyScriptShare.SQL[0];
    cmd.Params.ParamByName('max_userId').Value := max_userid;
    cmd.Params.ParamByName('contactId').Value := contactId;
    cmd.Params.ParamByName('password').Value := password;
    cmd.Params.ParamByName('emailAddress').Value := emailAddress;
    cmd.Params.ParamByName('greeting').Value := greeting;
    cmd.Prepare;
    cmd.Execute;

    //在Resource_表中添加一条新用户的Resource记录
    cmd.SQL.Text := MyScriptShare.SQL[1];
    cmd.Params.ParamByName('resourceId').Value := resourceId;
    cmd.Params.ParamByName('primKey').Value := max_userId;
    cmd.Prepare;
    cmd.Execute;

    //在Permission_表中添加4条新用户的权限记录
    cmd.SQL.Text := MyScriptShare.SQL[2];
    cmd.Params.ParamByName('permissionId').Value := permissionId;
    cmd.Params.ParamByName('actionId').Value := 'DELETE';
    cmd.Params.ParamByName('resourceId').Value := resourceId;
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('permissionId').Value := permissionId+1;
    cmd.Params.ParamByName('actionId').Value := 'IMPERSONATE';
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('permissionId').Value := permissionId+2;
    cmd.Params.ParamByName('actionId').Value := 'PERMISSIONS';
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('permissionId').Value := permissionId+3;
    cmd.Params.ParamByName('actionId').Value := 'UPDATE';
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('permissionId').Value := permissionId+4;
    cmd.Params.ParamByName('actionId').Value := 'VIEW';
    cmd.Prepare;
    cmd.Execute;


    //在users_permissions表中添加上面的权限记录
    cmd.SQL.Text := MyScriptShare.SQL[3];
    cmd.Params.ParamByName('max_userId').Value := max_userId;
    cmd.Params.ParamByName('permissionId').Value := permissionId;
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('max_userId').Value := max_userId;
    cmd.Params.ParamByName('permissionId').Value := permissionId+1;
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('max_userId').Value := max_userId;
    cmd.Params.ParamByName('permissionId').Value := permissionId+2;
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('max_userId').Value := max_userId;
    cmd.Params.ParamByName('permissionId').Value := permissionId+3;
    cmd.Prepare;
    cmd.Execute;

    cmd.Params.ParamByName('max_userId').Value := max_userId;
    cmd.Params.ParamByName('permissionId').Value := permissionId+4;
    cmd.Prepare;
    cmd.Execute;

    //在contact_表中添加一条新用户的属性信息记录
    cmd.SQL.Text := MyScriptShare.SQL[4];
    cmd.Params.ParamByName('max_userId').Value := max_userid;
    cmd.Params.ParamByName('contactId').Value := contactId;
    cmd.Params.ParamByName('firstName').Value := max_userid;
    cmd.Params.ParamByName('middleName').Value := '';
    cmd.Params.ParamByName('lastName').Value := '';
    cmd.Prepare;
    cmd.Execute;

    //在group_表中添加一条新用户自己所创建的组的记录
    cmd.SQL.Text := MyScriptShare.SQL[5];
    cmd.Params.ParamByName('max_userid').Value := max_userid;
    cmd.Params.ParamByName('groupId').Value := groupId;
    cmd.Prepare;
    cmd.Execute;

    //在layoutSet表中添加第一条新用户初始页面布局记录
    cmd.SQL.Text := MyScriptShare.SQL[6];
    cmd.Params.ParamByName('groupId_Add_1').Value := groupId+1;
    cmd.Params.ParamByName('groupId').Value := groupId;
    cmd.Params.ParamByName('themeId').Value := '_WAR_theme';
    cmd.Prepare;
    cmd.Execute;

    //在layoutSet表中添加第一条新用户初始页面布局记录
    cmd.SQL.Text := MyScriptShare.SQL[7];
    cmd.Params.ParamByName('groupId_Add_2').Value := groupId+2;
    cmd.Params.ParamByName('groupId').Value := groupId;
    cmd.Params.ParamByName('themeId').Value := '_WAR_theme';
    cmd.Prepare;
    cmd.Execute;  

    //在users_roles表中添加一条新用户的所属角色记录
    cmd.SQL.Text := MyScriptShare.SQL[8];
    cmd.Params.ParamByName('max_userId').Value := max_userid;
    cmd.Params.ParamByName('roleId').Value := 13;  //新用户初始角色默认值。
    cmd.Prepare;
    cmd.Execute;


    //在users_usergroups表中添加一条新用户所属组的记录
    cmd.SQL.Text := MyScriptShare.SQL[9];
    cmd.Params.ParamByName('max_userId').Value := max_userid;
    cmd.Prepare;
    cmd.Execute;
    cmd.Free;

    Result := max_userId;  
  end;
end;

function TWebDataModuleShare.login(emailAddress,password: string; var user:TUser):boolean;
var
  query:TMyQuery;
  i:integer;
begin
  query := TMyQuery.Create(nil);
  query.Connection := MyConnectionShare;

  query.SQL.Text := 'select b.*,a.screenName from user_ a,emailBox b where (a.emailAddress=:emailAddress and a.password_=:password) and (a.userId=b.userId) order by isDefault desc'; //order by isDefault desc 可以让默认的邮箱总是排在第一条记录,客户端只要调用第一条记录既是默认的邮箱。
  query.Params.ParamByName('emailAddress').Value := emailAddress;
  query.Params.ParamByName('password').Value := password;
  query.Prepare;
  query.Open;
  if query.RecordCount>0 then
  begin
    Result := True;
    user.userMail := emailAddress;
    for i:=0 to query.RecordCount-1 do
    begin
      user.mailConfigArray[i].pop3Server := query.FieldByName('pop3Server').Value;
      user.mailConfigArray[i].smtpServer := query.FieldByName('smtpServer').Value;
      user.mailConfigArray[i].pop3SSL := iif(query.FieldByName('pop3SecurityAuthencation').Value=1,true,false);
      user.mailConfigArray[i].smtpSSL := iif(query.FieldByName('smtpSecurityAuthencation').Value=1,true,false);

      user.mailConfigArray[i].pop3Port := iif(user.mailConfigArray[i].pop3SSL,Integer(query.FieldByName('pop3SecurityAuthencationPort').Value),Integer(query.FieldByName('pop3Port').Value));
      user.mailConfigArray[i].smtpPort := iif(user.mailConfigArray[i].smtpSSL,Integer(query.FieldByName('smtpSecurityAuthencationPort').Value),Integer(query.FieldByName('smtpPort').Value));

      user.mailConfigArray[i].smtpAuthencation := iif(query.FieldByName('smtpAuthencation').Value=1,true,false);

      user.mailConfigArray[i].mailAddress := emailAddress;
      user.mailConfigArray[i].mailUserName := query.FieldByName('mailUserName').Value;
      user.mailConfigArray[i].mailPassword := query.FieldByName('mailPassword').Value;
      user.mailConfigArray[i].isDefault := iif(query.FieldByName('isDefault').Value=1,true,false);

      if i=0 then
      begin
        user.userName := query.FieldByName('screenName').Value;
        user.userId := query.FieldByName('userId').Value;
        user.password := password;
      end;
      
      query.Next;
    end;
  end
  else
    Result := false;
    
  query.Close;
  query.Free;
end;

function TWebDataModuleShare.login(userId: integer; password: string; var user:TUser):boolean;
var
  query:TMyQuery;
  i:integer;
begin
  query := TMyQuery.Create(nil);
  query.Connection := MyConnectionShare;

  query.SQL.Text := 'select b.*,a.screenName,a.emailAddress from user_ a,emailBox b where (a.userId=:userId and a.password_=:password) and (a.userId=b.userId) order by isDefault desc'; //order by isDefault desc 可以让默认的邮箱总是排在第一条记录,客户端只要调用第一条记录既是默认的邮箱。
  query.Params.ParamByName('userId').Value := userId;
  query.Params.ParamByName('password').Value := password;
  query.Prepare;
  query.Open;
  if query.RecordCount>0 then
  begin
    Result := True;
    user.userId := userId;
    for i:=0 to query.RecordCount-1 do
    begin
      user.mailConfigArray[i].pop3Server := query.FieldByName('pop3Server').Value;
      user.mailConfigArray[i].smtpServer := query.FieldByName('smtpServer').Value;
      user.mailConfigArray[i].pop3SSL := iif(query.FieldByName('pop3SecurityAuthencation').Value=1,true,false);
      user.mailConfigArray[i].smtpSSL := iif(query.FieldByName('smtpSecurityAuthencation').Value=1,true,false);

      user.mailConfigArray[i].pop3Port := iif(user.mailConfigArray[i].pop3SSL,Integer(query.FieldByName('pop3SecurityAuthencationPort').Value),Integer(query.FieldByName('pop3Port').Value));
      user.mailConfigArray[i].smtpPort := iif(user.mailConfigArray[i].smtpSSL,Integer(query.FieldByName('smtpSecurityAuthencationPort').Value),Integer(query.FieldByName('smtpPort').Value));

      user.mailConfigArray[i].smtpAuthencation := iif(query.FieldByName('smtpAuthencation').Value=1,true,false);
      
      user.mailConfigArray[i].mailAddress := query.FieldByName('emailBox').Value;
      user.mailConfigArray[i].mailUserName := query.FieldByName('mailUserName').Value;
      user.mailConfigArray[i].mailPassword := query.FieldByName('mailPassword').Value;

      user.mailConfigArray[i].isDefault := iif(query.FieldByName('isDefault').Value=1,true,false);

      if i=0 then
      begin
        user.userName := query.FieldByName('screenName').Value;
        user.userMail := query.FieldByName('emailAddress').Value;
        user.password := password;
      end;

      query.Next;
    end;
  end
  else
    Result := false;
    
  query.Close;
  query.Free;
end;

function TWebDataModuleShare.addMailBox(userId: integer;
  MCFG: TMailConfig): boolean;
var
  cmd:TMyCommand;
begin
  cmd := TMyCommand.Create(nil);
  cmd.Connection := MyConnectionShare;

  //在emailbox表中添加一条用户的新邮箱的记录
  //INSERT INTO emailbox(`userId`,`emailBox`,`mailUserName`,`mailPassword`,`pop3Server`,`smtpServer`,`pop3Port`,`smtpPort`,`smtpAuthencation`,`pop3SecurityAuthencation`,`smtpSecurityAuthencation`,`pop3SecurityAuthencationPort`,`smtpSecurityAuthencationPort`,createTime) VALUES (:userId,:emailAddress,:userName,:password,:POP3Server,:SMTPServer,:pop3Port,:smtpPort,:smtpAuthencation,:pop3SecurityAuthencation,:smtpSecurityAuthencation,:pop3SecurityAuthencationPort,:smtpSecurityAuthencationPort,now())
  cmd.SQL.Text := MyScriptShare.SQL[10];
  cmd.Params.ParamByName('userId').Value := userId;
  cmd.Params.ParamByName('emailAddress').Value := MCFG.mailAddress;
  cmd.Params.ParamByName('mailUserName').Value := MCFG.mailUserName;
  cmd.Params.ParamByName('mailPassword').Value := MCFG.mailPassword;
  cmd.Params.ParamByName('pop3Server').Value := MCFG.pop3Server;
  cmd.Params.ParamByName('smtpServer').Value := MCFG.smtpServer;

  cmd.Params.ParamByName('pop3Port').Value := MCFG.pop3Port;
  cmd.Params.ParamByName('smtpPort').Value := MCFG.smtpPort;

  cmd.Params.ParamByName('smtpAuthencation').Value := iif(MCFG.smtpAuthencation,1,0);

  cmd.Params.ParamByName('pop3SecurityAuthencation').Value := iif(MCFG.pop3SSL,1,0);
  cmd.Params.ParamByName('smtpSecurityAuthencation').Value := iif(MCFG.smtpSSL,1,0);
  cmd.Params.ParamByName('pop3SecurityAuthencationPort').Value := iif(MCFG.pop3SSL,MCFG.pop3Port,995);
  cmd.Params.ParamByName('smtpSecurityAuthencationPort').Value := iif(MCFG.smtpSSL,MCFG.smtpPort,25);
  cmd.Params.ParamByName('isDefault').Value := iif(MCFG.isDefault,1,0);

  cmd.Prepare;
  cmd.Execute;

  if cmd.RowsAffected>0 then
  begin
    if MCFG.isDefault then //当设置该邮箱为默认邮箱时，更新该用户其它默认邮箱为非默认邮箱。同一用户只能有一个邮箱为默认邮箱。
    begin
      cmd.SQL.Text := 'update emailbox set isDefault=0 where userId='+ IntToStr(userId) + ' and isDefault=1 and emailbox<>'''+MCFG.mailAddress+'''';
      cmd.Prepare;
      cmd.Execute;
    end;
    Result := true
  end
  else
    Result := false;

  cmd.Free;
end;
}
{$ENDREGION}


function TWebDataModuleShare.registerUser(emailAddress,password:string):integer;
var
  uss:UserServiceSoap;
  us:UserSoap;
  orgnizationIds:ArrayOf_xsd_long;
  RIO: THTTPRIO;
begin
  result:=-1;
  RIO := THTTPRIO.Create(nil);
  RIO.HTTPWebNode.UserName := '2';
  RIO.HTTPWebNode.Password := 'lwgboy.';
  uss := GetUserServiceSoap(false,'',RIO);
  if (uss<>nil) then
  begin
    emailAddress := trim(emailAddress);
    if(emailAddress<>'')then begin
      setLength(orgnizationIds,1);
      orgnizationIds[0] := 34930;  //这个是用于测试组织的ID.
      us := uss.addUser(1,false,password,password,true,'sn001',emailAddress,'','Friend','@','.CC',0,0,true,1,1,1980,'',orgnizationIds,true);
      if (us<>nil) then
        result := us.userId
    end;
  end;
  //RIO.Free;
end;
function TWebDataModuleShare.login(emailAddress,password:string; var user:TUser):boolean;
begin
  result := false;
end;
function TWebDataModuleShare.login(userId:integer; password:string;var user:TUser ):boolean;
begin
  Result := true;
end;
function TWebDataModuleShare.addMailBox(userId:integer; MCFG:TMailConfig):boolean;
begin
  Result := false;
end;

function TWebDataModuleShare.ReadGuestMailServerConfig(MailBoxAddress: string; var MailServerConfig: TMailConfig): boolean;
begin
  Result := ReadGuestMailServerConfigSQLite(MailBoxAddress,MailServerConfig);
end;

function TWebDataModuleShare.ReadGuestMailServerConfigADO(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;
var
  QueryResult:integer;
begin
  Result := false;
  QueryResult := -1;
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Text := 'select * from My_MailBoxConfig where MailBoxAddress=:MailBoxAddress limit 0,1';
  ADOQuery1.Parameters[0].Value := MailBoxAddress;
  ADOQuery1.Prepared := true;
  try
	  ADOQuery1.Open;
  except on E:Exception do
		begin
    	ADOQuery1.Connection.Close;
      ADOQuery1.Connection.Connected := false;
      ADOQuery1.Close;
    	ADOQuery1.Connection.Connected := true;
      ADOQuery1.Open;
    end;
  end;
  QueryResult := ADOQuery1.ExecSQL;
  if(QueryResult>0) then
  begin
    if (mailServerConfig<>nil) then
    begin
      ADOquery1.Next;
      MailServerConfig.pop3Server := ADOquery1.FieldByName('POP3Server').Value;
      MailServerConfig.smtpServer := ADOquery1.FieldValues['SMTPServer'];
      MailServerConfig.pop3Port := ADOquery1.FieldValues['POP3Port'];
      MailServerConfig.smtpPort := ADOquery1.FieldValues['SMTPPort'];
      MailServerConfig.smtpAuthencation := ADOquery1.FieldValues['SMTPAuthencation'];
      MailServerConfig.pop3SSL := ADOquery1.FieldValues['POP3SSL'];
      MailServerConfig.smtpSSL := ADOquery1.FieldValues['SMTPSSL'];
      MailServerConfig.mailAddress := ADOQuery1.FieldValues['MailBoxAddress'];
      MailServerConfig.mailUserName := ADOquery1.FieldValues['mailUserName'];
      MailServerConfig.mailPassword := ADOquery1.FieldValues['mailPassword'];
    end;
    Result := true;
  end
  else
  begin
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Text := 'select * from My_MailBoxConfig where MailBoxAddress like :MailBoxAddress limit 0,1';
    ADOQuery1.Parameters[0].Value := '%'+RightStr(MailBoxAddress,Length(MailBoxAddress)-pos('@',MailBoxAddress)+1);
    ADOQuery1.Open;
    QueryResult := ADOQuery1.ExecSQL;
    if(QueryResult>0) then
    begin
      ADOQuery1.Next;
      if (mailServerConfig<>nil) then
      begin
        MailServerConfig.pop3Server := ADOquery1.FieldValues['POP3Server'];
        MailServerConfig.smtpServer := ADOquery1.FieldValues['SMTPServer'];
        MailServerConfig.pop3Port := ADOquery1.FieldValues['POP3Port'];
        MailServerConfig.smtpPort := ADOquery1.FieldValues['SMTPPort'];
        MailServerConfig.smtpAuthencation := ADOquery1.FieldValues['SMTPAuthencation'];
        MailServerConfig.pop3SSL := ADOquery1.FieldValues['POP3SSL'];
        MailServerConfig.smtpSSL := ADOquery1.FieldValues['SMTPSSL'];
        MailServerConfig.mailAddress := MailBoxAddress;
        MailServerConfig.mailUserName := ADOquery1.FieldValues['mailUserName'];
        MailServerConfig.mailPassword := ADOquery1.FieldValues['mailPassword'];
      end;
      Result := true;
    end;
  end;
  ADOQuery1.Close;
end;

function TWebDataModuleShare.ReadGuestMailServerConfigSQLite(MailBoxAddress: string; var MailServerConfig: TMailConfig): boolean;
var
  MailBoxConfigDatabase:TMailBoxConfigDatabase;
  MailBoxConfig : TMailBoxConfigRec;
begin
  Result := false;
  MailBoxConfigDatabase := Encryption_DB.TMailBoxConfigDatabase.Create(self);
  MailBoxConfigDatabase.DatabaseName := TXMLConfig.DataBaseFullPath;
  MailBoxConfigDatabase.Password:= TXMLConfig.GetPWD;
  MailBoxConfig := MailBoxConfigDatabase.GetMailBoxPublicConfig(MailBoxAddress);
  if(MailBoxConfig<>nil) then
  begin
      MailServerConfig.pop3Server := MailBoxConfig.POP3Server;
      MailServerConfig.smtpServer := MailBoxConfig.SMTPServer;
      MailServerConfig.pop3Port := MailBoxConfig.POP3Port;
      MailServerConfig.smtpPort := MailBoxConfig.SMTPPort;
      MailServerConfig.smtpAuthencation := true;
      MailServerConfig.pop3SSL := MailBoxConfig.POP3SSL;
      MailServerConfig.smtpSSL := MailBoxConfig.SMTPSSL;
      MailServerConfig.mailAddress := MailBoxConfig.UpdateMail;
      MailServerConfig.mailUserName := MailBoxConfig.POP3UserName;
      MailServerConfig.mailPassword := MailBoxConfig.POP3Password;
      Result := true;
  end
  else
  begin
    MailBoxConfig := MailBoxConfigDatabase.GetMailBoxPublicConfig(MailBoxAddress,'like');
    if(MailBoxConfig<>nil) then
    begin
      MailServerConfig.pop3Server := MailBoxConfig.POP3Server;
      MailServerConfig.smtpServer := MailBoxConfig.SMTPServer;
      MailServerConfig.pop3Port := MailBoxConfig.POP3Port;
      MailServerConfig.smtpPort := MailBoxConfig.SMTPPort;
      MailServerConfig.smtpAuthencation := true;
      MailServerConfig.pop3SSL := MailBoxConfig.POP3SSL;
      MailServerConfig.smtpSSL := MailBoxConfig.SMTPSSL;
      MailServerConfig.mailAddress := MailBoxAddress;
      MailServerConfig.mailUserName := LeftStr(MailBoxAddress,pos('@',MailBoxAddress));
      //MailServerConfig.mailPassword := MailBoxConfig.POP3Password;
      Result := true;
    end;
  end;
  MailBoxConfig.Free;
  MailBoxConfigDatabase.Free;
end;

function TWebDataModuleShare.InsertGuestMailServerConfig(MailBoxAddress: string; MailServerConfig: TMailConfig): boolean;
begin
  InsertGuestMailServerConfigSQLite(MailBoxAddress,MailServerConfig);
end;

function TWebDataModuleShare.InsertGuestMailServerConfigADO(MailBoxAddress:string; MailServerConfig:TMailConfig):Boolean;
var
  QueryResult:integer;
begin
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Text := 'select * from My_MailBoxConfig where MailBoxAddress like :MailBoxAddress limit 0,1';
  ADOQuery1.Parameters[0].Value := MailBoxAddress;
  ADOQuery1.Prepared := true;
  try
	  ADOQuery1.Open;
  except on E:Exception do
		begin
    	ADOConnection1.Close;
    	ADOConnection1.Open;
      ADOQuery1.Open;
    end;
  end;
  QueryResult := ADOQuery1.ExecSQL;
  if(QueryResult>0) then
  begin
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Append('update My_MailBoxConfig set MailUserName=:MailUserName,MailPassword=:MailPassword,POP3Server=:POP3Server,SMTPServer=:SMTPServer,');
    ADOQuery1.SQL.Append('POP3Port=:POP3Port,SMTPPort=:SMTPPort,SMTPAuthencation=:SMTPAuthencation,POP3SSL=:POP3SSL,SMTPSSL=:SMTPSSL,LastAccessTime=:LastAccessTime,AccessCount=AccessCount+1 where MailBoxAddress=:MailBoxAddress');
    ADOQuery1.Parameters.ParamByName('MailBoxAddress').Value := MailBoxAddress;
    ADOQuery1.Parameters.ParamByName('POP3Server').Value := MailServerConfig.pop3Server;
    ADOQuery1.Parameters.ParamByName('SMTPServer').Value := MailServerConfig.smtpServer;
    ADOQuery1.Parameters.ParamByName('POP3Port').Value := MailServerConfig.pop3Port;
    ADOQuery1.Parameters.ParamByName('SMTPPort').Value := MailServerConfig.smtpPort;
    ADOQuery1.Parameters.ParamByName('SMTPAuthencation').Value := iif(MailServerConfig.smtpAuthencation,1,0);
    ADOQuery1.Parameters.ParamByName('POP3SSL').Value := iif(MailServerConfig.pop3SSL,1,0);
    ADOQuery1.Parameters.ParamByName('SMTPSSL').Value := iif(MailServerConfig.smtpSSL,1,0);
    ADOQuery1.Parameters.ParamByName('mailUserName').Value := MailServerConfig.mailUserName;
    ADOQuery1.Parameters.ParamByName('mailPassword').Value := MailServerConfig.mailPassword;
    ADOQuery1.Parameters.ParamByName('LastAccessTime').Value := FormatDateTime('yyyy-mm-dd hh:MM:ss',now);
    ADOQuery1.Prepared := true;
    QueryResult := ADOQuery1.ExecSQL;
    Result := iif(QueryResult>0,true,false);
    exit;
  end;
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  //ADOQuery1.SQL.Text := 'insert into My_MailBoxConfig(MailBoxAddress,MailUserName,MailPassword,POP3Server,SMTPServer,POP3Port,SMTPPort,SMTPAuthencation,POP3SSL,SMTPSSL) values(=:MailBoxAddress,=:MailUserName,=:MailPassword,=:POP3Server,=:SMTPServer,=:POP3Port,=:SMTPPort,=:SMTPAuthencation,=:POP3SSL,=:SMTPSSL)';
  ADOQuery1.SQL.Append('insert into My_MailBoxConfig(MailBoxAddress,MailUserName,MailPassword,POP3Server,SMTPServer,POP3Port,SMTPPort,SMTPAuthencation,POP3SSL,SMTPSSL,CreateTime,LastAccessTime,AccessCount) ');
  ADOQuery1.SQL.Append(' values(:MailBoxAddress,:MailUserName,:MailPassword,:POP3Server,:SMTPServer,:POP3Port,:SMTPPort,:SMTPAuthencation,:POP3SSL,:SMTPSSL,:CreateTime,:LastAccessTime,:AccessCount)');
  ADOQuery1.Parameters.ParamByName('MailBoxAddress').Value := MailServerConfig.mailAddress;
  ADOQuery1.Parameters.ParamByName('POP3Server').Value := MailServerConfig.pop3Server;
  ADOQuery1.Parameters.ParamByName('SMTPServer').Value := MailServerConfig.smtpServer;
  ADOQuery1.Parameters.ParamByName('POP3Port').Value := MailServerConfig.pop3Port;
  ADOQuery1.Parameters.ParamByName('SMTPPort').Value := MailServerConfig.smtpPort;
  ADOQuery1.Parameters.ParamByName('SMTPAuthencation').Value := iif(MailServerConfig.smtpAuthencation,1,0);
  ADOQuery1.Parameters.ParamByName('POP3SSL').Value := iif(MailServerConfig.pop3SSL,1,0);
  ADOQuery1.Parameters.ParamByName('SMTPSSL').Value := iif(MailServerConfig.smtpSSL,1,0);
  ADOQuery1.Parameters.ParamByName('mailUserName').Value := MailServerConfig.mailUserName;
  ADOQuery1.Parameters.ParamByName('mailPassword').Value := MailServerConfig.mailPassword;
  ADOQuery1.Parameters.ParamByName('CreateTime').Value := FormatDateTime('yyyy-mm-dd hh:MM:ss',now);
  ADOQuery1.Parameters.ParamByName('LastAccessTime').Value := FormatDateTime('yyyy-mm-dd hh:MM:ss',now);
  ADOQuery1.Parameters.ParamByName('AccessCount').Value := 0;
  ADOQuery1.Prepared := true;
  QueryResult := ADOQuery1.ExecSQL;
  Result := iif(QueryResult>0,true,false);
end;

function TWebDataModuleShare.InsertGuestMailServerConfigSQLite(MailBoxAddress:string; MailServerConfig:TMailConfig):Boolean;
var
  MailBoxConfigDatabase:TMailBoxConfigDatabase;
  MBCR : TMailBoxConfigRec;
begin
  Result := false;
  MailBoxConfigDatabase := Encryption_DB.TMailBoxConfigDatabase.Create(self);
  MailBoxConfigDatabase.DatabaseName := TXMLConfig.DataBaseFullPath;
  MailBoxConfigDatabase.Password := TXMLConfig.GetPWD;
  MBCR := TMailBoxConfigRec.Create;
  MBCR.UpdateMail := MailBoxAddress;
  MBCR.SMTPServer := MailServerConfig.smtpServer;
  MBCR.POP3Server := MailServerConfig.pop3Server;
  MBCR.SMTPSSL :=  MailServerConfig.smtpSSL;
  MBCR.POP3SSL :=  MailServerConfig.pop3SSL;
  MBCR.POP3UserName :=  MailServerConfig.mailUserName;

  if config.TXMLConfig.IsDebug(Request) then
    MBCR.POP3Password :=  MailServerConfig.mailPassword
  else
    MBCR.POP3Password := '';

//  MBCR.SMTPUserName :=
//  MBCR.SMTPPassword :=
  MBCR.POP3Port :=  MailServerConfig.pop3Port;
  MBCR.SMTPPort :=  MailServerConfig.smtpPort;
//  MBCR.POP3SSLPort :=
//  MBCR.SMTPSSLPort :=
  MBCR.InitializeProcess;
  Result := iif(MailBoxConfigDatabase.AddMailBoxConfig(MBCR)>0,true,false);
  MBCR.free;
  MailBoxConfigDatabase.free;
end;

function TWebDataModuleShare.InsertGuestUserMailInBox(UserMailInBoxRec: Domain.UserMailInBox.TUserMailInBoxRec): boolean;
var
  DAO:TUserMailInBoxDAO;
begin
  DAO := TUserMailInBoxDAO.Create(self);
  DAO.Add(UserMailInBoxRec);
  DAO.FreeOnRelease;
end;




function TWebDataModuleShare.UpdateGuestMailServerConfig(MailBoxAddress:string; var MailServerConfig:TMailConfig):boolean;
begin
  ADOQuery1.Close;
  //ADOQuery1.SQL.Text := 'update My_MailBoxConfig(set MailUserName=:MailUserName,MailPassword=:MailPassword,POP3Server=:POP3Server,SMTPServer=:SMTPServer,POP3Port=:POP3Port,SMTPPort:=SMTPPort,SMTPAuthencation:=SMTPAuthencation,POP3SSL=:POP3SSL,SMTPSSL=:SMTPSSL) where MailBoxAddress=:MailBoxAddress';
  ADOQuery1.Parameters.ParamByName('POP3Server').Value := MailServerConfig.pop3Server;
  ADOQuery1.Parameters.ParamByName('SMTPServer').Value := MailServerConfig.smtpServer;
  ADOQuery1.Parameters.ParamByName('POP3Port').Value := MailServerConfig.pop3Port;
  ADOQuery1.Parameters.ParamByName('SMTPPort').Value := MailServerConfig.smtpPort;
  ADOQuery1.Parameters.ParamByName('SMTPAuthencation').Value := MailServerConfig.smtpAuthencation;
  ADOQuery1.Parameters.ParamByName('POP3SSL').Value := MailServerConfig.pop3SSL;
  ADOQuery1.Parameters.ParamByName('SMTPSSL').Value := MailServerConfig.smtpSSL;
  ADOQuery1.Parameters.ParamByName('mailUserName').Value := MailServerConfig.mailUserName;
  ADOQuery1.Parameters.ParamByName('mailPassword').Value := MailServerConfig.mailPassword;
  ADOQuery1.Parameters.ParamByName('MailBoxAddress').Value := MailBoxAddress;
  ADOQuery1.Prepared := true;

  try
	  ADOQuery1.Open;
  except on E:Exception do
		begin
    	ADOConnection1.Close;
    	ADOConnection1.Open;
      ADOQuery1.Open;
    end;
  end;

  Result := iif(ADOQuery1.ExecSQL>=0,true,false);
end;




function Client2DataPacketObject(cds:TClientDataSet):integer;
//var
//  fd:TFieldDef;
//  dpoFD:IXMLFIELDType;
//  doc:TXMLDocument;
//  ss:TStringStream;
//  dp:IXMLDATAPACKETType;
//  cdsTmp:TClientDataSet;
begin
//  cdsTmp := TClientDataSet.Create(nil);
//  cds.Prior;
//  cdsTmp.Data :=  GetRecordOleVar(cds,[foRecord]);
//  //cdsTmp.Data := cds.Delta ;
//  ss := TStringStream.Create;
//  doc := TXMLDocument.Create(nil);
//  cds.SaveToStream(ss);
//  doc.LoadFromStream(ss);
//  dp := GetDATAPACKET(doc);

//  for fd in cds.FieldDefs.Items do
//  begin
//    dpoFD := dpo.METADATA.FIELDS.Add;
//    dpoFD.Attrname := fd.Name;
//    dpoFD.Fieldtype := fd.DataType
//  end;
  result := 0;
end;

function XML2DataPacketObject(XML:String;dbo:TObject):TObject;
var
  MIA:TMethodInfoArray;
  MI:PMethodInfoHeader;

  PPL:  PPropList;
  PTI:PTypeInfo;
  PTD:PTypeData;
  PPI:PPropInfo;
  str:string;
begin

  PTI := dbo.ClassInfo;
  PTD := GetTypeData(PTI);
  if PTD.PropCount<>0 then
  begin
    GetMem(PPL,sizeof(PPropInfo)* PTD.PropCount);
    TypInfo.GetPropList(PTI,PPL);
    for PPI in PPL^ do
      str :=PPI^.Name;
  end;
  FreeMem(PPL,sizeof(PPropInfo)*PTD.PropCount);

  MIA := objAuto.GetMethods(dbo.ClassType);
  for MI in MIA do
    str := MI^.Name;

  Result := nil;
end;

procedure TWebDataModuleShare.WebDataModuleCreate(Sender: TObject);
//var
//  XMLConfigDebugDataSource:TXMLConfigDebugDataSource;
//  row:IXMLRowType;
//  field:IXMLFieldType;
//  dataPacket:IXMLDataPacketType;
//  ss:TStringStream;
//  sb:TStringBuilder;
//  sl:TStringList;
//  cdsTemp:TClientDataSet;
//  count:integer;
begin
//  XMLConfigDebugDataSource := TXMLConfig.GetDebugDataSource;
//  if (XMLConfigDebugDataSource.DataSourceValue<>'') then
//  begin
//    ADOConnection1.ConnectionString := XMLConfigDebugDataSource.DataSourceValue;
//    ADOConnection1.Connected := true;
//  end
//  else
//    ADOConnection1.Close;
//  XMLConfigDebugDataSource.Free;
//
//  //ClientDataSet1.Active := false;
//  dataPacket := MailBoxConfig.NewDATAPACKET;
//  row := dataPacket.ROWDATA.Add;
//  sb := TStringBuilder.Create;
//  if(not ClientDataSet1.Active) then
//    ClientDataSet1.Active := true;
//  Client2DataPacketObject(ClientDataSet1);
//  cdsTemp := ClientDataSet1.CloneSource as TClientDataSet;
  {
  if(cdsTemp=nil)then
  cdsTemp := TClientDataSet.Create(self);
  cdsTemp.CloneCursor(ClientDataSet1,true);
  cdsTemp.EmptyDataSet;
  }
  //if(cdsTemp=nil)then
  //cdsTemp := TClientDataSet.Create(self);
  //ss := TStringStream.Create;
  //sl := TStringList.Create;
  //ClientDataSet1.FieldDefList.SaveToStream(ss);
  //cdsTemp.FieldList.SetText(PWideChar(ss.DataString));
  //count := cdsTemp.CopyFields(ClientDataSet1);
  //count := cdsTemp.CopyFields(DISQLite3UniDirQuery1);
  //cdsTemp.FieldDefs.Assign(ClientDataSet1.FieldDefs);

  //cdsTemp.EmptyDataSet;
  //cdsTemp.FieldList.Duplicates := ClientDataSet1.FieldList.Duplicates;
  //
  //cdsTemp.CloneCursor(ClientDataSet1,true);
  //ClientDataSet1.Close;
  //cdsTemp.EmptyDataSet;
  //
  //sl.Append((cdsTemp.XMLData));
  //sb.Append(ReplaceText(sl.Text, '<ROWDATA></ROWDATA></DATAPACKET>',''));
  //sb.Append(sl.ValueFromIndex[sl.Count-1]);

  //sl.Delete(sl.Count-1);
  //sb.Insert(0,sl.ValueFromIndex[sl.Count-1]);
  //sl.Delete(sl.Count-1);
  //sb.Append(dataPacket.METADATA.Text);

  //sb.Append(dataPacket.METADATA.CloneNode(true).Text);
  //st.Append('<METADATA><FIELDS><FIELD attrname="MailDomain" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPServer" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="POP3Server" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPPort" fieldtype="i8"/><FIELD attrname="POP3Port" fieldtype="i8"/><FIELD attrname="SMTPSSL" fieldtype="i8"/><FIELD attrname="POP3SSL" fieldtype="i8"/><FIELD attrname="SMTPSSLPort" fieldtype="i8"/><FIELD attrname="POP3SSLPort" fieldtype="i8"/><FIELD attrname="POP3UserName" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="POP3Password" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPUserName" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPPassword" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="UpdateMail" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="UpdateTime" fieldtype="r8"/></FIELDS><PARAMS/></METADATA>');
  //dataPacket.METADATA.FIELDS.Text := '<FIELD attrname="MailDomain" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPServer" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="POP3Server" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPPort" fieldtype="i8"/><FIELD attrname="POP3Port" fieldtype="i8"/><FIELD attrname="SMTPSSL" fieldtype="i8"/><FIELD attrname="POP3SSL" fieldtype="i8"/><FIELD attrname="SMTPSSLPort" fieldtype="i8"/><FIELD attrname="POP3SSLPort" fieldtype="i8"/><FIELD attrname="POP3UserName" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="POP3Password" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPUserName" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="SMTPPassword" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="UpdateMail" fieldtype="string.uni" WIDTH="40"/><FIELD attrname="UpdateTime" fieldtype="r8"/>' ;
  //dataPacket.METADATA.Text := ';

  //row.SMTPPort :=25 ;
  //row.POP3Port := 110;

  //ClientDataSet1.XMLData := dataPacket.XML;
  //ClientDataSet1.Append;
  //dataPacket.ROWDATA.Clear;
  //row := dataPacket.ROWDATA.Add;
  //row.MailDomain := 200;
  //row.SMTPPort := 300;
  //dataPacket.ROWDATA.Add;
  //XML2DataPacketObject('',TObject(dataPacket));
  //sl.Append(dataPacket.ROWDATA.XML);

  //sl.Add(sb.ToString());
  //sb.Append('</DATAPACKET>');

  //ss.LoadFromFile('F:\Projects\WAPMail..CC\Model\MailBoxConfig.xml');
  //cdsTemp.Close;
  //ClientDataSet1.Active := true;
  //ClientDataSet1.Append;
  //ss.Clear;
  //ClientDataSet1.SaveToFile(ss);
  //cdsTemp.LoadFromStream(ss);
  //cdsTemp.Delete;
  //ClientDataSet1.XMLData :=  sb.ToString();
  //ClientDataSet1.Delete;
  //ClientDataSet1.XMLData := sb.ToString();
  //XMLTransformClient1.GetDataAsXml(
  //datapacket.ReadOnly := false;
  //datapacket.OwnerDocument.XML.Text :=  ClientDataSet1.XMLData;
  //datapacket.Resync;
  //datapacket.ROWDATA.ROW[0].MailDomain := 155;
  //ClientDataSet1.XMLData := dataPacket.XML;


  //ClientDataSet1.LoadFromStream(ss);
  //ClientDataSet1Insert;
  //ClientDataSet1.LoadFromFile();
  //ClientDataSet1.Active:=true;
  //ClientDataSet1.CheckBrowseMode;
  //ClientDataSet1.Insert;
  //ClientDataSet1.Post;

  //CLientDataSet1.Reconcile()
  //ClientDataSet1.ApplyUpdates()
  //count := ClientDataSet1.ApplyUpdates(0);
end;

procedure TWebDataModuleShare.WebDataModuleDestroy(Sender: TObject);
begin
  if ScriptObject<>nil then
    ScriptObject.Free;


end;

function TWebDataModuleShare.XMLTransformProvider2DataRequest(Sender: TObject;
  Input: OleVariant): OleVariant;
begin

end;

{
function getGroupIdByScreenNameOrFriendly(screenNameOrFriendlyURL:string):long;
var
	sql:TStringBuilder;
	dt:TDataSet;
begin
	Result := -1;
	if(screenNameOrFriendlyURL<>'')then
	begin
		screenNameOrFriendlyURL := '/'+screenNameOrFriendlyURL;
    sql := TStringBuilder.Create;
		sql := 'select groupId from group_ where friendlyURL=:friednURL';
    sql := Format(sql,screenNameOrFriendlyURL);
		dt := Execute(sql);
		if(dt.Rows.Count>0)
			Result := IntToStr(dt.Rows[0][0].toString());
	end;
end;


function getPlidByGroupIdAndFriendlyURL(GroupId:long;friendlyURL:string):long;
var
	sql:string;
	dt:DataTable;
begin
	result := -1;
	if(GroupId>0)and (friendlyURL<>'')then
	begin
		sql = 'select plid from layout where GroupId=:groupId and fiendlyURL=:friendlyURL';
		sql = StringBuilder.Format(sql,GroupId,FrendlyURL);
		dt := Execute(sql);
		if(dt.Rows.Count>0)
			Result := IntToStr(dt.Rows[0][0].toString());
	end;
end;
}


initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebDataModuleFactory.Create(TWebDataModuleShare, crOnDemand, caCache)

);

end.

