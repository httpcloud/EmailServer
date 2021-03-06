//delphi本身并不提供当前记录的数据封包，但我们有一个途经可以获取，通过TDataSetProvieder的GetRecords获取。 GetRecords虽然简单，但不能排除Blob字段、只取唯一主键字段等。通过研究CDS的RefreshRecord方法，提取了当前记录的封包。

Unit ClientDataSetEx;

interface



Uses

DBClient,Variants,DSIntf;

type
   TMyCDS = class(TCustomClientDataSet);//由于引用了Protected的一些方法和变量


function GetRecordOleVar(CDS:TClientDataSet;Options:TFetchOptions):OleVariant;
procedure RefreshRecordByOleVar(CDS:TClientDataSet;OleVar:OleVariant);
implementation

/// <summary>
/// 获取当前记录的 OleVariant 封包
/// </summary>
/// <param name="CDS"></param>
/// <param name="Options"></param>
/// <returns></returns>

function GetRecordOleVar(CDS:TClientDataSet;Options:TFetchOptions):OleVariant;

var
    DataPacket: TDataPacket;
   NewData: OleVariant;
begin
{ Throw error if we are closed, but not if we are in the middle of opening }
if not Assigned(TMyCDS(CDS).DSCursor) then
      TMyCDS(CDS).CheckActive;

TMyCDS(CDS).UpdateCursorPos;
TMyCDS(CDS).Check(TMyCDS(CDS).DSCursor.GetRowRequestPacket
   (foRecord in Options, foBlobs in Options ,False, True, DataPacket));
DataPacketToVariant(DataPacket, NewData);
Result := NewData;
end;

//假如服务端又返回一条记录的封包，怎样更新当前记录呢？

/// <summary>
/// 刷新当前记录
/// </summary>
/// <param name="CDS"></param>
/// <param name="OleVar">返回数据包</param>
procedure RefreshRecordByOleVar(CDS:TClientDataSet;OleVar:OleVariant);
begin
TMyCDS(CDS).UpdateCursorPos;
TMyCDS(CDS).Check(TMyCDS(CDS).DSCursor.RefreshRecord(VarToDataPacket(OleVar)));
if not TMyCDS(CDS).Active then
    Exit;
TMyCDS(CDS).DSCursor.GetCurrentRecord(TMyCDS(CDS).ActiveBuffer);
TMyCDS(CDS).Resync([]);
end;

//有了这两个方法，我们可以自定义刷新当前记录的方法。默认的RefreshRecord受限很多，而且效率不是很高。我们可以将当前记录（不含 Blob字段，发送效率更高）发送到服务端，通过自定义的类似TUpdateSQL的刷新方法，结合DSP，然后将查询回来的记录打包，再通过刷新合并当前记录。

end.
