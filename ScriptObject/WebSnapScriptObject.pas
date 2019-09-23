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
  //�������һ���ж�ԭ���Ƿ�Ϊ�������ǾͲ���һ������ȫ�ǿո񣬴ճ�ż����������β��������������ַ���
  UTF8 := TUTF8Codec.Create;
  if length(S) mod 2 <> 0 then  //���ָ���Ϊ��˫��ʱ�����油��һ������ȫ�ǿո����ת����UTF8����β����������֣����ձ�WebSnap��Bug��ȥ�����������յ���ҳ����ʹ���һ�����ֳ��ֳ����롣
    str := UTF8.EncodeStr(S+'��')
  else
    str := UTF8.EncodeStr(S);
  UTF8.Free;
  }

  {
   //���ַ���ת��λUTF8�ļ�������
   str := Utf8Encode(S);
   str := ansiToUTF8(S);
   str := StringToUTF8(S);
   str := WideBufToUTF8String(PWideChar(S),Length(S));
  }

  //���������,��ת��UTF8�ַ����ж����һ���ַ��Ƿ�Ϊ��������ַ������Ǿ���ԭ��ǰ����һ��ȫ�����Ŀո��ٽ���ת�����Ա���ת����UTF8����β�İ���ַ���WebSanp��Bug����ȥ��������ҳ�Ͻ����һ�������ַ���ʾ�����롣
  {
  str := UTF8Encode(S);
  strTemp :=AnsiLastChar(str); //AnsiLastChar(const S:string)�����һ���ַ���������ַ���λ��,��֧��˫�ֽ��ַ�
  if (length(strTemp)=1) and (ord(strTemp[1])>127) then
    str := Utf8Encode(S+'��')
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
