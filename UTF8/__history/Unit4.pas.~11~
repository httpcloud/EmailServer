unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  temp:string;
  bytes:TBytes;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  bytes :=  TEncoding.Convert(TEncoding.Default,TEncoding.UTF8,SysUtils.BytesOf(Edit1.Text));
  temp := StringOf(bytes);
  Edit2.Text:= temp;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
    Edit1.Text:=StringOf(TEncoding.Convert(TEncoding.UTF8,TEncoding.Default,bytes));
end;

end.
