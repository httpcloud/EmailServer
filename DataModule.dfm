object WebDataModuleShare: TWebDataModuleShare
  OldCreateOrder = False
  OnCreate = WebDataModuleCreate
  OnDestroy = WebDataModuleDestroy
  Height = 401
  Width = 566
  object ADOConnection1: TADOConnection
    ConnectionString = 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=test;'
    LoginPrompt = False
    Provider = 'MSDASQL.1'
    Left = 136
    Top = 24
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 232
    Top = 96
  end
  object ADOCommand1: TADOCommand
    Connection = ADOConnection1
    Parameters = <>
    Left = 136
    Top = 96
  end
  object SimpleDataSet1: TSimpleDataSet
    Aggregates = <>
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    Left = 296
    Top = 136
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    Left = 32
    Top = 160
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 160
    Top = 144
  end
  object DataSetProvider1: TDataSetProvider
    ResolveToDataSet = True
    Options = [poAllowMultiRecordUpdates, poAllowCommandText, poUseQuoteChar]
    Left = 48
    Top = 64
  end
end
