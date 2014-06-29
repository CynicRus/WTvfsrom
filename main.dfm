object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'War Thunder resource extractor'
  ClientHeight = 363
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    428
    363)
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 412
    Height = 330
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Filename'
        Width = 140
      end
      item
        Caption = 'FileSize(mb)'
        Width = 100
      end
      item
        Caption = 'Offset'
        Width = 110
      end>
    PopupMenu = ExtractMenu
    TabOrder = 0
    ViewStyle = vsReport
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 344
    Width = 428
    Height = 19
    Panels = <
      item
        Width = 120
      end
      item
        Width = 120
      end
      item
        Width = 100
      end
      item
        Width = 75
      end
      item
        Width = 50
      end>
  end
  object FileDlg: TOpenDialog
    Filter = 'War thunder VromFS|*.vromfs.bin| War thunder Dxp.bin|*.dxp.bin'
    Left = 112
    Top = 88
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 40
    object File1: TMenuItem
      Caption = 'File'
      object N2: TMenuItem
        Caption = 'Open'
        OnClick = N2Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
  end
  object ExtractMenu: TPopupMenu
    Left = 184
    Top = 200
    object Extract1: TMenuItem
      Caption = 'Extract'
      OnClick = Extract1Click
    end
    object Extractall1: TMenuItem
      Caption = 'Extract all'
      OnClick = Extractall1Click
    end
  end
end
