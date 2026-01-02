{===============================================================================

Copyright (c) COAS software systems BV

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
  Classes, SysUtils, ModBusConsts, ModbusTypes, Types, IdGlobal, IdTCPClient,
  SyncObjs;

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
  TModbusClientHeaderValidationEvent = procedure(const ReceivedSize: Integer;
    const ExpectedSize: Integer; const RawBuffer: TIdBytes) of object;

type
{$I ModBusPlatforms.inc}
  TIdModBusClient = class(TIdTCPClient)
  private
    FAutoConnect: Boolean;
    FBaseRegister: Word;
    FDisconnectOnCommandTimeout: Boolean;
    FLock: TCriticalSection;
    FTransportMode: TModBusTransportMode;
    FValidateHeader: TModBusHeaderValidation;
    FOnSendBuffer: TModbusClientSendBufferEvent;
    FOnReceiveBuffer: TModbusClientReceiveBufferEvent;
    FOnResponseError: TModbusClientErrorEvent;
    FOnResponseMismatch: TModBusClientResponseMismatchEvent;
    FOnHeaderValidation: TModbusClientHeaderValidationEvent;
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
    procedure HandleReadDeviceIdentificationResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandleReadFifoQueueResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandlePrivateFunctionResponse(const ResponseBuffer: TModBusResponseBuffer;
      out RegisterData: array of Word);
    procedure HandleReadWriteMultipleRegistersResponse(const ResponseBuffer: TModBusResponseBuffer;
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
    procedure DoHeaderValidation(const ReceivedSize: Integer; const ExpectedSize: Integer;
      const Buffer: TIdBytes); virtual;
    function ReadBits(const AModBusFunction: TModBusFunction; const RegNo, ABlockLength: Word;
      out RegisterData: array of Boolean): Boolean;
    procedure InitComponent; override;
    function SendCommandToSocket(const ARequestBuffer: TModBusRequestBuffer;
      var Data: array of Word; const AResponseHandler: TModbusClientHandleResponse = nil): Boolean;
  public
    property LastTransactionID: Word read FLastTransactionID;
  { public methods }
    destructor Destroy; override;
    procedure Connect; override;
    function ReadCoil(const RegNo: Word; out Value: Boolean): Boolean;
    function ReadCoils(const RegNo: Word; const Blocks: Word; out RegisterData: array of Boolean): Boolean;
    function ReadDouble(const RegNo: Word; out Value: Double): Boolean;
    function ReadDWord(const RegNo: Word; out Value: DWord): Boolean;
    function ReadFifoQueue(const FifoPointerAddress: Word; out Values: array of Word): Boolean;
    function ReadHoldingRegister(const RegNo: Word; out Value: Word): Boolean;
    function ReadHoldingRegisters(const RegNo: Word; const Blocks: Word; out RegisterData: array of Word): Boolean;
    function ReadInputBits(const RegNo: Word; const Blocks: Word; out RegisterData: array of Boolean): Boolean;
    function ReadInputRegister(const RegNo: Word; out Value: Word): Boolean;
    function ReadInputRegisters(const RegNo: Word; const Blocks: Word; var RegisterData: array of Word): Boolean;
    function ReadWriteMultipleRegisters(const WriteRegNo: Word; const WriteBlocks: Word;
      const WriteData: array of Word; const ReadRegNo: Word; const ReadBlocks: Word;
      out RegisterData: array of Word): Boolean;
    function ReadSingle(const RegNo: Word; out Value: Single): Boolean;
    function ReadString(const RegNo: Word; const ALength: Word): String;
    function ReportSlaveID(const Blocks: Word; out RegisterData: array of Word): Boolean;
    function ReadDeviceIdentification(const ReadDeviceIDCode: Byte; const ObjectID: Byte; 
      out DeviceIDData: TModDeviceIdentificationData): Boolean;
    procedure SafeDisconnect;
    function WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
    function WriteCoils(const RegNo: Word; const Blocks: Word; const RegisterData: array of Boolean): Boolean;
    function WriteRegister(const RegNo: Word; const Value: Word): Boolean;
    function WriteRegisterMasked(const RegNo: Word; const AndMask: Word; const OrMask: Word): Boolean;
    function WriteRegisters(const RegNo: Word; const RegisterData: array of Word): Boolean;
    function WriteDouble(const RegNo: Word; const Value: Double): Boolean;
    function WriteDWord(const RegNo: Word; const Value: DWord): Boolean;
    function WriteSingle(const RegNo: Word; const Value: Single): Boolean;
    function WriteString(const RegNo: Word; const Text: String): Boolean;
    function SendPrivateFunction(const FunctionCode: Byte; const RequestData: array of Byte;
      out ResponseData: array of Byte): Boolean;
  published
    property AutoConnect: Boolean read FAutoConnect write FAutoConnect default True;
    property BaseRegister: Word read FBaseRegister write FBaseRegister default 1;
    property DisconnectOnCommandTimeout: Boolean read FDisconnectOnCommandTimeout write FDisconnectOnCommandTimeout default False;
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout default 0;
    property Port default MB_PORT;
    property TimeOut: Cardinal read FTimeOut write FTimeout default 15000;
    property TransportMode: TModBusTransportMode read FTransportMode write FTransportMode default tmTCP;
    property UnitID: Byte read FUnitID write FUnitID default MB_IGNORE_UNITID;
    property ValidateHeader: TModBusHeaderValidation read FValidateHeader write FValidateHeader default hvDisabled;
    property Version: String read GetVersion write SetVersion stored False;
  { events }
    property OnSendBuffer: TModbusClientSendBufferEvent read FOnSendBuffer write FOnSendBuffer;
    property OnReceiveBuffer: TModbusClientReceiveBufferEvent read FOnReceiveBuffer write FOnReceiveBuffer;
    property OnResponseError: TModbusClientErrorEvent read FOnResponseError write FOnResponseError;
    property OnResponseMismatch: TModBusClientResponseMismatchEvent read FOnResponseMismatch write FOnResponseMismatch;
    property OnHeaderValidation: TModbusClientHeaderValidationEvent read FOnHeaderValidation write FOnHeaderValidation;
  end;


implementation

uses
  ModbusUtils, Math, ModbusStrConsts;

type
  TResponseErrorThread = class(TThread)
  private
    FFunctionCode: Byte;
    FErrorCode: Byte;
    FResponseBuffer: TModBusResponseBuffer;
    FOnResponseError: TModbusClientErrorEvent;
    procedure DoResponseError;
  protected
    procedure Execute; override;
  public
    constructor Create(const FunctionCode: Byte; const ErrorCode: Byte;
      const ResponseBuffer: TModBusResponseBuffer;
      const OnResponseError: TModbusClientErrorEvent); reintroduce;
  end;


{ TResponseErrorThread }

constructor TResponseErrorThread.Create(const FunctionCode, ErrorCode: Byte;
  const ResponseBuffer: TModBusResponseBuffer; const OnResponseError: TModbusClientErrorEvent);
begin
  inherited Create(true);
  FFunctionCode := FunctionCode;
  FErrorCode := ErrorCode;
  FResponseBuffer := ResponseBuffer;
  FOnResponseError := OnResponseError;
  Resume;
end;


procedure TResponseErrorThread.DoResponseError;
begin
  if Assigned(FOnResponseError) then
    FOnResponseError(FFunctionCode, FErrorCode, FResponseBuffer);
end;


procedure TResponseErrorThread.Execute;
begin
  Synchronize(DoResponseError);
end;

{ TIdModBusClient }

procedure TIdModBusClient.Connect;
begin
  inherited;
  FLastTransactionID := 0;
end;


destructor TIdModBusClient.Destroy;
begin
  SafeDisconnect;
  if Assigned(FLock) then
    FLock.Free;
  inherited;
end;


procedure TIdModBusClient.InitComponent;
begin
  inherited;
  FLock := TCriticalSection.Create;
  FAutoConnect := True;
  FBaseRegister := 1;
  FTransportMode := tmTCP;
  FValidateHeader := hvDisabled;
  FLastTransactionID := 0;
  FReadTimeout := 0;
  FUnitID := MB_IGNORE_UNITID;
  FTimeOut := 15000;
  Port := MB_PORT;
  FOnSendBuffer := nil;
  FOnReceiveBuffer := nil;
  FOnResponseError := nil;
  FOnResponseMismatch := nil;
  FOnHeaderValidation := nil;
end;


function TIdModBusClient.BuildRequestBuffer(const AModBusFunction: TModBusFunction;
  const ARegNumber: Word): TModBusRequestBuffer;
begin
  Result.TCPHeader.TransactionID := GetNewTransactionID;
  Result.TCPHeader.ProtocolID := MB_PROTOCOL;
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
var
  Thread: TResponseErrorThread;
begin
  if Assigned(FOnResponseError) then
  begin
    Thread := TResponseErrorThread.Create(FunctionCode, ErrorCode, ResponseBuffer, FOnResponseError);
    try
      Thread.WaitFor;
    finally
      Thread.Destroy;
    end;
  end;
end;


procedure TIdModBusClient.DoResponseMismatch(const RequestFunctionCode: Byte;
  const ResponseFunctionCode: Byte; const ResponseBuffer: TModBusResponseBuffer);
begin
  if Assigned(FOnResponseMismatch) then
    FOnResponseMismatch(RequestFunctionCode, ResponseFunctionCode, ResponseBuffer);
end;


procedure TIdModBusClient.DoHeaderValidation(const ReceivedSize: Integer;
  const ExpectedSize: Integer; const Buffer: TIdBytes);
begin
  if Assigned(FOnHeaderValidation) then
    FOnHeaderValidation(ReceivedSize, ExpectedSize, Buffer);
end;


procedure TIdModBusClient.SafeDisconnect;
begin
  if (not Assigned(FLock)) or (csDesigning in ComponentState) then
    Exit;

  FLock.Enter;
  try
    try
      if Connected then
      begin
        IOHandler.InputBuffer.Clear;
        IOHandler.CloseGracefully;
      end;
    except
      // Intentionally ignore exceptions here
    end;
  finally
    FLock.Leave;
  end;
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
  BufferSize: Integer;
begin
  CheckForGracefulDisconnect(True);
{ Clear input buffer to prevent reading possible data left from previous request }
  if Connected then
    IOHandler.InputBuffer.Clear;
{ Writeout the data to the connection }
  if (FTransportMode = tmRTUoverTCP) then
  begin
    // RTU mode: skip TCP header, send UnitID + FunctionCode + Data + CRC
    BufferSize := 1 + 1 + SizeOf(ARequestBuffer.MBPData); // UnitID + FunctionCode + Data
    Buffer := RawToBytes(ARequestBuffer.Header, BufferSize);
    Crc := CalculateCRC16(Buffer);
  {$IFDEF DMB_DELPHIXE3}
    SetLength(Buffer, IndyLength(Buffer) + 2);
  {$ELSE}
    SetLength(Buffer, Length(Buffer) + 2);
  {$ENDIF}
    Buffer[High(Buffer) - 1] := Lo(Crc);
    Buffer[High(Buffer)] := Hi(Crc);
  end
  else
  begin
    // TCP mode: send full buffer with TCP header
    Buffer := RawToBytes(ARequestBuffer, Swap16(ARequestBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE);
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
        if (FDisconnectOnCommandTimeout) then
          TThread.Queue(nil, SafeDisconnect);
        Result := False;
        Exit;
      end;
      Sleep(1);
    end;
  end;

  Result := True;
  iSize := IOHandler.InputBuffer.Size;
  IOHandler.ReadBytes(ReceiveBuffer, iSize);

  if (FTransportMode = tmRTUoverTCP) then
  begin
    // RTU mode: validate CRC and parse without TCP header
    if (iSize >= 2) then
    begin
      Crc := CalculateCRC16(Copy(ReceiveBuffer, 0, iSize - 2));
      if ((Lo(Crc) <> ReceiveBuffer[iSize - 2]) or (Hi(Crc) <> ReceiveBuffer[iSize - 1])) then
      begin
        Result := False;
        Exit;
      end;
    end
    else
    begin
      Result := False;
      Exit;
    end;
    // Copy response without TCP header
    FillChar(ResponseBuffer, SizeOf(ResponseBuffer), 0);
    Move(ReceiveBuffer[0], ResponseBuffer.Header, Min(iSize, SizeOf(ResponseBuffer) - SizeOf(ResponseBuffer.TCPHeader)));
  end
  else
  begin
    // TCP mode: parse normally with TCP header
    Move(ReceiveBuffer[0], ResponseBuffer, Min(iSize, Sizeof(ResponseBuffer)));
    
    // Validate MBAP header: check if RecLength matches received data
    // RecLength field indicates number of bytes following it (excluding the TCP header)
    if (FValidateHeader <> hvDisabled) then
    begin
      if (iSize >= SizeOf(TModBusTCPHeader)) then
      begin
        BufferSize := Swap16(ResponseBuffer.TCPHeader.RecLength);
        // iSize should be RecLength + TCP header size
        if (iSize <> BufferSize + MB_TCP_HEADER_SIZE) then
        begin
          DoHeaderValidation(iSize, BufferSize + MB_TCP_HEADER_SIZE, ReceiveBuffer);
          if (FValidateHeader = hvException) then
            raise EModbusHeaderValidation.CreateFmt(sHeaderValidationError, [iSize, BufferSize + MB_TCP_HEADER_SIZE]);
          // hvIgnore: just return False without raising exception
          Result := False;
          Exit;
        end;
      end
      else
      begin
        // Not enough data received for a valid MBAP header
        DoHeaderValidation(iSize, SizeOf(TModBusTCPHeader), ReceiveBuffer);
        if (FValidateHeader = hvException) then
          raise EModbusHeaderValidation.CreateFmt(sHeaderValidationError, [iSize, SizeOf(TModBusTCPHeader)]);
        Result := False;
        Exit;
      end;
    end;
  end;

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
    RequestBuffer.TCPHeader.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data, HandleReadBitsResponse);
    for i := 0 to (wBlockLength - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    if bNewConnection then
      SafeDisconnect;
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
  wBlockLength: Word;
begin
  FLock.Enter;
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
    wBlockLength := Blocks;
    if (wBlockLength > 125) then
      wBlockLength := 125; { Don't exceed max length }
  { Initialise the data part }
    RequestBuffer.MBPData[2] := Hi(wBlockLength);
    RequestBuffer.MBPData[3] := Lo(wBlockLength);
    RequestBuffer.TCPHeader.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data, HandleReadHoldingRegistersResponse);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    if bNewConnection then
      SafeDisconnect;
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
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
  wBlockLength: Word;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  FillChar(RegisterData[0], Length(RegisterData), 0);
  try
    SetLength(Data, Blocks);
    FillChar(Data[0], Length(Data), 0);
    RequestBuffer := BuildRequestBuffer(mbfReadInputRegs, RegNo - FBaseRegister);
    wBlockLength := Blocks;
    if (wBlockLength > 125) then
      wBlockLength := 125; { Don't exceed max length }
  { Initialise the data part }
    RequestBuffer.MBPData[2] := Hi(wBlockLength);
    RequestBuffer.MBPData[3] := Lo(wBlockLength);
    RequestBuffer.TCPHeader.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data, HandleReadInputRegistersResponse);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    if bNewConnection then
      SafeDisconnect;
  end;
end;


procedure TIdModBusClient.HandleReadWriteMultipleRegistersResponse(
  const ResponseBuffer: TModBusResponseBuffer; out RegisterData: array of Word);
var
  BlockLength: Word;
begin
  BlockLength := (ResponseBuffer.MBPData[0] shr 1);
  if (BlockLength > 125) then
    BlockLength := 125;
  GetRegistersFromBuffer(@ResponseBuffer.MBPData[1], BlockLength, RegisterData);
end;


function TIdModBusClient.ReadWriteMultipleRegisters(const WriteRegNo: Word; const WriteBlocks: Word;
  const WriteData: array of Word; const ReadRegNo: Word; const ReadBlocks: Word;
  out RegisterData: array of Word): Boolean;
var
  i: Integer;
  Data: array of Word;
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
  wReadBlocks: Word;
  wWriteBlocks: Word;
begin
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  FillChar(RegisterData[0], Length(RegisterData), 0);
  try
    SetLength(Data, ReadBlocks);
    FillChar(Data[0], Length(Data), 0);

    wReadBlocks := ReadBlocks;
    if (wReadBlocks > 125) then
      wReadBlocks := 125; { Don't exceed max length }

    wWriteBlocks := WriteBlocks;
    if (wWriteBlocks > 120) then
      wWriteBlocks := 120; { Don't exceed max length }

    RequestBuffer := BuildRequestBuffer(mbfReadWriteMultipleRegs, ReadRegNo - FBaseRegister);
    RequestBuffer.MBPData[0] := Hi(ReadRegNo - FBaseRegister);
    RequestBuffer.MBPData[1] := Lo(ReadRegNo - FBaseRegister);
    RequestBuffer.MBPData[2] := Hi(wReadBlocks);
    RequestBuffer.MBPData[3] := Lo(wReadBlocks);
    RequestBuffer.MBPData[4] := Hi(WriteRegNo - FBaseRegister);
    RequestBuffer.MBPData[5] := Lo(WriteRegNo - FBaseRegister);
    RequestBuffer.MBPData[6] := Hi(wWriteBlocks);
    RequestBuffer.MBPData[7] := Lo(wWriteBlocks);
    RequestBuffer.MBPData[8] := WriteBlocks * SizeOf(Word);
    RequestBuffer.TCPHeader.RecLength := Swap16(11 + RequestBuffer.MbpData[8]); { This includes UnitID/FuntionCode }
    PutRegistersIntoBuffer(@RequestBuffer.MBPData[9], WriteBlocks, WriteData);

  { Initialise the data part }
    Result := SendCommandToSocket(RequestBuffer, Data, HandleReadWriteMultipleRegistersResponse);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    if bNewConnection then
      SafeDisconnect;
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


function TIdModBusClient.ReadFifoQueue(const FifoPointerAddress: Word;
  out Values: array of Word): Boolean;
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
  FillChar(Values[0], Length(Values), 0);
  try
    RequestBuffer := BuildRequestBuffer(mbfReadFiFoQueue, FifoPointerAddress);
    RequestBuffer.TCPHeader.RecLength := Swap16(4); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Values, HandleReadFifoQueueResponse);
  finally
    if bNewConnection then
      SafeDisconnect;
  end;end;


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
  BlockLength := Swap16(ResponseBuffer.TCPHeader.RecLength) - 2;
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
    RequestBuffer.TCPHeader.RecLength := Swap16(2); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, RegisterData, HandleReportSlaveIDResponse);
  finally
    if bNewConnection then
      SafeDisconnect;
  end;
end;


procedure TIdModbusClient.HandleReadDeviceIdentificationResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  i: Integer;
begin
  for i := 0 to Min(High(RegisterData), Swap16(ResponseBuffer.TCPHeader.RecLength) - 3) do
    RegisterData[i] := ResponseBuffer.MBPData[i];
end;


procedure TIdModBusClient.HandleReadFifoQueueResponse(
  const ResponseBuffer: TModBusResponseBuffer; out RegisterData: array of Word);
var
  FifoCount: Word;
begin
  WordRec(FifoCount).Hi := ResponseBuffer.MBPData[0];
  WordRec(FifoCount).Lo := ResponseBuffer.MBPData[1];
  if (FifoCount > 125) then
    FifoCount := 125;
  GetRegistersFromBuffer(@ResponseBuffer.MBPData[2], FifoCount, RegisterData);
end;


procedure TIdModbusClient.HandlePrivateFunctionResponse(const ResponseBuffer: TModBusResponseBuffer;
  out RegisterData: array of Word);
var
  i: Integer;
  iDataSize: Integer;
  iIndex: Integer;
begin
  // Extract byte data from response and pack into Word array
  // Each Word can hold 2 bytes (low byte and high byte)
  iDataSize := Swap16(ResponseBuffer.TCPHeader.RecLength) - 2; // Subtract UnitID + FunctionCode

  // Pack bytes into words: 2 bytes per word
  iIndex := 0;
  for i := 0 to High(RegisterData) do
  begin
    if (iIndex < iDataSize) then
    begin
      RegisterData[i] := ResponseBuffer.MBPData[iIndex];
      Inc(iIndex);
      if (iIndex < iDataSize) then
      begin
        RegisterData[i] := RegisterData[i] or (Word(ResponseBuffer.MBPData[iIndex]) shl 8);
        Inc(iIndex);
      end;
    end
    else
      Break;
  end;
end;


function TIdModbusClient.ReadDeviceIdentification(const ReadDeviceIDCode: Byte; 
  const ObjectID: Byte; out DeviceIDData: TModDeviceIdentificationData): Boolean;
var
  bNewConnection: Boolean;
  RequestBuffer: TModbusRequestBuffer;
  RegisterData: array of Word;
  iDataIndex: Integer;
  iNumObjects: Integer;
  i: Integer;
  bObjectID: Byte;
  bObjectLength: Byte;
begin
  Result := False;
  SetLength(DeviceIDData, 0);
  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;
  
  SetLength(RegisterData, 256);
  FillChar(RegisterData[0], Length(RegisterData) * SizeOf(Word), 0);
  try
    RequestBuffer := BuildRequestBuffer(mbfReadDeviceIdentification, 0);
    // Set up the request data
    RequestBuffer.MBPData[0] := mbMEITypeReadDeviceIdentification; // MEI Type
    RequestBuffer.MBPData[1] := ReadDeviceIDCode; // Read Device ID Code
    RequestBuffer.MBPData[2] := ObjectID; // Object ID
    RequestBuffer.TCPHeader.RecLength := Swap16(5); // UnitID + FunctionCode + 3 data bytes
    
    if SendCommandToSocket(RequestBuffer, RegisterData, HandleReadDeviceIdentificationResponse) then
    begin
      // Parse the response
      // RegisterData[0] = MEI Type (0x0E)
      // RegisterData[1] = Read Device ID Code
      // RegisterData[2] = Conformity Level
      // RegisterData[3] = More Follows
      // RegisterData[4] = Next Object ID
      // RegisterData[5] = Number of Objects
      // RegisterData[6+] = Object List
      
      iNumObjects := RegisterData[5];
      if (iNumObjects > 0) then
      begin
        SetLength(DeviceIDData, iNumObjects);
        iDataIndex := 6;

        for i := 0 to (iNumObjects - 1) do
        begin
          bObjectID := Byte(RegisterData[iDataIndex]);
          Inc(iDataIndex);
          bObjectLength := Byte(RegisterData[iDataIndex]);
          Inc(iDataIndex);

          DeviceIDData[i].ObjectID := bObjectID;
          SetLength(DeviceIDData[i].ObjectValue, bObjectLength);
          if (bObjectLength > 0) then
          begin
            Move(RegisterData[iDataIndex], DeviceIDData[i].ObjectValue[1], bObjectLength);
            Inc(iDataIndex, bObjectLength);
          end;
        end;
        Result := True;
      end;
    end;
  finally
    if bNewConnection then
      SafeDisconnect;
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
  if (SizeOf(Buffer) >= SizeOf(Value)) then
  begin
    Move(Value, Buffer[0], SizeOf(Value));
    Result := WriteRegisters(RegNo, Buffer);
  end
  else
    Result := False;
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
  if (SizeOf(Buffer) >= SizeOf(Value)) then
  begin
    Move(Value, Buffer[0], SizeOf(Value));
    Result := WriteRegisters(RegNo, Buffer);
  end
  else
    Result := False;
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
    for i := 0 to (Length(Buffer) - 1) do
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
    RequestBuffer.TCPHeader.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      SafeDisconnect;
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
    RequestBuffer.TCPHeader.RecLength := Swap16(8); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      SafeDisconnect;
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
    RequestBuffer.TCPHeader.RecLength := Swap16(7 + RequestBuffer.MbpData[4]);
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      SafeDisconnect;
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
    RequestBuffer.TCPHeader.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      SafeDisconnect;
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
    RequestBuffer.TCPHeader.RecLength := Swap16(7 + RequestBuffer.MBPData[4]);
    Result := SendCommandToSocket(RequestBuffer, Data);
  finally
    if bNewConnection then
      SafeDisconnect;
  end;
end;


function TIdModBusClient.SendPrivateFunction(const FunctionCode: Byte; const RequestData: array of Byte;
  out ResponseData: array of Byte): Boolean;
var
  RequestBuffer: TModBusRequestBuffer;
  iDataSize: Integer;
  bNewConnection: Boolean;
  i: Integer;
  iIndex: Integer;
  iMaxResponseBytes: Integer;
  ResponseWords: array of Word;
begin
  // Validate function code is in the private/user-defined range
  if not IsValidPrivateFunctionCode(FunctionCode) then
    raise EModbusInvalidPrivateFunction.CreateFmt('Invalid private function code: $%x. Must be $41..$48 or $64..$6E', [FunctionCode]);

  bNewConnection := False;
  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    // Build request buffer
    RequestBuffer := BuildRequestBuffer(FunctionCode, 0);
    
    // Copy request data to buffer
    iDataSize := Length(RequestData);
    if (iDataSize > 0) then
    begin
      if (iDataSize > SizeOf(RequestBuffer.MBPData)) then
        iDataSize := SizeOf(RequestBuffer.MBPData);
      Move(RequestData[0], RequestBuffer.MBPData[0], iDataSize);
    end;
    
    // Set record length for TCP mode
    RequestBuffer.TCPHeader.RecLength := Swap16(2 + iDataSize); // UnitID + FunctionCode + Data
    
    // Allocate Word array to receive response (2 bytes per word, round up)
    iMaxResponseBytes := Length(ResponseData);
    SetLength(ResponseWords, (iMaxResponseBytes + 1) div 2);

    // Use SendCommandToSocket to handle all the communication
    Result := SendCommandToSocket(RequestBuffer, ResponseWords, HandlePrivateFunctionResponse);
    
    // Unpack response data from Word array to Byte array
    if Result and (Length(ResponseWords) > 0) then
    begin
      iIndex := 0;
      for i := 0 to High(ResponseWords) do
      begin
        if (iIndex < Length(ResponseData)) then
        begin
          ResponseData[iIndex] := Lo(ResponseWords[i]);
          Inc(iIndex);
        end;
        if (iIndex < Length(ResponseData)) then
        begin
          ResponseData[iIndex] := Hi(ResponseWords[i]);
          Inc(iIndex);
        end;
      end;
    end;
  finally
    if bNewConnection then
      SafeDisconnect;
  end;
end;


end.

