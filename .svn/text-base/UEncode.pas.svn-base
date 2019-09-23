unit UEncode;
//library UEncode;
{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }
interface

uses
  SysUtils,
  Classes;

implementation


function EnCryptStr(Passwordstr: string;
  Encryptflg: Boolean): ShortString;
var
  i: Integer;
  kk: BYTE;
begin
  Result := Passwordstr;
  if encryptflg then
  begin
    for i := 1 to Length(Passwordstr) do
    begin
      kk := Ord(Passwordstr[i]);
      kk := kk xor $FF;
      Result[i] := AnsiChar(kk);
    end;
  end
  else
  begin
    for i := 1 to Length(Passwordstr) do
    begin
      kk := Ord(Passwordstr[i]);
      kk := kk xor $FF;
      Result[i] := AnsiChar(kk);
    end;
  end;
end;

function EnDecode(str: string; flag: boolean): ShortString;stdcall;
var
  iLen,i,iTmp:integer;
  sTmp: ShortString;
  sResult:ShortString;
begin
  sResult:='';
  iLen:=Length(str);
  if flag then
  begin
    sTmp:=EnCryptStr(str,true);
    for i:=1 to iLen do
    begin
      iTmp:=Ord(sTmp[i]);
      sResult:=sResult+IntToHex(iTmp,2);
    end;
  end
  else
  begin
    iLen:=iLen div 2;
    for i:=1 to iLen do
    begin
      sTmp:=copy(str,2*i-1,2);
      iTmp:=StrToInt('$'+sTmp);
      sResult:=sResult+Chr(iTmp);
    end;
    sResult:=EnCryptStr(sResult,false);
  end;
  result:=sResult;
end;

exports
  EnDecode;

begin
end.
