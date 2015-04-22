program SGCE_Client;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uScripts in 'units\lua\uScripts.pas',
  uScriptThread in 'units\lua\uScriptThread.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SGCE Client';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
