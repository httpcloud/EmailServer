unit Unit1;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd;

type
  Ttest = class(TWebPageModule)
    PageProducer: TPageProducer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function test: Ttest;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants;

function test: Ttest;
begin
  Result := Ttest(WebContext.FindModuleClass(Ttest));
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(Ttest, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

