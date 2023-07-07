program SWAGView;

uses
  System.StartUpCopy,
  FMX.Forms,
  SWAGView.UI.MainForm in 'SWAGView.UI.MainForm.pas' {MainForm},

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
