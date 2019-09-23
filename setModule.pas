unit setModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,
  IdMessageClient, IdSMTP, IdMessage, idGlobal,
  StrUtils, WebDisp, IdUserPassProvider, IdSASLSKey, IdSASLPlain, IdSASLOTP,
  IdSASLLogin, IdSASLExternal, IdSASLAnonymous, IdBaseComponent, IdSASL,
  IdSASLUserPass, IdSASL_CRAM_MD5,
  IdSASLNTLM,
  // IdSASL_NTLM
  IdSSLOpenSSL, IdExplicitTLSClientServerBase, UTF8ContentParser, DataModule,DAO.UserMailInBox;

type
  Tset = class(TWebPageModule)
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
    msg:string;
  public
    { Public declarations }
  end;

function sysSet: Tset;
Function IsEMail(EMail: String): Boolean;

implementation

{$R *.dfm}  { *.wml }

uses WebReq, WebCntxt, WebFact, Variants, config, MainModule, loginModule,
   Encryption_DB,
  Generics.Collections, Domain.UserMailInBox,Common;

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

function CheckMailBox(MailBox: string; var msg: TIdMessage;
  var errorCode: string): Boolean;
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
        thePos := PosEx('"', quotation_mask, 1);
        if thePos > 1 then // 说明昵称部分格式即正确，也不会为空（即"");
        begin
          nick := midstr(quotation_mask, 2, thePos - 1);
          mailAddress := trim(midstr(quotation_mask, thePos, Length
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
              mailAddress := midstr(mailAddress, 1, Length(mailAddress) - 2)
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
                mailAddress := midstr(space[1], 2, Length(space[1]) - 2)
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
                  bracket[1] := leftStr(bracket[1], Length(bracket[1]) - 1);
                  // 去除邮箱:<zhangsan@163.com>最右边的'>'字符;
                  mailAddress := bracket[1];

                  nick := iif(trim(bracket[0]) = '', StrSplit(bracket[1], ['@'])
                      [0], StrSplit(trim(bracket[0]), ['@'])[0]);
                  // 处理类如<zhangsan@.163.com>,没有呢称部分形式的邮箱,把@前的用户名部分当作用户的呢称;
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

function sysSet: Tset;
begin
  Result := Tset(WebContext.FindModuleClass(Tset));
end;

procedure Tset.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  tmp: string;
  MailBoxConfig: TMailBoxConfigDatabase;
  MailBoxConfigRec: TMailBoxConfigRec;
  currentUser: TUser;
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
      ReplaceText := '<a href="' + Request.InternalScriptName +
        '/readTxtModule?ms=' + Session.SessionID + loginModule.AppendUserInfo +
        '&amp;f=' + tmp + '">' + ('详细信息') + '</a>';
    end;
  end
  else
  if TagString='SAC' then
  begin
    if not GetUserAndNullToFirstPage(currentUser) then
    begin
      DispatchPageName('main', Response, []);
      Main.Response.SendResponse;
      exit;
    end;

    MailBoxConfig := TMailBoxConfigDatabase.Create(self);
    MailBoxConfigRec := MailBoxConfig.GetMailBoxPrivateConfig(currentUser.currentSelectMail);
    if (MailBoxConfigRec.PhoneNum<>'') then
      ReplaceText := '保存'
    else
      ReplaceText := '取消';
    MailBoxConfigRec.Free;
    MailBoxConfig.Free;
  end
  else
  if TagString='MP' then
  begin
    if msg='' then
    begin
      if not GetUserAndNullToFirstPage(currentUser) then
      begin
        DispatchPageName('main', Response, []);
        Main.Response.SendResponse;
        exit;
      end;

      MailBoxConfig := TMailBoxConfigDatabase.Create(self);
      MailBoxConfigRec := MailBoxConfig.GetMailBoxPrivateConfig(currentUser.currentSelectMail);
      ReplaceText := MailBoxConfigRec.PhoneNum;
      MailBoxConfigRec.Free;
      MailBoxConfig.Free;
    end
  end
  else
  if TagString='msg' then
  begin
     ReplaceText := msg;
     msg := '';
  end;
end;

procedure Tset.WebPageModuleAfterDispatchPage(Sender: TObject; const PageName: string);
begin
  WebContext.Session.Values[TConfig.SendMailStateCode] := '';
  WebContext.Session.Values[TConfig.SendMailStateInfo] := '';
end;

// 保存邮件到DB
procedure SaveToOutMailBox(msg: TIdMessage; location: MailStatus);
var
  UserMailInBox: TUserMailInBoxRec;
  StringStream: TStringStream;
  guid: TGUID;
begin
  UserMailInBox := TUserMailInBoxRec.Create;
  UserMailInBox.UserEMail := msg.From.Text;
  SysUtils.CreateGUID(guid);
  UserMailInBox.MailID := ReplaceText
    (ReplaceText(ReplaceText(SysUtils.GUIDToString(guid), '-', ''), '{', ''),
    '}', '');
  UserMailInBox.UserEMail := ReplaceText(UserMailInBox.UserEMail, '<', '');
  UserMailInBox.UserEMail := ReplaceText(UserMailInBox.UserEMail, '>', '');
  UserMailInBox.RecvTime := now;
  UserMailInBox.FromAddr := msg.FromList.EMailAddresses; // trim(ReplaceText(msg.FromList.EMailAddresses,' <','<'));
  UserMailInBox.Recipient := msg.FromList.EMailAddresses; // trim(ReplaceText(msg.Recipients.EMailAddresses,' <','<'));
  UserMailInBox.CC := msg.CCList.EMailAddresses;
  UserMailInBox.BCC := msg.BccList.EMailAddresses;
  UserMailInBox.Subject := msg.Subject;
  UserMailInBox.Body := msg.Body.Text;

  StringStream := TStringStream.Create;
  msg.SaveToStream(StringStream);
  UserMailInBox.OrginalContent := StringStream.DataString;
  StringStream.Free;
  UserMailInBox.Status := Integer(location);
  DataModule.WebDataModuleShare.InsertGuestUserMailInBox(UserMailInBox);
  UserMailInBox.Free;
end;

procedure Tset.WebPageModuleBeforeDispatchPage
  (Sender: TObject; const PageName: string; var Handled: Boolean);
var
  currentUser: TUser;
  UserMailInBoxDAO: TUserMailInBoxDAO;
  kv: TKeyValue;
  MailList: TObjectList<TUserMailInBoxRec>;

  objList: TObjectList<TKeyValue>;
  sql, MailID: string;

  MailBoxConfig: TMailBoxConfigDatabase;
  MailBoxConfigRec: TMailBoxConfigRec;
  UserMailInBox:TUserMailInBoxRec;
  stream:TStream;
begin

  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
  // if WebContext.Session.Values[TConfig.cSMTPServer]='' then
  if not GetUserAndNullToFirstPage(currentUser) then
  begin
    DispatchPageName('main', Response, []);
    Main.Response.SendResponse;
    exit;
  end;

  MailBoxConfig := TMailBoxConfigDatabase.Create(self);
  MailBoxConfigRec := MailBoxConfig.GetMailBoxPrivateConfig(currentUser.currentSelectMail);


  if (Request.ContentFields.Values['T']<>'') then
  begin
   // pageProducer.HTMLDoc.LoadFromFile(GetCurrentPath,'setModule_CancelSaveMSG.wml');
    if (Request.ContentFields.Values['T'] = '0') then // T为Type的缩写;  0 表示不保存
    begin

        MailBoxConfigRec.SaveToOutMailBox := 0
    end
    else if (Request.ContentFields.Values['T'] = '1') then // T为Type的缩写;  1 表示保存
        MailBoxConfigRec.SaveToOutMailBox := 1;
    MailBoxConfig.Update(MailBoxConfigRec);

    //Response.Content := PageProducer.Content;
    //Handled := true;

//    if MailBoxConfigRec<>nil then
//      MailBoxConfigRec:=nil;
//    if MailBoxConfig<>nil then
//      MailBoxConfig:=nil;

//    exit;
  end;



  //删除
  if (Request.ContentFields.Values['D'] <>'')then
  begin
   // UserMailInBoxDAO := TUserMailInBoxDAO.Create(self);

    if (Request.ContentFields.Values['D'] = '0') then // D为 Delete 的缩写;  0 表示删除草稿箱邮件
    begin
//       kv := TKeyValue.Create('int', integer(Domain.UserMailInBox.eAlreadySent));
//       MailList := UserMailInBoxDAO.ReadMailBoxBy(currentUser.currentSelectMail,'Status',kv);
         sql := 'delete from userInBox where UserEMail='''+ currentUser.currentSelectMail+''' and Status='+IntToStr(Integer(MailStatus.eAlreadySent));
         MailBoxConfig.Execute16(sql);
        // UserMailInBoxDAO.Execute16(sql);
    end
    else if (Request.ContentFields.Values['D'] = '1') then //D为 Delete 的缩写;  1 表示删除发件箱邮件
    begin
       sql := 'delete from userInBox where UserEMail='''+ currentUser.currentSelectMail+''' and Status='+IntToStr(Integer(MailStatus.eWaitForSend));
       MailBoxConfig.Execute16(sql);
    end;

  end;

  //保存手机号
  if (Request.ContentFields.IndexOfName('MP')<>-1)then
  begin
    if (LeftStr(Request.ContentFields.Values['MP'],3) <> '135') then// in ['130'..'139','150'..'151','180'..'189'])) then
      msg := '手机号码错误！'
    else
    begin
      sql := 'Update MailBoxConfig set PhoneNum='''+Request.ContentFields.Values['MP']+''' where UpdateMail='''+ currentUser.currentSelectMail+'''';
      MailBoxConfig.Execute16(sql);
    end;
  end;


  if (MailBoxConfigRec<>nil) then
  begin
    if MailBoxConfigRec.SaveToOutMailBox=1 then
    begin
      //PageProducer.HTMLDoc.LoadFromFile(GetCurrentPath+'setModule_CancelSaveMSG.wml')
      //LoadFromResource(pageProducer,'setModule_CancelSaveMSG');   //防止 Range Check Error , 改成下面几句： 2009-9-28 09:29

      stream :=TStringStream.Create('',TEncoding.UTF8);
      LoadFromResource(stream,'setModule_CancelSaveMSG');
      PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
      stream.Free;
    end
    else
    begin
      //PageProducer.HTMLDoc.LoadFromFile(GetCurrentPath+'setModule_EnableSaveMSG.wml');
      //LoadFromResource(pageProducer,'setModule_EnableSaveMSG');  //防止 Range Check Error , 改成下面几句： 2009-9-28 09:29
      stream :=TStringStream.Create('',TEncoding.UTF8);
      LoadFromResource(stream,'setModule_EnableSaveMSG');
      PageProducer.HTMLDoc.Text := TStringStream(stream).DataString;
      stream.Free;
    end;

    MailBoxConfigRec.Free;
    MailBoxConfig.Free;
    Response.Content := PageProducer.Content;
    Response.SendResponse;
    Handled := true;

    if MailBoxConfigRec<>nil then
     MailBoxConfigRec:=nil;
    if MailBoxConfig<>nil then
     MailBoxConfig:=nil;

    exit;
  end;



end;

initialization

if WebRequestHandler <> nil then
  WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create
      (Tset, TWebPageInfo.Create([wpPublished
        { , wpLoginRequired } ], '.wml'), crOnDemand, caCache)

    );

end.
