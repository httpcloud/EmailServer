//处理BIG5繁体字的Base64编码:
unit big5;

Interface

uses
  Math;

  const
    cScaleChar = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  function Base64Encode(mSource: string; mAddLine: Boolean = True): string;
  function Base64Decode(mCode: string): string;
 
Implementation
  function IntToDigit(mNumber: Integer; mScale: Byte; mLength: Integer = 0): string;
  var
    I, J: Integer;
  begin
    Result := '';
    I := mNumber;
    while (I >= mScale) and (mScale > 1) do begin
      J := I mod mScale;
      I := I div mScale;
      Result := cScaleChar[J + 1] + Result;
    end;
    Result := cScaleChar[I + 1] + Result;
    for I := 1 to mLength - Length(Result) do Result := '0' + Result;
  end; { IntToDigit } 

  function DigitToInt(mDigit: string; mScale: Byte): Integer;
  var 
    I: Byte;
    L: Integer;
  begin 
    Result := 0;
    L := Length(mDigit);
    for I := 1 to L do
      Result := Result + (Pos(mDigit[L - I + 1], cScaleChar) - 1) *
        Trunc(IntPower(mScale, I - 1));
  end; { DigitToInt }

  const 
    cBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  function Base64Encode(mSource: string; mAddLine: Boolean = True): string;
  var 
    I, J: Integer;
    S: string;
    T: string;
  begin
    Result := '';
    J := 0;
    for I := 0 to Length(mSource) div 3 - 1 do begin
      S := Copy(mSource, I * 3 + 1, 3);
      T := IntToDigit(Ord(S[1]), 2, 8) + IntToDigit(Ord(S[2]), 2, 8) + IntToDigit(Ord(S[3]), 2, 8);
      Result := Result + cBase64[DigitToInt(Copy(T, 01, 6), 2) + 1];
      Result := Result + cBase64[DigitToInt(Copy(T, 07, 6), 2) + 1];
      Result := Result + cBase64[DigitToInt(Copy(T, 13, 6), 2) + 1];
      Result := Result + cBase64[DigitToInt(Copy(T, 19, 6), 2) + 1];
      if mAddLine then begin
        Inc(J, 4);
        if J >= 76 then begin
        Result := Result + #13#10;
        J := 0;
        end;
      end;
    end;
    I := Length(mSource) div 3;
    S := Copy(mSource, I * 3 + 1, 3);
    case Length(S) of
      1: begin
        T := IntToDigit(Ord(S[1]), 2, 8) + '0000';
        Result := Result + cBase64[DigitToInt(Copy(T, 01, 6), 2) + 1];
        Result := Result + cBase64[DigitToInt(Copy(T, 07, 6), 2) + 1]; 
        Result := Result + '=';
        Result := Result + '='; 
      end;
      2: begin 
        T := IntToDigit(Ord(S[1]), 2, 8) + IntToDigit(Ord(S[2]), 2, 8) + '0000'; 
        Result := Result + cBase64[DigitToInt(Copy(T, 01, 6), 2) + 1];
        Result := Result + cBase64[DigitToInt(Copy(T, 07, 6), 2) + 1]; 
        Result := Result + cBase64[DigitToInt(Copy(T, 13, 6), 2) + 1]; 
        Result := Result + '=';
      end;
    end;
  end; { Base64Encode }

  function Base64Decode(mCode: string): string;
  var
    I, L: Integer;
    S: string;
    T: string;
  begin 
    Result := '';
    L := Length(mCode);
    I := 1;
    while I <= L do begin
      if Pos(mCode[I], cBase64) > 0 then begin
        S := Copy(mCode, I, 4);
        if (Length(S) = 4) then begin
        T := IntToDigit(Pos(S[1], cBase64) - 1, 2, 6) +
            IntToDigit(Pos(S[2], cBase64) - 1, 2, 6) +
            IntToDigit(Pos(S[3], cBase64) - 1, 2, 6) +
            IntToDigit(Pos(S[4], cBase64) - 1, 2, 6);
        Result := Result + Chr(DigitToInt(Copy(T, 01, 8), 2));
        if S[3] <> '=' then begin
          Result := Result + Chr(DigitToInt(Copy(T, 09, 8), 2));
          if S[4] <> '=' then
            Result := Result + Chr(DigitToInt(Copy(T, 17, 8), 2));
        end;
        end;
        Inc(I, 4);
      end else Inc(I); 
    end;
  end; { Base64Decode }

end.
