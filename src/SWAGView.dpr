program SWAGView;

{$Resource Version.res}
{$Resource *.res}

uses
  System.StartUpCopy,
  FMX.Forms,
  SWAGView.SWAG in 'SWAGView.SWAG.pas',
  SWAGView.SWAG.Installer in 'SWAGView.SWAG.Installer.pas',
  SWAGView.SWAG.Reader in 'SWAGView.SWAG.Reader.pas',
  SWAGView.SWAG.Types in 'SWAGView.SWAG.Types.pas',
  SWAGView.SWAG.Version in 'SWAGView.SWAG.Version.pas',
  SWAGView.SWAG.XMLProcessor in 'SWAGView.SWAG.XMLProcessor.pas',
  SWAGView.UI.DBSetupDlg in 'SWAGView.UI.DBSetupDlg.pas' {DBSetupDlg},
  SWAGView.UI.MainForm in 'SWAGView.UI.MainForm.pas' {MainForm},
  SWAGView.UI.WaitDlg in 'SWAGView.UI.WaitDlg.pas' {WaitDlg},
  SWAGView.Utils.IO in 'SWAGView.Utils.IO.pas',
  SWAGView.Utils.StringParsers in 'SWAGView.Utils.StringParsers.pas',
  SWAGView.VersionInfo in 'SWAGView.VersionInfo.pas',
  SWAGView.XMLDocumentEx in 'SWAGView.XMLDocumentEx.pas';

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
