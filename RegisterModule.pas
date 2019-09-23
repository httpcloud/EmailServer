unit RegisterModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,
  Common,idGlobal;

type
  Treg = class(TWebPageModule)
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

  function reg: Treg;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants, DataModule, config;

function reg: Treg;
begin
  Result := Treg(WebContext.FindModuleClass(Treg));
end;

procedure Treg.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle;

  if(session.Values[TagString]<>'') then
  begin
    ReplaceText := session.Values[TagString]+'<br/>';  //��ʾ�û�ע��ɹ�����ħ��(Uerser)�����룬�����û��μǡ�
    session.Values[TagString] := '';
  end;
end;

procedure Treg.WebPageModuleBeforeDispatchPage(Sender: TObject;
  const PageName: string; var Handled: Boolean);
var
  emailAddress,password:string;
  userId:integer;
begin
  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';

//  PageProducer.HTMLDoc.LoadFromFile(config.GetCurrentPath+'register_success.wml');
//  Response.Content := PageProducer.Content;
//  Response.SendResponse;
//  Handled := true;

  emailAddress := trim(request.ContentFields.Values['MUID']);
  password := trim(request.ContentFields.Values['MPWD']);
  if(request.ContentFields.Count<3) then
    exit;

  if(emailAddress='') then
  begin
    Session.Values[TConfig.SYS_MSG]:= '���䲻��Ϊ�գ�����������ȫ�ơ�';
    config.SafeRedirectTo(Response,Request.InternalScriptName+Request.InternalPathInfo);
    Handled:=true;
    exit;
  end;

  if(password = '') then
  begin
    Session.Values[TConfig.SYS_MSG]:= '���벻��Ϊ�գ����������롣';
    config.SafeRedirectTo(Response,Request.InternalScriptName+Request.InternalPathInfo);
    Handled:=true;
    exit;
  end;

  if(emailAddress='') or (not Common.CheckEmail(emailAddress)) then
  begin
   Session.Values[TConfig.SYS_MSG]:= '��������������������롣';
    config.SafeRedirectTo(Response,Request.InternalScriptName+Request.InternalPathInfo);
    Handled:=true;
   exit;
  end;



  if password<>trim(request.ContentFields.Values['MPWD2']) then
  begin
    Session.Values[TConfig.SYS_MSG]:= '�����������벻һ�£������䲢�μǣ�';
    config.SafeRedirectTo(Response,Request.InternalScriptName+Request.InternalPathInfo);
    Handled:=true;
    exit;
  end;

  if (emailAddress<>'') and (password<>'') then
  begin
    userId := 123;//WebDataModuleShare.registerUser(emailAddress,password);
    if userId>0 then
    begin
       session.Values['userId'] := userId;
       session.Values['pwd'] := password;
       PageProducer.HTMLDoc.LoadFromFile(config.GetCurrentPath+'register_success.wml');
       Response.Content := PageProducer.Content;
       Response.SendResponse;
       Handled := true;
    end
    else
    if userId=-1 then
    begin
       session.Values['userId'] := '�������Ѿ�ע�����';
    end;
  end;
  
  
  
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(Treg, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

