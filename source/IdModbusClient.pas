{===============================================================================

Copyright (c) 2025 P.L. Polak

The MIT License (MIT)

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
  Classes, SysUtils, ModBusConsts, ModbusTypes, Types, IdGlobal, IdTCPClient;

type
  TModBusClientErrorEvent = procedure(const FunctionCode: Byte;
    const ErrorCode: Byte; const ResponseBuffer: TModBusResponseBuffer) of object;
  TModbusClientHandleResponse = procedure(const ResponseBuffer: TModBusResponseBuffer;
    out RegisterData: array of Word) of object;
  TModBusClientResponseMismatchEvent = procedure(const RequestFunctionCode: Byte;
    const ResponseFunctionCode: Byte; const ResponseBuffer: TModBusResponseBuffer) of object;
  TModbusClientSendBufferEvent = procedure(const RequestBuffer: TModBusRequestBuffer;
    const RawBuffer: TIdBytes) of object;
  TModbusClientReceiveBufferEvent = procedure(const RequestBuffer: TModBusRequestBuffer;
    const ResponseBuffer: TModBusResponseBuffer; const RawBuffer: TIdBytes) of object;

type
{$I ModBusPlatforms.inc}
  TIdModBusClient = class(TIdTCPClient)
  private
    FAutoConnect: Boolean;
    FBaseRegister: Word;
    FIncludeCrc: Boolean;
    FOnSendBuffer: TModbusClientSendBufferEvent;
    FOnReceiveBuffer: TModbusClientReceiveBufferEvent;
    FOnResponseError: TModbusClientErrorEvent;
    FOnResponseMismatch: TModBusClientResponseMismatchEvent;
    FLastTransactionID: Word;
    FReadTimeout: Integer;
    FTimeOut: Cardinal;
    FUnitID: Byte;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    function GetNewTransactionID: Word;
    procedure HandleReadBitsResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandleReadHoldingRegistersResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandleReadInputRegistersResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandleReportSlaveIDResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
  protected
    function BuildRequestBuffer(const AModBusFunction: TModBusFunction;
      const ARegNumber: Word): TModBusRequestBuffer; virtual;
    procedure DoReceiveBuffer(const ARequestBuffer: TModBusRequestBuffer;
      const AResponseBuffer: TModBusResponseBuffer; const Buffer: TIdBytes); virtual;
    procedure DoSendBuffer(const ARequestBuffer: TModBusRequestBuffer; const Buffer: TIdBytes); virtual;
    procedure DoResponseError(const FunctionCode: Byte; const ErrorCode: Byte;
      const ResponseBuffer: TModBusResponseBuffer); virtual;
    procedure DoResponseMismatch(const RequestFunctionCode: Byte; const ResponseFunctionCode: Byte;
      const ResponseBuffer: TModBusResponseBuffer); virtual;
    function ReadBits(const AModBusFunction: TModBusFunction; const RegNo, ABlockLength: Word;
      out RegisterData: array of Boolean): Boolean;
    procedure InitComponent; override;
    function SendCommand(var ARequestBuffer: TModBusRequestBuffer;
      const ABlockLength: Word; var Data: array of Word;
      const AResponseHandler: TModbusClientHandleResponse = nil): Boolean;
    function SendCommandToSocket(const ARequestBuffer: TModBusRequestBuffer;
      var Data: array of Word; const AResponseHandler: TModbusClientHandleResponse = nil): Boolean;
  public
    property LastTransactionID: Word read FLastTransactionID;
  { public methods }
    procedure Connect; override;
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
    function ReportSlaveID(const Blocks: Word; out RegisterData: array of Word):boolean;
    function WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
    function WriteCoils(const RegNo: Word; const Blocks: Word; const RegisterData: array of Boolean): Boolean;
    function WriteRegister(const RegNo: Word; const Value: Word): Boolean;
    function WriteRegisterMasked(const RegNo: Word; const AndMask: Word; const OrMask: Word): Boolean;
    function WriteRegisters(const RegNo: Word; const RegisterData: array of Word): Boolean;
    function WriteDouble(const RegNo: Word; const Value: Double): Boolean;
    function WriteDWord(const RegNo: Word; const Value: DWord): Boolean;
    function WriteSingle(const RegNo: Word; const Value: Single): Boolean;
    function WriteString(const RegNo: Word; const Text: String): Boolean;
  published
    property AutoConnect: Boolean read FAutoConnect write FAutoConnect default True;
    property BaseRegister: Word read FBaseRegister write FBaseRegister default 1;
    property IncludeCrc: Boolean read FIncludeCrc write FIncludeCrc default False;
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout default 0;
    property Port default MB_PORT;
    property TimeOut: Cardinal read FTimeOut write FTimeout default 15000;
    property UnitID: Byte read FUnitID write FUnitID default MB_IGNORE_UNITID;
    property Version: String read GetVersion write SetVersion stored False;
  { events }
    property OnSendBuffer: TModbusClientSendBufferEvent read FOnSendBuffer write FOnSendBuffer;
    property OnReceiveBuffer: TModbusClientReceiveBufferEvent read FOnReceiveBuffer write FOnReceiveBuffer;
    property OnResponseError: TModbusClientErrorEvent read FOnResponseError write FOnResponseError;
    property OnResponseMismatch: TModBusClientResponseMismatchEvent read FOnResponseMismatch write FOnResponseMismatch;
  end;


implementation

uses
  ModbusUtils;


{ TIdModBusClient }

procedure TIdModBusClient.Connect;
begin
  inherited;
  FLastTransactionID := 0;
end;


procedure TIdModBusClient.InitComponent;
begin
  inherited;
  FAutoConnect := True;
  FBaseRegister := 1;
  FIncludeCrc := False;
  FLastTransactionID := 0;
  FReadTimeout := 0;
  FUnitID := MB_IGNORE_UNITID;
  FTimeOut := 15000;
  Port := MB_PORT;
  FOnSendBuffer := nil;
  FOnReceiveBuffer := nil;
  FOnResponseError := nil;
  FOnResponseMismatch := nil;
end;


function TIdModBusClient.BuildRequestBuffer(const AModBusFunction: TModBusFunction;
  const ARegNumber: Word): TModBusRequestBuffer;
begin
  Result.Header.TransactionID := GetNewTransactionID;
  Result.Header.ProtocolID := MB_PROTOCOL;
  Result.FunctionCode := Byte(AModBusFunction);
  Result.Header.UnitID := FUnitID;
  Result.MBPData[0] := Hi(ARegNumber);
  Result.MBPData[1] := Lo(ARegNumber);
end;


procedure TIdModBusClient.DoReceiveBuffer(const ARequestBuffer: TModBusRequestBuffer;
  const AResponseBuffer: TModBusResponseBuffer; const Buffer: TIdBytes);
begin
  if Assigned(FOnReceiveBuffer) then
    FOnReceiveBuffer(ARequestBuffer, AResponseBuffer, Buffer);
end;


procedure TIdModBusClient.DoSendBuffer(const ARequestBuffer: TModBusRequestBuffer; const Buffer: TIdBytes);
begin
  if Assigned(FOnSendBuffer) then
    FOnSendBuffer(ARequestBuffer, Buffer);
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



function TIdModBusClient.SendCommand(var ARequestBuffer: TModBusRequestBuffer;
  const ABlockLength: Word; var Data: array of Word;
  const AResponseHandler: TModbusClientHandleResponse = nil): Boolean;
var
  BlockLength: Word;
begin
{ Perform function code specific operations }
  case ARequestBuffer.FunctionCode of
    mbfReadHoldingRegs,
    mbfReadInputRegs:
      begin
        BlockLength := ABlockLength;
        if (BlockLength > 125) then
          BlockLength := 125; { Don't exceed max length }
      { Initialise the data part }
        ARequestBuffer.MBPData[2] := Hi(BlockLength);
        ARequestBuffer.MBPData[3] := Lo(BlockLength);
        ARequestBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
  end;

  Result := SendCommandToSocket(ARequestBuffer, Data, AResponseHandler);
end;


function TIdModBusClient.SendCommandToSocket(const ARequestBuffer: TModBusRequestBuffer;
  var Data: array of Word; const AResponseHandler: TModbusClientHandleResponse = nil): Boolean;
var
  Buffer: TIdBytes;
  Crc: Word;
  dtTimeOut: TDateTime;
  iSize: Integer;
  ReceiveBuffer: TIdBytes;
  ResponseBuffer: TModBusResponseBuffer;
begin
  CheckForGracefulDisconnect(True);
{ Clear input buffer to prevent reading possible data left from previous request }
  if Connected then
    IOHandler.InputBuffer.Clear;
{ Writeout the data to the connection }
  Buffer := RawToBytes(ARequestBuffer, Swap16(ARequestBuffer.Header.RecLength) + 6);
  if FIncludeCrc then
  begin
    Crc := CalculateCRC16(Buffer);
  {$IFDEF DMB_DELPHIXE3}
    SetLength(Buffer, IndyLength(Buffer) + 2);
  {$ELSE}
    SetLength(Buffer, Length(Buffer) + 2);
  {$ENDIF}
    Buffer[High(Buffer)] := Hi(Crc);
    Buffer[High(Buffer) - 1] := Lo(Crc);
  end;

  IOHandler.WriteDirect(Buffer);
  DoSendBuffer(ARequestBuffer, Buffer);

{*** Wait for data from the PLC ***}
  if (FTimeOut > 0) then
  begin
    dtTimeOut := Now + (FTimeOut / 86400000);
    while (IOHandler.InputBuffer.Size = 0) do
    begin
      IOHandler.CheckForDataOnSource(FReadTimeout);
      if (Now > dtTimeOut) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

  Result := True;
  iSize := IOHandler.InputBuffer.Size;
  IOHandler.ReadBytes(ReceiveBuffer, iSize);
  Move(ReceiveBuffer[0], ResponseBuffer, iSize);

  DoReceiveBuffer(ARequestBuffer, ResponseBuffer, ReceiveBuffer);

{ Check if the result has the same function code as the request }
  if (ARequestBuffer.FunctionCode = ResponseBuffer.FunctionCode) then
  begin
    if Assigned(AResponseHandler) then
      AResponseHandler(ResponseBuffer, Data);
  end
  else
  begin
    if ((ARequestBuffer.FunctionCode or $80) = ResponseBuffer.FunctionCode) then
      DoResponseError(ARequestBuffer.FunctionCode, ResponseBuffer.MBPData[0], ResponseBuffer)
    else
      DoResponseMismatch(ARequestBuffer.FunctionCode, ResponseBuffer.FunctionCode, ResponseBuffer);
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


procedure TIdModBusClient.HandleReadBitsResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  BlockLength: Word;
begin
  BlockLength := ResponseBuffer.MBPData[0] * 8;
  if (BlockLength > 2000) then
    BlockLength := 2000;
  GetCoilsFromBuffer(@ResponseBuffer.MBPData[1], BlockLength, RegisterData);
end;


function TIdModBusClient.ReadBits(const AModBusFunction: TModBusFunction;
  const RegNo, ABlockLength: Word; out RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  wBlockLength: Word;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  wBlockLength := ABlockLength;
  { Don't exceed max length }
  if (wBlockLength > 2000) then
    wBlockLength := 2000;
  SetLength(Data, wBlockLength);
  FillChar(Data[0], Length(Data), 0);

  try
    RequestBuffer := BuildRequestBuffer(AModBusFunction, RegNo - FBaseRegister);
  { Initialise the data part }
    RequestBuffer.MBPData[2] := Hi(wBlockLength);
    RequestBuffer.MBPData[3] := Lo(wBlockLength);
    RequestBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommand(RequestBuffer, wBlockLength, Data, HandleReadBitsResponse);
    for i := 0 to (wBlockLength - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.ReadHoldingRegister(const RegNo: Word;
  out Value: Word): Boolean;
var
  Data: array[0..0] of Word;
begin
  Result := ReadHoldingRegisters(RegNo, 1, Data);
  Value := Data[0];
end;


procedure TIdModBusClient.HandleReadHoldingRegistersResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  BlockLength: Word;
begin
  BlockLength := (ResponseBuffer.MBPData[0] shr 1);
  if (BlockLength > 125) then
    BlockLength := 125;
  GetRegistersFromBuffer(@ResponseBuffer.MBPData[1], BlockLength, RegisterData);
end;


function TIdModBusClient.ReadHoldingRegisters(const RegNo, Blocks: Word;
  out RegisterData: array of Word): Boolean;
var
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    SetLength(Data, Blocks);
    FillChar(Data[0], Length(Data), 0);
    RequestBuffer := BuildRequestBuffer(mbfReadHoldingRegs, RegNo - FBaseRegister);
    Result := SendCommand(RequestBuffer, Blocks, Data, HandleReadHoldingRegistersResponse);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.ReadInputBits(const RegNo, Blocks: Word;
  out RegisterData: array of Boolean): Boolean;
begin
  Result := ReadBits(mbfReadInputBits, RegNo, Blocks, RegisterData);
end;


function TIdModBusClient.ReadInputRegister(const RegNo: Word;
  out Value: Word): Boolean;
var
  Data: array[0..0] of Word;
begin
  Result := ReadInputRegisters(RegNo, 1, Data);
  Value := Data[0];
end;


procedure TIdModBusClient.HandleReadInputRegistersResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  BlockLength: Word;
begin
  BlockLength := (ResponseBuffer.MBPData[0] shr 1);
  if (BlockLength > 125) then
    BlockLength := 125;
  GetRegistersFromBuffer(@ResponseBuffer.MBPData[1], BlockLength, RegisterData);
end;


function TIdModBusClient.ReadInputRegisters(const RegNo, Blocks: Word;
  var RegisterData: array of Word): Boolean;
var
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  FillChar(RegisterData[0], Length(RegisterData), 0);
  try
    RequestBuffer := BuildRequestBuffer(mbfReadInputRegs, RegNo - FBaseRegister);
    Result := SendCommand(RequestBuffer, Blocks, RegisterData, HandleReadInputRegistersResponse);
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
begin
  Result := ReadBits(mbfReadCoils, RegNo, Blocks, RegisterData);
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


procedure TIdModbusClient.HandleReportSlaveIDResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  BlockLength: Word;
begin
  BlockLength := Swap16(ResponseBuffer.Header.RecLength) - 2;
  GetReportFromBuffer(@ResponseBuffer.MBPData[0], BlockLength, RegisterData);
end;


function TIdModbusClient.ReportSlaveID(const Blocks: Word; out RegisterData: array of Word): Boolean;
var
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;
  FillChar(RegisterData[0], Length(RegisterData), 0);
  try
    RequestBuffer := BuildRequestBuffer(mbfReportSlaveID, 0);
    RequestBuffer.Header.RecLength := Swap16(2); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, RegisterData, HandleReportSlaveIDResponse);
  finally
    if bNewConnection then
      DisConnect;
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
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  Data[0] := Value;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    RequestBuffer := BuildRequestBuffer(mbfWriteOneReg, RegNo - FBaseRegister);
    RequestBuffer.MBPData[2] := Hi(Data[0]);
    RequestBuffer.MBPData[3] := Lo(Data[0]);
    RequestBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteRegisterMasked(const RegNo: Word; const AndMask: Word; const OrMask: Word): Boolean;
var
  Data: array[0..1] of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  Data[0] := AndMask;
  Data[1] := OrMask;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    RequestBuffer := BuildRequestBuffer(mbfMaskedWriteReg, RegNo - FBaseRegister);
    RequestBuffer.MBPData[2] := Hi(Data[0]);
    RequestBuffer.MBPData[3] := Lo(Data[0]);
    RequestBuffer.MBPData[4] := Hi(Data[1]);
    RequestBuffer.MBPData[5] := Lo(Data[1]);
    RequestBuffer.Header.RecLength := Swap16(8); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteRegisters(const RegNo: Word;
  const RegisterData: array of Word): Boolean;
var
  i: Integer;
  wBlockLength: Word;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  wBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    SetLength(Data, Length(RegisterData));
    for i := Low(RegisterData) to High(RegisterData) do
      Data[i] := RegisterData[i];
    RequestBuffer := BuildRequestBuffer(mbfWriteRegs, RegNo - FBaseRegister);
  { Don't exceed max length }
    if (wBlockLength > 120) then
      wBlockLength := 120;
  { Initialise the data part }
    RequestBuffer.MBPData[2] := Hi(wBlockLength);
    RequestBuffer.MBPData[3] := Lo(wBlockLength);
    RequestBuffer.MbpData[4] := Byte(wBlockLength shl 1);
    PutRegistersIntoBuffer(@RequestBuffer.MBPData[5], wBlockLength, Data);
    RequestBuffer.Header.RecLength := Swap16(7 + RequestBuffer.MbpData[4]);
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
var
  Data: array[0..0] of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  if Value then
    Data[0] := 1
  else
    Data[0] := 0;

  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    RequestBuffer := BuildRequestBuffer(mbfWriteOneCoil, RegNo - FBaseRegister);
  { Initialise the data part }
    if Value then
      RequestBuffer.MBPData[2] := 255
    else
       RequestBuffer.MBPData[2] := 0;
    RequestBuffer.MBPData[3] := 0;
    RequestBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


function TIdModBusClient.WriteCoils(const RegNo, Blocks: Word; const RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  wBlockLength: Word;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
begin
  bNewConnection := False;
  wBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  if FAutoConnect and not Connected then
  begin
    Connect;
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
    RequestBuffer := BuildRequestBuffer(mbfWriteCoils, RegNo - FBaseRegister);
  { Don't exceed max length }
    if (wBlockLength > 1968) then
      wBlockLength := 1968;
  { Initialise the data part }
    RequestBuffer.MBPData[2] := Hi(wBlockLength);
    RequestBuffer.MBPData[3] := Lo(wBlockLength);
    RequestBuffer.MBPData[4] := Byte((wBlockLength + 7) div 8);
    PutCoilsIntoBuffer(@RequestBuffer.MBPData[5], wBlockLength, Data);
    RequestBuffer.Header.RecLength := Swap16(7 + RequestBuffer.MBPData[4]);
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;


end.

