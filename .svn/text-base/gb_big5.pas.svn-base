{单元功能：利用操作系统API进行中文内码转换和进行简体与繁体转换(注：简体和和繁体都是GB编码，只是字型不相同)
 代码收集整理人：李春德
 整理日期：2005年8月4日
}
unit gb_big5;

interface

uses windows;

   function GB2Big5(GBStr : String): AnsiString;
   function GBCht2Chs(GBStr : String): AnsiString;
   function GBChs2Cht(GBStr : String): AnsiString;
   function Big52GB(BIG5Str : String): AnsiString;

Implementation
   
function Big52GB(BIG5Str : String): AnsiString;
{进行big5转GB内码}
var
  Len: Integer;
  pBIG5Char: PAnsiChar;
  pGBCHSChar: PAnsiChar;
  pGBCHTChar: PAnsiChar;
  pUniCodeChar: PWideChar;
begin
    //String -> PChar
    pBIG5Char := PAnsiChar(BIG5Str);
    Len := MultiByteToWideChar(950,0,pBIG5Char,-1,nil,0);
    GetMem(pUniCodeChar,Len*2);
    ZeroMemory(pUniCodeChar,Len*2);
    //Big5 -> UniCode
    MultiByteToWideChar(950,0,pBIG5Char,-1,pUniCodeChar,Len);
    Len := WideCharToMultiByte(936,0,pUniCodeChar,-1,nil,0,nil,nil);
    GetMem(pGBCHTChar,Len*2);
    GetMem(pGBCHSChar,Len*2);
    ZeroMemory(pGBCHTChar,Len*2);
    ZeroMemory(pGBCHSChar,Len*2);
    //UniCode->GB CHT
    WideCharToMultiByte(936,0,pUniCodeChar,-1,pGBCHTChar,Len,nil,nil);
    //GB CHT -> GB CHS
    LCMapString($804,LCMAP_SIMPLIFIED_CHINESE,PWideChar(pGBCHTChar),-1,PWideChar(pGBCHSChar),Len);
    Result := String(pGBCHSChar);
    FreeMem(pGBCHTChar);
    FreeMem(pGBCHSChar);
    FreeMem(pUniCodeChar);
end;

function GB2Big5(GBStr : String): AnsiString;
{进行GB转BIG5内码}
var
  Len: Integer;
  pGBCHTChar: PChar;
  pGBCHSChar: PChar;
  pUniCodeChar: PWideChar;
  pBIG5Char: PChar;
begin
  pGBCHSChar := PChar(GBStr);
  Len := MultiByteToWideChar(936,0,PAnsiChar(pGBCHSChar),-1,nil,0);
  GetMem(pGBCHTChar,Len*2+1);
  ZeroMemory(pGBCHTChar,Len*2+1);
  //GB CHS -> GB CHT
  LCMapString($804,LCMAP_TRADITIONAL_CHINESE,pGBCHSChar,-1,pGBCHTChar,Len*2);
  GetMem(pUniCodeChar,Len*2);
  ZeroMemory(pUniCodeChar,Len*2);
  //GB CHT -> UniCode
  MultiByteToWideChar(936,0,PAnsiChar(pGBCHTChar),-1,pUniCodeChar,Len*2);
  Len := WideCharToMultiByte(950,0,pUniCodeChar,-1,nil,0,nil,nil);
  GetMem(pBIG5Char,Len);
  ZeroMemory(pBIG5Char,Len);
  //UniCode -> Big5
  WideCharToMultiByte(950,0,pUniCodeChar,-1,PAnsiChar(pBIG5Char),Len,nil,nil);
  Result := String(pBIG5Char);
  FreeMem(pBIG5Char);
  FreeMem(pGBCHTChar);
  FreeMem(pUniCodeChar);
end;

function GBCht2Chs(GBStr : String): AnsiString;
{进行GBK繁体转简体}
var
  Len: Integer;
  pGBCHTChar: PChar;
  pGBCHSChar: PChar;
begin
  pGBCHTChar := PChar(GBStr);
  Len := MultiByteToWideChar(936,0,PAnsiChar(pGBCHTChar),-1,nil,0);
  GetMem(pGBCHSChar,Len*2+1);
  ZeroMemory(pGBCHSChar,Len*2+1);
  //GB CHS -> GB CHT
  LCMapString($804,LCMAP_SIMPLIFIED_CHINESE,pGBCHTChar,-1,pGBCHSChar,Len*2);
  Result := String(pGBChsChar);
  //FreeMem(pGBCHTChar);
  FreeMem(pGBCHSChar);
end;

function GBChs2Cht(GBStr : String): AnsiString;
{进行GBK简体转繁体}
var
  Len: Integer;
  pGBCHTChar: PChar;
  pGBCHSChar: PChar;
begin
  pGBCHSChar := PChar(GBStr);
  Len := MultiByteToWideChar(936,0,PAnsiChar(pGBCHSChar),-1,nil,0);
  GetMem(pGBCHTChar,Len*2+1);
  ZeroMemory(pGBCHTChar,Len*2+1);
  //GB CHS -> GB CHT
  LCMapString($804,LCMAP_TRADITIONAL_CHINESE,pGBCHSChar,-1,pGBCHTChar,Len*2);
  Result := String(pGBCHTChar);
  FreeMem(pGBCHTChar);
  //FreeMem(pGBCHSChar);
end;
end.
