{===============================================================================

Copyright (c) 2010 P.L. Polak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


===============================================================================}

unit frm_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdModbusClient, Types;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    edtIPAddress: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    mctPLC: TIdModbusClient;
    Label2: TLabel;
    edtReadReg: TEdit;
    btnRead: TButton;
    Label3: TLabel;
    edtWriteReg: TEdit;
    Label4: TLabel;
    edtValue: TEdit;
    btnWrite: TButton;
    Label5: TLabel;
    edtReadAmount: TEdit;
    procedure btnReadClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

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
end; { btnReadClick }


procedure TfrmMain.btnWriteClick(Sender: TObject);
begin
  mctPLC.Host := edtIPAddress.Text;
  if mctPLC.WriteRegister(StrToInt(edtWriteReg.Text), StrToInt(edtValue.Text)) then
    MessageDlg('PLC register write successful!', mtError, [mbOk], 0)
  else
    MessageDlg('PLC register write failed!', mtError, [mbOk], 0);
end; { btnWriteClick }


end.
