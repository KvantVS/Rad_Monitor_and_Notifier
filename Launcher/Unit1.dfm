object Form1: TForm1
  Left = 343
  Top = 388
  Width = 661
  Height = 561
  Caption = 'GPMonitor3Launcher'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    653
    527)
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 16
    Top = 276
    Width = 3
    Height = 13
    Anchors = [akLeft, akBottom]
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 653
    Height = 527
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 44
    Top = 56
  end
end
