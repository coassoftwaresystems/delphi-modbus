# Modbus RTU over TCP Support

## Overview

This document describes how to use the Modbus RTU over TCP transport mode added to the Delphi Modbus components.

## Background

Modbus supports two main transport protocols:
- **Modbus TCP**: Uses standard TCP/IP without additional error checking (uses TCP's built-in error detection)
- **Modbus RTU over TCP**: Wraps RTU frames (including CRC-16 error checking) in TCP packets

## Changes

The `IncludeCrc` boolean property has been replaced with a more descriptive `TransportMode` enumerated property:

```pascal
type
  TModBusTransportMode = (tmTCP, tmRTU);
```

This property is available in both `TIdModBusClient` and `TIdModBusServer` components.

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

When `TransportMode` is set to `tmRTU`:

### Client
- Outgoing messages have a CRC-16 checksum appended (2 bytes, little-endian)
- Incoming messages are validated for correct CRC-16 checksum
- Invalid CRC causes the message to be rejected

### Server
- Incoming requests are validated for correct CRC-16 checksum
- Invalid CRC causes the request to be ignored
- Outgoing responses and error messages have CRC-16 appended

## CRC-16 Implementation

The CRC-16 implementation uses the Modbus standard polynomial and is little-endian (LSB first):
- Low byte is sent/received first
- High byte is sent/received second

## Migration from IncludeCrc

If you were using the deprecated `IncludeCrc` property:

```pascal
// Old code
ModbusClient.IncludeCrc := True;

// New code
ModbusClient.TransportMode := tmRTU;
```

```pascal
// Old code
ModbusClient.IncludeCrc := False;

// New code
ModbusClient.TransportMode := tmTCP;  // or just leave as default
```
