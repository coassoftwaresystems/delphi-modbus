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

unit AboutComponentEditor;

interface

uses
{$IFDEF DMB_DELPHI6}
  DesignIntf
 ,DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

type
  TAboutComponentEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure Edit; override;
  end; { TAboutComponentEditor }

type
  TAboutPropertyEditor = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue:string; override;
  end; { TAboutPropertyEditor }


implementation

uses
  frm_About
 ,SysUtils
 ,ModbusConsts;


procedure ShowAboutDialog;
begin
  frmAbout := TfrmAbout.Create(nil);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end;
end; { ShowAboutDialog }


{ TAboutComponentEditor }

procedure TAboutComponentEditor.Edit;
begin
  ShowAboutDialog;
end; { Edit }


procedure TAboutComponentEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  if (Index = 0) then
    Edit;
end; { ExecuteVerb }


function TAboutComponentEditor.GetVerb(Index: Integer): string;
begin
  Result := '&About...';
end; { GetVerb }


function TAboutComponentEditor.GetVerbCount: Integer;
begin
  Result := 1;
end; { GetVerbCount }


{ TAboutPropertyEditor }

procedure TAboutPropertyEditor.Edit;
begin
  ShowAboutDialog;
end; { Edit }


function TAboutPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end; { GetAttributes }


function TAboutPropertyEditor.GetValue: String;
begin
  Result := Format('(%s)', [DMB_VERSION]);
end; { GetValue }


end.
