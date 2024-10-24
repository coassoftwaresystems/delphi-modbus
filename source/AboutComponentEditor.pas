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

unit AboutComponentEditor;

interface

uses
  DesignIntf
 ,DesignEditors;

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
