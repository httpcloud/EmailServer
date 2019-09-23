{WebSnap Script Object,write by lwgboy}
unit WebSnapScriptObject;

interface

uses
  HTTPProd,SysUtils, Classes;
  //config;

type
  {$METHODINFO ON}
  TScriptObject = class(TComponent, IWebVariableName)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function GetVariableName: string;
  public
    function EncodeStr_(const S: WideString): String;
    function DecodeStr_(const S: string):WideString;
    function EncodeStr(const S: WideString): String;
    function DecodeStr(const S: string):WideString;
    function GetCurrentTime(const Format:string='hh:nn'):string;
    function EncryptUserInfo(userName:AnsiString;password:AnsiString):AnsiString;
    { Public declarations }
  published
    { Published declarations }
  end;
  {$METHODINFO OFF}

procedure Register;

implementation

{ TUTF8ScriptObject }
function TScriptObject.GetCurrentTime(const Format:string='hh:nn'): string;
begin
  Result:=FormatDateTime(Format,now());
end;

function TScriptObject.GetVariableName: string;
begin
  Result := Self.Name;
end;

function TScriptObject.EncodeStr_(const S: WideString): String;
var
  //UTF8:TUTF8Codec;
  str,strTemp:String;
begin
  {
  //解决方案一，判断原文是否为奇数，是就补上一个中文全角空格，凑成偶数，避免行尾最后产生半个中文字符。
  UTF8 := TUTF8Codec.Create;
  if length(S) mod 2 <> 0 then  //汉字个数为非双数时，后面补上一个中文全角空格，免得转换成UTF8后，行尾产生半个汉字，最终被WebSnap的Bug所去掉，而在最终的网页中致使最后一个汉字呈现成乱码。
    str := UTF8.EncodeStr(S+'　')
  else
    str := UTF8.EncodeStr(S);
  UTF8.Free;
  }

  {
   //将字符串转换位UTF8的几个函数
   str := Utf8Encode(S);
   str := ansiToUTF8(S);
   str := StringToUTF8(S);
   str := WideBufToUTF8String(PWideChar(S),Length(S));
  }

  //解决方案二,先转成UTF8字符，判断最后一个字符是否为半个中文字符，若是就在原文前补上一个全角中文空格再进行转换，以避免转换成UTF8后行尾的半个字符被WebSanp的Bug不过去除而在网页上将最后一个中文字符显示成乱码。
  {
  str := UTF8Encode(S);
  strTemp :=AnsiLastChar(str); //AnsiLastChar(const S:string)获得在一个字符串中最后字符的位置,它支持双字节字符
  if (length(strTemp)=1) and (ord(strTemp[1])>127) then
    str := Utf8Encode(S+'　')
  else
    str := Utf8Encode(S);
  }
  Result := str;
end;


function TScriptObject.DecodeStr_(const S: string): WideString;
//var
//  UTF8:TUTF8Codec;
begin
  Result := '';
  {
  UTF8 := TUTF8Codec.Create;
  try
    UTF8.DecodeStr(PChar(s),length(s),Result);
  finally
    UTF8.Free;
  end;
  }
end;

function TScriptObject.EncodeStr(const S: WideString): String;
begin
  Result := S;
end;

function TScriptObject.DecodeStr(const S: string):WideString;
begin
  result := S;
end;

function TScriptObject.EncryptUserInfo(userName:AnsiString;password:AnsiString):ansiString;
begin
  if password = '' then
     password := 'NULL';
  //result := Config.encryptUserInfo(userName,password);
  result := '';
end;



procedure Register;
begin
  RegisterComponents('WebSnap', [TScriptObject]);
end;

end.
