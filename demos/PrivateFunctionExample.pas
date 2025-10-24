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
    1. Prepare request data as an array of bytes
    2. Call SendPrivateFunction with the function code and request data
    3. Process response data from the output parameter
    
  Example (Client):
    var
      RequestData: array[0..0] of Byte;
      ResponseData: array[0..255] of Byte;
    begin
      RequestData[0] := $01;  // Command
      if mscPLC.SendPrivateFunction($41, RequestData, ResponseData) then
        ShowMessage('Success');
    end;
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
        // Note: The Modbus library ensures RequestBuffer contains valid received data
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
        // Note: The Modbus library ensures RequestBuffer contains valid received data
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

end.
