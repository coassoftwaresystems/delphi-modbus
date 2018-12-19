{===============================================================================

Copyright (c) 2010 P.L. Polak

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

unit ModbusConsts;

interface

const
  MB_PORT = 502;
  MB_IGNORE_UNITID = 255;
  MB_PROTOCOL = 0;

// Define constants for the ModBus functions
const
  mbfReadCoils = $01;
  mbfReadInputBits = $02;
  mbfReadHoldingRegs = $03;
  mbfReadInputRegs = $04;
  mbfWriteOneCoil = $05;
  mbfWriteOneReg = $06;
  mbfWriteCoils = $0F;
  mbfWriteRegs = $10;
  mbfReadFileRecord = $14;
  mbfWriteFileRecord = $15;
  mbfMaskWriteReg = $16;
  mbfReadWriteRegs = $17;
  mbfReadFiFoQueue = $18;

// Define constants for the ModBus exceptions
const
  mbeOk = $00;
  mbeIllegalFunction = $01;
  mbeIllegalRegister = $02;
  mbeIllegalDataValue = $03;
  mbeServerFailure = $04;
  mbeAcknowledge = $05;
  mbeServerBusy = $06;
  mbeGatewayPathNotAvailable = $0A;
  mbeGatewayNoResponseFromTarget = $0B;

const
  MaxBlockLength = 125;
  MaxCoils = 2000;

const
  DMB_VERSION = '1.7.0'; {Do not Localize}
  
const
  DefaultLogTimeFormat = 'yyyy-mm-dd hh:nn:ss.zzz';  {Do not Localize}
  
implementation

end.

