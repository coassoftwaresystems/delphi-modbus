# Function Code 43 - Read Device Identification

## Overview

The Modbus Function Code 43 (0x2B) with MEI Type 14 (Read Device Identification) allows clients to query a Modbus server for device identification information such as vendor name, product code, version, and other identification details.

## Implementation

To implement support for Read Device Identification in your Modbus server, you need to handle the `OnReadDeviceIdentification` event.

### Event Handler Signature

```pascal
TModBusDeviceIdentificationEvent = procedure(
  const Sender: TIdContext;
  const ReadDeviceIDCode: Byte; 
  const ObjectID: Byte; 
  var DeviceIdentificationData: TModDeviceIdentificationData;
  const RequestBuffer: TModBusRequestBuffer; 
  var ErrorCode: Byte
) of object;
```

### Parameters

- `Sender`: The context of the client connection
- `ReadDeviceIDCode`: The type of device identification requested:
  - `mbReadDevIDBasic` ($01): Basic device identification (VendorName, ProductCode, MajorMinorRevision)
  - `mbReadDevIDRegular` ($02): Regular device identification (Basic + optional fields)
  - `mbReadDevIDExtended` ($03): Extended device identification (all fields)
  - `mbReadDevIDSpecific` ($04): Specific object by ID
- `ObjectID`: The starting object ID requested (used with stream access or specific object)
- `DeviceIdentificationData`: Array to populate with device identification objects
- `RequestBuffer`: The raw Modbus request buffer
- `ErrorCode`: Set to indicate success (`mbeOk`) or error (e.g., `mbeIllegalDataValue`, `mbeIllegalRegister`)

### Device Identification Data Structure

```pascal
TModDeviceIdentificationObject = record
  ObjectID: Byte;
  ObjectValue: String;
end;

TModDeviceIdentificationData = array of TModDeviceIdentificationObject;
```

### Object IDs

#### Basic Device Identification (Mandatory)
- `mbObjIDVendorName` ($00): Vendor name
- `mbObjIDProductCode` ($01): Product code
- `mbObjIDMajorMinorRevision` ($02): Major/Minor revision

#### Regular Device Identification (Optional)
- `mbObjIDVendorUrl` ($03): Vendor URL
- `mbObjIDProductName` ($04): Product name
- `mbObjIDModelName` ($05): Model name
- `mbObjIDUserApplicationName` ($06): User application name

#### Extended Device Identification (Device-specific)
- Range: $80 to $FF (manufacturer-dependent)

## Example Usage

```pascal
procedure TfrmMain.msrPLCReadDeviceIdentification(
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
        // Return basic device identification (mandatory)
        SetLength(DeviceIdentificationData, 3);
        
        DeviceIdentificationData[0].ObjectID := mbObjIDVendorName;
        DeviceIdentificationData[0].ObjectValue := 'ACME Corporation';
        
        DeviceIdentificationData[1].ObjectID := mbObjIDProductCode;
        DeviceIdentificationData[1].ObjectValue := 'ACME-PLC-1000';
        
        DeviceIdentificationData[2].ObjectID := mbObjIDMajorMinorRevision;
        DeviceIdentificationData[2].ObjectValue := 'V1.0.2';
        
        // For Regular and Extended, add more objects as needed
        if ReadDeviceIDCode >= mbReadDevIDRegular then
        begin
          SetLength(DeviceIdentificationData, 4);
          DeviceIdentificationData[3].ObjectID := mbObjIDVendorUrl;
          DeviceIdentificationData[3].ObjectValue := 'www.acme.com';
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
              DeviceIdentificationData[0].ObjectValue := 'ACME Corporation';
            end;
          mbObjIDProductCode:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDProductCode;
              DeviceIdentificationData[0].ObjectValue := 'ACME-PLC-1000';
            end;
          mbObjIDMajorMinorRevision:
            begin
              SetLength(DeviceIdentificationData, 1);
              DeviceIdentificationData[0].ObjectID := mbObjIDMajorMinorRevision;
              DeviceIdentificationData[0].ObjectValue := 'V1.0.2';
            end;
        else
          // Object ID not found
          ErrorCode := mbeIllegalRegister;
        end;
      end;
  else
    // Invalid Read Device ID Code
    ErrorCode := mbeIllegalDataValue;
  end;
end;
```

## Error Handling

The implementation automatically handles the following error conditions:

1. **Invalid MEI Type**: If the MEI type is not $0E (Read Device Identification), the server responds with `mbeIllegalDataValue` ($03).

2. **Invalid Read Device ID Code**: If the Read Device ID Code is not in the valid range ($01-$04), the server responds with `mbeIllegalDataValue` ($03).

3. **Custom Error Codes**: Your event handler can set custom error codes:
   - `mbeIllegalRegister` ($02): Object ID not found (for individual access)
   - `mbeIllegalDataValue` ($03): Invalid data value
   - `mbeServerFailure` ($04): Server failure
   - Other standard Modbus exception codes

**Note**: Throughout this document, hexadecimal values are shown with the '$' prefix (Pascal convention), e.g., $0E, $01, $02, etc.

## Protocol Details

### Request Format (TCP)
| Byte | Description |
|------|-------------|
| 0-5  | TCP Header (Transaction ID, Protocol ID, Length) |
| 6    | Unit ID |
| 7    | Function Code (0x2B) |
| 8    | MEI Type (0x0E) |
| 9    | Read Device ID Code |
| 10   | Object ID |

### Response Format (TCP)
| Byte | Description |
|------|-------------|
| 0-5  | TCP Header (Transaction ID, Protocol ID, Length) |
| 6    | Unit ID |
| 7    | Function Code (0x2B) |
| 8    | MEI Type (0x0E) |
| 9    | Read Device ID Code |
| 10   | Conformity Level |
| 11   | More Follows (0x00 or 0xFF) |
| 12   | Next Object ID |
| 13   | Number of Objects |
| 14+  | Object List (ID, Length, Value for each object) |

## References

- Modbus Application Protocol Specification V1.1b3
- Section 6.21: Read Device Identification (function code 43)
