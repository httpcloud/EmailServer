unit MainModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd, ReqMulti, WebSess, WebDisp,
  WebAdapt, WebComp,IniFiles,windows,idPOP3,HashMap,Config,SiteComp,
  Common.Debug,Common,JCLDebug, ExtCtrls, Sockets,
  httpsend, StrUtils
  ;

type
  TMain = class(TWebAppPageModule)
    PageProducer: TPageProducer;
    WebAppComponents: TWebAppComponents;
    ApplicationAdapter: TApplicationAdapter;
    EndUserSessionAdapter: TEndUserSessionAdapter;
    PageDispatcher: TPageDispatcher;
    AdapterDispatcher: TAdapterDispatcher;
    SessionsService: TSessionsService;
    AdapterAction: TAdapterAction;
    LocateFileService: TLocateFileService;
    Timer1: TTimer;
    TcpClient1: TTcpClient;
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
    procedure WebAppPageModuleBeforeDispatchPage(Sender: TObject;
      const PageName: string; var Handled: Boolean);
    procedure SessionsServiceEndSession(ASender: TObject;
      ASession: TAbstractWebSession; AReason: TEndSessionReason);
    procedure SessionsServiceStartSession(ASender: TObject;
      ASession: TAbstractWebSession);
    procedure AdapterDispatcherGetAdapterRequestParams(Sender: TObject;
      Handler: IInterface; var Identifer: string; Params: TStrings);
    procedure AdapterDispatcherActionRequestNotHandled(Sender, Action: TObject;
      Params: TStrings; var Handled: Boolean);
    procedure AdapterDispatcherBeforeDispatchAction(Sender, Action: TObject;
      Params: TStrings; var Handled: Boolean);
    procedure WebAppPageModuleActivate(Sender: TObject);
    procedure ApplicationAdapterGetActionParams(Sender, Action: TObject;
      Params: TStrings);
    procedure EndUserSessionAdapterBeforeExecuteAction(Sender, Action: TObject;
      Params: TStrings; var Handled: Boolean);
    procedure ApplicationAdapterBeforeExecuteAction(Sender, Action: TObject;
      Params: TStrings; var Handled: Boolean);
    procedure EndUserSessionAdapterGetActionParams(Sender, Action: TObject;
      Params: TStrings);
    procedure WebAppComponentsBeforeDispatch(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebDispatcher1Create(Sender: TObject);
    procedure WebAppComponentsException(Sender: TObject; E: Exception;
      var Handled: Boolean);
    procedure LocateFileServiceFindStream(ASender: TObject; AComponent: TComponent; const AFileName: string; var AFoundStream: TStream; var AOwned, AHandled: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure WebAppPageModuleCreate(Sender: TObject);
    procedure WebAppPageModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    http:THTTPSend;
  public
    { Public declarations }
  end;

  function Main: TMain;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants,loginModule,DataModule;

function Main: TMain;
begin
  Result := TMain(WebContext.FindModuleClass(TMain));
end;



procedure TMain.AdapterDispatcherActionRequestNotHandled(Sender,
  Action: TObject; Params: TStrings; var Handled: Boolean);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.AdapterDispatcherBeforeDispatchAction(Sender,
  Action: TObject; Params: TStrings; var Handled: Boolean);
var
  id:string;
begin
  id :=  params.Text;
end;

procedure TMain.AdapterDispatcherGetAdapterRequestParams(Sender: TObject;
  Handler: IInterface; var Identifer: string; Params: TStrings);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.ApplicationAdapterBeforeExecuteAction(Sender,
  Action: TObject; Params: TStrings; var Handled: Boolean);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.ApplicationAdapterGetActionParams(Sender, Action: TObject;
  Params: TStrings);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.EndUserSessionAdapterBeforeExecuteAction(Sender,
  Action: TObject; Params: TStrings; var Handled: Boolean);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.EndUserSessionAdapterGetActionParams(Sender,
  Action: TObject; Params: TStrings);
var
  id : string;
begin
  id := Params.Text;
end;

procedure TMain.LocateFileServiceFindStream(ASender: TObject; AComponent: TComponent; const AFileName: string; var AFoundStream: TStream; var AOwned, AHandled: Boolean);
var
  inStream:TResourceStream;
begin

  //重要!,从资源文件加载WML模板！    -lwgboy, 2009-9-20
//  if AFileName='return.wml' then
//    AFoundStream := TResourceStream.Create(Hinstance,ChangeFileExt(AFileName,''),'HTML')
//  else
  begin
    inStream:= TResourceStream.Create(Hinstance,ChangeFileExt(AFileName,''),'DATA');
    AFoundStream := TMemoryStream.Create;
    common.decryptTemplate(inStream,AFoundStream,inStream.Size);
    inStream.Free;
  end;
end;

procedure TMain.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  temp:string;
  InfoList:TStringList;
begin
//  if TagString='onlyForTest' then
//    ReplaceText := GetCurrentPath
//  else
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if TagString=TConfig.SYS_MSG then
  begin
    ReplaceText := Session.Values[TConfig.SYS_MSG];
    Session.Values[TConfig.SYS_MSG] := '';
  end
  else
  if tagString='info' then
  begin
     if TagParams.Values['card']=Request.QueryFields.Values['card'] then
        ReplaceText:=GetInfo(Request);
  end
  else
  if tagString='domain' then
  begin
    temp := Config.TXMLConfig.GetAppSettingValueByKey('domain');
    if temp='' then temp :='未设置';
    ReplaceText := temp;
  end
  else
  if tagString='mailUpdate' then
  begin
    if http<>nil then
    begin
      temp := '';
      try
         http.Timeout := 600;
         http.KeepAlive := false;
         if http.HTTPMethod('Get','http://wap..cc/mailUpdate/') then
         begin
           if http.ResultCode = 200 then
           begin
             InfoList := TStringList.Create;
             infoList.LoadFromStream(http.Document,TEncoding.UTF8);
             temp := StrUtils.ReplaceText(InfoList.Text,#13#10,'');
             infoList.Free;
           end;
         end;
         http.Clear;
         http.Abort;
      except on E:Exception do
        begin
          http.Abort;
          http.Clear;
        end;
      end;
      ReplaceText := temp;
    end;
  end
  else
    ReplaceText:=GetInfo(Request);
end;

procedure TMain.SessionsServiceEndSession(ASender: TObject;
  ASession: TAbstractWebSession; AReason: TEndSessionReason);
var
  currentPage,content:string;
  serialObj:string;
  obj:TIdPOP3;
  hash:THashMap;
  UName,PWD:string;
  User:TUser;
begin
  UName := WebContext.Session.Values[TConfig.cUserName];
  PWD := WebContext.Session.Values[TConfig.cPassword];
  if UName<>'' then
  begin
    hash := GetPOP3List;
    if hash.Values.First.GetObject<>nil then
    begin
      obj := hash.Values.First.Next as TIdPOP3;
      if (obj.Username = UName) and (obj.Password = PWD) then
      begin
        obj.Disconnect;
        obj.FreeOnRelease;
        hash.Values.Remove(obj);
      end
      else
        while hash.Values.First.HasNext do
        begin
          obj := hash.Values.First.Next as TIdPOP3;
          if (obj.Username = UName) and (obj.Password = PWD) then
          begin
            obj.Disconnect;
            obj.FreeOnRelease;
            hash.Values.Remove(obj);
            break;
          end;
        end;
    end;
  end;
end;

procedure TMain.SessionsServiceStartSession(ASender: TObject;
  ASession: TAbstractWebSession);
var
  id:string;
begin
  id := ASession.SessionID;
end;

procedure TMain.Timer1Timer(Sender: TObject);
var
  strTemp:string;
  FileNameList:TStringList;
begin
//  strTemp := Config.GetCurrentPath+'userData\inbox';
//  if DirectoryExists(strTemp) then
//  begin
//    FileNameList := TStringList.Create;
//    Common.FindAllFile(strTemp,FileNameList);
//    for strTemp in FileNameList do
//    begin
//      if FileExists(strTemp) then
//        DeleteFile(PWideChar(strTemp));
//    end;
//  end;
end;

procedure TMain.WebAppComponentsBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  id:string;
begin
  id := Session.SessionID;
end;

procedure TMain.WebAppComponentsException(Sender: TObject; E: Exception;
  var Handled: Boolean);
begin
  Response.ContentType := 'text/vnd.wap.wml; charset=utf-8';
  Handled := true;
  //RedirectToPageName('login',nil,Response,[dpPublished]);
  Response.SendRedirect(Request.InternalScriptName+'/login');
end;

procedure TMain.WebAppPageModuleActivate(Sender: TObject);
var
  id:string;
  MailServerConfig:TMailConfig;
begin

  Assert(Debug.Assert,'Session.Values["WebBrokerSessionID"]='+Session.Values['WebBrokerSessionID']+ VarToStr(LineByLevel(0)));
  id := Request.QueryFields.Values['ms'];
  Assert(Debug.Assert,'Request.QueryFields.Values["ms"]='+id);
  if id<>'' then
  begin  
    Request.CookieFields.Add('WebBrokerSessionID='+Request.QueryFields.Values['ms']);
    Request.CookieFields.Values['WebBrokerSessionID']:=id;
    if (Request.Cookie = 'WebBrokerSessionID=') or (Request.Cookie = '') then
    begin
      Request.CookieFields.Text := 'WebBrokerSessionID='+Request.QueryFields.Values['ms']+#13#10;  //MS:MailSession
    end;
  end;
  Assert(Debug.Assert,'Request.Query='+Request.Query);

  if not config.TXMLConfig.IsServer(Request) then
  begin
    MailServerConfig:=TMailConfig.create(self);
    if(Config.TXMLConfig.GetServerConfig(MailServerConfig))then
      WebDataModuleShare.InsertGuestMailServerConfig(MailServerConfig.mailAddress,MailServerConfig);
    MailServerConfig.Free;
  end;
end;

procedure TMain.WebAppPageModuleBeforeDispatchPage(Sender: TObject;
  const PageName: string; var Handled: Boolean);
var
  UserNameAndPassword:string;
  stream:TStream;
begin
  Response.ContentType := 'text/vnd.wap.wml';
  Response.ContentEncoding :='UTF-8';  //无效,delphi 中并不时根据它来决定输出页面的编码
  //PageProducer.HTMLDoc.LoadFromFile('MainModule.wml',TEncoding.UTF8);

  Response.ContentType := 'text/vnd.wap.wml; charset=utf-8'; //这样才能保证输出的页面为 UTF-8 格式。
//  Response.Content := PageProducer.Content;
//  if Session.Values[TConfig.SYS_MSG]<>'' then
//    PageProducer.HTMLDoc.LoadFromFile();
  if (Request.ContentFields.Count = 0) and (Request.QueryFields.Count>0) then
  begin
    UserNameAndPassword := Request.QueryFields.Values['up'];
    if UserNameAndPassword='' then
      UserNameAndPassword:=Request.QueryFields.Values['amp;up'];
    if UserNameAndPassword<>'' then
    begin
        DispatchPageName('login',Response,[]);
        login.Response.SendResponse;
    end;
  end;

  //重要!:据此判断加载的是自用的适应所有邮箱的完全版本还是适应单一域名的公开发行版本
  if not config.TXMLConfig.isDebug(Request) then
  begin
    //LoadFromResource(self.PageProducer,'');  //针对加密的模板会产生 Range Check Error！ 改成下面几句：  2009-9-28 03:22

    stream :=TStringStream.Create('',TEncoding.UTF8);
    LoadFromResource(stream,'MainModule_4_public');
    PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
    stream.Free;

    Response.Content := PageProducer.Content;
    Response.SendResponse;
    Handled := true;
  end;


end;

procedure TMain.WebAppPageModuleCreate(Sender: TObject);
var
  strTemp:string;
  FileNameList:TStringList;
begin
  strTemp := Config.GetCurrentPath2+'userData\inbox';
  if DirectoryExists(strTemp) then
  begin
    FileNameList := TStringList.Create;
    try
      Common.FindAllFileByTime(strTemp,FileNameList);  //按照日期进行查找。
      for strTemp in FileNameList do
      begin
        if FileExists(strTemp) then
          DeleteFile(PWideChar(strTemp));
      end;
    except on E:Exception do

    end;
    FileNameList.Free;
  end;

  strTemp := Config.GetCurrentPath2+'userData\outbox';
  if DirectoryExists(strTemp) then
  begin
    FileNameList := TStringList.Create;
    try
      Common.FindAllFileByTime(strTemp,FileNameList);  //按照日期进行查找。
      for strTemp in FileNameList do
      begin
        if FileExists(strTemp) then
          DeleteFile(PWideChar(strTemp));
      end;
    except on E:Exception do

    end;
    FileNameList.Free;
  end;

  if http=nil then
     http := THTTPSend.Create;
end;

procedure TMain.WebAppPageModuleDestroy(Sender: TObject);
begin
  try
    http.Abort;
    http.Free;
  except on E:Exception do
    http := nil;
  end;
end;

procedure TMain.WebDispatcher1Create(Sender: TObject);
var
  id:string;
begin
  id := Request.Cookie;
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebAppPageModuleFactory.Create(TMain, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), caCache)

);

end.

