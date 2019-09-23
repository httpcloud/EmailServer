unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdPOP3, IdSASLLogin, IdSASL,
  IdSASLUserPass, IdSASL_CRAMBase, IdSASL_CRAM_SHA1;

type
  TForm3 = class(TForm)
    IdPOP31: TIdPOP3;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  idPOP31.Connect;
  if(idPOP31.Connected) then
  begin
    ShowMessage(IntToStr(idPOP31.CheckMessages));
  end;
end;

end.
