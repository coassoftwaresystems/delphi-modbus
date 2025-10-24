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

{
  This unit provides example implementations for private/user-defined Modbus functions.
  
  Server Usage:
    1. Assign the OnPrivateFunction event handler to your TIdModBusServer component
    2. Call the provided example handler or implement your own
    
  Example (Server):
    msrPLC.OnPrivateFunction := ExampleServerPrivateFunction;
    
  Client Usage:
    1. Assign the OnPrivateFunction and OnPrivateResponse event handlers
    2. Call SendPrivateFunction with your custom function code
    
  Example (Client):
    mscPLC.OnPrivateFunction := ExampleClientPrivateFunction;
    mscPLC.OnPrivateResponse := ExampleClientPrivateResponse;
    if mscPLC.SendPrivateFunction($41) then
      ShowMessage('Success');
}

unit PrivateFunctionExample;

interface

uses
  IdContext, IdModBusServer, IdModBusClient, ModbusConsts, ModbusTypes, SysUtils;

// Server-side example event handler for Private Functions
procedure ExampleServerPrivateFunction(
  const Sender: TIdContext;
  const FunctionCode: Byte;
  const RequestBuffer: TModBusRequestBuffer;
  var ResponseData: TModBusDataBuffer;
  var ResponseDataSize: Integer;
  var ErrorCode: Byte);

// Client-side example event handlers for Private Functions
procedure ExampleClientPrivateFunction(
  const FunctionCode: Byte;
  const RequestBuffer: TModBusRequestBuffer;
  var Data: TModBusDataBuffer;
  var DataSize: Integer);

procedure ExampleClientPrivateResponse(
  const FunctionCode: Byte;
  const ResponseBuffer: TModBusResponseBuffer;
  const Data: TModBusDataBuffer;
  const DataSize: Integer);

implementation

// Server implementation
procedure ExampleServerPrivateFunction(
  const Sender: TIdContext;
  const FunctionCode: Byte;
  const RequestBuffer: TModBusRequestBuffer;
  var ResponseData: TModBusDataBuffer;
  var ResponseDataSize: Integer;
  var ErrorCode: Byte);
var
  Command: Byte;
begin
  ErrorCode := mbeOk;
  
  // Handle different private function codes
  case FunctionCode of
    $41: // Custom device identification
      begin
        // Get command byte from request
        Command := RequestBuffer.MBPData[0];
        
        case Command of
          $01: // Get device info
            begin
              ResponseData[0] := $01;  // Echo command
              ResponseData[1] := $12;  // Device ID high byte
              ResponseData[2] := $34;  // Device ID low byte
              ResponseData[3] := $56;  // Firmware version major
              ResponseData[4] := $78;  // Firmware version minor
              ResponseData[5] := $9A;  // Hardware version
              ResponseDataSize := 6;
            end;
          $02: // Get serial number
            begin
              ResponseData[0] := $02;  // Echo command
              ResponseData[1] := $00;  // Serial number byte 1
              ResponseData[2] := $00;  // Serial number byte 2
              ResponseData[3] := $12;  // Serial number byte 3
              ResponseData[4] := $34;  // Serial number byte 4
              ResponseDataSize := 5;
            end;
          else
            ErrorCode := mbeIllegalDataValue;
        end;
      end;
      
    $42: // Custom data read
      begin
        // Example: Read custom data based on address in request
        Command := RequestBuffer.MBPData[0]; // Data address
        ResponseData[0] := Command;           // Echo address
        ResponseData[1] := $AA;               // Sample data byte 1
        ResponseData[2] := $BB;               // Sample data byte 2
        ResponseData[3] := $CC;               // Sample data byte 3
        ResponseDataSize := 4;
      end;
      
    $64: // Custom diagnostic function
      begin
        // Example: Return diagnostic status
        ResponseData[0] := $00; // Status: OK
        ResponseData[1] := $64; // Temperature (example: 100 degrees)
        ResponseData[2] := $32; // Load percentage (example: 50%)
        ResponseDataSize := 3;
      end;
      
    else
      // Unknown private function code
      ErrorCode := mbeIllegalFunction;
  end;
end;


// Client implementation - prepare request data
procedure ExampleClientPrivateFunction(
  const FunctionCode: Byte;
  const RequestBuffer: TModBusRequestBuffer;
  var Data: TModBusDataBuffer;
  var DataSize: Integer);
begin
  // Prepare request data based on function code
  case FunctionCode of
    $41: // Custom device identification
      begin
        Data[0] := $01;  // Command: Get device info
        DataSize := 1;
      end;
      
    $42: // Custom data read
      begin
        Data[0] := $05;  // Data address to read
        DataSize := 1;
      end;
      
    $64: // Custom diagnostic function
      begin
        // No data needed for this example
        DataSize := 0;
      end;
      
    else
      DataSize := 0;
  end;
end;


// Client implementation - process response data
procedure ExampleClientPrivateResponse(
  const FunctionCode: Byte;
  const ResponseBuffer: TModBusResponseBuffer;
  const Data: TModBusDataBuffer;
  const DataSize: Integer);
var
  DeviceID: Word;
  FirmwareVersion: String;
begin
  // Process response based on function code
  case FunctionCode of
    $41: // Custom device identification
      begin
        if DataSize >= 6 then
        begin
          // Extract device info
          DeviceID := (Data[1] shl 8) or Data[2];
          FirmwareVersion := Format('%d.%d', [Data[3], Data[4]]);
          
          // Use the data (in real application, update UI or store values)
          // WriteLn(Format('Device ID: $%x', [DeviceID]));
          // WriteLn(Format('Firmware: %s', [FirmwareVersion]));
          // WriteLn(Format('Hardware: $%x', [Data[5]]));
        end;
      end;
      
    $42: // Custom data read
      begin
        if DataSize >= 4 then
        begin
          // Process the custom data
          // WriteLn(Format('Address: $%x', [Data[0]]));
          // WriteLn(Format('Data: $%x $%x $%x', [Data[1], Data[2], Data[3]]));
        end;
      end;
      
    $64: // Custom diagnostic function
      begin
        if DataSize >= 3 then
        begin
          // Process diagnostic data
          // WriteLn(Format('Status: $%x', [Data[0]]));
          // WriteLn(Format('Temperature: %d', [Data[1]]));
          // WriteLn(Format('Load: %d%%', [Data[2]]));
        end;
      end;
  end;
end;

end.
