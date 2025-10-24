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
  This unit provides an example of using the client-side Function Code 43 - Read Device Identification.
  
  Usage:
    1. Create a TIdModbusClient instance
    2. Set the Host and Port properties
    3. Call ReadDeviceIdentification with the desired parameters
    4. Process the returned device identification data
}

unit DeviceIdentificationClientExample;

interface

uses
  IdModbusClient, ModbusConsts, ModbusTypes, SysUtils;

// Example: Read basic device identification
function ReadBasicDeviceInfo(Client: TIdModbusClient): String;

// Example: Read specific object by ID
function ReadSpecificObject(Client: TIdModbusClient; ObjectID: Byte): String;

// Example: Read all available device identification
function ReadAllDeviceInfo(Client: TIdModbusClient): String;

implementation

function ReadBasicDeviceInfo(Client: TIdModbusClient): String;
var
  DeviceData: TModDeviceIdentificationData;
  i: Integer;
begin
  Result := '';
  
  // Request basic device identification (mandatory objects)
  if Client.ReadDeviceIdentification(mbReadDevIDBasic, $00, DeviceData) then
  begin
    Result := 'Basic Device Identification:' + sLineBreak;
    for i := 0 to High(DeviceData) do
    begin
      case DeviceData[i].ObjectID of
        mbObjIDVendorName:
          Result := Result + '  Vendor Name: ' + DeviceData[i].ObjectValue + sLineBreak;
        mbObjIDProductCode:
          Result := Result + '  Product Code: ' + DeviceData[i].ObjectValue + sLineBreak;
        mbObjIDMajorMinorRevision:
          Result := Result + '  Version: ' + DeviceData[i].ObjectValue + sLineBreak;
      else
        Result := Result + Format('  Object $%2.2X: %s', [DeviceData[i].ObjectID, DeviceData[i].ObjectValue]) + sLineBreak;
      end;
    end;
  end
  else
    Result := 'Error: Failed to read basic device identification';
end;


function ReadSpecificObject(Client: TIdModbusClient; ObjectID: Byte): String;
var
  DeviceData: TModDeviceIdentificationData;
  ObjectName: String;
begin
  Result := '';
  
  // Determine object name for display
  case ObjectID of
    mbObjIDVendorName: ObjectName := 'Vendor Name';
    mbObjIDProductCode: ObjectName := 'Product Code';
    mbObjIDMajorMinorRevision: ObjectName := 'Version';
    mbObjIDVendorUrl: ObjectName := 'Vendor URL';
    mbObjIDProductName: ObjectName := 'Product Name';
    mbObjIDModelName: ObjectName := 'Model Name';
    mbObjIDUserApplicationName: ObjectName := 'User Application Name';
  else
    ObjectName := Format('Object $%2.2X', [ObjectID]);
  end;
  
  // Request specific object
  if Client.ReadDeviceIdentification(mbReadDevIDSpecific, ObjectID, DeviceData) then
  begin
    if Length(DeviceData) > 0 then
      Result := ObjectName + ': ' + DeviceData[0].ObjectValue
    else
      Result := 'Error: No data returned for ' + ObjectName;
  end
  else
    Result := 'Error: Failed to read ' + ObjectName;
end;


function ReadAllDeviceInfo(Client: TIdModbusClient): String;
var
  DeviceData: TModDeviceIdentificationData;
  i: Integer;
  ObjectName: String;
begin
  Result := '';
  
  // Request extended device identification (all objects)
  if Client.ReadDeviceIdentification(mbReadDevIDExtended, $00, DeviceData) then
  begin
    Result := 'Complete Device Identification:' + sLineBreak;
    for i := 0 to High(DeviceData) do
    begin
      // Determine object name
      case DeviceData[i].ObjectID of
        mbObjIDVendorName: ObjectName := 'Vendor Name';
        mbObjIDProductCode: ObjectName := 'Product Code';
        mbObjIDMajorMinorRevision: ObjectName := 'Version';
        mbObjIDVendorUrl: ObjectName := 'Vendor URL';
        mbObjIDProductName: ObjectName := 'Product Name';
        mbObjIDModelName: ObjectName := 'Model Name';
        mbObjIDUserApplicationName: ObjectName := 'User Application';
      else
        ObjectName := Format('Object $%2.2X', [DeviceData[i].ObjectID]);
      end;
      
      Result := Result + Format('  %s: %s', [ObjectName, DeviceData[i].ObjectValue]) + sLineBreak;
    end;
  end
  else
    Result := 'Error: Failed to read device identification';
end;

end.
