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

$Id: frm_About.pas,v 1.7 2010/02/05 12:25:30 plpolak Exp $

===============================================================================}

{$I ModBusCompiler.inc}

unit frm_About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ModbusConsts, jpeg;

type
  TfrmAbout = class(TForm)
    pnlMain: TPanel;
    btnOk: TBitBtn;
    lblVersion: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblWebsite: TLabel;
    Image1: TImage;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblWebsiteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  ShellAPI;

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lblVersion.Caption := 'Version ' + DMB_VERSION;
end; { FormCreate }


procedure TfrmAbout.lblWebsiteClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(lblWebSite.Caption), nil, nil, SW_SHOW);
end; { lblWebsiteClick }


end.
