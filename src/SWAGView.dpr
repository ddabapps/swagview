program SWAGView;

{$Resource Version.res}
{$Resource *.res}

uses
  System.StartUpCopy,
  FMX.Forms,
  SWAGView.UI.MainForm in 'SWAGView.UI.MainForm.pas' {MainForm},

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
