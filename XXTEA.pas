unit XXTEA;

interface

function Encrypt(const data:AnsiString; const key:AnsiString):AnsiString;
function Decrypt(const data:AnsiString; const key:AnsiString):AnsiString;

implementation

type
  TLongWordDynArray = array of LongWord;

const
  delta:Longword = $9e3779b9;

function StrToArray(const data:AnsiString; includeLength:Boolean):TLongWordDynArray;
var
  n, i:LongWord;
begin
  n := Length(data);
  if ((n and 3) = 0) then n := n shr 2 else n := (n shr 2) + 1;
  if (includeLength) then begin
    setLength(result, n + 1);
    result[n] := Length(data);
  end else begin
    setLength(result, n);
  end;
  n := Length(data);
  for i := 0 to n - 1 do begin
    result[i shr 2] := result[i shr 2] or (($000000ff and ord(data[i + 1])) shl ((i and 3) shl 3));
  end;
end;

function ArrayToStr(const data:TLongWordDynArray; includeLength:Boolean):AnsiString;
var
  n, m, i:LongWord;
begin
  n := Length(data) shl 2;
  if (includeLength) then begin
    m := data[Length(data) - 1];
    if (m > n) then begin
      result := '';
      exit;
    end else begin
      n := m;
    end;
  end;
  SetLength(result, n);
  for i := 0 to n - 1 do begin
    result[i + 1] := AnsiChar(((data[i shr 2] shr ((i and 3) shl 3)) and $ff));
  end;
end;

function XXTeaEncrypt(const v:TLongWordDynArray; var k:TLongWordDynArray):TLongWordDynArray;
var
  n, z, y, sum, e, p, q:LongWord;
  function MX:LongWord;
  begin
    result := (((z shr 5) xor (y shl 2)) + ((y shr 3) xor (z shl 4))) xor ((sum xor y) + (k[p and 3 xor e] xor z));
  end;
begin
  n := Length(v) - 1;
  if (n < 1) then begin
    result := v;
    exit;
  end;
  if Length(k) < 4 then setLength(k, 4);
  z := v[n];
  y := v[0];
  sum := 0;
  q := 6 + 52 div (n + 1);
  repeat
    inc(sum, delta);
    e := (sum shr 2) and 3;
    for p := 0 to n - 1 do begin
      y := v[p + 1];
      inc(v[p], mx());
      z := v[p];
    end;
    p := n;
    y := v[0];
    inc(v[p], mx());
    z := v[p];
    dec(q);
  until q = 0;
  result := v;
end;

function XXTeaDecrypt(const v:TLongWordDynArray; var k:TLongWordDynArray):TLongWordDynArray;
var
  n, z, y, sum, e, p, q:LongWord;
  function MX:LongWord;
  begin
    result := (((z shr 5) xor (y shl 2)) + ((y shr 3) xor (z shl 4))) xor ((sum xor y) + (k[p and 3 xor e] xor z));
  end;
begin
  n := Length(v) - 1;
  if (n < 1) then begin
    result := v;
    exit;
  end;
  if Length(k) < 4 then setLength(k, 4);
  z := v[n];
  y := v[0];
  q := 6 + 52 div (n + 1);
  sum := q * delta;
  while (sum <> 0) do begin
    e := (sum shr 2) and 3;
    for p := n downto 1 do begin
      z := v[p - 1];
      dec(v[p], mx());
      y := v[p];
    end;
    p := 0;
    z := v[n];
    dec(v[0], mx());
    y := v[0];
    dec(sum, delta);
  end;
  result := v;
end;

function Encrypt(const data:AnsiString; const key:AnsiString):AnsiString;
var
  v, k:TLongWordDynArray;
begin
  if (Length(data) = 0) then exit;
  v := StrToArray(data, true);
  k := StrToArray(key, false);
  result := ArrayToStr(XXTeaEncrypt(v, k), false);
end;

function Decrypt(const data:AnsiString; const key:AnsiString):AnsiString;
var
  v, k:TLongWordDynArray;
begin
  if (Length(data) = 0) then exit;
  v := StrToArray(data, false);
  k := StrToArray(key, false);
  result := ArrayToStr(XXTeaDecrypt(v, k), true);
end;

end.
