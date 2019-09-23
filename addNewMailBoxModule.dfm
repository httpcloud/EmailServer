object Add: TAdd
  OldCreateOrder = False
  PageProducer = PageProducer
  OnBeforeDispatchPage = WebPageModuleBeforeDispatchPage
  Height = 150
  Width = 215
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    ScriptEngine = 'JScript'
    Left = 80
    Top = 40
  end
end
