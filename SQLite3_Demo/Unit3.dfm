object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 240
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 153
    Height = 25
    Caption = 'Test DISqlite3UniDirQuery1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 106
    Width = 169
    Height = 25
    Caption = 'GetMailBoxConfig By EMail - Read'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 66
    Width = 169
    Height = 25
    Caption = 'AddMailBoxConfig - Create'
    TabOrder = 2
    OnClick = Button3Click
  end
  object ButtonUpdate: TButton
    Left = 24
    Top = 145
    Width = 169
    Height = 25
    Caption = 'UpdateMailBoxConfig - Update'
    TabOrder = 3
    OnClick = ButtonUpdateClick
  end
  object ButtonDelete: TButton
    Left = 24
    Top = 184
    Width = 169
    Height = 25
    Caption = 'DeleteMailBoxConfig - Delete'
    TabOrder = 4
  end
  object Button4: TButton
    Left = 328
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 328
    Top = 66
    Width = 137
    Height = 25
    Caption = 'UserInBox_Add'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 328
    Top = 106
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 328
    Top = 145
    Width = 137
    Height = 25
    Caption = 'Read_return_stmt'
    TabOrder = 8
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 328
    Top = 176
    Width = 137
    Height = 25
    Caption = 'readBy'
    TabOrder = 9
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 328
    Top = 207
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 10
    OnClick = Button9Click
  end
  object DISqlite3UniDirQuery1: TDISqlite3UniDirQuery
    Database = DISQLite3Database1
    SelectSQL = 'select * from mailboxConfig'
    Left = 256
    Top = 8
  end
  object DISQLite3Database1: TDISQLite3Database
    DatabaseName = 'F:\Projects\WAPMail..CC_Delphi2010_20090830\bin\data\db.db'
    Left = 248
    Top = 64
  end
  object ADOCommand1: TADOCommand
    Parameters = <>
    Left = 264
    Top = 128
  end
end
