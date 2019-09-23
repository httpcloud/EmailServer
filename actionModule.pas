unit actionModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,
  IdGlobal,Windows;

type
  Taction = class(TWebPageModule)
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

  function action: Taction;
  function getCommonAction(actionFileName:string;codeValue:string='';guestMailAddress:string=''):string;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants,config, loginModule,Common;

function action: Taction;
begin
  Result := Taction(WebContext.FindModuleClass(Taction));
end;

function getCommonAction(actionFileName:string;codeValue:string='';guestMailAddress:string=''):string;
begin
  Result := 'action?ms='+WebContext.Session.SessionID+loginModule.AppendUserInfo(guestMailAddress)+'&ac='+actionFileName;
  if trim(codeValue)<>'' then
    Result := Result+'&'+TConfig.commonActionTagParagramName+'='+codeValue;
end;



procedure Taction.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  commonActionTagParagramValue,userName,PWD:string;
begin
  if TagString = 'ms' then
  begin
    userName := Request.QueryFields.Values['box'];
    PWD := Request.ContentFields.Values['PWD'];
    if userName = '' then userName := Request.ContentFields.Values['box'];
    if PWD<>'' then
      ReplaceText := Session.SessionID+loginModule.AppendUserInfo(userName,PWD)
    else
      ReplaceText := Session.SessionID+loginModule.AppendUserInfo(userName);
  end
  else
  if TagString=TConfig.commonActionTagName then
  begin
    commonActionTagParagramValue := Request.QueryFields.Values[TConfig.commonActionTagParagramName];
    if commonActionTagParagramValue = '' then
      commonActionTagParagramValue := Request.ContentFields.Values[TConfig.commonActionTagParagramName];
    if commonActionTagParagramValue <> '' then
      ReplaceText := GetInfo(commonActionTagParagramValue)+iif(Request.QueryFields.IndexOfName('errorMsg')<>-1,'<i>详细信息:'+Request.QueryFields.Values['errorMsg']+'</i><br/>','');
  end
  else
  if TagString = TConfig.ERROR404 then
  begin
    ReplaceText := '('+Session.Values[TConfig.ERROR404]+')';
    Session.Values[TConfig.ERROR404] := '';
  end
  else
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  begin
    if Request.ContentFields.IndexOfName(TagString)>=0 then
      ReplaceText := Request.ContentFields.ValueFromIndex[Request.ContentFields.IndexOfName(TagString)]
    else
    if Request.QueryFields.IndexOfName(TagString)>=0 then
      ReplaceText := Request.QueryFields.ValueFromIndex[Request.QueryFields.IndexOfName(TagString)];
  end;
end;

procedure Taction.WebPageModuleBeforeDispatchPage(Sender: TObject;
  const PageName: string; var Handled: Boolean);
var
  action:string;
  stream:TStream;
begin
  Response.ContentType := 'text/vnd.wap.wml; charset=utf-8';  //这里设置为　UTF-8 防止页面乱码。　--lwgboy,2009-9-7 23:24
  action := Request.QueryFields.Values['ac'];
  if action='' then action := Request.QueryFields.Values['amp;ac'];
  if action='' then action := Request.ContentFields.Values['ac'];
  action := GetCurrentPath+action+'.wml';
  //if not FileExists(action) then  //改为下句,从资源文件中查找
  //if FindResource(Hinstance,PWideChar(ChangeFileExt(ExtractFileName(action),'')),'HTML')<=0 then
  if FindResource(Hinstance,PWideChar(ChangeFileExt(ExtractFileName(action),'')),'DATA')<=0 then
  begin
    //Session.Values[TConfig.ERROR404] := ExtractFileName(action);
    Session.Values[TConfig.ERROR404] := action;
    action := GetCurrentPath+'Error404.wml';
  end;
  //PageProducer.HTMLDoc.LoadFromFile(action,TEncoding.UTF8);  //超级重要！设定以 UTF8 编码加载会导致 HTTPApp.pas中(约1025行)的 procedure TWebResponse.SetUnicodeContent(const AValue: string);　产生　ERankCheck Error! 　--lwgboy,2009-9-7 23:24


  //LoadFromResource(pageProducer,ChangeFileExt(ExtractFileName(action),''));  //会产生　ERankCheck Error!　有空儿再解决，暂且改为下面的方法。 　--lwgboy,2009-9-23 05:11

   //以下可防止产生　ERankCheck Error!　有空而再细究。　--lwgboy,2009-9-23 05:11　　
   stream :=TStringStream.Create('',TEncoding.UTF8);
   LoadFromResource(stream,ChangeFileExt(ExtractFileName(action),''));
   PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
   stream.Free;

  Response.Content := PageProducer.Content;
  Response.SendResponse;
  Handled := true;
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(Taction, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

