unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DISQLite3DataSet, DISQLite3Database, StdCtrls,Rtti, ADODB,TypInfo,Generics.Collections,
  Domain.UserMailInBox, DAO.UserMailInBox;

type
  TForm3 = class(TForm)
    DISqlite3UniDirQuery1: TDISqlite3UniDirQuery;
    Button1: TButton;
    DISQLite3Database1: TDISQLite3Database;
    Button2: TButton;
    Button3: TButton;
    ButtonUpdate: TButton;
    ButtonDelete: TButton;
    ADOCommand1: TADOCommand;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ButtonUpdateClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses
  DISQLite3_Encryption_DB, Encryption_DB;

const
  FILE_NAME = 'F:\Projects\WAPMail..CC_Delphi2010_20090830\bin\data\db.db';//'Encrypted.db3';


{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  DISQLite3Database1.Open;
  DISqlite3UniDirQuery1.Open;
end;

procedure TForm3.Button2Click(Sender: TObject);
var
  mdb:TMailBoxConfigDatabase;
  MBCR:TMailBoxConfigRec;
  p:PMailBoxConfigRec;
begin
  mdb:=TMailBoxConfigDatabase.Create(self);
  mdb.DatabaseName :=FILE_NAME;
  MBCR :=mdb.GetMailBoxConfig('i@.cc');
  ShowMessage(MBCR.MailDomain);
end;

procedure TForm3.Button3Click(Sender: TObject);
var
  mdb:TMailBoxConfigDatabase;
  MBCR:TMailBoxConfigRec;
begin
  mdb:=TMailBoxConfigDatabase.Create(self);
  mdb.DatabaseName :=FILE_NAME;
  MBCR := TMailBoxConfigRec.CreatePredigest('i@.cc','abc');
  mdb.AddMailBoxConfig(MBCR);

end;

procedure TForm3.Button4Click(Sender: TObject);
var
  mdb:TMailBoxConfigDatabase;
  MBCR:TMailBoxConfigRec;
  sql:string;
  //params:TParams;
  //parma:TParam;
  pairs:TList<TPair<String,TValue>>;

  test:TDictionary<String,TValue>;
  t:TPair<String,TValue>;
  lv:TList<TValue>;
  kind:TTypeKind;
  v:TValue;
  str:string;
begin
  mdb:=TMailBoxConfigDatabase.Create(self);
  mdb.DatabaseName :=FILE_NAME;
  MBCR := TMailBoxConfigRec.CreatePredigest('i@.cc','abc');
  MBCR.InitializeProcess;
  pairs := TList<TPair<String,TValue>>.Create;
  pairs.Add(TPair<String,TValue>.Create('str',MBCR.MailDomain));

  lv := TList<TValue>.Create;
  lv.Add('');
  lv.Add(1);
  lv.Add(Now);
  for v in lv do
    ShowMessage(v.TypeInfo^.Name);
  lv.free;

  test:=TDictionary<String,TValue>.Create;
  test.Add('str','中国人民！');
  test.Add('int',2);
  for t in test do
  begin
    str := t.Value.AsVariant ;
    ShowMessage(str);
  end;

  sql := 'INSERT INTO MailBoxConfig(MailDomain,SMTPServer,POP3Server,SMTPPort,POP3Port,SMTPSSL,POP3SSL,SMTPSSLPort,POP3SSLPort,POP3UserName,POP3Password,SMTPUserName,SMTPPassword,UpdateMail,UpdateTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,current_timestamp);';
  //mdb.AddMailBoxConfig(MBCR);
end;

procedure TForm3.Button5Click(Sender: TObject);
var
  inBox:Domain.UserMailInBox.TUserMailInBoxRec;
  guid:TGUID;
  DAOUserInbox:DAO.UserMailInBox.TUserMailInBoxDAO;
begin
  inBox := TUserMailInBoxRec.Create;
  inBox.UserEMail := 'i@.cc';
  CreateGUID(guid);
  inBox.MailID := GUIDToString(guid);
  inBox.FromAddr := 'helpus@163.com';
  inBox.Recipient := 'lwgboy@sohu.com,i@.cc';
  inBox.CC := '';
  inBox.BCC := '';
  inBox.Subject := '关于促进发展的决议';
  inBox.AttchFileName :='http://www..cc/wapmail/attachFile/1001.xls';
  inBox.Body :='详细内容';
  inBox.OrginalContent :='原始内容';
  inBox.RecvTime := now;
  inBox.Status := 0;

  DAOUserInbox := DAO.UserMailInBox.TUserMailInBoxDAO.Create(self);
  DAOUserInbox.DatabaseName := FILE_NAME;
  DAOUserInbox.Add(inBox);
end;

procedure TForm3.Button6Click(Sender: TObject);
var
  inBox:Domain.UserMailInBox.TUserMailInBoxRec;
  guid:TGUID;
  DAOUserInbox:DAO.UserMailInBox.TUserMailInBoxDAO;
  objList:TObjectList<TUserMailInBoxRec>;
begin
  DAOUserInbox:=DAO.UserMailInBox.TUserMailInBoxDAO.Create(self);
  DAOUserInbox.DatabaseName :=FILE_NAME;
  objList:=DAOUserInbox.Readx('i@.cc');
  ShowMessage(objList.Items[0].Subject+objList.Items[0].Body);
end;

procedure TForm3.Button7Click(Sender: TObject);
var
  mailBoxList:TObjectList<TUserMailInBoxRec>;
  userInBox:DAO.UserMailInBox.TUserMailInBoxDAO;
  mailInBox: TUserMailInBoxRec;
begin
  userInBox := DAO.UserMailInBox.TUserMailInBoxDAO.Create(self);
  userInBox.DatabaseName := FILE_NAME;
  mailBoxList := userInBox.Read('i@.cc');
  for mailInBox in mailBoxList do
  begin
    ShowMessage(DateToStr(mailInBox.RecvTime));
  end;
  mailBoxList.Free;
  userInBox.Free;
end;

procedure TForm3.Button8Click(Sender: TObject);
var
  mailBoxList:TObjectList<TUserMailInBoxRec>;
  userInBox:DAO.UserMailInBox.TUserMailInBoxDAO;
  mailInBox: TUserMailInBoxRec;
  objList:TObjectList<TKeyValue>;
begin
  userInBox := DAO.UserMailInBox.TUserMailInBoxDAO.Create(self);
  userInBox.DatabaseName := FILE_NAME;
  objList:=TObjectList<TKeyValue>.Create;
  //objList.Add(TKeyValue.Create('str','UserEmail'));
  //objList.Add(TKeyValue.Create('str','i@.cc'));
//  mailBoxList := userInBox.ReadBy('UserEmail',TKeyValue.Create('str','i@.cc'));
//  for mailInBox in mailBoxList do
//  begin
//    ShowMessage(DateTimeToStr(mailInBox.RecvTime));
//  end;
  mailBoxList.Free;
  userInBox.Free;
end;

procedure TForm3.Button9Click(Sender: TObject);
var
  userInBox:DAO.UserMailInBox.TUserMailInBoxDAO;
  mailInBox: TUserMailInBoxRec;
  objList:TObjectList<Encryption_DB.TKeyValue>;
  sql:string;
begin
  userInBox := DAO.UserMailInBox.TUserMailInBoxDAO.Create(self);
  userInBox.DatabaseName := FILE_NAME;
  objList:=TObjectList<TKeyValue>.Create;

  objList.Add(TKeyValue.Create('str','lwg@oceansoft.com.cn'));
  objList.Add(TKeyValue.Create('str','4AD09A001B134B09AE0647B79B0750C5'));
  sql := 'delete from userInBox where UserEMail=? and MailId=?;';
  userInBox.Delete(sql,objList);
  objList.clear;
  objList:= nil;
  userInBox.Free;
end;



procedure TForm3.ButtonUpdateClick(Sender: TObject);
var
  mdb:TMailBoxConfigDatabase;
  MBCR:TMailBoxConfigRec;
  ctx:TRTTIContext;
begin
  mdb:=TMailBoxConfigDatabase.Create(self);
  mdb.DatabaseName :=FILE_NAME;
  MBCR := TMailBoxConfigRec.CreatePredigest('i@.cc','中国');
  mdb.Update(MBCR);

 //ctx.GetType('TForm3').GetMethod('').Invoke()
end;

end.
