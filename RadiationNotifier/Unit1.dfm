object Form1: TForm1
  Left = 579
  Top = 462
  Width = 371
  Height = 211
  Caption = 'RadiationNotifier'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 12
    Width = 28
    Height = 13
    Caption = #1055#1086#1088#1090':'
  end
  object Label2: TLabel
    Left = 104
    Top = 12
    Width = 22
    Height = 13
    Caption = #1041#1086#1076':'
  end
  object Label3: TLabel
    Left = 200
    Top = 12
    Width = 43
    Height = 13
    Caption = #1053#1086#1084#1077#1088#1072':'
  end
  object Label4: TLabel
    Left = 216
    Top = 100
    Width = 138
    Height = 13
    Caption = '('#1054#1076#1085#1072' '#1089#1090#1088#1086#1082#1072' - '#1086#1076#1080#1085' '#1085#1086#1084#1077#1088')'
  end
  object Label5: TLabel
    Left = 4
    Top = 36
    Width = 59
    Height = 13
    Caption = #1058#1077#1082#1089#1090' '#1057#1052#1057':'
  end
  object Shape1: TShape
    Left = 4
    Top = 64
    Width = 17
    Height = 17
    Brush.Color = clLime
    Shape = stCircle
  end
  object cb_ports: TComboBox
    Left = 36
    Top = 8
    Width = 65
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
  object btnStart: TButton
    Left = 200
    Top = 124
    Width = 75
    Height = 25
    Caption = 'Start server'
    TabOrder = 1
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 280
    Top = 124
    Width = 75
    Height = 25
    Caption = 'Stop server'
    TabOrder = 2
    OnClick = btnStopClick
  end
  object cbBaudRate: TComboBox
    Left = 132
    Top = 8
    Width = 65
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 12
    TabOrder = 3
    Text = '115200'
    Items.Strings = (
      '110'
      '300'
      '600'
      '1200'
      '2400'
      '4800'
      '9600'
      '14400'
      '19200'
      '38400'
      '56000'
      '57600'
      '115200'
      '128000'
      '256000')
  end
  object m_TelNumbers: TMemo
    Left = 248
    Top = 8
    Width = 105
    Height = 89
    Lines.Strings = (
      '+77057636810')
    TabOrder = 4
  end
  object Memo1: TMemo
    Left = 4
    Top = 88
    Width = 185
    Height = 65
    TabOrder = 5
  end
  object Edit1: TEdit
    Left = 68
    Top = 32
    Width = 129
    Height = 21
    TabOrder = 6
    Text = #1055#1088#1080#1074#1077#1090'!!!'
  end
  object Button1: TButton
    Left = 200
    Top = 32
    Width = 21
    Height = 21
    TabOrder = 7
    OnClick = Button1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 156
    Width = 363
    Height = 21
    Panels = <
      item
        Width = 50
      end
      item
        Alignment = taRightJustify
        Style = psOwnerDraw
        Width = 50
      end>
    OnDrawPanel = StatusBar1DrawPanel
  end
  object PopupMenu1: TPopupMenu
    Left = 80
    Top = 136
  end
  object comport: TBComPort
    BaudRate = br115200
    ByteSize = bs8
    InBufSize = 2048
    OutBufSize = 2048
    Parity = paNone
    Port = 'COM9'
    SyncMethod = smThreadSync
    StopBits = sb1
    Timeouts.ReadInterval = -1
    Timeouts.ReadTotalMultiplier = 0
    Timeouts.ReadTotalConstant = 0
    Timeouts.WriteTotalMultiplier = 100
    Timeouts.WriteTotalConstant = 1000
    Left = 28
    Top = 136
  end
  object TrayIcon1: TTrayIcon
    Icon.Data = {
      0000010001002020040000000000E80200001600000028000000200000004000
      0000010004000000000000020000000000000000000000000000000000000000
      000000008000008000000080800080000000800080008080000080808000C0C0
      C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      00B3111111111111000000000000000000BBB333333333110000000000000000
      008888B333333331000000000000000000033333333331100000000000000000
      000888888BBBBB10000000000000000000000333333333100000000000000000
      000008BBBB3B10000444440000000000000008BBBB3310044676764400000000
      00000888BB3310476767667640000000000000BBBB3372267676676764000000
      000000BBBB3372777767627674000000000000888BB377777772226766400000
      0000000BBBB3377777722276764000000000000BBBB337777222226766400000
      0000000888BB37877222222666400000000000008BBB33777722772222400000
      000000008BBB337F777227222240000000000000888BB378F777222224000000
      000000000BBBB3377772222224000000000000000888B3372777222240000000
      000000000088BB373277772400000000000000000088BB337222220000000000
      0000000000088BB370000000000000000000000000088BB33100000000000000
      000000000000BBB333100000000000000B3333333333BBB33310000000000000
      0BB3333333333BBB33300000000000000BBB3333333BBBBBB330000000000000
      08BBBBBBBBBBB88BBB3000000000000008B8888888888888BB30000000000000
      08888888888888888BB00000000000000000000000000000000000000000FC00
      0FFFFC000FFFFC000FFFFE001FFFFE001FFFFF801FFFFF80783FFF80600FFF80
      4007FFC00003FFC00003FFC00001FFE00001FFE00001FFE00001FFF00001FFF0
      0001FFF00003FFF80003FFF80007FFFC000FFFFC003FFFFE07FFFFFE03FFFFFF
      01FFF80001FFF80001FFF80001FFF80001FFF80001FFF80001FFFFFFFFFF}
    IconVisible = False
    FormVisible = True
    AppVisible = True
    Left = 56
    Top = 112
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 32
    Top = 56
  end
end
