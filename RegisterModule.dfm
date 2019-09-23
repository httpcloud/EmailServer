object reg: Treg
  OldCreateOrder = False
  PageProducer = PageProducer
  OnBeforeDispatchPage = WebPageModuleBeforeDispatchPage
  Height = 227
  Width = 225
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    ScriptEngine = 'JScript'
    Left = 96
    Top = 24
  end
end
