{ $Id: frm_Main.pas,v 1.1 2011/08/25 10:05:10 plpolak Exp $ }

unit frm_Main;

interface

uses
  SysUtils, Types, Classes, UITypes, Variants, FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdModBusServer, FMX.Edit, FMX.Layouts, FMX.Grid, IdContext, ModbusTypes;

type
  TfrmMain = class(TForm)
    msrPLC: TIdModBusServer;
    btnStart: TButton;
    edtFirstReg: TEdit;
    edtLastReg: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    sgdRegisters: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure msrPLCReadHoldingRegisters(const Sender: TIdContext; const RegNr,
      Count: Integer; var Data: TModRegisterData;
      const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
    procedure msrPLCWriteRegisters(const Sender: TIdContext; const RegNr,
      Count: Integer; const Data: TModRegisterData;
      const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FFirstReg: Integer;
    FLastReg: Integer;
    FRegisterValues: array of Integer;
    procedure ClearRegisters;
    procedure FillRegisters;
    procedure Convert(const Index: Integer);
    procedure SetRegisterValue(const RegNo: Integer; const Value: Word);
    function GetRegisterValue(const RegNo: Integer): Word;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

function IntToBinary(const Value: Int64; const ALength: Integer): String;
var
  iWork: Int64;
begin
  Result := '';
  iWork := Value;
  while (iWork > 0) do
  begin
    Result := IntToStr(iWork mod 2) + Result;
    iWork := iWork div 2;
  end;
  while (Length(Result) < ALength) do
    Result := '0' + Result;
end;


procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  if msrPLC.Active then
  begin
    msrPLC.Active := False;
    edtFirstReg.Enabled := True;
    edtLastReg.Enabled := True;
    btnStart.Text := 'Start';
    ClearRegisters;
  end
  else
  begin
    FFirstReg := StrToInt(edtFirstReg.Text);
    FLastReg := StrToInt(edtLastReg.Text);
    msrPLC.MinRegister := FFirstReg;
    msrPLC.MaxRegister := FLastReg;
    btnStart.Text := 'Stop';
    msrPLC.Active := True;
    FillRegisters;
  end;
end;

procedure TfrmMain.ClearRegisters;
begin
  sgdRegisters.RowCount := 0;
end;


procedure TfrmMain.Convert(const Index: Integer);
begin
  sgdRegisters.Cells[2, Index] := IntToHex(FRegisterValues[Index], 4);
  sgdRegisters.Cells[3, Index] := IntToBinary(FRegisterValues[Index], 16);
end;


procedure TfrmMain.FillRegisters;
var
  i: Integer;
begin
  ClearRegisters;
  if (FLastReg >= FFirstReg) then
  begin
    sgdRegisters.RowCount := (FLastReg - FFirstReg) + 1;
    for i := FFirstReg to FLastReg do
    begin
      sgdRegisters.Cells[0, i - FFirstReg] := IntToStr(i);
      SetRegisterValue(i, Random(2000) + 3000);
    end;
  end;
end;


procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  msrPLC.Pause := True;
  if msrPLC.Active then
    btnStartClick(Sender);
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FFirstReg := 0;
  FLastReg := 0;
{ Start the ModBus slave }
  btnStartClick(Sender);
end;


function TfrmMain.GetRegisterValue(const RegNo: Integer): Word;

 function WordRange(const i: Integer):Word;
 begin
   if (i < 0) and (i >= -32767) then
     Result := Word(i)
   else if (i <= $FFFF) then
     Result := Word(i)
   else
     Result := $FFFF;
 end;

var
  Index: Integer;
begin
  if (RegNo >= FFirstReg) and (RegNo <= FLastReg) then
  begin
    Index := RegNo - FFirstReg;
    Assert(Index >= 0);
    Assert(Index < Length(FRegisterValues));
    if (Index >= 0) and (Index < Length(FRegisterValues)) then
      Result := WordRange(FRegisterValues[Index])
    else
      Result := 0;
  end
  else
    Result := 0;
end;


procedure TfrmMain.msrPLCReadHoldingRegisters(const Sender: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
var
  i: Integer;
begin
  for i := 0 to (Count - 1) do
    Data[i] := GetRegisterValue(RegNr + i);
end;


procedure TfrmMain.msrPLCWriteRegisters(const Sender: TIdContext; const RegNr,
  Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
var
  i: Integer;
begin
  for i := 0 to (Count - 1) do
    SetRegisterValue(RegNr + i, Data[i]);
end;


procedure TfrmMain.SetRegisterValue(const RegNo: Integer; const Value: Word);
var
 Index: Integer;
begin
  if (RegNo >= FFirstReg) and (RegNo <= FLastReg) then
  begin
    Index := RegNo - FFirstReg;
    if (Index >= Length(FRegisterValues)) then
      SetLength(FRegisterValues, (Index + 1) * 2);
    FRegisterValues[Index] := Value;
    sgdRegisters.Cells[1, Index] := IntToStr(Value);
    Convert(Index);
  end;
end;


end.

