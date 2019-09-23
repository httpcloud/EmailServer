unit addNewMailBoxModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,idGlobal,StrUtils;

type
  TAdd = class(TWebPageModule)
    PageProducer: TPageProducer;
    procedure WebPageModuleBeforeDispatchPage(Sender: TObject;
      const PageName: string; var Handled: Boolean);
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function Add: TAdd;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants, Config,DataModule,WebDisp,ActionModule,serialization,sendModule,
  loginModule;

function Add: TAdd;
begin
  Result := TAdd(WebContext.FindModuleClass(TAdd));
end;

procedure TAdd.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if TagString='ms' then ReplaceText := Session.SessionID+loginModule.AppendUserInfo;

end;

procedure TAdd.WebPageModuleBeforeDispatchPage(Sender: TObject;
  const PageName: string; var Handled: Boolean);
var
  mcfg:TMailConfig;
  user:TUser;
  userId:integer;
  emailAddress,pop3Server,smtpServer,userName,msg:string;
  pop3SSL,smtpSSL,pop3Port,smtpPort,isDefault:integer;
begin
  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
  //if (Request.ContentFields.Count<10) and (Request.QueryFields.Count<10) then
  //  exit;
  if(Session.Values[TConfig.currentUserSession]='') then
  begin
    DispatchPageName('main',Response,[]);
    handled := true;
    exit;
  end;
  if (Request.ContentFields.Count=6) and (Request.ContentFields.Values['s']='1') then//s=1 代表 step=1，亦即第一步
  begin
    emailAddress := Request.ContentFields.Values['box'];
    if isEmail(emailAddress) then
    begin
      pop3SSL := StrToIntDef(Request.ContentFields.Values['PS'],0);
      smtpSSL := StrToIntDef(Request.ContentFields.Values['SS'],0);
      isDefault := StrToIntDef(Request.ContentFields.Values['D'],1);

      userName := LeftStr(emailAddress,pos('@',emailAddress)-1);

      pop3Server := replaceText(emailAddress,userName+'@','pop3.');
      smtpServer := replaceText(emailAddress,userName+'@','smtp.');

      pop3Port := iif(pop3SSL=1,995,110);
      smtpPort := iif(smtpSSL=1,25,25) ;

      //SafeRedirect(Response,getCommonAction('addNewMailBoxStep2','')+'&box='+emailAddress+'&PS='+IntToStr(pop3SSL)+'&SS='+IntToStr(smtpSSL)+'&MUID='+userName+'&PSvr='+pop3Server+'&SSvr='+smtpServer+'&PP='+IntToStr(pop3Port)+'&SP='+IntToStr(smtpPort));
      Response.SendRedirect(getCommonAction('addNewMailBoxStep2','')+'&box='+emailAddress+'&PS='+IntToStr(pop3SSL)+'&SS='+IntToStr(smtpSSL)+'&MUID='+userName+'&PSvr='+pop3Server+'&SSvr='+smtpServer+'&PP='+IntToStr(pop3Port)+'&SP='+IntToStr(smtpPort)+'&D='+IntToStr(isDefault));
    end
    else
      Response.SendRedirect(getCommonAction('addNewMailBoxStep1','-8'));
    handled := true;
    exit;
  end
  else
  begin
    user := TUser.Create(self);
    serialization.StrToComponent(Session.Values[TConfig.currentUserSession],user);
    userId := user.userId;
    user.Free;
  end;
  mcfg := TMailConfig.create(self);
  mcfg.mailAddress := Request.ContentFields.Values['box'];
  mcfg.pop3Server := Request.ContentFields.Values['PSvr'];
  mcfg.smtpServer := Request.ContentFields.Values['SSvr'];
  mcfg.mailUserName := Request.ContentFields.Values['MUID'];
  mcfg.mailPassword := Request.ContentFields.Values['MPWD'];
  mcfg.smtpAuthencation := iif(Request.ContentFields.Values['SA']='1',true,false);
  mcfg.pop3Port := StrToIntDef(Request.ContentFields.Values['PP'],110);
  mcfg.pop3SSL := iif(Request.ContentFields.Values['PS']='1',true,false);
  mcfg.smtpPort := StrToIntDef(Request.ContentFields.Values['SP'],25);
  mcfg.smtpSSL := iif(Request.ContentFields.Values['SS']='1',true,false);
  mcfg.isDefault := iif(Request.ContentFields.Values['D']='1',true,false);

  if (not POP3Test(mcfg,msg)) or (not SMTPTest(mcfg,msg)) then
  begin
    mcfg.Free;
    Response.SendRedirect(getCommonAction('addNewMailBoxStatus_Failure')+'&errorMsg='+msg);
    //Response.SendRedirect(getCommonAction('addNewMailBoxStep2','')+'&box='+mcfg.mailAddress+'&PS='+iif(mcfg.pop3SSL,'1','0')+'&SS='+iif(mcfg.smtpSSL,'1','0')+'&MUID='+mcfg.mailUserName+'&PSvr='+mcfg.pop3Server+'&SSvr='+smtpServer+'&PP='+IntToStr(pop3Port)+'&SP='+IntToStr(smtpPort)+'&D='+IntToStr(isDefault));
  end
  else
  if WebDataModuleShare.addMailBox(userId,mcfg) then
  begin
    mcfg.Free;
    Response.SendRedirect(getCommonAction('addNewMailBoxStatus_Success'))
  end
  else
  begin
    mcfg.Free;
    SafeRedirect(Response,getCommonAction('addNewMailBoxStatus_Failure'));
  end;
  Handled := true;
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(TAdd, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

