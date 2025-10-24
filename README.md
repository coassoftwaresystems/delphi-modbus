# delphi-modbus
Delphi ModbusTCP components


Download are available [here](https://github.com/coassoftwaresystems/delphi-modbus/releases)

N.B. The old downloads are still available from [SourceForge.net](http://sourceforge.net/projects/delphimodbus/)


A listing of implementations using the components is available in the [wiki](https://github.com/coassoftwaresystems/delphi-modbus/wiki).

## Features

### Supported Function Codes
- Function Code 01 (0x01): Read Coils
- Function Code 02 (0x02): Read Input Bits
- Function Code 03 (0x03): Read Holding Registers
- Function Code 04 (0x04): Read Input Registers
- Function Code 05 (0x05): Write Single Coil
- Function Code 06 (0x06): Write Single Register
- Function Code 15 (0x0F): Write Multiple Coils
- Function Code 16 (0x10): Write Multiple Registers
- Function Code 43 (0x2B): Read Device Identification (MEI Type 14) - *New in v2.0*

### Documentation
- [Read Device Identification](docs/ReadDeviceIdentification.md) - Guide for Function Code 43
- [RTU over TCP](docs/RTU_over_TCP.md) - RTU transport mode documentation
- [Implementation Summary](docs/IMPLEMENTATION_SUMMARY.md) - Technical details of recent changes

