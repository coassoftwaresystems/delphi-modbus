unit frm_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, IdModBusClient;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnRead: TButton;
    btnWrite: TButton;
    edtReadAmount: TEdit;
    edtValue: TEdit;
    edtReadReg: TEdit;
    edtIPAddress: TEdit;
    edtWriteReg: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    mctPLC: TIdModBusClient;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnReadClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnReadClick(Sender: TObject);
var
  Data: array[0..4096] of Word;
  iAmount: Integer;
  i: Integer;
  sLine: String;
begin
  iAmount := StrToInt(edtReadAmount.Text);
  if (iAmount > 0) then
  begin
    mctPLC.Host := edtIPAddress.Text;
    if mctPLC.ReadHoldingRegisters(StrToInt(edtReadReg.Text), iAmount, Data) then
    begin
      sLine := 'Register value(s) read:';
      for i := 0 to (iAmount - 1) do
        sLine := sLine +
                 #13#10'     ' +
                 IntToStr(StrToInt(edtReadReg.Text) + i) +
                 ': 0x'  +
                 IntToHex(Data[i], 4);
      ShowMessage(sLine);
    end
    else
      ShowMessage('PLC read operation failed!');
  end;
end;


procedure TfrmMain.btnWriteClick(Sender: TObject);
begin
  mctPLC.Host := edtIPAddress.Text;
  if mctPLC.WriteRegister(StrToInt(edtWriteReg.Text), StrToInt(edtValue.Text)) then
    MessageDlg('PLC register write successful!', mtError, [mbOk], 0)
  else
    MessageDlg('PLC register write failed!', mtError, [mbOk], 0);
end;


end.

