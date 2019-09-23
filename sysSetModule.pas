unit sysSetModule;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd;

type
  TPageProducerPage5 = class(TWebPageModule)
    PageProducer: TPageProducer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function PageProducerPage5: TPageProducerPage5;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants;

function PageProducerPage5: TPageProducerPage5;
begin
  Result := TPageProducerPage5(WebContext.FindModuleClass(TPageProducerPage5));
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebPageModuleFactory.Create(TPageProducerPage5, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), crOnDemand, caCache)

);

end.

