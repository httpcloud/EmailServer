program Algos;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmAlgos},
  AbstractContainer in '..\..\AbstractContainer.pas',
  Algorithms in '..\..\Algorithms.pas',
  ArrayList in '..\..\ArrayList.pas',
  ArraySet in '..\..\ArraySet.pas',
  BinaryTree in '..\..\BinaryTree.pas',
  DCL_intf in '..\..\DCL_intf.pas',
  DCLUtil in '..\..\DCLUtil.pas',
  HashMap in '..\..\HashMap.pas',
  HashSet in '..\..\HashSet.pas',
  LinkedList in '..\..\LinkedList.pas',
  Queue in '..\..\Queue.pas',
  Stack in '..\..\Stack.pas',
  Vector in '..\..\Vector.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmAlgos, frmAlgos);
  Application.Run;
end.
