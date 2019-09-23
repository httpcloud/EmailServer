unit Common.Debug;

interface

uses windows,
     SysUtils,
     JCLDebug,
     Config;


  type
    Debug = class
      class procedure outputInfo(DebugInfo:string);
      class function Assert:boolean;
    end;

implementation

{ Debug }

class function Debug.Assert: boolean;
begin
  Result := not Config.TXMLConfig.IsDebug;
end;

class procedure Debug.outputInfo(DebugInfo: string);
var
   f, proc:String;
   line:Integer;
   R:String;
begin
  if Config.TXMLConfig.IsDebug then
  begin
    //OutputDebugString(PWideChar(DebugInfo));
    //Assert(false,DebugInfo);
   f:=FileByLevel(0); //获得调用它的文件名
   line:=LineByLevel(0); //获得调用它的行号
   proc:=ProcByLevel(0); //获得调用它的模块名
   R:= DebugInfo+' '+f + ':' + IntToStr(line) + ' ' + proc;
   OutputDebugString(PWideChar(R));
  end;
end;


var
   oldAssertErrorProc : TAssertErrorProc;

procedure LogAssert(const Message, Filename: string;
    LineNumber: Integer; ErrorAddr: Pointer);
Var
   runErrMsg:String;
begin
  runErrMsg := format('Error: %s, in file(%d): %s, Addr: %p',
                      [Message, LineNumber, FileName, ErrorAddr]);
  if IsConsole then
    Writeln(runErrMsg)
  else
    //MessageBox(0, pChar(runErrMsg), 'Error Log by AssertLogs', 0);
    OutputDebugString(PWideChar(runErrMsg));
end;

initialization
  oldAssertErrorProc := AssertErrorProc;
  AssertErrorProc:=@LogAssert;

finalization
  AssertErrorProc := oldAssertErrorProc;


end.
