unit sendModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,
  IdMessageClient, IdSMTP, IdMessage, idGlobal,
  StrUtils, WebDisp, IdUserPassProvider, IdSASLSKey, IdSASLPlain, IdSASLOTP,
  IdSASLLogin, IdSASLExternal, IdSASLAnonymous, IdBaseComponent, IdSASL,
  IdSASLUserPass, IdSASL_CRAM_MD5,
  IdSASLNTLM,
  // IdSASL_NTLM
  IdSSLOpenSSL, IdExplicitTLSClientServerBase,UTF8ContentParser,DataModule,
  Domain.UserMailInBox,
  Common
  ;

type
  Tsend = class(TWebPageModule)
    PageProducer: TPageProducer;
    PageProducerInfo: TPageProducer;
    procedure WebPageModuleBeforeDispatchPage
      (Sender: TObject; const PageName: string; var Handled: Boolean);
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
    procedure WebPageModuleAfterDispatchPage
      (Sender: TObject; const PageName: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function send: Tsend;
Function IsEMail(EMail: String): Boolean;

implementation

{$R *.dfm}  { *.wml }

uses WebReq, WebCntxt, WebFact, Variants, config, MainModule, loginModule,
    DAO.UserMailInBox, Encryption_DB,
    Generics.Collections;

Function IsEMail(EMail: String): Boolean;
var
  s: String;
  ETpos: Integer;
begin
  ETpos := StrUtils.PosEx('@', EMail); // 获取@符号的位置
  if ETpos > 1 then
  begin
    s := copy(EMail, ETpos + 1, Length(EMail)); // 截取子串
    if (StrUtils.PosEx('.', s) > 1) and (StrUtils.PosEx('.', s) < Length(s))
      then
      Result := true
    else
      Result := false;
  end
  else
    Result := false;
end;

function StrSplit(const Input: String; Delimiter: TSysCharSet): TStringList;
begin
  Result := TStringList.Create;
  ExtractStrings(Delimiter, [], PChar(Input), Result);
end;

function CheckMailBox(MailBox: string; var msg: TIdMessage;  var errorCode: string): Boolean;
var
  dot, semicolon, bracket, space: TStringList;
  nick, MailBoxName, mailAddress, quotation_mask: string;
  i, j, thePos: Integer;
begin
  dot := StrSplit(MailBox, [',']);
  for i := 0 to dot.Count - 1 do
  begin
    semicolon := StrSplit(dot[i], [';']);
    for j := 0 to semicolon.Count - 1 do
    begin
      quotation_mask := trim(semicolon[j]);
      if quotation_mask[1] = '"' then // 先检查是否是昵称部分带引号的形式，即:"张三" zhangsan@.cc的形式。
      begin
        thePos := PosEx('"', quotation_mask, 2);
        if thePos > 1 then // 说明昵称部分格式即正确，也不会为空（即"");
        begin
          nick := midstr(quotation_mask, 2, thePos - 2);
          mailAddress := trim(midstr(quotation_mask, thePos+1, Length
                (quotation_mask) - thePos));
          if not IsEMail(mailAddress) then
          begin
            errorCode := '-3';
            msg.Free;
            Result := false;
            exit;
          end
          else if (mailAddress[1] = '<') then
          begin
            if (mailAddress[Length(mailAddress)] = '>') then
              mailAddress := midstr(mailAddress, 2, Length(mailAddress) - 2)
            else
            begin
              errorCode := '-3';
              msg.Free;
              Result := false;
              exit;
            end;
          end;
        end
        else
        begin
          errorCode := '-3';
          msg.Free;
          Result := false;
          exit;
        end;
      end
      else
      begin
        space := StrSplit(semicolon[j], [' ']); // 先以空格进行昵称和邮箱地址两部分的分离。
        if space.Count = 2 then
        begin
          if IsEMail(space[1]) then // 说明后面是邮箱，那么将前面作为昵称部分。这也是本系统推荐的方式:"昵称"+空格+<邮箱地址>
          begin
            space[1] := trim(space[1]);
            if (space[1][1] = '<') then
            begin
              if (space[1][Length(space[1])] = '>') then
                mailAddress := midstr(space[1], 2, Length(space[1]) - 1)
              else
              begin
                errorCode := '-3';
                msg.Free;
                Result := false;
                exit;
              end;
            end
            else
              mailAddress := space[1];
            nick := replaceStr(space[0], '"', '');
          end
          else
          begin
            errorCode := '-3';
            msg.Free;
            Result := false;
            exit;
          end;
        end
        else if space.Count = 1 then // 说明后面只有邮箱部分而没有昵称或者为昵称<abc@.cc>的形式，即昵称和信箱之间没有空格。
        begin

          bracket := StrSplit(space[0], ['<']);
          // 进一步处理象：张三<zhangsan@163.com> 这样的邮箱格式
          if (bracket.Count = 2) or (bracket.Count = 1) then // 当length(s1)=2,说明是:张三<zhangsan@163.com>这种格式;当length(s1)=1,说明是:<zhangsan@163.com>或zhangsan@163.com这种格式
          begin
            if bracket.Count = 2 then
              mailAddress := bracket[1]
            else
              mailAddress := bracket[0];
            if IsEMail(mailAddress) then // 分离出真正的邮件地址:zhangsan@163.com
            begin
              if (bracket.Count = 2) then // 当包含昵称和邮件地址两部分时:张三<zhangsan@163.com>
              begin
                if (bracket[1][Length(bracket[1])] <> '>') then
                // 当包含昵称和邮件地址两部分时,若邮箱部分的最后一个字符不是'>'时，提示邮箱格式错误。
                begin
                  errorCode := '-3';
                  msg.Free;
                  Result := false;
                  exit;
                end
                else
                begin
                  bracket[1] := leftStr(bracket[1], Length(bracket[1]) - 1); // 去除邮箱:<zhangsan@163.com>最右边的'>'字符;
                  mailAddress := bracket[1];

                  nick := iif(trim(bracket[0]) = '', StrSplit(bracket[1], ['@'])
                      [0], StrSplit(trim(bracket[0]),['@'])[0]); // 处理类如<zhangsan@.163.com>,没有呢称部分形式的邮箱,把@前的用户名部分当作用户的呢称;
                  MailBoxName := StrSplit(bracket[1], ['@'])[0]; // 处理类如:张三<zhangsan@.163.com>或<zhangsan@.163.com>形式的邮箱,提取其用户名.
                end;
              end
              else
              begin
                nick := StrSplit(bracket[0], ['@'])[0]; // 处理类如:zhangsan@.163.com形式的没有任何用户呢称或尖括号<做前缀的邮箱,提取用户名做为其呢称
                MailBoxName := nick;
              end;

              {
                with msg.Recipients.Add do
                begin
                Name   := nick;         //呢称
                //User   := MailBoxName;  //登陆名，即邮箱@的前缀部分
                Address:= mailAddress;
                Result := true;
                end;
                }
              // ShowMessage('NickName: '+nick+#13#10+'UserName: '+MailBoxName+#13#10+'MailBox   :'+iif(length(bracket)=2,bracket[1],bracket[0]));
            end
            else
            begin
              errorCode := '-3';
              msg.Free;
              Result := false;
              exit;
            end;
          end
          else
          {
            begin
            errorCode := '-3';
            msg.Free;
            Result := false;
            exit;
            end;
            }

          if IsEMail(space[0]) then
          begin
            if (space[0][1] = '<') then
            begin
              if (space[0][Length(space[0])] = '>') then
                mailAddress := midstr(space[0], 1, Length(space[0]) - 2)
              else
              begin
                errorCode := '-3';
                msg.Free;
                Result := false;
                exit;
              end;
            end
            else
              mailAddress := space[0];
            nick := '';
          end
          else
          begin
            errorCode := '-3';
            msg.Free;
            Result := false;
            exit;
          end;
        end
        else
        begin
          errorCode := '-3';
          msg.Free;
          Result := false;
          exit;
        end;

      end;

      with msg.Recipients.Add do
      begin
        Name := nick; // 呢称
        // User   := MailBoxName;  //登陆名，即邮箱@的前缀部分
        Address := mailAddress;
        Result := true;
      end;
      {
        bracket := StrSplit(semicolon[j],['<']);     //进一步处理象：张三<zhangsan@163.com> 这样的邮箱格式
        if (bracket.Count=2) or (bracket.Count=1)  then      //当length(s1)=2,说明是:张三<zhangsan@163.com>这种格式;当length(s1)=1,说明是:<zhangsan@163.com>或zhangsan@163.com这种格式
        begin
        if bracket.Count=2 then
        mailAddress := bracket[1]
        else
        mailAddress := bracket[0];
        if IsEmail(mailAddress) then //分离出真正的邮件地址:zhangsan@163.com
        begin
        if (bracket.Count=2) then                       //当包含昵称和邮件地址两部分时:张三<zhangsan@163.com>
        begin
        if (bracket[1][length(bracket[1])]<>'>') then     //当包含昵称和邮件地址两部分时,若邮箱部分的最后一个字符不是'>'时，提示邮箱格式错误。
        begin
        errorCode := '-3';
        msg.Free;
        Result := false;
        exit;
        end
        else
        begin
        bracket[1]  := leftStr(bracket[1],length(bracket[1])-1);    //去除邮箱:<zhangsan@163.com>最右边的'>'字符;
        nick        := iif(trim(bracket[0])='',StrSplit(bracket[1],['@'])[0],trim(bracket[0])); //处理类如<zhangsan@.163.com>,没有呢称部分形式的邮箱,把@前的用户名部分当作用户的呢称;
        MailBoxName := StrSplit(bracket[1],['@'])[0];  //处理类如:张三<zhangsan@.163.com>或<zhangsan@.163.com>形式的邮箱,提取其用户名.
        end;
        end
        else
        begin
        nick        := StrSplit(bracket[0],['@'])[0]; //处理类如:zhangsan@.163.com形式的没有任何用户呢称或尖括号<做前缀的邮箱,提取用户名做为其呢称
        MailBoxName := nick ;
        end;

        with msg.Recipients.Add do
        begin
        Name   := nick;         //呢称
        //User   := MailBoxName;  //登陆名，即邮箱@的前缀部分
        Address:= mailAddress;
        Result := true;
        end;
        //ShowMessage('NickName: '+nick+#13#10+'UserName: '+MailBoxName+#13#10+'MailBox   :'+iif(length(bracket)=2,bracket[1],bracket[0]));
        end
        else
        begin
        errorCode := '-3';
        msg.Free;
        Result := false;
        exit;
        end;
        end
        else
        begin
        errorCode := '-3';
        msg.Free;
        Result := false;
        exit;
        end;
        }
    end;
  end;
end;

function send: Tsend;
begin
  Result := Tsend(WebContext.FindModuleClass(Tsend));
end;

procedure Tsend.PageProducerHTMLTag(Sender: TObject; Tag: TTag; const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  tmp: string;
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if compareText(TagString, 'info') = 0 then
    ReplaceText := GetInfo(WebContext.Session.Values[TConfig.SendMailStateCode])
  else if TagString = 'ms' then
    ReplaceText := Session.SessionID + loginModule.AppendUserInfo
  else
  // if (compareText(tagString,'detailInfo')=0) and (WebContext.Session.Values[TConfig.SendMailErrorInfo]<>'') then ReplaceText := '<a href='''+TConfig.userLogPath+'/'+(WebContext.Session.Values[TConfig.SendMailErrorInfo])+'''>'+UTF8.EncodeStr('详细信息')+'</a>';
    if (compareText(TagString, 'detailInfo') = 0) then
  begin
    tmp := WebContext.Session.Values[TConfig.SendMailStateInfo];
    if StrToIntDef(tmp, 0) < 0 then
    begin
      ReplaceText := '<a href="' + Request.InternalScriptName + '/readTxtModule?ms=' + Session.SessionID + loginModule.AppendUserInfo + '&amp;f=' + tmp + '">' + ('详细信息') + '</a>';
    end;
  end;
end;

procedure Tsend.WebPageModuleAfterDispatchPage
  (Sender: TObject; const PageName: string);
begin
  WebContext.Session.Values[TConfig.SendMailStateCode] := '';
  WebContext.Session.Values[TConfig.SendMailStateInfo] := '';
end;

//保存邮件到DB
procedure SaveToOutMailBox(msg:TIdMessage;location:MailStatus);
var
  UserMailInBox:TUserMailInBoxRec;
  StringStream:TStringStream;
  guid:TGUID;
begin
  UserMailInBox := TUserMailInBoxRec.Create;
  UserMailInBox.UserEMail := msg.From.Text;
  SysUtils.CreateGUID(guid);
  UserMailInBox.MailID := ReplaceText(ReplaceText(ReplaceText(SysUtils.GUIDToString(guid),'-',''),'{',''),'}','');
  UserMailInBox.UserEMail := ReplaceText(UserMailInBox.UserEMail,'<','');
  UserMailInBox.UserEMail := ReplaceText(UserMailInBox.UserEMail,'>','');
  UserMailInBox.RecvTime := now;
  UserMailInBox.FromAddr := msg.FromList.EMailAddresses;//trim(ReplaceText(msg.FromList.EMailAddresses,' <','<'));
  UserMailInBox.Recipient := msg.FromList.EMailAddresses;//trim(ReplaceText(msg.Recipients.EMailAddresses,' <','<'));
  UserMailInBox.CC := msg.CCList.EMailAddresses;
  UserMailInBox.BCC := msg.BccList.EMailAddresses;
  UserMailInBox.Subject := msg.Subject;
  UserMailInBox.Body := msg.Body.Text;

  StringStream := TStringStream.Create;
  msg.SaveToStream(StringStream);
  UserMailInBox.OrginalContent := StringStream.DataString;
  StringStream.Free;
  UserMailInBox.Status := integer(location);
  DataModule.WebDataModuleShare.InsertGuestUserMailInBox(UserMailInBox);
  UserMailInBox.Free;
end;

procedure Tsend.WebPageModuleBeforeDispatchPage(Sender: TObject; const PageName: string; var Handled: Boolean);
var
  Recipients, subject, body, logFileName, errorCode, tmp: string;
  msg: TIdMessage;
  smtp: TIdSMTP;
  log: TStrings;
  title, content: widestring;
  user: TUser;
  currentSelectMailConfig: TMailConfig;

  SASLLogin: TIdSASLLogin;
  MD5: TIdSASLCRAMMD5;
  NTLM: TIdSASLNTLM;
  Anonymous: TIdSASLAnonymous;
  SASLExternal: TIdSASLExternal;
  OTP: TIdSASLOTP;
  Plain: TIdSASLPlain;
  SKey: TIdSASLSKey;
  UserPassProvider: TIdUserPassProvider;
  sslIOHandler: TIdSSLIOHandlerSocketOpenSSL;

  UserMailInBox : TUserMailInBoxRec;
  StringStream:TStringStream;


  currentUser: TUser;
  UserMailInBoxDAO: TUserMailInBoxDAO;
  kv: TKeyValue;
  MailList:TObjectList<TUserMailInBoxRec>;

  objList:TObjectList<TKeyValue>;
  sql,MailID:string;
  FStream:TResourceStream;
  stream: TStream;
begin

  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
  // if WebContext.Session.Values[TConfig.cSMTPServer]='' then
  if not GetUserAndNullToFirstPage(user) then
  begin
    DispatchPageName('main', Response, []);
    Main.Response.SendResponse;
    exit;
  end;

  Recipients := (Request.ContentFields.Values['R']);
  subject := (Request.ContentFields.Values['S']);
  body := (Request.ContentFields.Values['C']);
  if trim(Recipients) = '' then
  begin
    WebContext.Session.Values[TConfig.SendMailStateCode] := -2;
    // Response.Content := PageProducerInfo.Content;
    // Response.SendResponse;
    // Handled := true;
    exit;
  end;

  msg := TIdMessage.Create(nil);
  msg.ContentType := 'text/plain';
  msg.CharSet := 'gb2312';
  msg.Encoding := meMIME;

  msg.ContentTransferEncoding := 'base64';

  {
  if Request.ContentFields.Values['mt']='2' then  //如果是从草稿箱转过来重发的，则可能会导致收件人被 TIdMessage 再次处理后加入引号导致收件人错误，所以这里直接将之前从msg.recipients.EMailAddresses 取出来存放到数据库中的EmailAddresses 再次取出直接赋值给msg.recipients.EMailAddresses。 OP 表示 Operate，为1表示发件箱操作，为2表示从草稿箱过来充发操作。
  begin
    msg.recipients.EMailAddresses := trim(ReplaceText(Recipients,' <','<'));
  end
  else
  }
  if not CheckMailBox(Recipients, msg, errorCode) then
  begin
    WebContext.Session.Values[TConfig.SendMailStateCode] := errorCode;
    // Response.Content := PageProducerInfo.Content;
    // Response.SendResponse;
    // Handled := true;
    exit;
  end;
  if not GetUserCurrentSelectMailConfig(currentSelectMailConfig) then
    exit;

  smtp := TIdSMTP.Create(nil);
  {
    smtp.Host := WebContext.Session.Values[TConfig.cSMTPServer];
    smtp.Port := 25;
    smtp.Username := WebContext.Session.Values[TConfig.cUserName];
    smtp.Password := WebContext.Session.Values[TConfig.cPassword];
  }

  smtp.Host := currentSelectMailConfig.smtpServer;
  smtp.Port := currentSelectMailConfig.smtpPort;
  smtp.MailAgent := 'OutLook 6.0';

  {
    smtp.Username := currentSelectMailConfig.mailUserName;
    smtp.Password := currentSelectMailConfig.mailPassword;
    smtp.AuthenticationType :=  atLogin;
    }

  UserPassProvider := TIdUserPassProvider.Create;
  UserPassProvider.UserName := currentSelectMailConfig.mailUserName;
  UserPassProvider.Password := currentSelectMailConfig.mailPassword;

  SASLLogin := TIdSASLLogin.Create;
  SKey := TIdSASLSKey.Create;
  MD5 := TIdSASLCRAMMD5.Create;
  NTLM := TIdSASLNTLM.Create;
  Anonymous := TIdSASLAnonymous.Create;
  SASLExternal := TIdSASLExternal.Create;
  OTP := TIdSASLOTP.Create;
  Plain := TIdSASLPlain.Create;

  SASLLogin.UserPassProvider := UserPassProvider;
  SKey.UserPassProvider := UserPassProvider;
  MD5.UserPassProvider := UserPassProvider;
  NTLM.UserPassProvider := UserPassProvider;
  OTP.UserPassProvider := UserPassProvider;
  Plain.UserPassProvider := UserPassProvider;

  smtp.SASLMechanisms.Add.SASL := SASLLogin;
  smtp.SASLMechanisms.Add.SASL := SKey;
  smtp.SASLMechanisms.Add.SASL := MD5;
  smtp.SASLMechanisms.Add.SASL := NTLM;
  smtp.SASLMechanisms.Add.SASL := OTP;
  smtp.SASLMechanisms.Add.SASL := Plain;
  smtp.SASLMechanisms.Add.SASL := SASLExternal;
  smtp.SASLMechanisms.Add.SASL := Anonymous;

  smtp.AuthType := TIdSMTPAuthenticationType.satSASL; // 为了编译，暂时去掉 2008-10-13

  smtp.ConnectTimeout := 2500;
  try
    if (currentSelectMailConfig.smtpSSL) then
    begin
      smtp.ConnectTimeout := 3500;
      sslIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(smtp);
      sslIOHandler.SSLOptions.Method := sslvTLSv1;
      // sslIOHandler.SSLOptions.Mode := sslmUnassigned;
      // sslIOHandler.SSLOptions.VerifyMode := [];
      // sslIOHandler.SSLOptions.VerifyDepth := 0;
      smtp.IOHandler := sslIOHandler;
      smtp.UseTLS := TIdUseTLS.utUseRequireTLS;
      smtp.Port := currentSelectMailConfig.smtpPort;
    end;
    smtp.Connect;
    {
      //indy9
      if (smtp.AuthSchemesSupported.IndexOf('LOGIN')<>-1) then  //服务器要求验证
      begin
      smtp.AuthenticationType:=atlogin;
      if not smtp.Authenticate then    //验证不通过
      begin
      WebContext.Session.Values[TConfig.SendMailStateCode] := -6;
      smtp.Disconnect;
      smtp.Free;
      msg.Free;
      exit;
      end;
      end;
    }
    if not smtp.Authenticate then // 验证不通过
    begin
      msg.Free;
      WebContext.Session.Values[TConfig.SendMailStateCode] := -6;
      smtp.Disconnect;
      smtp.Free;
      exit;
    end;
  except
    on e: Exception do
    begin
      WebContext.Session.Values[TConfig.SendMailStateCode] := -7;
      if smtp.IOHandler <> nil then
      begin
        if sslIOHandler <> nil then
        begin
          sslIOHandler.Close;
          sslIOHandler.Free;
        end;
      end;
      smtp.Disconnect;
      smtp.Free;
      msg.Free;
      exit;
    end;
  end;

  // msg.From.Address := WebContext.Session.Values[TConfig.cMailAddress];
  msg.From.Address := currentSelectMailConfig.mailAddress;
  //UTF8.DecodeStr(PChar(subject),length(subject),title);
  //UTF8.DecodeStr(PChar(body),length(body),content);

  // msg.Subject := UTF8ToString(subject);
  // msg.Body.Text := UTF8ToString(body)+TConfig.MailAppendContent;
  msg.subject := (subject);
  msg.body.Text := (body) + TConfig.MailAppendContent;
  if config.TXMLConfig.IsDebug(Request)  then
    msg.SaveToFile(config.GetCurrentPath + TConfig.userOutBoxPath + currentSelectMailConfig.mailAddress + '_' + FormatDateTime('yyyymmddhhmmss', Now) + '.eml');
  try
    try
      smtp.send(msg);
      WebContext.Session.Values[TConfig.SendMailStateCode] := 50; // 发送成功

      //发送成功后从草稿箱删除该草稿存根。
      if Request.ContentFields.Values['mt']='2' then  // MT表示MaiBoxType,1表示从发件箱过来，2表示从草稿箱过来；OP 表示 Operate，为1表示发件箱操作，为2表示从草稿箱过来充发操作。
      begin
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
      end;

      SaveToOutMailBox(msg,MailStatus.eAlreadySent);

    except
      on e: Exception do
      begin
        logFileName := FormatDateTime('yyyymmdd-hhmmss', Now) + smtp.UserName + '.log';

        if config.TXMLConfig.IsDebug(Request) then
        begin
          log := TStringList.Create;
          tmp := FormatDateTime('yyyy-mm-dd hh:mm:ss', Now);
          log.Add(tmp);
          log.Add('host=' + smtp.Host + ':' + IntToStr(smtp.Port));
          log.Add('Recipients=' + msg.Recipients.EMailAddresses);
          log.Add(e.Message);
          log.SaveToFile(GetCurrentPath + TConfig.userLogPath + logFileName);
          log.Free;
        end;

        WebContext.Session.Values[TConfig.SendMailStateInfo] := logFileName;
        WebContext.Session.Values[TConfig.SendMailStateCode] := -5;

        SaveToOutMailBox(msg,MailStatus.eWaitForSend);
      end;
    end;
  finally
    if smtp.IOHandler <> nil then
    begin
      if sslIOHandler <> nil then
      begin
        sslIOHandler.Close;
        sslIOHandler.Free;
      end;
    end;
    smtp.Disconnect;
    smtp.Free;
    msg.Free;
  end;

  //LoadFromResource(PageProducer,UnitName);   //改为下面几句，防止产生 Range Check Error , 2009-09-29 04:40
  stream :=TStringStream.Create('',TEncoding.UTF8);
  LoadFromResource(stream,UnitName);
  PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
  stream.Free;

  Response.Content := PageProducer.Content;
  Response.SendResponse;
  Handled := true;
end;

initialization

if WebRequestHandler <> nil then
  WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create
      (Tsend, TWebPageInfo.Create([wpPublished
        { , wpLoginRequired } ], '.wml'), crOnDemand, caCache)

    );

end.
