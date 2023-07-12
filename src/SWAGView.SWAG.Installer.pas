{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Defines a class that can install the SWAG database from a zip file.
}


unit SWAGView.SWAG.Installer;

interface

type
  ///  <summary>Class that can install a local copy of the SWAG database from a
  ///  zip file.</summary>
  TSWAGInstaller = class
  strict private
    const
      SWAGSubDir = 'swag';
      TempSubDirStub = '~swag~';
    var
      fZipFilePath: string;
      fTempDirPath: string;
    function TempDirPath: string;
    procedure UnZipFileToTempDir;
    procedure CopySwagDirToProgDir;
    procedure TidyTempFiles;
    procedure RemoveExistingData;
  public
    constructor Create(const AZipFilePath: string);
    function Execute: Boolean;
    class function SWAGDataDir: string;
    class function IsInstalled: Boolean;
    class procedure RemoveInstallation;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.Zip,
  SWAGView.SWAG.Version;

{ TSWAGInstaller }

procedure TSWAGInstaller.CopySwagDirToProgDir;
begin
  TDirectory.Copy(
    TPath.Combine(TempDirPath, SWAGSubDir),
    TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), SWAGSubDir)
  );
end;

constructor TSWAGInstaller.Create(const AZipFilePath: string);
begin
  inherited Create;
  fZipFilePath := AZipFilePath;
end;

function TSWAGInstaller.Execute: Boolean;
begin
  try
    UnZipFileToTempDir;
    RemoveExistingData;
    CopySwagDirToProgDir;
    TidyTempFiles;
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      RemoveExistingData;
    end;
  end;
end;

class function TSWAGInstaller.IsInstalled: Boolean;
begin
  Result := TDirectory.Exists(SWAGDataDir)
    and TFile.Exists(
      TPath.Combine(SWAGDataDir, TSWAGVersion.SWAGVersionFileName)
    );
end;

procedure TSWAGInstaller.RemoveExistingData;
begin
  RemoveInstallation;
end;

class procedure TSWAGInstaller.RemoveInstallation;
begin
  if TDirectory.Exists(SWAGDataDir) then
    TDirectory.Delete(SWAGDataDir, True);
end;

class function TSWAGInstaller.SWAGDataDir: string;
begin
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), SWAGSubDir);
end;

function TSWAGInstaller.TempDirPath: string;
begin
  if fTempDirPath.IsEmpty then
  begin
    fTempDirPath := TPath.Combine(
      TPath.GetTempPath,
      TempSubDirStub + TGUID.NewGuid.ToString.Trim(['{','}'])
    );
    TDirectory.CreateDirectory(fTempDirPath);
  end;
  Result := fTempDirPath;
end;

procedure TSWAGInstaller.TidyTempFiles;
begin
  if TDirectory.Exists(TempDirPath) then
    TDirectory.Delete(TempDirPath, True);
end;

procedure TSWAGInstaller.UnZipFileToTempDir;
begin
  var Zip := TZipFile.Create;
  try
    Zip.ExtractZipFile(fZipFilePath, TempDirPath);
  finally
    Zip.Free;
  end;
end;

end.

