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

$Id: ModbusSplash.pas,v 1.8 2011/06/21 11:50:22 plpolak Exp $

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
