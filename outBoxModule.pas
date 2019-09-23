unit outBoxModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,IdPOP3,
  Domain.UserMailInBox,
  Generics.Collections,
  Encryption_DB;

type
  ToutBox = class(TWebPageModule)
    PageProducer: TPageProducer;
    procedure WebPageModuleBeforeDispatchPage
      (Sender: TObject; const PageName: string; var Handled: Boolean);
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag; const TagString: string; TagParams: TStrings; var ReplaceText: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function outBox: ToutBox;
function paginationShow(MailList:TObjectList<TUserMailInBoxRec>; selfURL, detailURL, sessionID: string;
  currentPage: integer; pageItemNum: integer; totalNumber: integer): string;

implementation

{$R *.dfm}  { *.wml }

uses WebReq, WebCntxt, WebFact, Variants, loginModule, MainModule,config,WebDisp,
     //Contnrs,
     DAO.UserMailInBox, StrUtils, IdGlobal;

function outBox: ToutBox;
begin
  Result := ToutBox(WebContext.FindModuleClass(ToutBox));
end;

procedure ToutBox.PageProducerHTMLTag(Sender: TObject; Tag: TTag; const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
end;

procedure ToutBox.WebPageModuleBeforeDispatchPage
  (Sender: TObject; const PageName: string; var Handled: Boolean);
var
  currentPage, content: string;
  currentUser: TUser;
  UserMailInBoxDAO: TUserMailInBoxDAO;
  kv: TKeyValue;
  MailList:TObjectList<TUserMailInBoxRec>;

  objList:TObjectList<TKeyValue>;
  sql:string;
begin
  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
  if GetUserAndNullToFirstPage(currentUser) then
  begin
    UserMailInBoxDAO := TUserMailInBoxDAO.Create(self);

    if (Request.ContentFields.Values['md']<>'') and ((Request.ContentFields.Values['op']='1') or (Request.ContentFields.Values['op']='2')) then  //从 WriteModule 过来的删除邮件请求,md:MailID, op:operate,操作，1表示从发件箱删除邮件请求，2表示从草稿箱删除邮件请求
    begin
      objList:=TObjectList<TKeyValue>.Create;
      objList.Add(TKeyValue.Create('str',currentUser.currentSelectMail));
      objList.Add(TKeyValue.Create('str',Request.ContentFields.Values['md']));
      sql := 'delete from userInBox where UserEMail=? and MailId=?;';
      UserMailInBoxDAO.Delete(sql,objList);
      objList.clear;
      objList:= nil;
    end;

    if (Request.ContentFields.Values['op']='1')     //从 WriteModule 过来的删除邮件请求,md:MailID, op:operate,操作，1表示从发件箱删除邮件请求，2表示从草稿箱删除邮件请求
    or (Request.QueryFields.Values['mt']='1') then  // 从 Login 成功后的邮箱列表点击过来，mt: MailBoxType的缩写，1表示发件箱，2表示草稿箱
      kv := TKeyValue.Create('int', integer(Domain.UserMailInBox.eAlreadySent))
    else
    if (Request.QueryFields.Values['mt']='2')        //从 WriteModule 过来的删除邮件请求,md:MailID, op:operate,操作，1表示从发件箱删除邮件请求，2表示从草稿箱删除邮件请求
    or (Request.ContentFields.Values['op']='2') then // 从 Login 成功后的邮箱列表点击过来，mt: MailBoxType的缩写，1表示发件箱，2表示草稿箱
      kv := TKeyValue.Create('int', integer(Domain.UserMailInBox.eWaitForSend));

    MailList := UserMailInBoxDAO.ReadMailBoxBy(currentUser.currentSelectMail, 'Status', kv);

    currentPage := Request.QueryFields.Values['p'];
    if currentPage = '' then currentPage := '1';



    currentPage := paginationShow(MailList, Request.InternalScriptName + Request.InternalPathInfo,
      Request.InternalScriptName + '/write',
      WebContext.Session.sessionID + loginModule.AppendUserInfo,
      StrToInt(currentPage), TConfig.pageItemCount, MailList.Count);
    content := '<?xml version="1.0"?><!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN" "http://www.wapforum.org/DTD/wml_1.1.xml">';
    content := content + '<wml><card id="card1" title="" newcontext="true"><p>';
    Response.content := content + currentPage + '<br/><a href="' +
      Request.InternalScriptName + '/login?ms=' + Session.sessionID +
      loginModule.AppendUserInfo + '">' + ('切换邮箱') + '</a></p></card></wml>';
    Session.UpdateResponse(Response); // 用UpdateResponse方法可以防止Session丢失．

    MailList.Clear;
    MailList.Free;
    UserMailInBoxDAO.Free;
    //currentUser.Free;   //千万不可加这句，因为它会提前释放存放于POP3List 中的用户，从而导致后来再用时查找错误，出现类型无法转换错误。

    Response.SendResponse;
  end
  else
  begin
    DispatchPageName('main', Response, []);
    Main.Response.SendResponse;
  end;
end;

function paginationShow(MailList:TObjectList<TUserMailInBoxRec>; selfURL, detailURL, sessionID: string;
  currentPage: integer; pageItemNum: integer; totalNumber: integer): string;
var
  summaryPage: integer; // 总页数
  currentItem: integer; // 当前的记录行
  currentPageFirstItem: integer; // 当前页的第一行记录
  i,position: integer;
  theSubject: string;
  txtTemp: WideString;
  format: TFormatSettings;
  content: TStringList;
  msg:TUserMailInBoxRec;
begin
  if totalNumber <= 0 then
  begin
    if (WebContext.Request.ContentFields.Values['op']='')
    and (WebContext.Request.QueryFields.Values['mt']='') then
      Result := ('您的收件箱没有任何邮件.')
    else
    if (WebContext.Request.ContentFields.Values['op']='1') //从 WriteModule 过来的删除邮件请求,md:MailID, op:operate,操作，1表示从发件箱删除邮件请求，2表示从草稿箱删除邮件请求
    or (WebContext.Request.QueryFields.Values['mt']='1')  // 从 Login 成功后的邮箱列表点击过来，mt: MailBoxType的缩写，1表示发件箱，2表示草稿箱
    then
      Result := ('您的发件箱没有任何邮件.')
    else
    if (WebContext.Request.ContentFields.Values['op']='2') //从 WriteModule 过来的删除邮件请求,md:MailID, op:operate,操作，1表示从发件箱删除邮件请求，2表示从草稿箱删除邮件请求
    or (WebContext.Request.QueryFields.Values['mt']='2')  // 从 Login 成功后的邮箱列表点击过来，mt: MailBoxType的缩写，1表示发件箱，2表示草稿箱
    then
      Result := ('您的草稿箱没有任何邮件.');
    exit;
  end;

  if totalNumber mod pageItemNum > 0 then
    summaryPage := totalNumber div pageItemNum + 1
  else
    summaryPage := totalNumber div pageItemNum;

  // ReleaseAll;
  content := TStringList.Create;
  if currentPage <= 1 then
  begin
    currentPage := 1;
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(currentPage + 1) + '">' + ('下') + '</a>');
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(summaryPage) + '">' + ('尾') + '</a>');
  end
  else if currentPage >= summaryPage then
  begin
    currentPage := summaryPage;
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=1">' + ('头') + '</a>');
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(currentPage - 1) + '">' + ('上') + '</a>');
  end
  else
  begin
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=1">' + ('头') + '</a>');
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(currentPage - 1) + '">' + ('上') + '</a>');
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(currentPage + 1) + '">' + ('下') + '</a>');
    content.Add('<a href="' + selfURL + '?ms=' + sessionID + '&amp;p=' + IntToStr(summaryPage) + '">' + ('尾') + '</a>');
  end;
  content.Add('<br/>');

  // try
  // GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, format);
  // format.ShortDateFormat := 'yyyyMMdd';
  // format.ShortTimeFormat := 'hh:mm';
  // except
  // On Exception do begin
  // end;
  // end;

  currentPageFirstItem := (currentPage - 1) * pageItemNum + 1;
  pageItemNum := (totalNumber - currentPageFirstItem) + 1;
  if pageItemNum > TConfig.pageItemCount then
    pageItemNum := TConfig.pageItemCount;
  for i := 1 to pageItemNum do // Mial MessageNumbers start with 1 !!!
  begin
    msg := MailList.Items[i-1];

    if (1 = 2) then // 暂时不采用下面的格式,因其在MTK芯片手机上大都显示效果不好，总是一个很长的框框。   -- lwgboy 2009-09-10 03:10
    begin
      content.Add('<select name="time' + IntToStr(i) + '" title="time' + IntToStr(i) + '" multiple="false" tabindex="0">');
      // 下面这句话中的<small/><i/>在有些手机如MTK芯片上部分手机上不兼容，所以注释掉：
      // content.Add('<option value="'+ IntToStr(currentPageFirstItem+i-1)+'"><small><i>'+{DateTimeToStr(msg.Date,format)}FormatdateTime('yy-mm-dd hh:mm',msg.Date)+'</i></small></option>');
      content.Add('<option value="' + IntToStr(currentPageFirstItem + i - 1) + '">' + { DateTimeToStr(msg.Date,format) } FormatdateTime('yy-mm-dd hh:mm', msg.RecvTime) + '</option>');
      content.Add('</select><br/>');
    end
    else
    begin
      content.Add(FormatdateTime('yyyymmdd hh:mm', msg.RecvTime));
    end;

    // 发件人
    position :=  pos('<',msg.FromAddr);
    txtTemp := iif(position>0,LeftStr(msg.FromAddr,position-1),LeftStr(msg.FromAddr,pos('@',msg.FromAddr)-1));
    if txtTemp <> '' then
        txtTemp := txtTemp + ':';
    // content.Add(iif(Pos('?utf-8?',lowercase(msg.Subject))>0,txtTemp,(txtTemp)));
    txtTemp := Config.FilterSpecialCharacter(txtTemp);
    content.Add((txtTemp));

    // 主题

    if trim(msg.Subject) = '' then
      txtTemp := '...'
    else
    begin
      txtTemp := msg.Subject;
      theSubject := txtTemp;

      if (length(txtTemp) > 30) then
        txtTemp := LeftStr(txtTemp, 30) + '...'
      else
        txtTemp := theSubject;
    end;
    txtTemp := FilterSpecialCharacter(txtTemp);
    // content.Add('<a href="'+detailURL+'?id='+ IntToStr(currentPageFirstItem+i-1)+'" name="subject'+intToStr(i)+'">'+iif(Pos('?utf-8?',lowercase(msg.Subject))>0,txtTemp,(txtTemp))+'</a><br/>');
    content.Add('<a href="' + detailURL + '?ms=' + sessionID + '&amp;id=' +
        IntToStr(currentPageFirstItem + i - 1) + '&amp;lp=' + IntToStr
        (currentPage) + '&amp;name=subject' + IntToStr(i) + '&amp;md='+msg.MailID+'">' + (txtTemp)
        + '</a><br/>'); // lp: ListPage,邮件列表页码

  end;
  WebContext.Session.Values['summaryPage'] := summaryPage;
  WebContext.Session.Values['currentPage'] := currentPage;
  WebContext.Session.Values['totalNumber'] := totalNumber;
  // content.Add(('共'+IntToStr(summaryPage)+'页')+',<a href="'+WebContext.Request.InternalScriptName+'/inBox?ms='+WebContext.Session.SessionID+loginModule.AppendUserInfo+'&amp;p=$go">'+('转到')+'</a><input name="go" maxlength="5" size="3" format="5N" emptyok="false" value="'+IntToStr(currentPage)+'"/>'+('页'));
  content.Add(('共' + IntToStr(summaryPage) + '页') +
      ',转<input name="go" maxlength="5" size="3" format="5N" emptyok="false" value="'
      + IntToStr(currentPage) + '"/>' + ('页')
      + ' <a href="' + WebContext.Request.InternalScriptName + '/inBox?ms=' +
      WebContext.Session.sessionID + loginModule.AppendUserInfo +
      '&amp;p=$go">Go!</a>');

  Result := content.Text;
  content.Free;
end;

initialization

if WebRequestHandler <> nil then
  WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create
      (ToutBox, TWebPageInfo.Create([wpPublished
        { , wpLoginRequired } ], '.wml'), crOnDemand, caCache)

    );

end.
