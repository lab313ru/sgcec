object frmMain: TfrmMain
  Left = 0
  Top = 0
  ActiveControl = btnRun
  ClientHeight = 481
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpConfig: TGroupBox
    Left = 0
    Top = 0
    Width = 464
    Height = 81
    Align = alTop
    Caption = 'Settings:'
    TabOrder = 0
    object lblScript: TLabel
      Left = 25
      Top = 22
      Width = 61
      Height = 13
      Alignment = taRightJustify
      Caption = 'Script Name:'
    end
    object cbbScript: TComboBox
      Left = 92
      Top = 19
      Width = 259
      Height = 21
      AutoDropDown = True
      AutoCloseUp = True
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbbScriptChange
    end
    object btnRefreshScripts: TButton
      Left = 357
      Top = 17
      Width = 66
      Height = 25
      Caption = '&Refresh'
      DoubleBuffered = True
      ModalResult = 4
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = btnRefreshScriptsClick
    end
    object btnRun: TButton
      Left = 92
      Top = 48
      Width = 81
      Height = 25
      Caption = '&Run Script'
      Default = True
      DoubleBuffered = True
      ModalResult = 6
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = btnRunClick
    end
    object btnAbout: TButton
      Left = 357
      Top = 48
      Width = 66
      Height = 25
      Caption = '&About'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 3
      OnClick = btnAboutClick
    end
    object btnSaveLua: TButton
      Left = 179
      Top = 48
      Width = 82
      Height = 25
      Caption = '&Save Script'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 4
      OnClick = btnSaveLuaClick
    end
    object btnDevInfo: TButton
      Left = 267
      Top = 48
      Width = 84
      Height = 25
      Caption = '&Device Info'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 5
      OnClick = btnDevInfoClick
    end
  end
  object mmoLog: TMemo
    Left = 0
    Top = 81
    Width = 464
    Height = 383
    Align = alClient
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clPurple
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Pitch = fpVariable
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object pbProgress: TProgressBar
    Left = 0
    Top = 464
    Width = 464
    Height = 17
    Align = alBottom
    Smooth = True
    TabOrder = 2
  end
  object xpMan: TXPManifest
    Left = 256
    Top = 256
  end
  object dlgSaveBin: TSaveDialog
    DefaultExt = 'bin'
    Filter = 'Binary Files (*.bin)|*.bin|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofFileMustExist, ofNoNetworkButton, ofEnableSizing, ofDontAddToRecent]
    Title = 'Where to save?..'
    Left = 216
    Top = 256
  end
end
