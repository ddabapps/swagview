{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Based on code extracted from Src/UIOUTils.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Provides methods for assisting with common file operations.
}


unit SWAGView.Utils.IO;

interface

uses
  System.SysUtils,
  System.Classes;

type
  ///  <summary>Container for methods that assist with common file reading
  ///  operations.</summary>
  ///  <remarks><c>TFileIO</c> is used instead of <c>IOUtils.TFile</c> because
  ///  the assumptions <c>TFile</c> makes about the use of byte order marks with
  ///  encoded text files are not compatible with the needs of this program.
  ///  </remarks>
  TFileIO = record
  strict private

    ///  <summary>Copies content of a whole stream into a byte array.</summary>
    class function StreamToBytes(const Stream: TStream): TBytes; static;

    ///  <summary>Checks if given byte array begins with the BOM of the given
    ///  encoding.</summary>
    ///  <remarks>
    ///  <para>If the given encoding does not have a BOM then <c>False</c> is
    ///  returned.</para>
    ///  <para>If the byte array has fewer bytes than the required BOM then
    ///  <c>False</c> is returned.</para>
    ///  </remarks>
    class function CheckBOM(const Bytes: TBytes; const Encoding: TEncoding):
      Boolean; overload; static;

  public
    ///  <summary>Reads all bytes from a file into a byte array.</summary>
    ///  <param name="FileName">[in] Name of file.</param>
    ///  <returns><c>TBytes</c>. Array containing the file's contents.</returns>
    class function ReadAllBytes(const FileName: string): TBytes; static;

    ///  <summary>Reads all the text from a text file.</summary>
    ///  <param name="FileName">[in] Name of file.</param>
    ///  <param name="Encoding">[in] Text encoding used by file.</param>
    ///  <param name="HasBOM">[in] Flag indicating if file has a byte order
    ///  mark. Ignored if <c>Encoding</c> has no BOM.</param>
    ///  <returns><c>string</c> containing contents of file.</returns>
    ///  <exception><c>EFileIO</c> raised if file preamble does not match
    ///  expected encoding.</exception>
    ///  <remarks>When <c>HasBOM</c> is true and <c>Encoding</c> has a BOM then
    ///  the BOM must begin the file, otherwise an exception is raised.
    ///  </remarks>
    class function ReadAllText(const FileName: string;
      const Encoding: TEncoding; const HasBOM: Boolean = False): string; static;

  end;

type
  ///  <summary>Class of exception raised by <c>TFileIO</c> methods.</summary>
  EFileIO = class(Exception);

implementation

resourcestring
  // Error messages
  sBadBOM = 'Preamble of file %s does not match expected encoding';

{ TFileIO }

class function TFileIO.CheckBOM(const Bytes: TBytes; const Encoding: TEncoding):
  Boolean;
begin
  Assert(Assigned(Encoding), 'TFileIO.CheckBOM: Encoding is nil');
  var Preamble := Encoding.GetPreamble;
  Result := True;
  if Length(Preamble) = 0 then
    Exit(False);
  if Length(Bytes) < Length(Preamble) then
    Exit(False);
  for var I := 0 to Pred(Length(Preamble)) do
    if Bytes[I] <> Preamble[I] then
      Exit(False);
end;

class function TFileIO.ReadAllBytes(const FileName: string): TBytes;
begin
  var FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := StreamToBytes(FS);
  finally
    FS.Free;
  end;
end;

class function TFileIO.ReadAllText(const FileName: string;
  const Encoding: TEncoding; const HasBOM: Boolean): string;
begin
  Assert(Assigned(Encoding), 'TFileIO.ReadAllBytes: Encoding is nil');
  var Content := ReadAllBytes(FileName);
  var SizeOfBOM: Integer := 0;
  if HasBOM then
  begin
    SizeOfBOM := Length(Encoding.GetPreamble);
    if (SizeOfBOM > 0) and not CheckBOM(Content, Encoding) then
      raise EFileIO.CreateFmt(sBadBOM, [FileName]);
  end;
  Result := Encoding.GetString(Content, SizeOfBOM, Length(Content) - SizeOfBOM);
end;

class function TFileIO.StreamToBytes(const Stream: TStream): TBytes;
begin
  Stream.Position := 0;
  SetLength(Result, Stream.Size);
  if Stream.Size > 0 then
    Stream.ReadBuffer(Result[0], Length(Result));
end;

end.

