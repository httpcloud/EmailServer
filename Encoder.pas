Unit Encoder;

Interface

Uses
  SysUtils;
Const
  cBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/,';
Function QuotedPrintableEncode(mSource: String): String;
Function QuotedPrintableDecode(mCode: String): String;
Function Base64Encode(mSource: String; mAddLine: Boolean = True): String;
Function Base64Decode(mCode: String): String;
Function GetTitle(Const Value: String): String;

Implementation

Function QuotedPrintableEncode(mSource: String): String;
Var
  I, J: Integer;
Begin
  Result := '';
  J := 0;
  For I := 1 To Length(mSource) Do Begin
      If mSource[I] In [#32..#127, #13, #10] - ['='] Then Begin
          Result := Result + mSource[I];
          Inc(J);
        End Else Begin
          Result := Result + '=' + IntToHex(Ord(mSource[I]), 2);
          Inc(J, 3);
        End;
      If mSource[I] In [#13, #10] Then J := 0;
      If J >= 70 Then Begin
          Result := Result + #13#10;
          J := 0;
        End;
    End;
End; { QuotedPrintableEncode }

Function QuotedPrintableDecode(mCode: String): String;
Var
  I, J, L: Integer;
Begin
  Result := '';
  J := 0;
  mCode := AdjustLineBreaks(mCode);
  L := Length(mCode);
  I := 1;
  While I <= L Do Begin
      If mCode[I] = '=' Then Begin
          Result := Result + Chr(StrToIntDef('$' + Copy(mCode, I + 1, 2), 0));
          Inc(J, 3);
          Inc(I, 3);
        End Else If mCode[I] In [#13, #10] Then Begin
          If J < 70 Then Result := Result + mCode[I];
          If mCode[I] = #10 Then J := 0;
          Inc(I);
        End Else Begin
          Result := Result + mCode[I];
          Inc(J);
          Inc(I);
        End;
    End;
End; { QuotedPrintableDecode }


Function Base64Encode(mSource: String; mAddLine: Boolean = True): String;
Var
  I, J: Integer;
  S: String;
Begin
  Result := '';
  J := 0;
  For I := 0 To Length(mSource) Div 3 - 1 Do Begin
      S := Copy(mSource, I * 3 + 1, 3);
      Result := Result + cBase64[Ord(S[1]) Shr 2 + 1];
      Result := Result + cBase64[((Ord(S[1]) And $03) Shl 4) + (Ord(S[2]) Shr 4) + 1];
      Result := Result + cBase64[((Ord(S[2]) And $0F) Shl 2) + (Ord(S[3]) Shr 6) + 1];
      Result := Result + cBase64[Ord(S[3]) And $3F + 1];
      If mAddLine Then Begin
          Inc(J, 4);
          If J >= 76 Then Begin
              Result := Result + #13#10;
              J := 0;
            End;
        End;
    End;
  I := Length(mSource) Div 3;
  S := Copy(mSource, I * 3 + 1, 3);
  Case Length(S) Of
    1: Begin
        Result := Result + cBase64[Ord(S[1]) Shr 2 + 1];
        Result := Result + cBase64[(Ord(S[1]) And $03) Shl 4 + 1];
        Result := Result + cBase64[65];
        Result := Result + cBase64[65];
      End;
    2: Begin
        Result := Result + cBase64[Ord(S[1]) Shr 2 + 1];
        Result := Result + cBase64[((Ord(S[1]) And $03) Shl 4) + (Ord(S[2]) Shr 4) + 1];
        Result := Result + cBase64[(Ord(S[2]) And $0F) Shl 2 + 1];
        Result := Result + cBase64[65];
      End;
  End;
End; { Base64Encode }

Function Base64Decode(mCode: String): String;
Var
  I, L: Integer;
  S: String;
Begin
  Result := '';
  L := Length(mCode);
  I := 1;
  While I <= L Do Begin
      If Pos(mCode[I], cBase64) > 0 Then Begin
          S := Copy(mCode, I, 4);
          If (Length(S) = 4) Then Begin
              Result := Result + Chr((Pos(S[1], cBase64) - 1) Shl 2 +
                (Pos(S[2], cBase64) - 1) Shr 4);
              If S[3] <> cBase64[65] Then Begin
                  Result := Result + Chr(((Pos(S[2], cBase64) - 1) And $0F) Shl 4 +
                    (Pos(S[3], cBase64) - 1) Shr 2);
                  If S[4] <> cBase64[65] Then
                    Result := Result + Chr(((Pos(S[3], cBase64) - 1) And $03) Shl 6 +
                      (Pos(S[4], cBase64) - 1));
                End;
            End;
          Inc(I, 4);
        End Else Inc(I);
    End;
End; { Base64Decode }

Function Find(SubStr, Str: String; IsEnd: Boolean = False): Integer;
Var
  i: integer;
Begin
  Result := 0;
  If IsEnd Then
    Begin
      For i := Length(Str) Downto 0 Do
        If Copy(Str, i, Length(SubStr)) = SubStr Then
          Begin
            Result := i;
            Break;
          End;
    End
  Else
    For i := 0 To Length(Str) Do
      If Copy(Str, i, Length(SubStr)) = SubStr Then
        Begin
          Result := i;
          Break;
        End;

End;

Function GetTitle(Const Value: String): String;
Var
  TempStr, sStr, eStr: String;
Begin
  sStr := Copy(Value, 1, Pos('=?', Value) - 1);
  TempStr := Copy(Value, Pos('=?', Value) + 2, Length(Value));
  eStr := Copy(TempStr, Find('?=', TempStr, True) + 2, Length(TempStr));
  TempStr := Copy(TempStr, 1, Find('?=', TempStr, True) - 1);
  If Pos('?B?', TempStr) > 0 Then
    Begin
      TempStr := Copy(TempStr, Pos('?B?', TempStr) + 3, Length(TempStr));
      TempStr := Base64Decode(TempStr);
      Result := sStr + TempStr + eStr;
      Exit;
    End
  Else
    If Pos('?b?', TempStr) > 0 Then
    Begin
      TempStr := Copy(TempStr, Pos('?b?', TempStr) + 3, Length(TempStr));
      TempStr := Base64Decode(TempStr);
      Result := sStr + TempStr + eStr;
      Exit;
    End;


  If Pos('?Q?', TempStr) > 0 Then
    Begin
      TempStr := Copy(TempStr, Pos('?Q?', TempStr) + 3, Length(TempStr));
      TempStr := QuotedPrintableDecode(TempStr);
      Result := sStr + TempStr + eStr;
      Exit;
    End
  Else
    If Pos('?q?', TempStr) > 0 Then
    Begin
      TempStr := Copy(TempStr, Pos('?q?', TempStr) + 3, Length(TempStr));
      TempStr := QuotedPrintableDecode(TempStr);
      Result := sStr + TempStr + eStr;
      Exit;
    End;
  Result := Value;

End;
End.
