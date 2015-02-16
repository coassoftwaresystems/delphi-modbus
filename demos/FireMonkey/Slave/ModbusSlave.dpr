program ModbusSlave;

uses
  FMX.Forms,
  frm_Main in 'frm_Main.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
