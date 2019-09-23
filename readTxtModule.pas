unit readTxtModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd;

type
  TreadTxt = class(TWebPageModule)
    PageProducer: TPageProducer;
    procedure PageProducerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
    procedure WebPageModuleBeforeDispatchPage(Sender: TObject; const PageName: string; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function readTxt: TreadTxt;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants,config,Common;

function readTxt: TreadTxt;
begin
  Result := TreadTxt(WebContext.FindModuleClass(TreadTxt));
end;

procedure TreadTxt.PageProducerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin
  if TagString='title' then
    ReplaceText := TXMLConfig.GetAppSettingTitle
  else
  if Request.QueryFields.Values['f']<>'' then
  begin
    TagParams.LoadFromFile(getCurrentPath+TConfig.userLogPath+'\'+Request.QueryFields.Values['f']);
    ReplaceText := TagParams.Text;
  end;

end;

procedure TreadTxt.WebPageModuleBeforeDispatchPage(Sender: TObject; const PageName: string; var Handled: Boolean);
begin
  Response.ContentType := 'text/vnd.wap.wml;charset=utf-8';
  LoadFromResource(pageProducer,self.UnitName);
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(TreadTxt, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

