{===============================================================================

Copyright (c) 2010 P.L. Polak

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

{$I ModBusCompiler.inc}

unit ModbusReg;

interface

procedure Register;

implementation

uses
  Classes
{$IFDEF FPC}
 ,LazarusPackageIntf
{$ELSE}
 ,DesignIntf
{$ENDIF}
 ,IdModbusClient
 ,IdModbusServer
{$IFNDEF FPC}
 ,AboutComponentEditor
 ,ModbusSplash
{$ENDIF}
 ,ModbusStrConsts;


procedure Register;
begin
{ Register the components }
  RegisterComponents('Modbus', [TIdModbusClient, TIdModbusServer]);
{$IFNDEF FPC}
{ Register the component editors }
  RegisterComponentEditor(TIdModbusClient, TAboutComponentEditor);
  RegisterComponentEditor(TIdModbusServer, TAboutComponentEditor);
{ Register the property editors }
  RegisterPropertyEditor(TypeInfo(String), TIdModbusClient, 'Version', TAboutPropertyEditor);
  RegisterPropertyEditor(TypeInfo(String), TIdModbusServer, 'Version', TAboutPropertyEditor);
{$ENDIF}
{ Register the property categories for the client component }
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'AutoConnect');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'BaseRegister');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'BlockLength');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'ReadTimeout');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'TimeOut');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'UnitID');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'Version');
{ Register the property categories for the client events }
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'OnResponseError');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'OnResponseMismatch');

{ Register the property categories for the server component }
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'BaseRegister');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OneShotConnection');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'MaxRegister');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'MinRegister');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'UnitID');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'Version');
  RegisterPropertyInCategory(sLogging, TIdModbusServer, 'LogEnabled');
  RegisterPropertyInCategory(sLogging, TIdModbusServer, 'LogFile');
  RegisterPropertyInCategory(sLogging, TIdModbusServer, 'LogTimeFormat');
{ Register the property categories for the server events }
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnError');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnInvalidFunction');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnReadCoils');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnReadHoldingRegisters');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnReadInputBits');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnReadInputRegisters');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnWriteCoils');
  RegisterPropertyInCategory(sModbus, TIdModbusServer, 'OnWriteRegisters');

  RegisterIDEPlugins;
end;


end.

