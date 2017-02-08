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

unit ModbusTypes;

interface

type
  TModBusFunction = Byte;

type
  TModBusDataBuffer = array[0..260] of Byte;

type
  TModBusHeader = packed record
    TransactionID: Word;
    ProtocolID: Word;
    RecLength: Word;
    UnitID: Byte;
  end;

type
  TModBusRequestBuffer = packed record
    Header: TModBusHeader;
    FunctionCode: TModBusFunction;
    MBPData: TModBusDataBuffer;
  end;

type
  TModBusResponseBuffer = packed record
    Header: TModBusHeader;
    FunctionCode: TModBusFunction;
    MBPData: TModBusDataBuffer;
  end;

type
  TModBusExceptionBuffer = packed record
    Header: TModBusHeader;
    ExceptionFunction: TModBusFunction;
    ExceptionCode: Byte;
  end;


implementation

end.

