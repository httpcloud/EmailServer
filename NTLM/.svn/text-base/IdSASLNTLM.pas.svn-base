{
  $Project$
  $Workfile$
  $Revision$
  $DateUTC$
  $Id$

  This file is part of the Indy (Internet Direct) project, and is offered
  under the dual-licensing agreement described on the Indy website.
  (http://www.indyproject.org/)

  Copyright:
   (c) 1993-2005, Chad Z. Hower and the Indy Pit Crew. All rights reserved.
}
{
  $Log$
}

{   Rev 1.0   2008.3.10 03:20:00 AM  lwgboy
{ Indy implementation of the NTLM authentication protocol
}
unit IdSASLNTLM;

// S.G. 9/5/2003: First implementation of the CRAM-MD5 authentication algorythm
// S.G. 9/5/2003: Refs: RFC 1321 (MD5)
// S.G. 9/5/2003:       RFC 2195 (IMAP/POP3 AUTHorize Extension for Simple Challenge/Response)
// S.G. 9/5/2003:       IETF draft draft-ietf-ipsec-hmac-md5-txt.00


interface

uses
  IdSASL,
  IdSASLUserPass, IdCoderMIME,
  IdAuthenticationSSPI,
  classes;

type


  TIdSASLNTLM = class(TIdSASLUserPass)
  protected
    //ntlm : TIdNTLMAuthentication;
    ntlm : TIdSSPINTLMAuthentication;
  public
    class function ServiceName: TIdSASLServiceName; override;

    //function StartAuthenticate(const AChallenge:string) : String; override;   //结合Delphi2009的 Indy 10,改成下句： --lwgboy 2008-10-13
    function StartAuthenticate(const AChallenge, AHost, AProtocolName : string):String;override; //--lwgboy 2008-10-13
    //function ContinueAuthenticate(const ALastResponse: String): String;         //结合Delphi2009的 Indy 10,改成下句： --lwgboy 2008-10-13
    function ContinueAuthenticate(const ALastResponse, AHost, AProtocolName : string):string;   //--lwgboy 2008-10-13
      override;

    constructor Create(AOwner: TComponent); overload;
    destructor Destroy; overload;

  end;

implementation

uses
  IdGlobal, IdGlobalProtocols, IdHashMessageDigest, IdHash, idBuffer, IdSys,
  IdObjs;

{ TIdSASLNTLM }

constructor TIdSASLNTLM.Create(AOwner: TComponent);
begin
  inherited;
  //ntlm := TIdNTLMAuthentication.Create;
  ntlm:=TIdSSPINTLMAuthentication.Create;
end;

destructor TIdSASLNTLM.Destroy;
begin
  ntlm.Free;
  inherited;
end;

function TIdSASLNTLM.ContinueAuthenticate(const ALastResponse, AHost, AProtocolName : string): String;
begin
  {
  //当 ntlm.CurrentStep >= 2时,还原成继续从第一步开始。目的是用于一轮下来仍然没有成功要循环多次登陆的情况下用，没有测试过是否能够成功。一般每什么用处。 --write by lwgboy ,2008-3-10
  if(ntlm.CurrentStep=2)then
  begin
    ntlm.Reset;
    ntlm.Next;
  end
  else
  }
    ntlm.Next;
  ntlm.AuthParams.Text := ALastResponse;  //
  Result := ntlm.Authentication;
  Result := RightStr(Result,length(Result)-5);
end;

class function TIdSASLNTLM.ServiceName: TIdSASLServiceName;
begin
  result := 'NTLM'; {do not localize}
end;

function TIdSASLNTLM.StartAuthenticate(const AChallenge, AHost, AProtocolName : string): String;
var
  Digest: String;
begin
  ntlm.Username := GetUsername;
  ntlm.Password := GetPassword;
  ntlm.Reset;
  ntlm.Next;
  Result := ntlm.Authentication;
  Result := RightStr(Result,length(Result)-5);//在SMTP 之 NTLM 认证中，去除认证字符串前面的NTLM+空格五个字符。
end;

end.
