{===============================================================================

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above. If you wish to
allow use of your version of this file only under the terms of the GPL and not
to allow others to use your version of this file under the MPL, indicate your
decision by deleting the provisions above and replace them with the notice and
other provisions required by the GPL. If you do not delete the provisions
above, a recipient may use your version of this file under either the MPL or
the GPL.

===============================================================================}

{$I ModBusCompiler.inc}

unit ModbusReg;

interface

procedure Register;

implementation

uses
  Classes
{$IFDEF DMB_DELPHI6}
 ,DesignIntf
{$ELSE}
{$IFDEF FPC}
 ,LazarusPackageIntf
{$ELSE}
 ,DsgnIntf
{$ENDIF}
{$ENDIF}
 ,IdModbusClient
 ,IdModbusServer
{$IFNDEF FPC}
{$IFDEF DMB_DELPHI2005}
 ,ModbusSplash
{$ENDIF}
 ,AboutComponentEditor
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
{$IFDEF DMB_DELPHI6}
{ Register the property categories for the client component }
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'AutoConnect');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'BaseRegister');
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'BlockLength');
{$IFNDEF DMB_INDY10}
  RegisterPropertyInCategory(sModbus, TIdModbusClient, 'ConnectTimeOut');
{$ENDIF}
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
{$ENDIF}
{$IFDEF DMB_DELPHI2005}
  RegisterIDEPlugins;
{$ENDIF}
end;


end.

