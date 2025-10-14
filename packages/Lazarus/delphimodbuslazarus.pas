{ This file was automatically created by Lazarus. do not edit!
  This source is only used to compile and install the package.
 }

unit delphimodbuslazarus; 

interface

uses
    IdModbusClient, ModbusUtils, ModbusTypes, ModbusStrConsts, ModbusConsts, 
  IdModbusServer, ModbusReg, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('ModbusReg', @ModbusReg.Register); 
end; 

initialization
  RegisterPackage('DelphiModbusLazarus', @Register); 
end.
