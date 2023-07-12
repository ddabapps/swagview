{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2020-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Derived from Src/SWAG.UVersion.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Defines an advanced record that reads and validates the SWAG collection's
 * version information from file.
}

unit SWAGView.SWAG.Version;

interface

uses
  System.SysUtils,
  SWAGView.VersionInfo;

type
  ///  <summary>Advanced record that reads and validates the SWAG collection's
  ///  VERSION file.</summary>
  TSWAGVersion = record
  strict private

    ///  <summary>Reads and returns the version string from the version file.
    ///  </summary>
    class function ReadVersionStr(const SWAGFilePath: string): string;
      static;

    ///  <summary>Reads, parses and validates version information from file.
    ///  </summary>
    ///  <returns><c>TVersionNumber</c>. Structure containing version
    ///  information.</returns>
    ///  <exception><c>ESWAGVersion</c> raised if version information in file
    ///  is corrupt, missing, or if the file is missing, or if the version
    ///  information read represents an unsupported format.</exception>
    class function ReadAndValidateVersionFile(const SWAGFilePath: string):
      TVersionNumber; static;

    ///  <summary>Returns the full path to the SWAG version file.</summary>
    class function VersionFileName(ASWAGPath: string): string; static;

  public
    const
      ///  <summary>SWAG version file name, without path.</summary>
      SWAGVersionFileName = 'VERSION';
      ///  <summary>First supported SWAG version.</summary>
      LowestSupportedVersion: TVersionNumber = (V1: 1; V2: 0; V3: 0; V4: 0);
      ///  <summary>Lowest SWAG version that is NOT supported.</summary>
      LowestUnSupportedVersion: TVersionNumber = (V1: 1; V2: 1; V3: 0; V4: 0);

    ///  <summary>Validates the version file. Returns normally if there are no
    ///  errors or raises an exception if an error is found.</summary>
    ///  <param name="SWAGDir">[in] Directory where version file should be
    ///  located.</param>
    ///  <exception><c>ESWAGVersion</c> raised if version information in file
    ///  is corrupt, missing, or if the file is missing, or if the version
    ///  information read represents an unsupported format.</exception>
    class procedure ValidateVersionFile(const SWAGDir: string); static;

    ///  <summary>Gets SWAG version from file.</summary>
    ///  <param name="SWAGDir">[in] Directory where version file should be
    ///  located.</param>
    ///  <returns><c>TVersionNumber</c>. Structure containing version
    ///  information.</returns>
    ///  <exception><c>ESWAGVersion</c> raised if version information in file
    ///  is corrupt, missing, or if the file is missing, or if the version
    ///  information read represents an unsupported format.</exception>
   class function GetVersion(const SWAGDir: string): TVersionNumber; static;
  end;

  ///  <summary>Class of exceptions by <c>TSWAGVersion</c> validation methods.
  ///  </summary>
  ESWAGVersion = class(Exception);

implementation

uses
  System.IOUtils,
  SWAGView.Utils.IO;

{ TSWAGVersion }

class function TSWAGVersion.GetVersion(const SWAGDir: string):
  TVersionNumber;
begin
  Result := ReadAndValidateVersionFile(VersionFileName(SWAGDIR));
end;

class function TSWAGVersion.ReadAndValidateVersionFile(
  const SWAGFilePath: string): TVersionNumber;
resourcestring
  sMissingOrEmptyFile = 'Missing or empty %s file';
  sCorruptFile = 'Corrupt %s file';
  sOutOfRange = 'SWAG version %0:s is not supported. '
    + 'The version must be at least v%1:s and less than v%2:s';
begin
  var VerStr := ReadVersionStr(SWAGFilePath);
  if VerStr.IsEmpty then
    raise ESWAGVersion.CreateFmt(
      sMissingOrEmptyFile, [SWAGVersionFileName]
    );
  if not TVersionNumber.TryStrToVersionNumber(VerStr, Result) then
    raise ESWAGVersion.CreateFmt(sCorruptFile, [SWAGVersionFileName]);
  if (Result < LowestSupportedVersion)
    or (Result >= LowestUnSupportedVersion) then
    raise ESWAGVersion.CreateFmt(
      sOutOfRange,
      [
        Result.ToString,
        LowestSupportedVersion.ToString,
        LowestUnSupportedVersion.ToString
      ]
    );
end;

class function TSWAGVersion.ReadVersionStr(const SWAGFilePath: string):
  string;
begin
  if not TFile.Exists(SWAGFilePath) then
    Exit(string.Empty);
  Result := TFileIO.ReadAllText(SWAGFilePath, TEncoding.UTF8, False);
end;

class procedure TSWAGVersion.ValidateVersionFile(const SWAGDir: string);
begin
  ReadAndValidateVersionFile(VersionFileName(SWAGDir));
end;

class function TSWAGVersion.VersionFileName(ASWAGPath: string): string;
begin
  Result := TPath.Combine(ASWAGPath, SWAGVersionFileName);
end;

end.

