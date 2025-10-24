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

unit IdModBusServer;

interface

uses
  Classes, SysUtils, IdContext, IdCustomTCPServer, IdGlobal, ModBusConsts,
  ModbusTypes, ModbusUtils, SyncObjs;

type
  TModRegisterData = array[0..MaxBlockLength] of Word;

type
  TModCoilData = array[0..MaxCoils] of ByteBool;

type
  TModBusCoilReadEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte) of object;
  TModBusRegisterReadEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte) of object;
  TModBusCoilWriteEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte) of object;
  TModBusRegisterWriteEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte) of object;
  TModBusErrorEvent = procedure(const Sender: TIdContext;
    const FunctionCode: Byte; const ErrorCode: Byte;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusInvalidFunctionEvent = procedure(const Sender: TIdContext;
    const FunctionCode: TModBusFunction;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModbusServerHeaderValidationEvent = procedure(const Sender: TIdContext;
    const ReceivedSize: Integer; const ExpectedSize: Integer;
    const RawBuffer: TIdBytes) of object;
  TModBusDeviceIdentificationEvent = procedure(const Sender: TIdContext;
    const ReadDeviceIDCode: Byte; const ObjectID: Byte; 
    var DeviceIdentificationData: TModDeviceIdentificationData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte) of object;

type
{$I ModBusPlatforms.inc}
  TIdModBusServer = class(TIdCustomTCPServer)
  private
    FBaseRegister: Word;
    FOneShotConnection: Boolean;
    FLogCriticalSection: TCriticalSection;
    FLogEnabled: Boolean;
    FLogFile: String;
    FLogTimeFormat: String;
    FMaxRegister: Word;
    FMinRegister: Word;
    FOnError: TModBusErrorEvent;
    FOnInvalidFunction: TModBusInvalidFunctionEvent;
    FOnReadCoils: TModBusCoilReadEvent;
    FOnReadHoldingRegisters: TModBusRegisterReadEvent;
    FOnReadInputBits: TModBusCoilReadEvent;
    FOnReadInputRegisters: TModBusRegisterReadEvent;
    FOnWriteCoils: TModBusCoilWriteEvent;
    FOnWriteRegisters: TModBusRegisterWriteEvent;
    FOnReadDeviceIdentification: TModBusDeviceIdentificationEvent;
    FOnHeaderValidation: TModbusServerHeaderValidationEvent;
    FPause: Boolean;
    FTransportMode: TModBusTransportMode;
    FValidateHeader: TModBusHeaderValidation;
    FUnitID: Byte;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    function IsLogTimeFormatStored: Boolean;
    procedure LogByteBuffer(const LogType: String; const PeerIP: String; const ByteBuffer: array of Byte; const Size: Integer);
    procedure InternalReadCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
    procedure InternalReadInputBits(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
    procedure InternalWriteCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
  protected
    procedure InitComponent; override;
    procedure DoError(const AContext: TIdContext; const FunctionCode: Byte;
      const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer); virtual;
    function DoExecute(AContext: TIdContext): Boolean; override;
    procedure DoInvalidFunction(const AContext: TIdContext;
      const FunctionCode: TModBusFunction; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoHeaderValidation(const AContext: TIdContext; const ReceivedSize: Integer;
      const ExpectedSize: Integer; const Buffer: TIdBytes); virtual;
    procedure DoReadHoldingRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoReadInputRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoReadCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoReadInputBits(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoWriteCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoWriteRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure DoReadDeviceIdentification(const AContext: TIdContext; const ReadDeviceIDCode: Byte;
      const ObjectID: Byte; var DeviceIdentificationData: TModDeviceIdentificationData;
      const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte); virtual;
    procedure LogExceptionBuffer(const AContext: TIdContext; const Buffer: TModBusExceptionBuffer);
    procedure LogRequestBuffer(const AContext: TIdContext; const Buffer: TModBusRequestBuffer; const Size: Integer);
    procedure LogResponseBuffer(const AContext: TIdContext; const Buffer: TModBusResponseBuffer; const Size: Integer);
    procedure ReadCommand(const AContext: TIdContext);
    procedure SendError(const AContext: TIdContext; const ErrorCode: Byte;
      const ReceiveBuffer: TModBusRequestBuffer);
    procedure SendResponse(const AContext: TIdContext; const ReceiveBuffer: TModBusRequestBuffer;
      const Data: TModRegisterData);
    procedure SendDeviceIdentificationResponse(const AContext: TIdContext; 
      const ReceiveBuffer: TModBusRequestBuffer; const ReadDeviceIDCode: Byte;
      const DeviceIdentificationData: TModDeviceIdentificationData);
  public
    destructor Destroy(); override;
  { public properties }
    property Pause: Boolean read FPause write FPause;
  published
    property BaseRegister: Word read FBaseRegister write FBaseRegister default 1;
    property DefaultPort default MB_PORT;
    property LogEnabled: Boolean read FLogEnabled write FLogEnabled default False;
    property LogFile: String read FLogFile write FLogFile;
    property LogTimeFormat: String read FLogTimeFormat write FLogTimeFormat stored IsLogTimeFormatStored;
    property OneShotConnection: Boolean read FOneShotConnection write FOneShotConnection default False;
    property MaxRegister: Word read FMaxRegister write FMaxRegister default $FFFF;
    property MinRegister: Word read FMinRegister write FMinRegister default 1;
    property TransportMode: TModBusTransportMode read FTransportMode write FTransportMode default tmTCP;
    property UnitID: Byte read FUnitID write FUnitID default MB_IGNORE_UNITID;
    property ValidateHeader: TModBusHeaderValidation read FValidateHeader write FValidateHeader default hvDisabled;
    property Version: String read GetVersion write SetVersion stored False;
  { events }
    property OnError: TModBusErrorEvent read FOnError write FOnError;
    property OnInvalidFunction: TModBusInvalidFunctionEvent read FOnInvalidFunction write FOnInvalidFunction;
    property OnReadCoils: TModBusCoilReadEvent read FOnReadCoils write FOnReadCoils;
    property OnReadHoldingRegisters: TModBusRegisterReadEvent read FOnReadHoldingRegisters write FOnReadHoldingRegisters;
    property OnReadInputBits: TModBusCoilReadEvent read FOnReadInputBits write FOnReadInputBits;
    property OnReadInputRegisters: TModBusRegisterReadEvent read FOnReadInputRegisters write FOnReadInputRegisters;
    property OnWriteCoils: TModBusCoilWriteEvent read FOnWriteCoils write FOnWriteCoils;
    property OnWriteRegisters: TModBusRegisterWriteEvent read FOnWriteRegisters write FOnWriteRegisters;
    property OnReadDeviceIdentification: TModBusDeviceIdentificationEvent read FOnReadDeviceIdentification write FOnReadDeviceIdentification;
    property OnHeaderValidation: TModbusServerHeaderValidationEvent read FOnHeaderValidation write FOnHeaderValidation;
  end; { TIdModBusServer }


implementation

uses
  Math, ModbusStrConsts;

{ TIdModBusServer }

procedure TIdModBusServer.InitComponent;
begin
  inherited;
  FBaseRegister := 1;
  DefaultPort := MB_PORT;
  FLogCriticalSection := SyncObjs.TCriticalSection.Create;
  FLogEnabled := False;
  FLogFile := '';
  FLogTimeFormat := DefaultLogTimeFormat;
  FMaxRegister := $FFFF;
  FMinRegister := 1;
  FOneShotConnection := False;
  FOnError := nil;
  FOnInvalidFunction := nil;
  FOnReadCoils := nil;
  FOnReadHoldingRegisters := nil;
  FOnReadInputBits := nil;
  FOnReadInputRegisters := nil;
  FOnWriteCoils := nil;
  FOnWriteRegisters := nil;
  FOnReadDeviceIdentification := nil;
  FOnHeaderValidation := nil;
  FPause := False;
  FTransportMode := tmTCP;
  FValidateHeader := hvDisabled;
  FUnitID := MB_IGNORE_UNITID;
end;


destructor TIdModBusServer.Destroy();
begin
  inherited;
  // freed AFTER inherited destructor because this will first stop the server
  FLogCriticalSection.Free();
end;


procedure TIdModBusServer.LogByteBuffer(const LogType: String;
  const PeerIP: String; const ByteBuffer: array of Byte; const Size: Integer);
var
  F: TextFile;
begin
  if FLogEnabled and (FLogFile <> '') then
  begin
    FLogCriticalSection.Enter;
    try
      AssignFile(F, FLogFile);
      if FileExists(FLogFile) then
        Append(F)
      else
        Rewrite(F);
      try
        WriteLn(F, FormatDateTime(FLogTimeFormat, Now)
                  ,'; ', LogType
                  ,'; ', PeerIP
                  ,'; ', IntToStr(Size)
                  ,'; ', BufferToHex(ByteBuffer));
      finally
        CloseFile(F);
      end;
    finally
      FLogCriticalSection.Leave;
    end;
  end;
end;


procedure TIdModBusServer.InternalReadCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
  DoReadCoils(AContext, RegNr, Count, CoilData, RequestBuffer, ErrorCode);
  for i := 0 to (Count - 1) do
  begin
    if CoilData[i] then
      Data[i] := 1;
  end;
end;


procedure TIdModBusServer.InternalReadInputBits(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
  DoReadInputBits(AContext, RegNr, Count, CoilData, RequestBuffer, ErrorCode);
  for i := 0 to (Count - 1) do
  begin
    if CoilData[i] then
      Data[i] := 1;
  end;

end;


procedure TIdModBusServer.InternalWriteCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
  for i := 0 to (Count - 1) do
    CoilData[i] := (Data[i] = 1);
  DoWriteCoils(AContext, RegNr, Count, CoilData, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.LogExceptionBuffer(const AContext: TIdContext;
  const Buffer: TModBusExceptionBuffer);
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('excp', PeerIP, ByteBuffer, SizeOf(Buffer));
end;


procedure TIdModBusServer.LogRequestBuffer(const AContext: TIdContext;
  const Buffer: TModBusRequestBuffer; const Size: Integer);
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('recv', PeerIP, ByteBuffer, Size);
end;


procedure TIdModBusServer.LogResponseBuffer(const AContext: TIdContext;
  const Buffer: TModBusResponseBuffer; const Size: Integer);
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('sent', PeerIP, ByteBuffer, Size);
end;


procedure TIdModBusServer.ReadCommand(const AContext: TIdContext);

  function GetRegNr(const RegNr: Integer): Integer;
  begin
    Result := RegNr;
    if (RegNr < 0) then
      Result := Result + $FFFF
    else if (RegNr > $FFFF) then
      Result := RegNr - ($FFFF + 1);
    Result := Result + FBaseRegister;
  end; { GetRegNr }
  
var
  iCount: Integer;
  iRegNr: Integer;
  ErrorCode: Byte;
  ReceiveBuffer: TModBusRequestBuffer;
  Data: TModRegisterData;
  Buffer: TIdBytes;
  DeviceIDData: TModDeviceIdentificationData;
begin
{ Initialize all register data to 0 }
  FillChar(Data[0], SizeOf(Data), 0);
  FillChar(ReceiveBuffer, SizeOf(ReceiveBuffer), 0);
{ Read the data from the peer connection }
{ Ensure receiving databuffer is completely empty, and filled with zeros }
  SetLength(Buffer, SizeOf(ReceiveBuffer));
  FillChar(Buffer[0], SizeOf(ReceiveBuffer), 0);
{ Wait max. 250 msecs. for available data }
  AContext.Connection.IOHandler.CheckForDataOnSource(250);
  if not AContext.Connection.IOHandler.InputBufferIsEmpty then
  begin
    AContext.Connection.IOHandler.InputBuffer.ExtractToBytes(Buffer, -1, False, -1);
    iCount := Length(Buffer);
    if (iCount > 0) then
    begin
      if (FTransportMode = tmRTU) then
      begin
        // RTU mode: validate CRC and parse without TCP header
        if (iCount >= 2) then
        begin
          if (CalculateCRC16(Copy(Buffer, 0, iCount - 2)) <> Word((Buffer[iCount - 1] shl 8) or Buffer[iCount - 2])) then
            Exit; // Invalid CRC, ignore the request
        end
        else
          Exit; // Not enough data for CRC
        // Copy without TCP header - start from Header (UnitID)
        FillChar(ReceiveBuffer, SizeOf(ReceiveBuffer), 0);
        Move(Buffer[0], ReceiveBuffer.Header, Min(iCount, SizeOf(ReceiveBuffer) - SizeOf(ReceiveBuffer.TCPHeader)));
      end
      else
      begin
        // TCP mode: parse normally with TCP header
        Move(Buffer[0], ReceiveBuffer, Min(iCount, SizeOf(ReceiveBuffer)));
        
        // Validate MBAP header: check if RecLength matches received data
        // RecLength field indicates number of bytes following it (excluding the TCP header)
        if (FValidateHeader <> hvDisabled) then
        begin
          if (iCount >= SizeOf(TModBusTCPHeader)) then
          begin
            if (iCount <> Swap16(ReceiveBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE) then
            begin
              DoHeaderValidation(AContext, iCount, Swap16(ReceiveBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE, Buffer);
              if (FValidateHeader = hvException) then
                raise EModbusHeaderValidation.CreateFmt(sHeaderValidationError, [iCount, Swap16(ReceiveBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE]);
              // hvIgnore: just exit without raising exception
              Exit;
            end;
          end
          else
          begin
            // Not enough data for a valid MBAP header
            DoHeaderValidation(AContext, iCount, SizeOf(TModBusTCPHeader), Buffer);
            if (FValidateHeader = hvException) then
              raise EModbusHeaderValidation.CreateFmt(sHeaderValidationError, [iCount, SizeOf(TModBusTCPHeader)]);
            Exit;
          end;
        end;
      end;
      if FLogEnabled then
        LogRequestBuffer(AContext, ReceiveBuffer, iCount);
    end
    else
      Exit;
  end
  else
    Exit;
{ Process the data }
  if (FTransportMode = tmTCP) then
  begin
    if ((FUnitID <> MB_IGNORE_UNITID) and (ReceiveBuffer.Header.UnitID <> FUnitID)) or
       (ReceiveBuffer.TCPHeader.ProtocolID <> MB_PROTOCOL)
    then
    begin
    // When listening for a specific UnitID, only except data for that ID
      SendError(AContext, mbeServerFailure, ReceiveBuffer);
      Exit;
    end;
  end
  else
  begin
    // RTU mode: only check UnitID
    if ((FUnitID <> MB_IGNORE_UNITID) and (ReceiveBuffer.Header.UnitID <> FUnitID)) then
    begin
      Exit; // Ignore requests not for this unit
    end;
  end;
  
  if ((Byte(ReceiveBuffer.FunctionCode) and $80) <> 0) then
  begin
    ErrorCode := Integer(ReceiveBuffer.MBPData[0]);
    DoError(AContext, ReceiveBuffer.FunctionCode and not $80, ErrorCode, ReceiveBuffer);
  end
  else
  begin
    ErrorCode := mbeOk;
    case ReceiveBuffer.FunctionCode of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
          iCount := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Signal the user that data is needed }
            if (ReceiveBuffer.FunctionCode = mbfReadCoils) then
              InternalReadCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode)
            else
              InternalReadInputBits(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfReadInputRegs,
      mbfReadHoldingRegs:
        begin
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
          iCount := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Signal the user that data is needed }
            if (ReceiveBuffer.FunctionCode = mbfReadInputRegs) then
              DoReadInputRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode)
            else
              DoReadHoldingRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfWriteOneCoil:
        begin
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
          iCount := 1;
          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Decode the contents of the Registers }
            GetCoilsFromBuffer(@ReceiveBuffer.MBPData[2], iCount, Data);
          { Send back the response to the master }
            InternalWriteCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfWriteOneReg:
        begin
        { Get the register number }
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
        { Get the register value }
          Data[0] := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
        { This function always writes one register }
          iCount := 1;

          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Send back the response to the master }
            DoWriteRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfWriteRegs:
        begin
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
          iCount := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Decode the contents of the Registers }
            GetRegistersFromBuffer(@ReceiveBuffer.MbpData[5], iCount, Data);
          { Send back the response to the master }
            DoWriteRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfWriteCoils:
        begin
          iRegNr := GetRegNr(Swap16(Word((@ReceiveBuffer.MBPData[0])^)));
          iCount := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if ((iRegNr < FMinRegister) or ((iRegNr + iCount - 1) > FMaxRegister)) then
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          else
          begin
          { Decode the contents of the Registers }
            GetCoilsFromBuffer(@ReceiveBuffer.MbpData[5], iCount, Data);
          { Send back the response to the master }
            InternalWriteCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer, ErrorCode);
            if (ErrorCode = mbeOk) then
              SendResponse(AContext, ReceiveBuffer, Data)
            else
              SendError(AContext, ErrorCode, ReceiveBuffer);
          end;
        end;
      mbfReadDeviceIdentification:
        begin
          // Function Code 43 (0x2B) - Read Device Identification
          // Check MEI Type (should be 0x0E for Read Device Identification)
          if (ReceiveBuffer.MBPData[0] <> mbMEITypeReadDeviceIdentification) then
            // Invalid MEI Type - send illegal data value error
            SendError(AContext, mbeIllegalDataValue, ReceiveBuffer)
          else
          begin
            // Read Device ID Code (byte 1)
            iRegNr := ReceiveBuffer.MBPData[1]; // Using iRegNr as ReadDeviceIDCode
            // Object ID (byte 2)
            iCount := ReceiveBuffer.MBPData[2]; // Using iCount as ObjectID
            
            // Validate Read Device ID Code
            if (iRegNr < mbReadDevIDBasic) or (iRegNr > mbReadDevIDSpecific) then
              SendError(AContext, mbeIllegalDataValue, ReceiveBuffer)
            else
            begin
              // Request device identification data from user
              SetLength(DeviceIDData, 0);
              ErrorCode := mbeOk;
              DoReadDeviceIdentification(AContext, Byte(iRegNr), Byte(iCount), DeviceIDData, ReceiveBuffer, ErrorCode);
              
              if (ErrorCode = mbeOk) then
                // Send successful response with device identification data
                SendDeviceIdentificationResponse(AContext, ReceiveBuffer, Byte(iRegNr), DeviceIDData)
              else
                // Send error response
                SendError(AContext, ErrorCode, ReceiveBuffer);
            end;
          end;
        end;
    else
      if (ReceiveBuffer.FunctionCode <> 0) then
      begin
      { Illegal or unsupported function code }
        SendError(AContext, mbeIllegalFunction, ReceiveBuffer);
        DoInvalidFunction(AContext, ReceiveBuffer.FunctionCode, ReceiveBuffer);
      end;
    end;
  end;
{ If needed: the server terminates the connection, after the request has been handled }
  if FOneShotConnection then
    AContext.Connection.Disconnect;
end;


procedure TIdModBusServer.DoError(const AContext: TIdContext;
  const FunctionCode: Byte; const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer);
begin
  if Assigned(FOnError) then
    FOnError(AContext, FunctionCode, ErrorCode, RequestBuffer);
end;


function TIdModBusServer.DoExecute(AContext: TIdContext): Boolean;
begin
  Result := False;
  if not FPause then
  begin
    ReadCommand(AContext);
    Result := inherited DoExecute(AContext);
  end;
end;


procedure TIdModBusServer.DoInvalidFunction(const AContext: TIdContext;
  const FunctionCode: TModBusFunction; const RequestBuffer: TModBusRequestBuffer);
begin
  if Assigned(FOnInvalidFunction) then
    FOnInvalidFunction(AContext, FunctionCode, RequestBuffer);
end;


procedure TIdModBusServer.DoHeaderValidation(const AContext: TIdContext;
  const ReceivedSize: Integer; const ExpectedSize: Integer; const Buffer: TIdBytes);
begin
  if Assigned(FOnHeaderValidation) then
    FOnHeaderValidation(AContext, ReceivedSize, ExpectedSize, Buffer);
end;


procedure TIdModBusServer.DoReadCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnReadCoils) then
    FOnReadCoils(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoReadInputBits(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnReadInputBits) then
    FOnReadInputBits(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoReadHoldingRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnReadHoldingRegisters) then
    FOnReadHoldingRegisters(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoReadInputRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnReadInputRegisters) then
    FOnReadInputRegisters(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoReadDeviceIdentification(const AContext: TIdContext;
  const ReadDeviceIDCode: Byte; const ObjectID: Byte; 
  var DeviceIdentificationData: TModDeviceIdentificationData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnReadDeviceIdentification) then
    FOnReadDeviceIdentification(AContext, ReadDeviceIDCode, ObjectID, DeviceIdentificationData, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoWriteCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnWriteCoils) then
    FOnWriteCoils(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.DoWriteRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer; var ErrorCode: Byte);
begin
  if Assigned(FOnWriteRegisters) then
    FOnWriteRegisters(AContext, RegNr, Count, Data, RequestBuffer, ErrorCode);
end;


procedure TIdModBusServer.SendError(const AContext: TIdContext;
  const ErrorCode: Byte; const ReceiveBuffer: TModBusRequestBuffer);
var
  SendBuffer: TModBusExceptionBuffer;
  Buffer: TIdBytes;
  Crc: Word;
  BufferSize: Integer;
begin
  if Active then
  begin
    SendBuffer.TCPHeader := ReceiveBuffer.TCPHeader;
    SendBuffer.Header := ReceiveBuffer.Header;
    SendBuffer.ExceptionFunction := ReceiveBuffer.FunctionCode or $80;
    SendBuffer.ExceptionCode := ErrorCode;
    SendBuffer.TCPHeader.RecLength := Swap16(3);

    if (FTransportMode = tmRTU) then
    begin
      // RTU mode: send without TCP header
      BufferSize := 1 + 1 + 1; // UnitID + ExceptionFunction + ExceptionCode
      Buffer := RawToBytes(SendBuffer.Header, BufferSize);
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
      // TCP mode: send with TCP header
      Buffer := RawToBytes(SendBuffer, SizeOf(SendBuffer));
    end;
    AContext.Connection.Socket.WriteDirect(Buffer);
    if FLogEnabled then
      LogExceptionBuffer(AContext, SendBuffer);
  end;
end;


procedure TIdModBusServer.SendResponse(const AContext: TIdContext;
  const ReceiveBuffer: TModBusRequestBuffer; const Data: TModRegisterData);
var
  SendBuffer: TModBusResponseBuffer;
  L: Integer;
  ValidRequest : Boolean;
  Buffer: TIdBytes;
  Crc: Word;
  BufferSize: Integer;
begin
  if Active then
  begin
    { Check Valid }
    ValidRequest  := false;
    FillChar(SendBuffer, SizeOf(SendBuffer), 0);
    SendBuffer.TCPHeader.TransactionID := ReceiveBuffer.TCPHeader.TransactionID;
    SendBuffer.TCPHeader.ProtocolID := ReceiveBuffer.TCPHeader.ProtocolID;
    SendBuffer.Header.UnitID := ReceiveBuffer.Header.UnitID;
    SendBuffer.FunctionCode := ReceiveBuffer.FunctionCode;
    SendBuffer.TCPHeader.RecLength := Swap16(0);

    case ReceiveBuffer.FunctionCode of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          L := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if (L > 0) and (L <= MaxCoils) then
          begin
            SendBuffer.MBPData[0] := Byte((L + 7) div 8);
            PutCoilsIntoBuffer(@SendBuffer.MBPData[1], L, Data);
            SendBuffer.TCPHeader.RecLength := Swap16(3 + SendBuffer.MBPData[0]);
            ValidRequest  := true;
          end;
        end;
      mbfReadInputRegs,
      mbfReadHoldingRegs:
        begin
          L := Swap16(Word((@ReceiveBuffer.MBPData[2])^));
          if (L > 0) and (L <= MaxBlockLength) then
          begin
            SendBuffer.MBPData[0] := Byte(L shl 1);
            PutRegistersIntoBuffer(@SendBuffer.MBPData[1], L, Data);
            SendBuffer.TCPHeader.RecLength := Swap16(3 + SendBuffer.MBPData[0]);
            ValidRequest  := true;
          end;
        end;
    else
      begin
        SendBuffer.MBPData[0] := ReceiveBuffer.MBPData[0];
        SendBuffer.MBPData[1] := ReceiveBuffer.MBPData[1];
        SendBuffer.MBPData[2] := ReceiveBuffer.MBPData[2];
        SendBuffer.MBPData[3] := ReceiveBuffer.MBPData[3];
        SendBuffer.TCPHeader.RecLength := Swap16(6);
        ValidRequest  := true;
      end;
    end;
    { Send buffer if Request is Valid }
    if ValidRequest then
    begin
      if (FTransportMode = tmRTU) then
      begin
        // RTU mode: send without TCP header
        BufferSize := Swap16(SendBuffer.TCPHeader.RecLength) + 1; // RecLength + UnitID
        Buffer := RawToBytes(SendBuffer.Header, BufferSize);
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
        // TCP mode: send with TCP header
        Buffer := RawToBytes(SendBuffer, Swap16(SendBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE);
      end;
      AContext.Connection.Socket.WriteDirect(Buffer);
      if FLogEnabled then
        LogResponseBuffer(AContext, SendBuffer, Swap16(SendBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE);
    end
    else
    begin
      { Send error for invalid request}
      SendError(AContext, mbeServerFailure, ReceiveBuffer);
      Exit;
    end;
  end;
end;


procedure TIdModBusServer.SendDeviceIdentificationResponse(const AContext: TIdContext;
  const ReceiveBuffer: TModBusRequestBuffer; const ReadDeviceIDCode: Byte;
  const DeviceIdentificationData: TModDeviceIdentificationData);
var
  SendBuffer: TModBusResponseBuffer;
  Buffer: TIdBytes;
  Crc: Word;
  BufferSize: Integer;
  DataIndex: Integer;
  ObjectCount: Integer;
  i: Integer;
  ObjectValueLength: Integer;
begin
  if Active then
  begin
    FillChar(SendBuffer, SizeOf(SendBuffer), 0);
    SendBuffer.TCPHeader.TransactionID := ReceiveBuffer.TCPHeader.TransactionID;
    SendBuffer.TCPHeader.ProtocolID := ReceiveBuffer.TCPHeader.ProtocolID;
    SendBuffer.Header.UnitID := ReceiveBuffer.Header.UnitID;
    SendBuffer.FunctionCode := ReceiveBuffer.FunctionCode;
    
    // MEI Type (always 0x0E for Read Device Identification)
    SendBuffer.MBPData[0] := mbMEITypeReadDeviceIdentification;
    // Read Device ID Code (echo from request)
    SendBuffer.MBPData[1] := ReadDeviceIDCode;
    // Conformity Level (0x01 = Basic, 0x02 = Regular, 0x03 = Extended)
    SendBuffer.MBPData[2] := $01; // Basic conformity level
    // More Follows (0x00 = no more objects, 0xFF = more objects to follow)
    SendBuffer.MBPData[3] := $00;
    // Next Object ID (0x00 if More Follows = 0x00)
    SendBuffer.MBPData[4] := $00;
    // Number of Objects
    ObjectCount := Length(DeviceIdentificationData);
    SendBuffer.MBPData[5] := Byte(ObjectCount);
    
    // Build the objects list
    DataIndex := 6;
    for i := 0 to ObjectCount - 1 do
    begin
      // Object ID
      SendBuffer.MBPData[DataIndex] := DeviceIdentificationData[i].ObjectID;
      Inc(DataIndex);
      
      // Object Length
      ObjectValueLength := Length(DeviceIdentificationData[i].ObjectValue);
      SendBuffer.MBPData[DataIndex] := Byte(ObjectValueLength);
      Inc(DataIndex);
      
      // Object Value (ASCII string)
      if ObjectValueLength > 0 then
      begin
        Move(DeviceIdentificationData[i].ObjectValue[1], SendBuffer.MBPData[DataIndex], ObjectValueLength);
        Inc(DataIndex, ObjectValueLength);
      end;
    end;
    
    // Set the RecLength (UnitID + FunctionCode + Data)
    SendBuffer.TCPHeader.RecLength := Swap16(1 + 1 + DataIndex);
    
    if (FTransportMode = tmRTU) then
    begin
      // RTU mode: send without TCP header
      BufferSize := Swap16(SendBuffer.TCPHeader.RecLength) + 1; // RecLength + UnitID
      Buffer := RawToBytes(SendBuffer.Header, BufferSize);
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
      // TCP mode: send with TCP header
      Buffer := RawToBytes(SendBuffer, Swap16(SendBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE);
    end;
    AContext.Connection.Socket.WriteDirect(Buffer);
    if FLogEnabled then
      LogResponseBuffer(AContext, SendBuffer, Swap16(SendBuffer.TCPHeader.RecLength) + MB_TCP_HEADER_SIZE);
  end;
end;


function TIdModBusServer.GetVersion: String;
begin
  Result := DMB_VERSION;
end;


function TIdModBusServer.IsLogTimeFormatStored: Boolean;
begin
  Result := (FLogTimeFormat <> DefaultLogTimeFormat);
end;


procedure TIdModBusServer.SetVersion(const Value: String);
begin
{ This intentionally is a readonly property }
end;


end.

