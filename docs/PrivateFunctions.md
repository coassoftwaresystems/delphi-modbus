# Private/User-Defined Modbus Functions

This document describes how to use private or user-defined Modbus function codes with the Delphi Modbus components.

## Overview

The Modbus specification reserves certain function code ranges for private or user-defined functions:
- **0x41-0x48** (65-72 decimal)
- **0x64-0x6E** (100-110 decimal)

These function codes allow vendors to implement proprietary device-specific functions for tasks such as:
- Device identification
- Firmware updating
- Specialized data access
- Custom diagnostics

## Client Implementation

To use private functions from a client, you need to:

1. Assign event handlers for `OnPrivateFunction` and `OnPrivateResponse`
2. Call the `SendPrivateFunction` method with the desired function code

### Example

```pascal
procedure TForm1.ModbusClientPrivateFunction(const FunctionCode: Byte;
  const RequestBuffer: TModBusRequestBuffer; var Data: TModBusDataBuffer;
  var DataSize: Integer);
begin
  // Populate the request data for the private function
  // For example, to send a command with 4 bytes of data:
  Data[0] := $01;  // Command byte
  Data[1] := $00;  // Parameter 1
  Data[2] := $00;  // Parameter 2
  Data[3] := $00;  // Parameter 3
  DataSize := 4;   // Total bytes to send
end;

procedure TForm1.ModbusClientPrivateResponse(const FunctionCode: Byte;
  const ResponseBuffer: TModBusResponseBuffer; const Data: TModBusDataBuffer;
  const DataSize: Integer);
var
  i: Integer;
begin
  // Process the response data from the private function
  Memo1.Lines.Add(Format('Received response for function $%x with %d bytes:', 
    [FunctionCode, DataSize]));
  for i := 0 to DataSize - 1 do
    Memo1.Lines.Add(Format('  Byte[%d] = $%x', [i, Data[i]]));
end;

procedure TForm1.ButtonSendPrivateFunctionClick(Sender: TObject);
begin
  // Assign event handlers
  IdModbusClient1.OnPrivateFunction := ModbusClientPrivateFunction;
  IdModbusClient1.OnPrivateResponse := ModbusClientPrivateResponse;
  
  // Send private function code 0x41 (65 decimal)
  if IdModbusClient1.SendPrivateFunction($41) then
    ShowMessage('Private function sent successfully')
  else
    ShowMessage('Private function failed');
end;
```

### Error Handling

The `SendPrivateFunction` method will raise an `EModbusInvalidPrivateFunction` exception if:
- The function code is not in the valid private function ranges (0x41-0x48 or 0x64-0x6E)
- The `OnPrivateFunction` event handler is not assigned

## Server Implementation

To handle private functions on a server, you need to:

1. Assign an event handler for `OnPrivateFunction`
2. Process the request and populate the response data

### Example

```pascal
procedure TForm1.ModbusServerPrivateFunction(const Sender: TIdContext;
  const FunctionCode: Byte; const RequestBuffer: TModBusRequestBuffer;
  var ResponseData: TModBusDataBuffer; var ResponseDataSize: Integer;
  var ErrorCode: Byte);
var
  Command: Byte;
begin
  // Extract request data
  Command := RequestBuffer.MBPData[0];
  
  // Process based on function code and command
  case FunctionCode of
    $41: // Custom device identification
      begin
        case Command of
          $01: // Get device info
            begin
              ResponseData[0] := $01;  // Echo command
              ResponseData[1] := $12;  // Device ID high byte
              ResponseData[2] := $34;  // Device ID low byte
              ResponseData[3] := $56;  // Firmware version
              ResponseDataSize := 4;
              ErrorCode := mbeOk;
            end;
          else
            ErrorCode := mbeIllegalDataValue;
        end;
      end;
    $42: // Custom data access
      begin
        // Implement your custom data access logic
        ResponseData[0] := RequestBuffer.MBPData[0]; // Echo first byte
        ResponseDataSize := 1;
        ErrorCode := mbeOk;
      end;
    else
      ErrorCode := mbeIllegalFunction;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Assign event handler
  IdModbusServer1.OnPrivateFunction := ModbusServerPrivateFunction;
  IdModbusServer1.Active := True;
end;
```

### Error Codes

When handling private functions on the server, you can return any standard Modbus error code:
- `mbeOk` ($00): Success
- `mbeIllegalFunction` ($01): Function not supported
- `mbeIllegalDataValue` ($03): Invalid data in request
- `mbeServerFailure` ($04): Server error

If an error code other than `mbeOk` is returned, the server will automatically send a Modbus exception response.

## Security Considerations

When implementing private functions:
1. Always validate input data from the client
2. Implement proper authentication if required
3. Limit the data size to prevent buffer overflows
4. Log private function usage for security auditing
5. Document your private function implementations for maintenance

## Best Practices

1. **Document your functions**: Maintain clear documentation of what each private function code does
2. **Version control**: Include version information in responses to handle backward compatibility
3. **Error handling**: Always return appropriate error codes when requests cannot be processed
4. **Data validation**: Validate all input data before processing
5. **Testing**: Thoroughly test private function implementations with various data inputs

## References

- Modbus Application Protocol Specification V1.1b3
- Section 5 Function Code Categories (0x41-0x48, 0x64-0x6E are reserved for user-defined functions)
