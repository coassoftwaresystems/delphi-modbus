# Modbus RTU over TCP Support

## Overview

This document describes how to use the Modbus RTU over TCP transport mode added to the Delphi Modbus components.

## Background

Modbus supports two main transport protocols:
- **Modbus TCP**: Uses MBAP (Modbus Application Protocol) header with TransactionID, ProtocolID, Length, and UnitID
- **Modbus RTU over TCP**: Uses RTU framing (UnitID + Function + Data + CRC-16) wrapped in TCP packets

### Protocol Frames

**Modbus TCP Frame:**
```
[TransactionID: 2 bytes][ProtocolID: 2 bytes][Length: 2 bytes][UnitID: 1 byte][Function: 1 byte][Data: N bytes]
```

**Modbus RTU over TCP Frame:**
```
[UnitID: 1 byte][Function: 1 byte][Data: N bytes][CRC: 2 bytes]
```

## Changes

The implementation uses separate header structures for the two transport modes:

```pascal
type
  TModBusTransportMode = (tmTCP, tmRTU);

type
  TModBusTCPHeader = packed record
    TransactionID: Word;
    ProtocolID: Word;
    RecLength: Word;
  end;

type
  TModBusHeader = packed record
    UnitID: Byte;
  end;
```

Buffer structures include both headers, but only the relevant parts are sent/received based on the transport mode.

## Usage

### Client Example

```pascal
var
  ModbusClient: TIdModBusClient;
begin
  ModbusClient := TIdModBusClient.Create(nil);
  try
    ModbusClient.Host := '192.168.1.100';
    ModbusClient.Port := 502;
    ModbusClient.TransportMode := tmRTU;  // Enable RTU over TCP
    ModbusClient.Connect;
    
    // Use the client as normal
    ModbusClient.ReadHoldingRegister(1000, Value);
  finally
    ModbusClient.Free;
  end;
end;
```

### Server Example

```pascal
var
  ModbusServer: TIdModBusServer;
begin
  ModbusServer := TIdModBusServer.Create(nil);
  try
    ModbusServer.DefaultPort := 502;
    ModbusServer.TransportMode := tmRTU;  // Enable RTU over TCP
    ModbusServer.Active := True;
    
    // Server is now ready to accept RTU over TCP connections
  finally
    ModbusServer.Free;
  end;
end;
```

## Default Behavior

The default value for `TransportMode` is `tmTCP`, ensuring backward compatibility with existing code. Existing applications will continue to work without any code changes.

## Technical Details

### Client Behavior

**TCP Mode:**
- Sends: Full buffer with TCP header (6 bytes) + UnitID (1 byte) + Function + Data
- Receives: Full buffer with TCP header + UnitID + Function + Data
- Validates: ProtocolID and TransactionID matching

**RTU Mode:**
- Sends: UnitID (1 byte) + Function + Data + CRC-16 (2 bytes)
- Receives: UnitID + Function + Data + CRC-16
- Validates: CRC-16 checksum

### Server Behavior

**TCP Mode:**
- Receives: Full buffer with TCP header + UnitID + Function + Data
- Validates: ProtocolID and UnitID (if configured)
- Sends: Full buffer with TCP header + UnitID + Function + Data

**RTU Mode:**
- Receives: UnitID + Function + Data + CRC-16
- Validates: CRC-16 checksum and UnitID (if configured)
- Sends: UnitID + Function + Data + CRC-16

## CRC-16 Implementation

The CRC-16 implementation uses the Modbus standard polynomial and is little-endian (LSB first):
- Low byte is sent/received first (at position N-2)
- High byte is sent/received second (at position N-1)
