//delphi���������ṩ��ǰ��¼�����ݷ������������һ��;�����Ի�ȡ��ͨ��TDataSetProvieder��GetRecords��ȡ�� GetRecords��Ȼ�򵥣��������ų�Blob�ֶΡ�ֻȡΨһ�����ֶεȡ�ͨ���о�CDS��RefreshRecord��������ȡ�˵�ǰ��¼�ķ����

Unit ClientDataSetEx;

interface



Uses

DBClient,Variants,DSIntf;

type
   TMyCDS = class(TCustomClientDataSet);//����������Protected��һЩ�����ͱ���


function GetRecordOleVar(CDS:TClientDataSet;Options:TFetchOptions):OleVariant;
procedure RefreshRecordByOleVar(CDS:TClientDataSet;OleVar:OleVariant);
implementation

/// <summary>
/// ��ȡ��ǰ��¼�� OleVariant ���
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

//���������ַ���һ����¼�ķ�����������µ�ǰ��¼�أ�

/// <summary>
/// ˢ�µ�ǰ��¼
/// </summary>
/// <param name="CDS"></param>
/// <param name="OleVar">�������ݰ�</param>
procedure RefreshRecordByOleVar(CDS:TClientDataSet;OleVar:OleVariant);
begin
TMyCDS(CDS).UpdateCursorPos;
TMyCDS(CDS).Check(TMyCDS(CDS).DSCursor.RefreshRecord(VarToDataPacket(OleVar)));
if not TMyCDS(CDS).Active then
    Exit;
TMyCDS(CDS).DSCursor.GetCurrentRecord(TMyCDS(CDS).ActiveBuffer);
TMyCDS(CDS).Resync([]);
end;

//�������������������ǿ����Զ���ˢ�µ�ǰ��¼�ķ�����Ĭ�ϵ�RefreshRecord���޺ܶ࣬����Ч�ʲ��Ǻܸߡ����ǿ��Խ���ǰ��¼������ Blob�ֶΣ�����Ч�ʸ��ߣ����͵�����ˣ�ͨ���Զ��������TUpdateSQL��ˢ�·��������DSP��Ȼ�󽫲�ѯ�����ļ�¼�������ͨ��ˢ�ºϲ���ǰ��¼��

end.