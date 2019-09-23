object action: Taction
  OldCreateOrder = False
  PageProducer = PageProducer
  OnBeforeDispatchPage = WebPageModuleBeforeDispatchPage
  Height = 150
  Width = 215
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    ScriptEngine = 'JScript'
    Left = 64
    Top = 8
  end
end
