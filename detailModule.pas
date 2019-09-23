unit detailModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd,IdMessage,MSHtml,
  ActiveX,ComObj,IdGlobal,EMailCode,StrUtils,IdPOP3,webDisp,IdStrings,windows,IdText,IdAttachment,common;

type
  Tdetail = class(TWebPageModule)
    PageProducer: TPageProducer;
    procedure WebPageModuleBeforeDispatchPage(Sender: TObject;
      const PageName: string; var Handled: Boolean);
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
  private
    { Private declarations }
    addresser,recipients,CC,subject,mailTime,body:string;
    Attachment:TStringList;
  public
    { Public declarations }
  end;

  function detail: Tdetail;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants,loginModule,inBoxModule,MainModule,Config,gb_big5,DCPbase64,UTF8ContentParser;

function getTextOfHTML_For_Delphi_Net(htmlText:string):string;
var
  IDoc : IhtmlDocument2;
//  IPFile:IPersistFile;
//  strhtml : String;
//  v : Variant;
begin
  CoInitialize(nil);
  IDoc := CreateComObject(Class_htmlDOcument) as IhtmlDocument2;
//  IPFile := IDoc as IPersistFile;
  try
    IDoc.designMode := 'off';
//    v:= VarArrayCreate([0,0],VarVariant);
//    v[0]:= htmlText;
//    IDoc.write(PSafeArray(v)) ;
    IDOC.body.insertAdjacentHTML('BeforeEnd',htmlText);
    Result := IDoc.body.outerText;
  finally
    IDoc.close;
    IDoc := nil;
  end;
end;

function getTextOfHTML(htmlText:string):string;
var
  IDoc : IhtmlDocument2;
  IPFile:IPersistFile;
  strhtml : String;
  v : Variant;
begin
  CoInitializeEx(nil,COINIT_MULTITHREADED);
  IDoc := CreateComObject(Class_htmlDOcument) as IhtmlDocument2;
  IPFile := IDoc as IPersistFile;
  try
    IDoc.designMode := 'off';
    v:= VarArrayCreate([0,0],VarVariant);
    v[0]:= htmlText;
    IDoc.write(pSafearray(TVarData(v).VArray)) ;
    Result := IDoc.body.outerText;
  finally
    IDoc.close;
    IDoc := nil;
  end;
end;


function detail: Tdetail;
begin
  Result := Tdetail(WebContext.FindModuleClass(Tdetail));
end;

{$REGION '��ȡָ�����ֵ�ƴ��������ĸ���磺��������������ĸ�ǡ�H��'}
function   GetPYIndexChar(   hzchar:string):char;
begin
    case   WORD(hzchar[1])   shl   8   +   WORD(hzchar[2])   of
        $B0A1..$B0C4   :   result   :=   'A';
        $B0C5..$B2C0   :   result   :=   'B';
        $B2C1..$B4ED   :   result   :=   'C';
        $B4EE..$B6E9   :   result   :=   'D';
        $B6EA..$B7A1   :   result   :=   'E';
        $B7A2..$B8C0   :   result   :=   'F';
        $B8C1..$B9FD   :   result   :=   'G';
        $B9FE..$BBF6   :   result   :=   'H';
        $BBF7..$BFA5   :   result   :=   'J';
        $BFA6..$C0AB   :   result   :=   'K';
        $C0AC..$C2E7   :   result   :=   'L';
        $C2E8..$C4C2   :   result   :=   'M';
        $C4C3..$C5B5   :   result   :=   'N';
        $C5B6..$C5BD   :   result   :=   'O';
        $C5BE..$C6D9   :   result   :=   'P';
        $C6DA..$C8BA   :   result   :=   'Q';
        $C8BB..$C8F5   :   result   :=   'R';
        $C8F6..$CBF9   :   result   :=   'S';
        $CBFA..$CDD9   :   result   :=   'T';
        $CDDA..$CEF3   :   result   :=   'W';
        $CEF4..$D188   :   result   :=   'X';
        $D1B9..$D4D0   :   result   :=   'Y';
        $D4D1..$D7F9   :   result   :=   'Z';
    else
        result   :=   char(0);
    end;
end;
{$ENDREGION}

function getMsgSaveToFileName(msgId:string;extName:string='.lwg'):string;
var
  fname:string;
begin
  fname := ReplaceText(MsgId,'\','');
  fname := ReplaceText(fname,'/','');
  fname := ReplaceText(fname,'|','');
  fname := ReplaceText(fname,'?','');
  fname := ReplaceText(fname,'*','');
  fname := ReplaceText(fname,'<','');
  fname := ReplaceText(fname,'>','');
  fname := ReplaceText(fname,':','');
  fname := ReplaceText(fname,'"','');
  //fname := ReplaceText(fname,'$','$$'); //$��Wap�лᱻ����ΪWap�ı���,����ᱻWap��������ɱ���������$��������ݲ����ύ����˵��ͻ��˵������$���ŵ��ļ���ʱ���ܻ���ʾ�Ҳ���,���������滻������$$ʹ֮ת��Ϊ����������������������ȷ���ύ��
  fname := ReplaceText(fname,'$','');   //Ϊ�˼��ٴ�������ֱ�ӽ�����$�滻�����������滻��$$��ת��Ϊ����
  Result := GetCurrentPath+TConfig.userInBoxPath+fname+extName;
end;

//var
//  addresser,recipients,CC,subject,mailTime,body,Attachment:string;
procedure Tdetail.WebPageModuleBeforeDispatchPage(Sender: TObject; const PageName: string; var Handled: Boolean);
var
  id:string;
  txtTmp,fileName,fileNameTmp,charSet,encoder,mailType,tmp:string;
  msg:TIdMessage;
  i,mailSize,
  bodyAllPageNum,    //�ż�����ҳ��
  currentPageNum //��ǰ���ż���ĵڼ�ҳ
  :integer;
  POP3:TIdPOP3;
  //contentStr:TStringList;

  AStream:TFileStream;
  Stream:TBytesStream;

  fs:TFileStream;
  ms:TMemoryStream;
  fid:string;

  msgInStream,msgOutStream:TMemoryStream;
begin

  if GetUserPOP3(POP3) then
  begin
    if not POP3.Connected then
    begin
      POP3.ConnectTimeout := 1500;
      POP3.Connect;
    end;

    fid := Request.QueryFields.Values['fid'];
    filename:= Request.QueryFields.Values['fn'];
    if (fid<>'') then
    begin
      fid := GetCurrentPath+TConfig.userInBoxPath+fid;
      if not FileExists(fid) then
        Response.Content := 'û�з�����Ϊ'+Request.QueryFields.Values['fid']+'����'
      else
      begin
        filename := HTTPDecode(filename); // ����ͨ�� HTTPEncode ���������ĵ��ַ����ļ���ת��Ϊ HTML�������ļ���   --lwgboy 2009-9-11 0:15
        filename := iif(filename<>'',filename,'����'+ExtractFileExt(fid));
        try
          ms:=TMemoryStream.Create;
          //ms.LoadFromFile(fid);  //�ĳ����漸�䣬�Ի�ԭ����.  -- lwgboy, 2009-09-26
          msgInStream:= TMemoryStream.Create;
          msgInStream.LoadFromFile(fid);
          common.decryptTemplate(msgInStream,ms,msgInStream.Size);
          msgInStream.Free;
          ms.Position := 0;
        {
          Response.ContentType := Config.GetMIMEType(ExtractFileExt(fid));
          Response.CustomHeaders.Append('Content-Disposition= attachment; filename="'+fileName+'"');
          Response.CustomHeaders.Append('Content-Length= '+IntToStr(ms.Size));
          Response.CustomHeaders.Append('Content-Transfer-Encoding= binary');
          Response.ContentStream:=ms;
          Response.SendResponse;
          Response.SendStream();
          Handled := true;
        }
        Request.WriteString('HTTP/1.1 200'#13#10);
        //Request.WriteString(Format('%s;boundary="%s"'#13#10#13#10, [MultipartContentType, Boundary]));
        //Request.WriteString(#13#10   '--'   Boundary   #13#10);
        Request.WriteString('Content-Type: '+Config.GetMIMEType(ExtractFileExt(fid))+#13#10);
        Request.WriteString('Content-Disposition: attachment; filename="'+fileName+'"'+#13#10);
        Request.WriteString('Content-Length: '+IntToStr(ms.Size)+#3#10);
        Request.WriteString('Content:'+ #13#10#13#10);
        Response.SendStream(ms);
        Response.SendResponse;
        Sleep(50);
        finally
          if (Response.Sent) then
            ms.Free;
        end;
        exit;
      end;
    end;
    Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';

    id := Request.QueryFields.Values['id'];
    if id<>'' then
    begin
      try
        msg := TIdMessage.Create(nil);
        try
          POP3.RetrieveHeader(strToIntDef(id,1),msg);
          session.values['mailID'] := strToIntDef(id,1);
          fileName := getMsgSaveToFileName(msg.MsgId);
          if SysUtils.FileExists(fileName) then
          begin

//             msg.Clear;
//             msg.NoDecode := false;
//             msg.NoEncode := false;
//             msg.IsEncoded := false;

              //msg.LoadFromFile(fileName);  //�滻Ϊ����ļ���,�Ա�����ż�����. 2009-9-26 15:48
              msgInStream:= TMemoryStream.Create;
              msgOutStream:= TMemoryStream.Create;
              msgInStream.LoadFromFile(fileName);
              common.decryptTemplate(msgInStream,msgOutStream,msgInStream.Size);
              msgOutStream.Position :=0;
              msg.LoadFromStream(msgOutStream);
              msgInStream.Free;
              msgOutStream.Free;
          end
          else
          begin
            mailSize := POP3.RetrieveMsgSize(strToIntDef(id,1));
            if mailSize<1024*1024 then //���ƽ��յ��ʼ���СΪ1M.
            begin
               //msg.NoDecode := true;
               msg.NoDecode := false;
               msg.NoEncode := False;
               POP3.Retrieve(strToIntDef(id,1),msg);
               //msg.SaveToFile(fileName);    ��Ϊ���漸�䣬�Լ����ż�����

                msgInStream:= TMemoryStream.Create;
                msgOutStream:= TMemoryStream.Create;
                msg.SaveToStream(msgInStream);
                msgInStream.Position := 0;
                common.encryptTemplate(msgInStream,msgOutStream,msgInStream.Size);
                msgOutStream.SaveToFile(fileName);
                msgInStream.Free;
                msgOutStream.Free;

               msg.NoDecode := False;
               msg.NoEncode := True;
               //msg.LoadFromFile(fileName);
            end;
          end;
        except on E:Exception do
           if E.ClassNameIs('EIdConnClosedGracefully') then
           begin
             try
                POP3.ConnectTimeout := 1500;
                POP3.Connect;
             except on E:Exception do
               begin
                 DispatchPageName('main',Response,[]);
                 Main.Response.SendResponse;
               end;
             end;
             if POP3.Connected then
             begin
                POP3.RetrieveHeader(strToIntDef(id,1),msg);
                session.values['mailID'] := strToIntDef(id,1);
                fileName := getMsgSaveToFileName(msg.MsgId);
                if SysUtils.FileExists(fileName) then
                begin
                   //msg.LoadFromFile(fileName);  //��Ϊ���漸�䣬�Լ��ڼ��ܵ����ݣ�

                    msgInStream:= TMemoryStream.Create;
                    msgOutStream:= TMemoryStream.Create;
                    msgInStream.LoadFromFile(fileName);
                    common.decryptTemplate(msgInStream,msgOutStream,msgInStream.Size);
                    msgOutStream.Position :=0;
                    msg.LoadFromStream(msgOutStream);
                    msgInStream.Free;
                    msgOutStream.Free;
                end
                else
                begin
                  mailSize := POP3.RetrieveMsgSize(strToIntDef(id,1));
                  if mailSize<1024*1024 then //���ƽ��յ��ʼ���СΪ1M.
                  begin
                     //POP3.Retrieve(strToIntDef(id,1),msg);
                     Stream := TBytesStream.Create();
                     POP3.RetrieveRaw(strToIntDef(id,1),Stream);
                     msg.loadFromStream(stream);

                     //msg.SaveToFile(fileName);  //��Ϊ���漸�䣬�Լ����ʼ����ݡ�


                      msgOutStream:= TMemoryStream.Create;
                      Stream.Position :=0;
                      common.encryptTemplate(Stream,msgOutStream,Stream.Size);
                      msgOutStream.SaveToFile(fileName);
                      msgOutStream.Free;

                      stream.Free;
                  end;
                end;
             end;
           end
           else
           begin
             DispatchPageName('main',Response,[]);
             Main.Response.SendResponse;
           end;
        end;

        txtTmp := iif(msg.From.Name='',msg.From.text,msg.From.Name);
        if(posEx('?B?',txtTmp)>0) or (posEx('?Q?',txtTmp)>0)then
          txtTmp := MyDecode(txtTmp);
        txtTmp := iif(txtTmp<>'',txtTmp,'')+'&lt;'+msg.From.Address+'&gt;';

        addresser := txtTmp;
        //self.PageProducer.OnHTMLTag(Sender,tag,'sender',nil,txtTmp);

        recipients := '';
        for i:=0 to msg.Recipients.Count-1 do
        begin
          txtTmp := ifThen(msg.Recipients[i].Name='',msg.Recipients[i].text,msg.Recipients[i].Name);
          if(posEx('?B?',txtTmp)>0) or (posEx('?Q?',txtTmp)>0)then
            txtTmp := MyDecode(txtTmp);
          if i > 0 then
            recipients := recipients + ',';
            recipients := recipients + iif(txtTmp<>'',txtTmp+' ','')+'&lt;'+msg.Recipients[i].Address+'&gt;'
        end;

        CC:='';
        for i:=0 to msg.CCList.Count-1 do
        begin
          txtTmp := iif(msg.CCList[i].Name='',msg.CCList[i].text,msg.CCList[i].Name);
          if(posEx('?B?',txtTmp)>0) or (posEx('?Q?',txtTmp)>0)then
            txtTmp := MyDecode(txtTmp);
          CC:= CC+iif(txtTmp<>'','&lt;'+txtTmp+'&gt;','')+msg.CCList[i].Address+' ';
        end;


        if(posEx('?B?',uppercase(msg.Subject))>0) or (posEx('?Q?',uppercase(msg.Subject))>0)then
           subject := MyDecode(msg.Subject)
        else
           subject := msg.Subject;

        subject := FilterSpecialCharacter(subject);

        mailTime := FormatDateTime('yyyymmdd hh:mm',msg.Date);

        txtTmp := '';
        body   := '';
        Attachment := nil;
        if msg.MessageParts.Count>0 then
          for i:=0 to msg.MessageParts.Count-1 do
          begin
            if (msg.MessageParts.Items[i] is TIDtext) and (txtTmp='') then //�ż�����
            begin
              txtTmp := TIdText(msg.MessageParts.Items[i]).Body.text;
              {
              while PosEx(#13#10#13#10,txtTmp)>0 do
                txtTmp := StringReplace(txtTmp,#13#10#13#10,'',[rfReplaceAll]);
              txtTmp := StringReplace(txtTmp,#13#10,'<br/>',[rfReplaceAll]);
              }

              {
              //if lowercase(TIdText(msg.MessageParts.Items[i]).CharSet)<>'gb2312' then //indy10
              if Pos('gb2312',lowercase(TIdText(msg.MessageParts.Items[i]).ContentType))<1 then
              begin

                if (pos('?B?',uppercase(txtTmp))>0) or (pos('?Q?',uppercase(txtTmp))>0) then
                   txtTmp :=  MyDecode(txtTmp)
                else
                if pos('big5',lowercase(TIdText(msg.MessageParts.Items[i]).ContentType))>0 then
                   txtTmp := GBChs2Cht(Big52GB(txtTmp));
//                else
//                if pos('utf-8',lowercase(TIdText(msg.MessageParts.Items[i]).ContentType))>0 then
//                   txtTmp := GBChs2Cht(Big52GB(txtTmp));

              end;
                 //txtTmp := System.Text.ASCIIEncoding.Default.GetString(Encoding.Convert(Encoding.GetEncoding(TIdText(msg.MessageParts.Items[i]).CharSet),Encoding.GetEncoding('GB2312'),System.Text.Encoding.Default.GetBytes(txtTmp)));

              if msg.MessageParts.Items[i].ContentType<>'text/html' then  //�ı���ʽ�ż�
                 body := body+txtTmp
              else  //HTML��ʽ�ʼ�
                 body := body+getTextOfHTML(txtTmp);
                 //body := body+StringReplace(getTextOfHTML(txtTmp),#13#10,'<br/>',[rfReplaceAll,rfIgnoreCase]);
              }

              //delphi2009 ���е� indy �Ѿ���CharSet��ContentType���룬��CharSet�Ѿ���һ�����������ԣ��Ѿ�����ֵ���������ﲻ�ٽ���������CharSet�ˡ� --lwgoby
              {
              SplitString(TIdText(msg.MessageParts.Items[i]).ContentType,';',mailType,charSet);  -- lwgboy 2009-10-26 ע�͵�
              mailType := lowercase(trim(mailType));
              SplitString(charSet,'=',tmp,charSet);
              charSet := lowercase(ReplaceStr(charSet,'"',''));
              }
              mailType :=  lowercase(TIdText(msg.MessageParts.Items[i]).ContentType);
              charSet :=   lowercase(TIdText(msg.MessageParts.Items[i]).CharSet);

              if mailType = 'text/html' then
                 txtTmp := getTextOfHTML(txtTmp);

              //txtTmp := MyDecode(txtTmp,charSet,TIdText(msg.MessageParts.Items[i]).ContentTransfer);
              //�������ݵ������Ѿ��ǽ����ģ����Բ��ٽ��н��룬ֻ���ַ�����ת�������������Ϊ�¾䡣
              txtTmp := MyDecode(txtTmp,charSet,'',TContentType.mailBody);

              body := body+txtTmp;


            end
            else
            if msg.MessageParts.Items[I] is TIdAttachment then //�ż�����
            begin
               if Attachment=nil then
                  Attachment := TStringList.Create;
               fileName := TIdAttachment(msg.MessageParts.Items[i]).FileName;
               if (Pos('?B?',uppercase(fileName))>0) or (Pos('?Q?',uppercase(fileName))>0) then
                  fileName := MyDecode(fileName);

               fileNameTmp := getMsgSaveToFileName(msg.MsgId,IntToStr(I)+ExtractFileExt(fileName));
               Attachment.Append(fileNameTmp+'='+fileName);
               //TIdAttachment(msg.MessageParts.Items[i]).SaveToFile(fileNameTmp); //ע�͵�����Ϊ���漸�䣬�Խ��аѸ������ܣ� --lwgboy 2009-9-26 17:13
                msgInStream:= TMemoryStream.Create;
                msgOutStream:= TMemoryStream.Create;
                TIdAttachment(msg.MessageParts.Items[i]).SaveToStream(msgInStream);
                msgInStream.Position := 0;
                common.encryptTemplate(msgInStream,msgOutStream,msgInStream.Size);
                msgOutStream.SaveToFile(fileNameTmp);
                msgInStream.Free;
                msgOutStream.Free;



               //TIdAttachment(msg.MessageParts.Items[i]).ContentType; //�������ͣ�����ͼ��
            end;
          end
        else
        begin
          txtTmp := msg.Body.text;
          {
          if lowercase(msg.CharSet)<>'gb2312' then
            txtTmp :=  MyDecode(txtTmp);
          }
          //contentStr := TStringList.Create;
          if pos('text/html',msg.ContentType)<1 then
          begin
            {
            if msg.ContentTransferEncoding<>'' then
            begin
               if  lowercase(msg.ContentTransferEncoding) = 'quoted-printable' then
               begin
                 txtTmp := StringReplace(txtTmp,'='+#13#10+'=',#13#10+'=',[rfReplaceAll]);
                 txtTmp := StringReplace(txtTmp,'='+#13#10,#13#10,[rfReplaceAll]);

                 contentStr.Text := txtTmp;
                 body := QuotedPrintableDecode(txtTmp);
               end
               else
                 body := MyDecode(txtTmp);
            end
            else
              body := MyDecode(txtTmp);
            }
          end
          else  //HTML ��ʽ�ʼ�
          begin
            txtTmp := getTextOfHTML(txtTmp);
            //body := body+StringReplace(txtTmp,#13#10,'<br/>',[rfReplaceAll]);
          end;

          if msg.ContentTransferEncoding<>'' then
          begin
            if lowercase(msg.ContentTransferEncoding) = 'quoted-printable' then
            begin
              txtTmp := StringReplace(txtTmp,'='+#13#10+'=',#13#10+'=',[rfReplaceAll]);   //���˷Ƿ����룺�Ⱥ�+�س�����+�Ⱥţ�����ת��Ϊ�س�����+�Ⱥ�
              txtTmp := StringReplace(txtTmp,'='+#13#10,#13#10,[rfReplaceAll]);           //���˷Ƿ����룺�Ⱥ�+�س�����+�Ⱥţ�����ת��Ϊ�س�����
              txtTmp := StringReplace(txtTmp,'= =','=',[rfReplaceAll]);                   //���˷Ƿ����룺�Ⱥ�+�ո�+�Ⱥţ�����ת��Ϊ�Ⱥ�
              txtTmp := StringReplace(txtTmp,'= ',' ',[rfReplaceAll]);                   //���˷Ƿ����룺�Ⱥ�+�ո񣬽���ת��Ϊ�ո�

              //contentStr.Text := txtTmp;
              body := QuotedPrintableDecode(txtTmp);
            end
            else
              //delphi 2009 ���е�Indy �Ѿ���Stream����ʽ������ˣ������ٴν��н��룬����ע�͵���Ϊ�¾䣬ֱ�ӽ���ֵ��ĵ����ݸ�ֵ��Body�� --lwgboy 2009-10-26
              //body := MyDecode(txtTmp,lowercase(msg.CharSet),lowercase(msg.ContentTransferEncoding));
              body := txtTmp; //delphi 2009 ���е�Indy �Ѿ���Stream����ʽ������ˣ������ٴν��н��룬  --lwgboy 2009-10-26

          end
          else
            //body := MyDecode(txtTmp,msg.charset,'',TContentType.mailBody);
            body := txtTmp;

          {
          //only for debug
          if body<>#13#10 then
            contentStr.Append(body);
          for I := 0 to contentStr.Count - 1 do
          begin
            OutputDebugString(PChar(contentStr.Strings[i]));
          end;
          contentStr.Free;
          }
        end;

        {
        while PosEx('''',body)>0 do
          body := StringReplace(body,'''','',[rfReplaceAll]);
        }

        {
        body := StringReplace(body,'<br>',#13#10,[rfReplaceAll,rfIgnoreCase]);
        body := StringReplace(body,'</br>',#13#10,[rfReplaceAll,rfIgnoreCase]);
        //body := StringReplace(body,'<br/>',#13#10,[rfReplaceAll,rfIgnoreCase]);

        i := 0;
        while (PosEx('<',body)>0) and (i<3) do
        begin
          body := StringReplace(body,'<','&lt;',[rfReplaceAll]);
          i := i+1;
        end;
        i := 0;
        while (PosEx('>',body)>0) and (i<3) do
        begin
          body := StringReplace(body,'>','&gt;',[rfReplaceAll]);
          i := i+1;
        end;
        i := 0;
        while (PosEx(#13#10#13#10,body)>0) and (i<4) do
        begin
          body := StringReplace(body,#13#10#13#10,#13#10,[rfReplaceAll]);
          i := i+1;
        end;
        }
        {
        i := 0;
        while (PosEx(#13#10,body)>0) and (i<4) do
        begin
          body := StringReplace(body,#13#10,'<br/>',[rfReplaceAll]);
          i := i+1;
        end;
        }

        if (body='') and (mailSize>=1024*1024) then
          body := 'Sorry,�÷��ʼ����ݳ�������ط�̫С����ʾ���£�'
        else
        if (body<>'') then
        begin
          i := 0 ;
          while(Pos(body,'     ')>0) and (i<3) do //�����д���4��Ӣ�Ŀո�Ŀհ��滻��4���ո�����Ӧ���Ķ��俪ͷ�п������ϰ��,���Ὣ4��Ӣ�Ŀո��滻��4��&nbsp;����ʾwml�еĿո�
          begin
            body := StringReplace(body,'     ','    ',[rfReplaceAll]);
            i := i+1;
          end;

          mailSize := length(WideString(body)); //Ҫ��ʾ���ݵ��ܵĳ���
          bodyAllPageNum := (mailSize+TConfig.pageWordNum-1) div TConfig.pageWordNum; //��ƪ�����ܹ��ɷֵ���ҳ��
          currentPageNum := StrToIntDef(Request.QueryFields.Values['cp'],1); //�ڼ�ҳ�ı��

          if currentPageNum >= bodyAllPageNum then currentPageNum := bodyAllPageNum
          else
          if currentPageNum <= 0 then currentPageNum := 1;

          //txtTmp := midStr(body,(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum); //����mid�����������ݵĽ�ȡ��mid�����ĺ��壺���ַ����з���ָ����Ŀ���ַ���

          {
          i := 0;
          if TConfig.pageWordNum*currentPageNum+i<mailSize then
          while (Pos(body[TConfig.pageWordNum*currentPageNum+i],TConfig.EndSignSet)<1) and ((TConfig.pageWordNum+i)<mailSize) do
          begin
            if TConfig.pageWordNum*currentPageNum+i+1<mailSize then
              i := i+1
            else
              break;
          end;
          body := midStr(body,(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum+i); //����mid�����������ݵĽ�ȡ��mid�����ĺ��壺���ַ����з���ָ����Ŀ���ַ���
          }

          //body := '<![CDATA[ '+midStr(body,(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum)+' ]]>'; //����mid�����������ݵĽ�ȡ��mid�����ĺ��壺���ַ����з���ָ����Ŀ���ַ���

          {
          //������λ���Ҫ���ڹ����ַ������İ�����ֵȷǷ��ַ���
          if currentPageNum>1 then
          begin
            tmp := midStr((body),(currentPageNum-2)*TConfig.PageWordNum,TConfig.PageWordNum);
            if FilterHalfUnicode(tmp) then
              body := midStr((body),(currentPageNum-1)*TConfig.PageWordNum-1,TConfig.PageWordNum) //����mid�����������ݵĽ�ȡ��mid�����ĺ��壺���ַ����з���ָ����Ŀ���ַ���
            else
              body := midStr((body),(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum); //����mid�����������ݵĽ�ȡ��mid�����ĺ��壺���ַ����з���ָ����Ŀ���ַ���
          end
          else
            body := midStr((body),(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum);
          FilterHalfUnicode(body);
          }

          body := midStr(WideString(body),(currentPageNum-1)*TConfig.PageWordNum,TConfig.PageWordNum);
          FilterHalfUnicode(body);

          body := FilterSpecialCharacter(body);
          body := MyDecode(body,msg.CharSet,'',TContentType.mailBody);
          //body := '<![CDATA[ ' + body + ' ]]>';

          if bodyAllPageNum>1 then
          begin
             Session.Values['currentPageNum'] := currentPageNum;
             Session.Values['bodyAllPageNum'] := bodyAllPageNum;
             if currentPageNum>=bodyAllPageNum then
             begin
                Session.Values['firstPageText'] := 'ͷҳ';
                Session.Values['PrevPageText' ] := '��ҳ';
                Session.Values['nextPageText' ] := '';
                Session.Values['lastPageText' ] := '';
             end
             else
             if currentPageNum=1 then
             begin
                Session.Values['firstPageText'] := '';
                Session.Values['PrevPageText' ] := '';
                Session.Values['nextPageText' ] := '��ҳ';
                Session.Values['lastPageText' ] := 'βҳ';
             end
             else
             begin
                Session.Values['firstPageText'] := 'ͷҳ';
                Session.Values['PrevPageText' ] := '��ҳ';
                Session.Values['nextPageText' ] := '��ҳ';
                Session.Values['lastPageText' ] := 'βҳ';
             end;
          end;
        end;
      finally
        msg.Free;
      end;
    end;
  end
  else
  begin
    DispatchPageName('login',Response,[]);
    login.Response.SendResponse;
  end;
end;

procedure Tdetail.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  i:integer;
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if TagString='sender'        then ReplaceText := (addresser)
  else
  if TagString='recipients'    then ReplaceText := (recipients)
  else
  if TagString='CC'            then ReplaceText := CC
  else
  if TagString='subject'       then ReplaceText := (subject)
  else
  if TagString='attachment'    then begin
    if (Attachment<>nil) and (Attachment.Count>0) then
    begin
      ReplaceText := '����:<br/>';
      for i:=0 to Attachment.Count-1 do
      begin
        //ReplaceText := ReplaceText+'<a href="/attachment/'+ExtractFileName(Attachment.Names[i])+'">';
        //ReplaceText := ReplaceText+Attachment.ValueFromIndex[i]+'</a><br/>';
        ReplaceText := ReplaceText+'<a href="'+Request.URL+Request.InternalPathInfo+'?fid='+ExtractFileName(Attachment.Names[i])+'&amp;fn='+HTTPEncode(Attachment.ValueFromIndex[i])+'">';  // ͨ�� HTMLEncode �����ĵ��ַ�ת��ΪHTML�����ֹ�������ת��ΪUTF8,�����µ�����ӳ��ֵ����ļ�����������Ҳ����ļ������.  --lwgboy 2009-9-11 0:10
        ReplaceText := ReplaceText+Attachment.ValueFromIndex[i]+'</a><br/>';
      end;
      Attachment := nil;
    end
  end
  else
  if TagString='time'          then ReplaceText := mailTime
  else
  if TagString='body'          then ReplaceText := (body)
  else
  if TagString='ms'            then ReplaceText := Session.SessionID+loginModule.AppendUserInfo
  else
  if TagString='id'            then ReplaceText := Session.Values['mailID']
  else
  if TagString='prevPage'      then ReplaceText := IntToStr(StrToIntDef(Session.Values['currentPageNum'],1)-1)
  else
  if TagString='nextPage'      then ReplaceText := IntToStr(StrToIntDef(Session.Values['currentPageNum'],1)+1)
  else
  if TagString='lastPage'      then ReplaceText := Session.Values['bodyAllPageNum']
  else
  if TagString='firstPageText' then ReplaceText := (Session.Values['firstPageText'])
  else
  if TagString='prevPageText'  then ReplaceText := (Session.Values['prevPageText'])
  else
  if TagString='nextPageText'  then ReplaceText := (Session.Values['nextPageText'])
  else
  if TagString='lastPageText'  then ReplaceText := (Session.Values['lastPageText'])
  else
  if TagString='mailListPage'  then ReplaceText := Request.QueryFields.Values['lp'];

end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(Tdetail, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.
