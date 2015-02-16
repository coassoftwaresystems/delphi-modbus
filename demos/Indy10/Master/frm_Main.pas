{===============================================================================

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above. If you wish to
allow use of your version of this file only under the terms of the GPL and not
to allow others to use your version of this file under the MPL, indicate your
decision by deleting the provisions above and replace them with the notice and
other provisions required by the GPL. If you do not delete the provisions
above, a recipient may use your version of this file under either the MPL or
the GPL.

$Id: frm_Main.pas,v 1.4 2010/02/05 10:17:28 plpolak Exp $

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
    mctPLC: TIdModBusClient;
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

