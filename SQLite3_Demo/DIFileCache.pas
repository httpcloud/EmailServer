unit DIFileCache;

interface

uses
  Classes, DISQLite3Cache;

type
  TDIFileBlock = record
    Len: Integer; // Count of data bytes in block.
    Data: record end;
  end;
  PDIFileBlock = ^TDIFileBlock;

  //------------------------------------------------------------------------------
  // TDIFileCache class
  //------------------------------------------------------------------------------

  { Provides buffered access to blocks of a file. }
  TDIFileCache = class
  private
    FBlockSize: Integer;
    FCache: TDISQLite3Cache;
    FFileName: AnsiString;
    FFileStream: TFileStream;
    FUpdateCount: Integer;
  public
    constructor Create(const AFileName: AnsiString; const ABlockSize: Integer);
    { Reads blocks from file and adds them to the internal cache. Returns a
      pointer to the last block added to the cache. }
    function AddBlocksToCache(ABlockIdx, ABlockCount: Integer): PDIFileBlock;
    procedure BeginUpdate;
    procedure EndUpdate;
    { Reads a block from disk into the cache and returns a pointer to
      the cached block. }
    function GetBlock(const ABlockIdx: Integer): PDIFileBlock;
    procedure Invalidate;

    property BlockSize: Integer read FBlockSize;
  end;

function BlockToHex(const ABlock: PDIFileBlock): AnsiString;

function BlockToText(const ABlock: PDIFileBlock): AnsiString;

implementation

uses
  SysUtils;

//------------------------------------------------------------------------------
// TDIFileCache class
//------------------------------------------------------------------------------

constructor TDIFileCache.Create(const AFileName: AnsiString; const ABlockSize: Integer);
begin
  FFileName := AFileName;
  FBlockSize := ABlockSize;
  FCache := TDISQLite3Cache.Create(SizeOf(TDIFileBlock) + ABlockSize);
  FCache.MaxCount := 396;
end;

//------------------------------------------------------------------------------

function TDIFileCache.AddBlocksToCache(ABlockIdx, ABlockCount: Integer): PDIFileBlock;
var
  Pos: Int64;
begin
  Result := nil;
  BeginUpdate;
  try
    Pos := ABlockIdx * FBlockSize;
    if FFileStream.Seek(Pos, soFromBeginning) = Pos then
      repeat
        Result := FCache.GetItem(ABlockIdx);
        if not Assigned(Result) then
          Result := FCache.AddItem(ABlockIdx);
        Result.Len := FFileStream.Read(Result^.Data, FBlockSize);
        Inc(ABlockIdx);
        Dec(ABlockCount);
      until (Result.Len < FBlockSize) or (ABlockCount = 0);
  finally
    EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TDIFileCache.BeginUpdate;
begin
  if FUpdateCount = 0 then
    FFileStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
  Inc(FUpdateCount);
end;

//------------------------------------------------------------------------------

procedure TDIFileCache.EndUpdate;
begin
  if FUpdateCount > 0 then
    begin
      Dec(FUpdateCount);
      if FUpdateCount = 0 then
        FFileStream.Free;
    end;
end;

//------------------------------------------------------------------------------

function TDIFileCache.GetBlock(const ABlockIdx: Integer): PDIFileBlock;
begin
  Result := FCache.GetItem(ABlockIdx);
  if not Assigned(Result) then
    Result := AddBlocksToCache(ABlockIdx, 1);
end;

//------------------------------------------------------------------------------

procedure TDIFileCache.Invalidate;
begin
  FCache.Invalidate;
end;

//------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------

function BlockToHex(const ABlock: PDIFileBlock): AnsiString;
var
  l: Integer;
  p: ^Byte;
begin
  Result := '';
  p := @ABlock^.Data;
  l := ABlock^.Len;
  while l > 0 do
    begin
      Result := Result + IntToHex(p^, 2) + ' ';
      Inc(p); Dec(l);
    end;
end;

//------------------------------------------------------------------------------

function BlockToText(const ABlock: PDIFileBlock): AnsiString;
var
  l: Integer;
  p: PAnsiChar;
begin
  l := ABlock.Len;
  SetString(Result, PAnsiChar(@ABlock^.Data), l);
  p := Pointer(Result);
  while l > 0 do
    begin
      if p^ < #32 then p^ := '.';
      Inc(p); Dec(l);
    end;
end;

end.

