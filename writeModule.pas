unit writeModule;

interface

uses
  SysUtils, Classes,  HTTPApp, WebModu,  HTTPProd,
  Domain.UserMailInBox,
  Generics.Collections,
  Encryption_DB;

type
  Twrite = class(TWebPageModule)
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

  function write: Twrite;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact,  loginModule,DAO.UserMailInBox,config,common;

function write: Twrite;
begin
  Result := Twrite(WebContext.FindModuleClass(Twrite));
end;

function CreateDelURL():string;
var
  str:TStringBuilder;
begin
  str := TStringBuilder.Create;
  str.Append('<anchor>删除');
  str.Append('<go accept-charset="utf-8" href="<%=Pages.send.HREF%>?ms=<#ms>" method="post">');
	str.Append('<postfield name="R" value="$(rcpnts)"/>');
  str.Append('</go>');
  str.Append('</anchor>');
  Result := str.ToString();
  str.Free;
end;

procedure Twrite.PageProducerHTMLTag(Sender: TObject; Tag: TTag;  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  currentPage, content, serialObj: string;
  currentUser: TUser;
  UserMailInBoxDAO: TUserMailInBoxDAO;
  kv: TKeyValue;
  MailList:TObjectList<TUserMailInBoxRec>;
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if TagString = 'ms' then ReplaceText := session.SessionID+loginModule.AppendUserInfo
  else
  if Request.QueryFields.Values['md']<>'' then   //md:MailID
  begin

    if GetUserAndNullToFirstPage(currentUser) then
    begin
      UserMailInBoxDAO := TUserMailInBoxDAO.Create(self);
      {
      if Request.QueryFields.Values['tp']='1' then
        kv := TKeyValue.Create('int', integer(Domain.UserMailInBox.eAlreadySent))
      else
        kv := TKeyValue.Create('int', integer(Domain.UserMailInBox.eWaitForSend));
      MailList := UserMailInBoxDAO.ReadMailBoxBy(currentUser.currentSelectMail, 'Status', kv);
      }
      kv := TKeyValue.Create('Str', Request.QueryFields.Values['md']);
      MailList := UserMailInBoxDAO.ReadMailBoxBy(currentUser.currentSelectMail, 'MailID', kv);

      if MailList.Count>0 then
      begin
        if TagString='rcpnts'    then ReplaceText := Config.FilterSpecialCharacter(MailList[0].Recipient)
        else
        if TagString='sbjct'     then ReplaceText := MailList[0].Subject
        else
        if TagString='bdy'       then ReplaceText := StringReplace(MailList[0].Body,TConfig.MailAppendContent,'',[rfReplaceAll])
        else
        if (TagString='sender') and (MailList[0].Status = Integer(MailStatus.eWaitForSend))   then ReplaceText:='发送' //对于未发送成功的、并保存在草稿箱中的邮件，显示发送按钮。 已发送成功的只显示下面的删除按钮，不显示发送按钮。
        else
        if TagString='cancel'    then ReplaceText := '删除' //当从发件箱或草稿箱打开邮件时，可出现此删除功能。
        else
        if TagString='md'        then ReplaceText := MailList[0].MailID; //当从发件箱或草稿箱打开邮件时，可根据此MailID删除发件箱或草稿箱中的邮件。

      end;
      MailList.Free;
      UserMailInBoxDAO.Free;

    end;

  end
  else
    if TagString='send' then ReplaceText:= '发送';    //新撰写的邮件，当然显示发送按钮。

end;

procedure Twrite.WebPageModuleBeforeDispatchPage(Sender: TObject;
  const PageName: string; var Handled: Boolean);

var
  currentPage, content: string;
  currentUser: TUser;
  UserMailInBoxDAO: TUserMailInBoxDAO;
  kv: TKeyValue;
  MailList:TObjectList<TUserMailInBoxRec>;
  stream:TStream;
begin
   Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
   if Request.QueryFields.Values['md']<>'' then   //md:MailID
   begin

    if GetUserAndNullToFirstPage(currentUser) then
    begin
      UserMailInBoxDAO := TUserMailInBoxDAO.Create(self);
      kv := TKeyValue.Create('Str', Request.QueryFields.Values['md']);
      MailList := UserMailInBoxDAO.ReadMailBoxBy(currentUser.currentSelectMail, 'MailID', kv);
      if MailList.Count>0 then
      begin
        if MailList.Items[0].Status = integer(MailStatus.eAlreadySent) then
        begin
          //PageProducer.HTMLDoc.LoadFromFile(config.GetCurrentPath+'writeModule_For_OutBox.wml')
          //LoadFromResource(pageProducer,'writeModule_For_OutBox');   // 改成下面几句，防止 Range Error 错误 2009-9-29 04:21

          stream :=TStringStream.Create('',TEncoding.UTF8);
          LoadFromResource(stream,'writeModule_For_OutBox');
          PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
          stream.Free;
        end
        else
        if MailList.Items[0].Status = integer(MailStatus.eWaitForSend) then
        begin
          //PageProducer.HTMLDoc.LoadFromFile(config.GetCurrentPath+'writeModule_For_DraftBox.wml');
          //LoadFromResource(pageProducer,'writeModule_For_DraftBox'); //改成下面几句，防止 Range Error 错误 2009-9-29 04:21
          stream :=TStringStream.Create('',TEncoding.UTF8);
          LoadFromResource(stream,'writeModule_For_DraftBox');
          PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
          stream.Free;
        end;
        Response.Content := PageProducer.Content;
        Response.SendResponse;
        Handled := true;
      end;
      MailList.Free;
      UserMailInBoxDAO.Free;
    end;
   end;

end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(Twrite, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

