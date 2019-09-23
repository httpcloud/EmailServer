object set: Tset
  OldCreateOrder = False
  PageProducer = PageProducer
  OnBeforeDispatchPage = WebPageModuleBeforeDispatchPage
  OnAfterDispatchPage = WebPageModuleAfterDispatchPage
  Height = 150
  Width = 215
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    ScriptEngine = 'JScript'
    Left = 48
    Top = 8
  end
  object PageProducerInfo: TPageProducer
    HTMLFile = 'send_err.wml'
    ScriptEngine = 'JScript'
    Left = 48
    Top = 64
  end
end
