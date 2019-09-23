unit Unit1;

interface

uses
  SysUtils, Classes, HTTPApp, WebModu, HTTPProd, ReqMulti, WebDisp, WebAdapt,
  WebComp;

type
  TPageProducerPage3 = class(TWebAppPageModule)
    PageProducer: TPageProducer;
    WebAppComponents: TWebAppComponents;
    ApplicationAdapter: TApplicationAdapter;
    PageDispatcher: TPageDispatcher;
    AdapterDispatcher: TAdapterDispatcher;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function PageProducerPage3: TPageProducerPage3;

implementation

{$R *.dfm}  {*.wml}

uses WebReq, WebCntxt, WebFact, Variants;

function PageProducerPage3: TPageProducerPage3;
begin
  Result := TPageProducerPage3(WebContext.FindModuleClass(TPageProducerPage3));
end;

initialization
  if WebRequestHandler <> nil then
    WebRequestHandler.AddWebModuleFactory(TWebAppPageModuleFactory.Create(TPageProducerPage3, TWebPageInfo.Create([wpPublished {, wpLoginRequired}], '.wml'), caCache)

);

end.

