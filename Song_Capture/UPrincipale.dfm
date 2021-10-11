object FrmPincipale: TFrmPincipale
  Left = 234
  Top = 133
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Song Capture'
  ClientHeight = 484
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object GroupBoxFichierCapture: TGroupBox
    Left = 8
    Top = 8
    Width = 409
    Height = 161
    Caption = ' Record path '
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 30
      Height = 16
      Caption = 'Path:'
    end
    object Label2: TLabel
      Left = 16
      Top = 80
      Width = 59
      Height = 16
      Caption = 'Failname:'
    end
    object LabelChemin: TLabel
      Left = 16
      Top = 136
      Width = 66
      Height = 16
      Caption = 'SongLabel'
    end
    object EditChemin: TEdit
      Left = 16
      Top = 48
      Width = 337
      Height = 25
      TabOrder = 0
      OnChange = EditCheminChange
    end
    object BtnParcourir: TButton
      Left = 360
      Top = 48
      Width = 33
      Height = 25
      Caption = '...'
      TabOrder = 1
      OnClick = BtnParcourirClick
    end
    object EditNomFichier: TEdit
      Left = 16
      Top = 104
      Width = 377
      Height = 25
      TabOrder = 2
      Text = 'SongCapture'
      OnChange = EditNomFichierChange
    end
  end
  object GroupBoxControleEnregistrement: TGroupBox
    Left = 8
    Top = 176
    Width = 409
    Height = 65
    Caption = ' Record control '
    TabOrder = 1
    object ComboBoxSource: TComboBox
      Left = 16
      Top = 30
      Width = 209
      Height = 24
      ItemHeight = 16
      TabOrder = 0
      Text = 'Source selection'
      OnChange = ComboBoxSourceChange
    end
    object BtnCtrlEnregistrement: TButton
      Left = 232
      Top = 30
      Width = 161
      Height = 27
      Caption = 'Record control...'
      TabOrder = 1
      OnClick = BtnCtrlEnregistrementClick
    end
  end
  object GroupBoxOptionsAudio: TGroupBox
    Left = 8
    Top = 246
    Width = 409
    Height = 110
    Caption = ' Audio options '
    TabOrder = 2
    object Label3: TLabel
      Left = 24
      Top = 32
      Width = 43
      Height = 16
      Caption = 'Stereo:'
    end
    object Label4: TLabel
      Left = 208
      Top = 30
      Width = 68
      Height = 16
      Caption = 'Frequence:'
    end
    object Label5: TLabel
      Left = 24
      Top = 72
      Width = 18
      Height = 16
      Caption = 'Bit:'
    end
    object ComboBoxStereo: TComboBox
      Left = 80
      Top = 24
      Width = 89
      Height = 24
      ItemHeight = 16
      TabOrder = 0
      Text = 'Stereo'
      OnChange = ComboBoxStereoChange
      Items.Strings = (
        'Mono'
        'Stereo')
    end
    object ComboBoxFrequence: TComboBox
      Left = 288
      Top = 24
      Width = 105
      Height = 24
      ItemHeight = 16
      TabOrder = 1
      Text = '44100 Hz'
      OnChange = ComboBoxFrequenceChange
      Items.Strings = (
        '11025 Hz'
        '22050 Hz'
        '44100 Hz')
    end
    object ComboBoxBit: TComboBox
      Left = 80
      Top = 69
      Width = 89
      Height = 24
      ItemHeight = 16
      TabOrder = 2
      Text = '16 bits'
      OnChange = ComboBoxBitChange
      Items.Strings = (
        '8   bits'
        '16 bits')
    end
  end
  object GroupBoxEnregistrement: TGroupBox
    Left = 8
    Top = 360
    Width = 409
    Height = 97
    Caption = ' Recording '
    TabOrder = 3
    object BtnDemarreEnregistrement: TButton
      Left = 16
      Top = 24
      Width = 377
      Height = 25
      Caption = 'Start recording'
      TabOrder = 0
      OnClick = BtnDemarreEnregistrementClick
    end
    object BtnStoppeEnregistrement: TButton
      Left = 16
      Top = 56
      Width = 377
      Height = 25
      Caption = 'Stop recording'
      Enabled = False
      TabOrder = 1
      OnClick = BtnStoppeEnregistrementClick
    end
    object MediaPlayer1: TMediaPlayer
      Left = 326
      Top = 37
      Width = 35
      Height = 37
      ColoredButtons = [btPause, btStop, btNext, btPrev, btStep, btBack, btRecord, btEject]
      VisibleButtons = []
      Visible = False
      TabOrder = 2
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 465
    Width = 426
    Height = 19
    Panels = <
      item
        Width = 150
      end>
  end
end
