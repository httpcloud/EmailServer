unit XML2DataPakcetObj;

interface

uses ObjAuto,windows;

implementation

function XML2DataPacketObject(XML:String;dbo:TObject):TObject;
var
  MIA:TMethodInfoArray;
  MI:PMethodInfoHeader;
begin
  MIA := objAuto.GetMethods(dbo.ClassType);
//  for MI in MIA do
//    ShowMessage(MI^.Name);

  Result := nil;
end;

end.
