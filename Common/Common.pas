unit Common;

interface

uses
//PerlRegEx,
xmldom, XMLIntf, msxmldom, XMLDoc,classes,windows,StrUtils,HTTPProd,DCPdes,DCPsha1,DCPbase64,SysUtils,DateUtils;



function CheckEmail(EmailAddr:string):boolean;
function IsEMail(EMail: String): Boolean;
function ComponentToStr(AComponent: TComponent): string;
function StrToComponent(const Value: string; Instance: TComponent): TComponent;
procedure LoadFromResource(var pageProducer:TPageProducer;UnitName:string);overload;
procedure LoadFromResource(var contentStream:TStream;UnitName:string);overload;
function encryptTemplate(inStream,outStream:TStream;size:cardinal):cardinal;
function decryptTemplate(inStream,outStream:TStream;size:cardinal):cardinal;

procedure FindAllFile(const Dir: string;var FileNameList: TStringlist); //��ȡĿ¼�������ļ��б�
procedure FindAllFileByTime(const Dir: string;var FileNameList: TStringlist);

implementation

function CheckEmail(EmailAddr: string): Boolean;
//var
  //PerlRegEx:TPerlRegEx;
begin
//   PerlRegEx := TPerlRegEx.Create(nil);
//   PerlRegEx.Subject := EmailAddr;
//   PerlRegEx.RegEx := '\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*';
//   Result := PerlRegEx.Match;


Result := IsEMail(EmailAddr);
end;

function IsEMail(EMail: String): Boolean;
var
  s: String;
  ETpos: Integer;
begin
  ETpos := StrUtils.PosEx('@', EMail); // ��ȡ@���ŵ�λ��
  if ETpos > 1 then
  begin
    s := copy(EMail, ETpos + 1, Length(EMail)); // ��ȡ�Ӵ�
    if (StrUtils.PosEx('.', s) > 1) and (StrUtils.PosEx('.', s) < Length(s))
      then
      Result := true
    else
      Result := false;
  end
  else
    Result := false;
end;

function ComponentToStr(AComponent: TComponent): string;
var
  BinStream: TMemoryStream;
  StrStream: TStringStream;
  s: string;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create(s);
    try
      BinStream.WriteComponent(AComponent);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, StrStream);
      StrStream.Seek(0, soFromBeginning);
      Result := StrStream.DataString;
    finally
      StrStream.Free;
    end;
  finally
    BinStream.Free
  end;
end;

function StrToComponent(const Value: string;
  Instance: TComponent): TComponent;
var
  StrStream: TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result := BinStream.ReadComponent(Instance);
    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;


function encryptTemplate(inStream,outStream:TStream;size:cardinal):cardinal;
const rnd:array[0..51] of AnsiChar='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  Cipher: TDCP_des;
begin
  Cipher := TDCP_des.Create(nil);
  Cipher.InitStr(StrUtils.ReverseString(rnd[8]+rnd[11]+rnd[14]+rnd[21]+rnd[30]+rnd[37]+rnd[48]+rnd[32]),TDCP_sha1);
  Result := Cipher.EncryptStream(inStream,OutStream,size);
  Cipher.Burn;
  Cipher.Free;
end;

function decryptTemplate(inStream,outStream:TStream;size:cardinal):cardinal;
const rnd:array[0..51] of AnsiChar='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  Cipher: TDCP_des;
begin
  Cipher := TDCP_des.Create(nil);
  Cipher.InitStr(StrUtils.ReverseString(rnd[8]+rnd[11]+rnd[14]+rnd[21]+rnd[30]+rnd[37]+rnd[48]+rnd[32]),TDCP_sha1);
  Result := Cipher.DecryptStream(inStream,OutStream,size);
  Cipher.Burn;
  Cipher.Free;
end;



procedure LoadFromResource(var pageProducer:TPageProducer;UnitName:string);
var
  inStream:TResourceStream;
  outStream:TStream;

begin
  //inStream := TResourceStream.Create(Hinstance,UnitName,'HTML');
  //pageProducer.HTMLDoc.LoadFromStream(inStream);

  inStream := TResourceStream.Create(Hinstance,UnitName,'DATA');
  outStream := TStringStream.Create('',TEncoding.UTF8);
  //outStream := TMemoryStream.Create;
  if decryptTemplate(inStream,outStream,inStream.Size)>0 then
    pageProducer.HTMLDoc.LoadFromStream(TStringStream(outStream),TEncoding.UTF8);  //��Ҫ���趨�� UTF8 ������ػᵼ�� HTTPApp.pas��(Լ1025��)�� procedure TWebResponse.SetUnicodeContent(const AValue: string);��������ERankCheck Error! ��--lwgboy,2009-9-7 23:24
  inStream.Free;
  outStream.Free;
end;

 procedure LoadFromResource(var contentStream:TStream;UnitName:string);
 var
  inStream:TResourceStream;
 begin
     inStream := TResourceStream.Create(Hinstance,UnitName,'DATA');
     decryptTemplate(inStream,contentStream,inStream.Size) ;
 end;

procedure FindAllFile(const Dir: string;var FileNameList: TStringlist);
var
  hFindFile: THandle;
  FindFileData: WIN32_FIND_DATA;
  FullName,FName,s:string;
begin
  s:=IncludeTrailingPathDelimiter(Dir);
  hFindFile := FindFirstFile(pchar(s+'*.*'), FindFileData);
  if hFindFile <> 0 then begin
    repeat
      FName:=FindFileData.cFileName;
      FullName:=s+FName;
      if (FName='.') or (FName='..') then continue;
      if (FindFileData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
        FindAllFile(FullName,FileNameList)
      else
        FileNameList.Add(FullName);
    until FindNextFile(hFindFile, FindFileData) = false;
    windows.FindClose(hFindFile);
  end;
end;

procedure FindAllFileByTime(const Dir: string;var FileNameList: TStringlist);
var
  hFindFile: THandle;
  FindFileData: WIN32_FIND_DATA;
  FullName,FName,s:string;

  fd,ft:WORD;
  fdt:WORD;
  lft,Time:FILETIME;
  dayBetween:integer;
begin
  s:=IncludeTrailingPathDelimiter(Dir);
  hFindFile := FindFirstFile(pchar(s+'*.*'), FindFileData);
  if hFindFile <> 0 then begin
  repeat
      FName:=FindFileData.cFileName;
      FullName:=s+FName;
      if (FName='.') or (FName='..') then continue;
      if (FindFileData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
        FindAllFile(FullName,FileNameList)
      else
      begin
        FileTimeToLocalFileTime(&FindFileData.ftCreationTime,&lft);
        FileTimeToDosDateTime(&lft,&fd,&ft);
        dayBetween := DaysBetween(Now,FileDateToDateTime(MAKELONG(ft,fd)));
        if dayBetween>7 then //�г�����7�죨һ�ܣ���
          FileNameList.Add(FullName);
      end;
    until FindNextFile(hFindFile, FindFileData) = false;
    windows.FindClose(hFindFile);
  end;
end;

end.