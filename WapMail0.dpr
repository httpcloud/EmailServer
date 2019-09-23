//library WapMail;
//
//uses
//  ActiveX,
//  ComObj,
//  WebBroker,
//  ISAPIApp,
//  ISAPIThreadPool,
//  //mainFrm in 'mainFrm.pas' {MainForm},
//  Main in 'Main.pas' {MainModule: TWebAppPageModule} {*.wml},
//  login in 'login.pas' {loginModule: TWebPageModule} {*.wml},
//  inBox in 'inBox.pas' {inBoxModule: TWebPageModule} {*.wml},
//  outBox in 'outBox.pas' {outBoxModule: TWebPageModule} {*.wml},
//  sendMail in 'sendMail.pas' {sendMailModule: TWebPageModule} {*.wml},
//  EMailCode in 'EMailCode.pas',
//  detail in 'detail.pas' {detailModule: TWebPageModule} {*.wml};
//
//{$R *.res}
//
//exports
//  GetExtensionVersion,
//  HttpExtensionProc,
//  TerminateExtension;
//
//begin
//  CoInitFlags := COINIT_MULTITHREADED;
//  Application.Initialize;
//  Application.Run;
//end.


program WapMail0;

{$APPTYPE GUI}

uses
  Forms,
  SockApp,
  mainFrm in 'mainFrm.pas' {MainForm},
  MainModule in 'MainModule.pas' {Main: TWebAppPageModule} {*.wml},
  loginModule in 'loginModule.pas' {login: TWebPageModule} {*.wml},
  inBoxModule in 'inBoxModule.pas' {inBox: TWebPageModule} {*.wml},
  outBoxModule in 'outBoxModule.pas' {outBox: TWebPageModule} {*.wml},
  sendModule in 'sendModule.pas' {send: TWebPageModule} {*.wml},
  writeModule in 'writeModule.pas' {write: TWebPageModule} {*.wml},
  detailModule in 'detailModule.pas' {detail: TWebPageModule} {*.wml},
  readTxtModule in 'readTxtModule.pas' {readTxt: TWebPageModule} {*.wml},
  EMailCode in 'EMailCode.pas',
  gb_big5 in 'gb_big5.pas',
  serialization in 'serialization.pas',
  HashMap in 'dcl\HashMap.pas',
  config in 'config.pas' ,
  big5 in 'big5.pas',
  AbstractContainer in 'dcl\AbstractContainer.pas',
  DCLUtil in 'dcl\DCLUtil.pas',
  DCL_intf in 'dcl\DCL_intf.pas',
  ArrayList in 'dcl\ArrayList.pas',
  ArraySet in 'dcl\ArraySet.pas',
  Algorithms in 'dcl\Algorithms.pas',
  UEncode in 'UEncode.pas',
  EZCrypt in 'EZCrypt.pas',
  RegisterModule in 'RegisterModule.pas' {reg: TWebPageModule},
  actionModule in 'actionModule.pas' {action: TWebPageModule},
  DataModule in 'DataModule.pas' {WebDataModuleShare: TWebDataModule},
  addNewMailBoxModule in 'addNewMailBoxModule.pas' {Add: TWebPageModule} {*.wml};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

