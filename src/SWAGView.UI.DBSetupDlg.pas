{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements a dialogue box that guides the user through the process of
 * downloading a copy of the SWAG database and gets the location of a
 * downloaded zip file containing the database.
}


unit SWAGView.UI.DBSetupDlg;

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Types;

type

  ///  <summary>Form class that implements a dialogue box that guides the user
  ///  through the process of downloading a copy of the SWAG database and gets
  ///  the location of a downloaded zip file containing the database.</summary>
  TDBSetupDlg = class(TForm)
    InfoLbl1: TLabel;
    InfoLbl2: TLabel;
    InfoLbl3: TLabel;
    InfoLbl4: TLabel;
    BulletLbl1: TLabel;
    BulletLbl2: TLabel;
    BulletLbl3: TLabel;
    InfoLbl5: TLabel;
    SWAGPathEdit: TEdit;
    ChooseDirBtn: TButton;
    InfoLbl6: TLabel;
    BulletLbl4: TLabel;
    InstallBtn: TButton;
    CancelBtn: TButton;
    SWAGFileOpenDlg: TOpenDialog;
    SWAGWebBtn: TButton;
    procedure ChooseDirBtnClick(Sender: TObject);
    procedure SWAGPathEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SWAGPathEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure SWAGWebBtnClick(Sender: TObject);
  strict private
    const
      SWAGReleasesURL = 'https://github.com/delphidabbler/swag/releases';
    function GetPathFromEditCtrl: string;
    procedure UpdateInstallButton;
  public
    class function GetDBFilePath(AOwner: TComponent;
      out AZipFilePath: string): Boolean;
  end;

implementation

uses
  System.IOUtils,
  System.UITypes,
  Winapi.Windows,
  Winapi.ShellAPI;

{$R *.fmx}

procedure TDBSetupDlg.ChooseDirBtnClick(Sender: TObject);
begin
  if SWAGFileOpenDlg.Execute then
    SWAGPathEdit.Text := SWAGFileOpenDlg.FileName;
end;

procedure TDBSetupDlg.FormShow(Sender: TObject);
begin
  UpdateInstallButton;
end;

class function TDBSetupDlg.GetDBFilePath(AOwner: TComponent;
  out AZipFilePath: string): Boolean;
begin
  var Dlg := TDBSetupDlg.Create(AOwner);
  try
    Result := Dlg.ShowModal = mrOk;
    if Result then
      AZipFilePath := Dlg.GetPathFromEditCtrl;
  finally
    Dlg.Free;
  end;
end;

function TDBSetupDlg.GetPathFromEditCtrl: string;
begin
  Result := SWAGPathEdit.Text.Trim;
end;

procedure TDBSetupDlg.SWAGPathEditChange(Sender: TObject);
begin
  UpdateInstallButton;
end;

procedure TDBSetupDlg.SWAGPathEditKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  UpdateInstallButton;
end;

procedure TDBSetupDlg.SWAGWebBtnClick(Sender: TObject);
begin
  ShellExecute(0, 'open', SWAGReleasesURL, '', '', SW_SHOWNORMAL);
end;

procedure TDBSetupDlg.UpdateInstallButton;
begin
  InstallBtn.Enabled := not GetPathFromEditCtrl.IsEmpty
    and TFile.Exists(GetPathFromEditCtrl);
end;

end.

