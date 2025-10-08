object frmMain: TfrmMain
  Left = 243
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Delphi Modbus master demo'
  ClientHeight = 175
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 104
    Height = 13
    Caption = 'IP address of the PLC'
  end
  object edtIPAddress: TEdit
    Left = 120
    Top = 8
    Width = 137
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 249
    Height = 129
    Caption = ' Read test '
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 24
      Width = 75
      Height = 13
      Caption = 'PLC register nr.'
    end
    object Label5: TLabel
      Left = 16
      Top = 52
      Width = 57
      Height = 13
      Caption = 'Block length'
    end
    object edtReadReg: TEdit
      Left = 104
      Top = 20
      Width = 129
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object btnRead: TButton
      Left = 16
      Top = 88
      Width = 217
      Height = 25
      Caption = '&Read register'
      TabOrder = 2
      OnClick = btnReadClick
    end
    object edtReadAmount: TEdit
      Left = 104
      Top = 48
      Width = 73
      Height = 21
      TabOrder = 1
      Text = '1'
    end
  end
  object GroupBox2: TGroupBox
    Left = 264
    Top = 40
    Width = 249
    Height = 129
    Caption = ' Write test '
    TabOrder = 2
    object Label3: TLabel
      Left = 16
      Top = 24
      Width = 75
      Height = 13
      Caption = 'PLC register nr.'
    end
    object Label4: TLabel
      Left = 16
      Top = 56
      Width = 50
      Height = 13
      Caption = 'New value'
    end
    object edtWriteReg: TEdit
      Left = 104
      Top = 20
      Width = 129
      Height = 21
      TabOrder = 0
    end
    object edtValue: TEdit
      Left = 104
      Top = 52
      Width = 129
      Height = 21
      TabOrder = 1
    end
    object btnWrite: TButton
      Left = 16
      Top = 88
      Width = 217
      Height = 25
      Caption = '&Write register'
      TabOrder = 2
      OnClick = btnWriteClick
    end
  end
  object mctPLC: TIdModBusClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Left = 480
    Top = 8
  end
end
