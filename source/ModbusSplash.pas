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

unit ModbusSplash;

interface

{$R ModBusSplash.res}

procedure RegisterIDEPlugins;

implementation

uses
  ToolsApi, Windows, Classes, Graphics, ModbusConsts;

var
  PluginIndex: Integer = -1;

type
  TLogoRegisterProc = procedure(const AImage: HBITMAP);


procedure AddToAboutBox(const AImage: HBITMAP);
{$IFDEF DMB_DELPHI2005}
var
  AboutBoxServices: IOTAAboutBoxServices;
{$ENDIF}
begin
{$IFDEF DMB_DELPHI2005}
  if BorlandIDEServices.SupportsService(IOTAAboutBoxServices) then
  begin
    AboutBoxServices := BorlandIDEServices.GetService(IOTAAboutBoxServices) as IOTAAboutBoxServices;
    if (AboutBoxServices <> nil) then
    begin
      PluginIndex := AboutBoxServices.AddPluginInfo(
         'Delphi ModbusTCP components ' + DMB_VERSION
        ,'Free Delphi components for ModbusTCP communication version ' + DMB_VERSION
        ,AImage
        ,False
        ,'Open source'
        ,'Delphi Modbus');
    end;
  end;
{$ENDIF}
end;


procedure AddToSplash(const AImage: HBITMAP);
begin
{$IFDEF DMB_DELPHI2005}
  SplashScreenServices.AddPluginBitmap(
    'Delphi ModbusTCP components ' + DMB_VERSION
   ,AImage
   ,False
   ,'Open source'
   ,'');
{$ENDIF}
end;


procedure RegisterLogo(const RegisterProc: TLogoRegisterProc);
var
  bmpLogo: TBitmap;
begin
  bmpLogo := TBitmap.Create;
  try
    bmpLogo.LoadFromResourceName(HInstance, 'MODBUSSPLASH');
    RegisterProc(bmpLogo.Handle);
  finally
    bmpLogo.Free;
  end;
end;


procedure RegisterIDEPlugins;
begin
  RegisterLogo(AddToAboutBox);
end;


procedure CleanupIDE;
{$IFDEF DMB_DELPHI2005}
var
  AboutBoxServices: IOTAAboutBoxServices;
{$ENDIF}
begin
{$IFDEF DMB_DELPHI2005}
  if (PluginIndex >= 0) and BorlandIDEServices.SupportsService(IOTAAboutBoxServices) then
  begin
    AboutBoxServices := BorlandIDEServices.GetService(IOTAAboutBoxServices) as IOTAAboutBoxServices;
    if (AboutBoxServices <> nil) then
      AboutBoxServices.RemovePluginInfo(PluginIndex);
  end;
{$ENDIF}
end;


initialization
  RegisterLogo(AddToSplash);

finalization
  CleanupIDE;

end.
