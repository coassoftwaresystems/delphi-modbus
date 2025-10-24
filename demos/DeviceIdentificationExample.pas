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
  This unit provides an example implementation of Function Code 43 - Read Device Identification.
  
  Usage:
    1. Assign the OnReadDeviceIdentification event handler to your TIdModBusServer component
    2. Call the provided example handler or implement your own
    
  Example:
    msrPLC.OnReadDeviceIdentification := ExampleReadDeviceIdentification;
}

unit DeviceIdentificationExample;

interface

uses
  IdContext, IdModBusServer, ModbusConsts, ModbusTypes, SysUtils;

// Example event handler for Read Device Identification
procedure ExampleReadDeviceIdentification(
  const Sender: TIdContext;
  const ReadDeviceIDCode: Byte; 
  const ObjectID: Byte;
  var DeviceIdentificationData: TModDeviceIdentificationData;
  const RequestBuffer: TModBusRequestBuffer; 
  var ErrorCode: Byte);

implementation

procedure ExampleReadDeviceIdentification(
  const Sender: TIdContext;
  const ReadDeviceIDCode: Byte; 
  const ObjectID: Byte;
  var DeviceIdentificationData: TModDeviceIdentificationData;
  const RequestBuffer: TModBusRequestBuffer; 
  var ErrorCode: Byte);
begin
  ErrorCode := mbeOk;
  
  case ReadDeviceIDCode of
    mbReadDevIDBasic, mbReadDevIDRegular, mbReadDevIDExtended:
      begin
        // Return basic device identification (mandatory objects)
        SetLength(DeviceIdentificationData, 3);
        
        DeviceIdentificationData[0].ObjectID := mbObjIDVendorName;
        DeviceIdentificationData[0].ObjectValue := 'COAS software systems';
        
        DeviceIdentificationData[1].ObjectID := mbObjIDProductCode;
        DeviceIdentificationData[1].ObjectValue := 'delphi-modbus';
        
        DeviceIdentificationData[2].ObjectID := mbObjIDMajorMinorRevision;
        DeviceIdentificationData[2].ObjectValue := 'V2.0.0';
        
        // For Regular and Extended, add optional objects
        if ReadDeviceIDCode >= mbReadDevIDRegular then
        begin
          SetLength(DeviceIdentificationData, 6);
          
          DeviceIdentificationData[3].ObjectID := mbObjIDVendorUrl;
          DeviceIdentificationData[3].ObjectValue := 'github.com/coassoftwaresystems';
          
          DeviceIdentificationData[4].ObjectID := mbObjIDProductName;
          DeviceIdentificationData[4].ObjectValue := 'Delphi ModbusTCP Server';
          
          DeviceIdentificationData[5].ObjectID := mbObjIDModelName;
          DeviceIdentificationData[5].ObjectValue := 'ModbusServer-Standard';
        end;
      end;
      
    mbReadDevIDSpecific:
      begin
        // Return specific object by ID
        case ObjectID of
          mbObjIDVendorName:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDVendorName;
              DeviceIdentificationData[0].ObjectValue := 'COAS software systems';
            end;
          mbObjIDProductCode:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDProductCode;
              DeviceIdentificationData[0].ObjectValue := 'delphi-modbus';
            end;
          mbObjIDMajorMinorRevision:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDMajorMinorRevision;
              DeviceIdentificationData[0].ObjectValue := 'V2.0.0';
            end;
          mbObjIDVendorUrl:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDVendorUrl;
              DeviceIdentificationData[0].ObjectValue := 'github.com/coassoftwaresystems';
            end;
          mbObjIDProductName:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDProductName;
              DeviceIdentificationData[0].ObjectValue := 'Delphi ModbusTCP Server';
            end;
          mbObjIDModelName:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDModelName;
              DeviceIdentificationData[0].ObjectValue := 'ModbusServer-Standard';
            end;
        else
          // Object ID not found - return illegal data address error
          ErrorCode := mbeIllegalRegister;
        end;
      end;
  else
    // Invalid Read Device ID Code
    ErrorCode := mbeIllegalDataValue;
  end;
end;

end.
