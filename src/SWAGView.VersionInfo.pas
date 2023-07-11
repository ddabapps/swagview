{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements a class used to extract version information from the program's
 * resources, along with an advanced record used to manipulate version numbers.
}


unit SWAGView.VersionInfo;

interface

type

  {
  TVersionNumber:
    Record representing the four fields of a version number.
  }
  TVersionNumber = record
  strict private
    ///  <summary>Compares two version numbers, <c>Left</c> and <c>Right</c> and
    ///  returns -ve if <c>Left</c> &lt; <c>Right</c>, +ve if <c>Left</c> &gt;
    ///  <c>Right</c> or 0 if <c>Left</c> = <c>Right</c>.</summary>
    class function CompareVerNums(const Left, Right: TVersionNumber): Integer;
      static;
  public
    var
      V1: Word;   // Major version number
      V2: Word;   // Minor version number
      V3: Word;   // Revision version number
      V4: Word;   // Build number
    ///  <summary>Attempts to convert a string to a version number.</summary>
    ///  <param name="S">[in] String to convert.</param>
    ///  <param name="V">[out] Converted version number.</param>
    ///  <returns><c>True</c> if conversion succeeded, <c>False</c> otherwise.
    ///  </returns>
    ///  <remarks>String must represent a dotted quad of non-negative integers,
    ///  separated by dots, where each integer must be representable as a
    ///  <c>Word</c>.</remarks>
    class function TryStrToVersionNumber(const S: string;
      out V: TVersionNumber): Boolean; static;

    ///  <summary>Converts version number to a string.</summary>
    function ToString: string;

    // Comparison operator overloads
    class operator LessThanOrEqual(Left, Right: TVersionNumber): Boolean;
    class operator LessThan(Left, Right: TVersionNumber): Boolean;
    class operator GreaterThan(Left, Right: TVersionNumber): Boolean;
    class operator GreaterThanOrEqual(Left, Right: TVersionNumber): Boolean;
    class operator Equal(Left, Right: TVersionNumber): Boolean;
    class operator NotEqual(Left, Right: TVersionNumber): Boolean;

  end;

  ///  <summary>Extracts version information from version information resources.
  ///  </summary>
  TVersionInfo = record
  private
    ///  <summary>Gets the named string information value from string table.
    ///  </summary>
    ///  <remarks>Required that a string table with translation ID
    ///  <c>080904E4</c> exists in the version information resource.</remarks>
    class function GetStringFileInfo(const AName: string): string; static;
  public
    ///  <summary>Gets 'ProductVersion' string information value from string
    ///  table.</summary>
    class function ProductVersionStr: string; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  SWAGView.Utils.StringParsers;

{ TVersionInfo }

class function TVersionInfo.GetStringFileInfo(const AName: string): string;
const
  // Sub-block identifying copyright info
  SubBlockFmt = '\StringFileInfo\080904E4\%s';
begin
  Result := '';
  // get size of version info
  var Dummy: Cardinal;
  var VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize <= 0 then
    Exit;
  // create buffer and read version info into it
  var VerInfoBuf: Pointer;
  GetMem(VerInfoBuf, VerInfoSize);
  try
    var SubBlock := Format(SubBlockFmt, [AName]);
    if not GetFileVersionInfo(
      PChar(ParamStr(0)), 0, VerInfoSize, VerInfoBuf
    ) then Exit;
    var ResultPtr: Pointer;
    var ResultLen: Cardinal;
    if not VerQueryValue(VerInfoBuf, PChar(SubBlock), ResultPtr, ResultLen) then
      Exit;
    Result := PChar(ResultPtr);
  finally
    FreeMem(VerInfoBuf);
  end;
end;

class function TVersionInfo.ProductVersionStr: string;
  {Gets product version string from string table. May differ from
  ProductVersionNumberStr.
    @return Product version string.
  }
begin
  Result := GetStringFileInfo('ProductVersion');
end;

{ TVersionNumber }

class function TVersionNumber.CompareVerNums(const Left, Right: TVersionNumber):
  Integer;
begin
  Result := Left.V1 - Right.V1;
  if Result <> 0 then
    Exit;
  Result := Left.V2 - Right.V2;
  if Result <> 0 then
    Exit;
  Result := Left.V3 - Right.V3;
  if Result <> 0 then
    Exit;
  Result := Left.V4 - Right.V4;
end;

class operator TVersionNumber.Equal(Left, Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) = 0;
end;

class operator TVersionNumber.GreaterThan(Left, Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) > 0;
end;

class operator TVersionNumber.GreaterThanOrEqual(Left,
  Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) >= 0;
end;

class operator TVersionNumber.LessThan(Left, Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) < 0;
end;

class operator TVersionNumber.LessThanOrEqual(Left,
  Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) <= 0;
end;

class operator TVersionNumber.NotEqual(Left, Right: TVersionNumber): Boolean;
begin
  Result := CompareVerNums(Left, Right) <> 0;
end;

function TVersionNumber.ToString: string;
begin
  Result := Format('%d.%d.%d.%d', [V1, V2, V3, V4]);
end;

class function TVersionNumber.TryStrToVersionNumber(const S: string;
  out V: TVersionNumber): Boolean;
begin
  var Parts := TStringList.Create;
  try
    Parts.AddStrings(S.Split(['.'], TStringSplitOptions.None));
    // trim spaces from Parts and delete any empty elements after trimming
    for var I := Pred(Parts.Count) downto 0 do
    begin
      Parts[I] := Parts[I].Trim;
      if Parts[I].IsEmpty then
        Parts.Delete(I);
    end;
    // pad Parts out to 4 elements by adding 0 entries
    while Parts.Count < 4 do
      Parts.Add('0');
    // convert all parts to integers if possible
    if not TryStrToWord(Parts[0], V.V1) then
      Exit(False);
    if not TryStrToWord(Parts[1], V.V2) then
      Exit(False);
    if not TryStrToWord(Parts[2], V.V3) then
      Exit(False);
    if not TryStrToWord(Parts[3], V.V4) then
      Exit(False);
    Result := True;
  finally
    Parts.Free;
  end;
end;

end.

