object Main: TMain
  OldCreateOrder = False
  OnCreate = WebAppPageModuleCreate
  OnDestroy = WebAppPageModuleDestroy
  OnBeforeDispatchPage = WebAppPageModuleBeforeDispatchPage
  OnActivate = WebAppPageModuleActivate
  PageProducer = PageProducer
  AppServices = WebAppComponents
  Height = 393
  Width = 253
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    ScriptEngine = 'JScript'
    Left = 48
    Top = 8
  end
  object WebAppComponents: TWebAppComponents
    Sessions = SessionsService
    LocateFileService = LocateFileService
    PageDispatcher = PageDispatcher
    AdapterDispatcher = AdapterDispatcher
    ApplicationAdapter = ApplicationAdapter
    EndUserAdapter = EndUserSessionAdapter
    OnBeforeDispatch = WebAppComponentsBeforeDispatch
    OnException = WebAppComponentsException
    Left = 48
    Top = 56
  end
  object ApplicationAdapter: TApplicationAdapter
    OnBeforeExecuteAction = ApplicationAdapterBeforeExecuteAction
    OnGetActionParams = ApplicationAdapterGetActionParams
    Left = 48
    Top = 104
    object TAdapterDefaultActions
      object AdapterAction: TAdapterAction
      end
    end
    object TAdapterDefaultFields
    end
  end
  object EndUserSessionAdapter: TEndUserSessionAdapter
    OnBeforeExecuteAction = EndUserSessionAdapterBeforeExecuteAction
    OnGetActionParams = EndUserSessionAdapterGetActionParams
    Left = 48
    Top = 152
    object TAdapterDefaultActions
    end
    object TAdapterDefaultFields
    end
  end
  object PageDispatcher: TPageDispatcher
    Left = 48
    Top = 200
  end
  object AdapterDispatcher: TAdapterDispatcher
    OnGetAdapterRequestParams = AdapterDispatcherGetAdapterRequestParams
    OnBeforeDispatchAction = AdapterDispatcherBeforeDispatchAction
    OnActionRequestNotHandled = AdapterDispatcherActionRequestNotHandled
    Left = 48
    Top = 248
  end
  object SessionsService: TSessionsService
    OnStartSession = SessionsServiceStartSession
    OnEndSession = SessionsServiceEndSession
    Left = 48
    Top = 296
  end
  object LocateFileService: TLocateFileService
    OnFindStream = LocateFileServiceFindStream
    Left = 160
    Top = 224
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 160
    Top = 152
  end
  object TcpClient1: TTcpClient
    Left = 160
    Top = 296
  end
end
