library MobileMail;





{$R 'Mail_Encrypted.res' 'bin\Mail_Encrypted.rc'}

uses
  ActiveX,
  ComObj,
  WebBroker,
  ISAPIApp,
  ISAPIThreadPool,
  MainModule in 'MainModule.pas' {Main: TWebAppPageModule} {*.wml},
  loginModule in 'loginModule.pas' {login: TWebPageModule} {*.wml},
  inBoxModule in 'inBoxModule.pas' {inBox: TWebPageModule},
  outBoxModule in 'outBoxModule.pas' {outBox: TWebPageModule} {*.wml},
  sendModule in 'sendModule.pas' {send: TWebPageModule} {*.wml},
  writeModule in 'writeModule.pas' {write: TWebPageModule} {*.wml},
  detailModule in 'detailModule.pas' {detail: TWebPageModule} {*.wml},
  readTxtModule in 'readTxtModule.pas' {readTxt: TWebPageModule} {*.wml},
  EMailCode in 'EMailCode.pas',
  gb_big5 in 'gb_big5.pas',
  serialization in 'serialization.pas',
  HashMap in 'dcl\HashMap.pas',
  config in 'config.pas' {$R *.res},
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
  addNewMailBoxForGuestModule in 'addNewMailBoxForGuestModule.pas' {NewGuest: TWebPageModule} {*.wml},
  IdAuthenticationSSPI in 'NTLM2009\IdAuthenticationSSPI.pas',
  IdSASLNTLM in 'NTLM2009\IdSASLNTLM.pas',
  IdSSPI in 'NTLM2009\IdSSPI.pas',
  Portal_UserService in 'Portal_UserService.pas',
  Common in 'Common\Common.pas',
  Portlet_Blogs_BlogsEntryService in 'Portlet_Blogs_BlogsEntryService.pas',
  addNewMailBoxModule in 'addNewMailBoxModule.pas' {Add: TWebPageModule},
  WebSnapScriptObject in 'ScriptObject\WebSnapScriptObject.pas',
  Common.Debug in 'Common\Common.Debug.pas',
  XML2DataPakcetObj in 'Common\XML2DataPakcetObj.pas',
  ClientDataSetEx in 'Common\ClientDataSetEx.pas',
  MSHTML in 'win32\internet\MSHTML.pas',
  SessColn in 'win32\my_websnap\SessColn.pas',
  SiteComp in 'win32\my_websnap\SiteComp.pas',
  WebDisp in 'win32\my_websnap\WebDisp.pas',
  WebSess in 'win32\my_websnap\WebSess.pas',
  HTTPApp in 'win32\my_internet\HTTPApp.pas',
  Encryption_DB in 'DataAccessLayer\Encryption_DB.pas',
  Domain.UserMailInBox in 'DataAccessLayer\Domain\Domain.UserMailInBox.pas',
  DAO.UserMailInBox in 'DataAccessLayer\DAO\DAO.UserMailInBox.pas',
  Cities in 'DataAccessLayer\Cities.pas',
  UTF8ContentParser in 'win32\my_internet\UTF8ContentParser.pas',
  setModule in 'setModule.pas' {sysSet: TWebPageModule} {*.wml},
  cfg in 'Common\cfg.pas',
  WebSnapObjs in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebSnapObjs.pas',
  AutoAdap in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\AutoAdap.pas',
  WebScript in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebScript.pas',
  WebAuto in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebAuto.pas',
  AdaptReq in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\AdaptReq.pas',
  WebModu in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebModu.pas',
  WebAdapt in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebAdapt.pas',
  WebCntxt in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\internet\WebCntxt.pas',
  WebReq in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\internet\WebReq.pas',
  WebFact in 'D:\Program Files (x86)\Embarcadero\RAD Studio\7.0\source\Win32\websnap\WebFact.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.Run;
end.


//program WapMail;
//
//{$APPTYPE GUI}
//
//uses
//  Forms,
//  SockApp,
//  mainFrm in 'mainFrm.pas' {MainForm},
//  MainModule in 'MainModule.pas' {Main: TWebAppPageModule} {*.wml},
//  loginModule in 'loginModule.pas' {login: TWebPageModule} {*.wml},
//  inBoxModule in 'inBoxModule.pas' {inBox: TWebPageModule} {*.wml},
//  outBoxModule in 'outBoxModule.pas' {outBox: TWebPageModule} {*.wml},
//  sendModule in 'sendModule.pas' {send: TWebPageModule} {*.wml},
//  writeModule in 'writeModule.pas' {write: TWebPageModule} {*.wml},
//  detailModule in 'detailModule.pas' {detail: TWebPageModule} {*.wml},
//  readTxtModule in 'readTxtModule.pas' {readTxt: TWebPageModule} {*.wml},
//  EMailCode in 'EMailCode.pas',
//  gb_big5 in 'gb_big5.pas',
//  serialization in 'serialization.pas',
//  HashMap in 'dcl\HashMap.pas',
//  config in 'config.pas' {$R *.res},
//  big5 in 'big5.pas',
//  AbstractContainer in 'dcl\AbstractContainer.pas',
//  DCLUtil in 'dcl\DCLUtil.pas',
//  DCL_intf in 'dcl\DCL_intf.pas',
//  ArrayList in 'dcl\ArrayList.pas',
//  ArraySet in 'dcl\ArraySet.pas',
//  Algorithms in 'dcl\Algorithms.pas',
//  UEncode in 'UEncode.pas',
//  EZCrypt in 'EZCrypt.pas',
//  RegisterModule in 'RegisterModule.pas' {reg: TWebPageModule},
//  actionModule in 'actionModule.pas' {action: TWebPageModule},
//  DataModule in 'DataModule.pas' {WebDataModuleShare: TWebDataModule},
//  addNewMailBoxModule in 'addNewMailBoxModule.pas' {Add: TWebPageModule} {*.wml},
//  WebSnapScriptObject in 'ScriptObject\WebSnapScriptObject.pas',
//  IdAuthenticationSSPI in 'NTLM2009\IdAuthenticationSSPI.pas',
//  IdSASLNTLM in 'NTLM2009\IdSASLNTLM.pas',
//  IdSSPI in 'NTLM2009\IdSSPI.pas',
//
//  {IdAuthentication in 'NTLM\IdAuthentication.pas', },//  Common.Debug in 'Common\Common.Debug.pas',//  Common in 'Common\Common.pas';
//
//{$R *.res}
//
//begin
//  Application.Initialize;
//  Application.CreateForm(TMainForm, MainForm);
//  Application.Run;
//end.

