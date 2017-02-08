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

{$I ModBusCompiler.inc}

unit IdModBusClient;

interface

uses
  Classes
 ,SysUtils
 ,ModBusConsts
 ,ModbusTypes
{$IFDEF DMB_DELPHI6}
 ,Types
{$ENDIF}
 ,IdGlobal
 ,IdTCPClient;

type
  TModBusClientErrorEvent = procedure(const FunctionCode: Byte;
    const ErrorCode: Byte; const ResponseBuffer: TModBusResponseBuffer) of object;
  TModBusClientResponseMismatchEvent = procedure(const RequestFunctionCode: Byte;
    const ResponseFunctionCode: Byte; const ResponseBuffer: TModBusResponseBuffer) of object;

type
{$IFDEF DMB_DELPHIXE3}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or
                               pidLinux32 or
  {$IFDEF DMB_DELPHIXE5}
                               pidAndroid or
  {$ENDIF}
  {$IFDEF DMB_DELPHIXE4}
                               pidiOSDevice or pidiOSSimulator or
  {$ENDIF}
  {$IFDEF DMB_DELPHIXE8}
                               pidiOSDevice64 or
  {$ENDIF}
                               pidOSX32)]
{$ENDIF}
  TIdModBusClient = class(TIdTCPClient)
  private
    FAutoConnect: Boolean;
    FBaseRegister: Word;
  {$IFNDEF DMB_INDY10}
    FConnectTimeOut: Integer;
  {$ENDIF}
    FOnResponseError: TModbusClientErrorEvent;
    FOnResponseMismatch: TModBusClientResponseMismatchEvent;
    FLastTransactionID: Word;
    FReadTimeout: Integer;
    FTimeOut: Cardinal;
    FUnitID: Byte;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    function GetNewTransactionID: Word;
  protected
    procedure DoResponseError(const FunctionCode: Byte; const ErrorCode: Byte;
      const ResponseBuffer: TModBusResponseBuffer);
    procedure DoResponseMismatch(const RequestFunctionCode: Byte; const ResponseFunctionCode: Byte;
      const ResponseBuffer: TModBusResponseBuffer);
  {$IFDEF DMB_INDY10}
    procedure InitComponent; override;
  {$ENDIF}
    function SendCommand(const AModBusFunction: TModBusFunction; const ARegNumber: Word;
      const ABlockLength: Word; var Data: array of Word): Boolean;
  public
    property LastTransactionID: Word read FLastTransactionID;
  {$IFNDEF DMB_INDY10}
    constructor Create(AOwner: TComponent); override;
  {$ENDIF}
  { public methods }
  {$IFDEF DMB_INDY10}
    procedure Connect; override;
  {$ELSE}
    procedure Connect(const ATimeout: Integer = IdTimeoutDefault); override;
  {$ENDIF}
    function ReadCoil(const RegNo: Word; out Value: Boolean): Boolean;
    function ReadCoils(const RegNo: Word; const Blocks: Word; out RegisterData: array of Boolean): Boolean;
    function ReadDouble(const RegNo: Word; out Value: Double): Boolean;
    function ReadDWord(const RegNo: Word; out Value: DWord): Boolean;
    function ReadHoldingRegister(const RegNo: Word; out Value: Word): Boolean;
    function ReadHoldingRegisters(const RegNo: Word; const Blocks: Word; out RegisterData: array of Word): Boolean;
    function ReadInputBits(const RegNo: Word; const Blocks: Word; out RegisterData: array of Boolean): Boolean;
    function ReadInputRegister(const RegNo: Word; out Value: Word): Boolean;
    function ReadInputRegisters(const RegNo: Word; const Blocks: Word; var RegisterData: array of Word): Boolean;
    function ReadSingle(const RegNo: Word; out Value: Single): Boolean;
    function ReadString(const RegNo: Word; const ALength: Word): String;
    function WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
    function WriteCoils(const RegNo: Word; const Blocks: Word; const RegisterData: array of Boolean): Boolean;
    function WriteRegister(const RegNo: Word; const Value: Word): Boolean;
    function WriteRegisters(const RegNo: Word; const RegisterData: array of Word): Boolean;
    function WriteDouble(const RegNo: Word; const Value: Double): Boolean;
    function WriteDWord(const RegNo: Word; const Value: DWord): Boolean;
    function WriteSingle(const RegNo: Word; const Value: Single): Boolean;
    function WriteString(const RegNo: Word; const Text: String): Boolean;
  published
    property AutoConnect: Boolean read FAutoConnect write FAutoConnect default True;
    property BaseRegister: Word read FBaseRegister write FBaseRegister default 1; 
  {$IFNDEF DMB_INDY10}
    property ConnectTimeOut: Integer read FConnectTimeOut write FConnectTimeOut default -1;
  {$ENDIF}
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout default 0;
    property Port default MB_PORT;
    property TimeOut: Cardinal read FTimeOut write FTimeout default 15000;
    property UnitID: Byte read FUnitID write FUnitID default MB_IGNORE_UNITID;
    property Version: String read GetVersion write SetVersion stored False;
  { events }
    property OnResponseError: TModbusClientErrorEvent read FOnResponseError write FOnResponseError;
    property OnResponseMismatch: TModBusClientResponseMismatchEvent read FOnResponseMismatch write FOnResponseMismatch;
  end;


implementation

uses
  ModbusUtils;


{ TIdModBusClient }

{$IFDEF DMB_INDY10}
procedure TIdModBusClient.Connect;
{$ELSE}
procedure TIdModBusClient.Connect(const ATimeout: Integer = IdTimeoutDefault);
{$ENDIF}
begin
  inherited;
  FLastTransactionID := 0;
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusClient.InitComponent;
{$ELSE}
constructor TIdModBusClient.Create(AOwner: TComponent);
{$ENDIF}
begin
{$IFDEF DMB_INDY10}
  inherited;
{$ELSE}
  inherited Create(AOwner);
  FConnectTimeOut := -1;
{$ENDIF}
  FAutoConnect := True;
  FBaseRegister := 1;
  FLastTransactionID := 0;
  FReadTimeout := 0;
  FUnitID := MB_IGNORE_UNITID;
  FTimeOut := 15000;
  Port := MB_PORT;
  FOnResponseError := nil;
  FOnResponseMismatch := nil;
end;


procedure TIdModBusClient.DoResponseError(const FunctionCode: Byte; const ErrorCode: Byte;
  const ResponseBuffer: TModBusResponseBuffer);
begin
  if Assigned(FOnResponseError) then
    FOnResponseError(FunctionCode, ErrorCode, ResponseBuffer);
end;


procedure TIdModBusClient.DoResponseMismatch(const RequestFunctionCode: Byte;
  const ResponseFunctionCode: Byte; const ResponseBuffer: TModBusResponseBuffer);
begin
  if Assigned(FOnResponseMismatch) then
    FOnResponseMismatch(RequestFunctionCode, ResponseFunctionCode, ResponseBuffer);
end;


function TIdModBusClient.SendCommand(const AModBusFunction: TModBusFunction;
  const ARegNumber: Word; const ABlockLength: Word; var Data: array of Word): Boolean;
var
  SendBuffer: TModBusRequestBuffer;
  ReceiveBuffer: TModBusResponseBuffer;
  BlockLength: Word;
  RegNumber: Word;
  dtTimeOut: TDateTime;
{$IFDEF DMB_INDY10}
  Buffer: TIdBytes;
  RecBuffer: TIdBytes;
  iSize: Integer;
{$ENDIF}
begin
{$IFDEF DMB_INDY10}
  CheckForGracefulDisconnect(True);
{$ELSE}
  CheckForDisconnect(True, True);
{$ENDIF}
  SendBuffer.Header.TransactionID := GetNewTransactionID;
  SendBuffer.Header.ProtocolID := MB_PROTOCOL;
{ Initialise data related variables }
  RegNumber := ARegNumber - FBaseRegister;
{ Perform function code specific operations }
  case AModBusFunction of
    mbfReadCoils,
    mbfReadInputBits:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 2000) then
          BlockLength := 2000;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfReadHoldingRegs,
    mbfReadInputRegs:
      begin
        BlockLength := ABlockLength;
        if (BlockLength > 125) then
          BlockLength := 125; { Don't exceed max length }
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteOneCoil:
      begin
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        if (Data[0] <> 0) then
          SendBuffer.MBPData[2] := 255
        else
          SendBuffer.MBPData[2] := 0;
        SendBuffer.MBPData[3] := 0;
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteOneReg:
      begin
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(Data[0]);
        SendBuffer.MBPData[3] := Lo(Data[0]);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteCoils:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 1968) then
          BlockLength := 1968;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.MBPData[4] := Byte((BlockLength + 7) div 8);
        PutCoilsIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
        SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MBPData[4]);
      end;
    mbfWriteRegs:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 120) then
          BlockLength := 120;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := FUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.MbpData[4] := Byte(BlockLength shl 1);
        PutRegistersIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
        SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MbpData[4]);
      end;
  end;
{ Writeout the data to the connection }
{$IFDEF DMB_INDY10}
  Buffer := RawToBytes(SendBuffer, Swap16(SendBuffer.Header.RecLength) + 6);
  IOHandler.WriteDirect(Buffer);
{$ELSE}
  WriteBuffer(SendBuffer, Swap16(SendBuffer.Header.RecLength) + 6);
{$ENDIF}

{*** Wait for data from the PLC ***}
  if (FTimeOut > 0) then
  begin
    dtTimeOut := Now + (FTimeOut / 86400000);
  {$IFDEF DMB_INDY10}
    while (IOHandler.InputBuffer.Size = 0) do
  {$ELSE}
    while (InputBuffer.Size = 0) do
  {$ENDIF}
    begin
   {$IFDEF DMB_INDY10}
      IOHandler.CheckForDataOnSource(FReadTimeout);
   {$ELSE}
      if Socket.Binding.Readable(FReadTimeout) then
        ReadFromStack;
    {$ENDIF}
      if (Now > dtTimeOut) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

  Result := True;
{$IFDEF DMB_INDY10}
  iSize := IOHandler.InputBuffer.Size;
  IOHandler.ReadBytes(RecBuffer, iSize);
  Move(RecBuffer[0], ReceiveBuffer, iSize);
{$ELSE}
  ReadBuffer(ReceiveBuffer, InputBuffer.Size);
{$ENDIF}
{ Check if the result has the same function code as the request }
  if (AModBusFunction = ReceiveBuffer.FunctionCode) then
  begin
    case AModBusFunction of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          BlockLength := ReceiveBuffer.MBPData[0] * 8;
          if (BlockLength > 2000) then
            BlockLength := 2000;
          GetCoilsFromBuffer(@ReceiveBuffer.MBPData[1], BlockLength, Data);
        end;
      mbfReadHoldingRegs,
      mbfReadInputRegs:
        begin
          BlockLength := (ReceiveBuffer.MBPData[0] shr 1);
          if (BlockLength > 125) then
            BlockLength := 125;
          GetRegistersFromBuffer(@ReceiveBuffer.MBPData[1], BlockLength, Data);
        end;
    end;
  end
  else
  begin
    if ((AModBusFunction or $80) = ReceiveBuffer.FunctionCode) then
      DoResponseError(AModBusFunction, ReceiveBuffer.MBPData[0], ReceiveBuffer)
    else
      DoResponseMismatch(AModBusFunction, ReceiveBuffer.FunctionCode, ReceiveBuffer);
    Result := False;
  end;
end;


function TIdModBusClient.GetNewTransactionID: Word;
begin
  if (FLastTransactionID = $FFFF) then
    FLastTransactionID := 0
  else
    Inc(FLastTransactionID);
  Result := FLastTransactionID;
end;


function TIdModBusClient.ReadHoldingRegister(const RegNo: Word;
  out Value: Word): Boolean;
var
  Data: array[0..0] of Word;  
begin
  Result := ReadHoldingRegisters(RegNo, 1, Data);
  Value := Data[0];
end;


function TIdModBusClient.ReadHoldingRegisters(const RegNo, Blocks: Word;
  out RegisterData: array of Word): Boolean;
var
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  try
    SetLength(Data, Blocks);
    FillChar(Data[0], Length(Data), 0);
    Result := SendCommand(mbfReadHoldingRegs, RegNo, Blocks, Data);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.ReadInputBits(const RegNo, Blocks: Word;
  out RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  SetLength(Data, Blocks);
  FillChar(Data[0], Length(Data), 0);
  try
    Result := SendCommand(mbfReadInputBits, RegNo, Blocks, Data);
    for i := 0 to (Blocks - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;

function TIdModBusClient.ReadInputRegister(const RegNo: Word;
  out Value: Word): Boolean;
var
  Data: array[0..0] of Word;
begin
  Result := ReadInputRegisters(RegNo, 1, Data);
  Value := Data[0];
end;


function TIdModBusClient.ReadInputRegisters(const RegNo, Blocks: Word;
  var RegisterData: array of Word): Boolean;
var
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  FillChar(RegisterData[0], Length(RegisterData), 0);
  try
    Result := SendCommand(mbfReadInputRegs, RegNo, Blocks, RegisterData);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.ReadCoil(const RegNo: Word; out Value: Boolean): Boolean;
var
  Data: array[0..0] of Boolean;
begin
  Result := ReadCoils(RegNo, 1, Data);
  Value := Data[0];
end;


function TIdModBusClient.ReadCoils(const RegNo, Blocks: Word; out RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  SetLength(Data, Blocks);
  FillChar(Data[0], Length(Data), 0);
  try
    Result := SendCommand(mbfReadCoils, RegNo, Blocks, Data);
    for i := 0 to (Blocks - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModbusClient.ReadDouble(const RegNo: Word; out Value: Double): Boolean;
var
  Buffer: array[0..3] of Word;
begin
  Result := ReadHoldingRegisters(RegNo, 4, Buffer);
  if Result then
    Move(Buffer, Value, SizeOf(Value))
  else
    Value := 0.0;
end;


function TIdModbusClient.ReadDWord(const RegNo: Word; out Value: DWord): Boolean;
var
  Buffer: array[0..1] of Word;
begin
  Result := ReadHoldingRegisters(RegNo, 2, Buffer);
  if Result then
  begin
    LongRec(Value).Hi := Buffer[0];
    LongRec(Value).Lo := Buffer[1];
  end
  else
    Value := 0;
end;


function TIdModbusClient.ReadSingle(const RegNo: Word; out Value: Single): Boolean;
var
  Buffer: array[0..1] of Word;
begin
  Result := ReadHoldingRegisters(RegNo, 2, Buffer);
  if Result then
    Move(Buffer, Value, SizeOf(Value))
  else
    Value := 0.0;
end;


function TIdModbusClient.ReadString(const RegNo: Word; const ALength: Word): String;
var
  BlockCount: Word;
  Data: array of Word;
  i: Integer;
begin
  Result := '';
  BlockCount := Round((ALength / 2) + 0.1);
  SetLength(Data, BlockCount);
  FillChar(Data[0], BlockCount, 0);

  if ReadHoldingRegisters(RegNo, BlockCount, Data) then
  begin
    for i := 0 to (BlockCount - 1) do
    begin
      Result := Result + Chr(WordRec(Data[i]).Hi);
      if (Length(Result) < ALength) then
        Result := Result + Chr(WordRec(Data[i]).Lo);
    end;
  end;
end;


function TIdModBusClient.GetVersion: String;
begin
  Result := DMB_VERSION;
end;


procedure TIdModBusClient.SetVersion(const Value: String);
begin
{ This intentionally is a readonly property }
end;


function TIdModBusClient.WriteDouble(const RegNo: Word; const Value: Double): Boolean;
var
  Buffer: array[0..3] of Word;
begin
  Move(Value, Buffer, SizeOf(Value));
  Result := WriteRegisters(RegNo, Buffer);
end;


function TIdModBusClient.WriteDWord(const RegNo: Word; const Value: DWord): Boolean;
var
  Buffer: array[0..1] of Word;
begin
  Buffer[0] := LongRec(Value).Hi;
  Buffer[1] := LongRec(Value).Lo;
  Result := WriteRegisters(RegNo, Buffer);
end;


function TIdModBusClient.WriteSingle(const RegNo: Word; const Value: Single): Boolean;
var
  Buffer: array[0..1] of Word;
begin
  Move(Value, Buffer, SizeOf(Value));
  Result := WriteRegisters(RegNo, Buffer);
end;



function TIdModBusClient.WriteString(const RegNo: Word; const Text: String): Boolean;
var
  Buffer: array of Word;
  i: Integer;
  iIndex: Integer;
begin
  if (Text <> '') then
  begin
    SetLength(Buffer, Round((Length(Text) / 2) + 0.1));
    FillChar(Buffer[0], Length(Buffer), 0);
    for i := 0 to Length(Buffer) do
    begin
      iIndex := (i * 2) + 1;
      if (iIndex <= Length(Text)) then
        WordRec(Buffer[i]).Hi := Ord(Text[iIndex]);
      if ((iIndex + 1) <= Length(Text)) then
        WordRec(Buffer[i]).Lo := Ord(Text[iIndex + 1]);
    end;
    Result := WriteRegisters(RegNo, Buffer);
  end
  else
    Result := False;
end;


function TIdModBusClient.WriteRegister(const RegNo, Value: Word): Boolean;
var
  Data: array[0..0] of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  Data[0] := Value;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  try
    Result := SendCommand(mbfWriteOneReg, RegNo, 0, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteRegisters(const RegNo: Word;
  const RegisterData: array of Word): Boolean;
var
  i: Integer;
  iBlockLength: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  iBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  try
    SetLength(Data, Length(RegisterData));
    for i := Low(RegisterData) to High(RegisterData) do
      Data[i] := RegisterData[i];
    Result := SendCommand(mbfWriteRegs, RegNo, iBlockLength, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
var
  Data: array[0..0] of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if Value then
    Data[0] := 1
  else
    Data[0] := 0;

  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  try
    Result := SendCommand(mbfWriteOneCoil, RegNo, 0, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteCoils(const RegNo, Blocks: Word; const RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  iBlockLength: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  iBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  if FAutoConnect and not Connected then
  begin
  {$IFDEF DMB_INDY10}
    Connect;
  {$ELSE}
    Connect(FConnectTimeOut);
  {$ENDIF}
    bNewConnection := True;
  end;

  try
    SetLength(Data, Length(RegisterData));
    for i := Low(RegisterData) to High(RegisterData) do
    begin
      if RegisterData[i] then
        Data[i] := 1
      else
        Data[i] := 0;
    end;
    Result := SendCommand(mbfWriteCoils, RegNo, iBlockLength, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


end.

