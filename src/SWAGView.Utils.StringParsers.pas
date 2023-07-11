{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Based on code extracted from Src/UUtils.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Copyright (C) 2005-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Routines that can parse data in various formats from string representations
 * of the data.
}

unit SWAGView.Utils.StringParsers;

interface

///  <summary>Attempts to convert a date-time value in SQL format into a
///  <c>TDateTime</c> value.</summary>
///  <param name="SQLDateTime">[in] SQL format date-time value to be converted.
///  </param>
///  <param name="Value">[out] Set to converted date-time value if conversion
///  succeeded or undefined if conversion failed.</param>
///  <returns><c>True</c> if conversion succeeds, <c>False</c> if not.</returns>
function TryParseSQLDateTime(const SQLDateTime: string; out Value: TDateTime):
  Boolean;

///  <summary>Attempts to convert string <c>S</c> into a <c>Cardinal</c> value.
///  </summary>
///  <param name="S">[in] String to be converted.</param>
///  <param name="Value">[out] Value of converted string. Undefined if
///  conversion fails.</param>
///  <returns><c>True</c> if conversion succeeds, <c>False</c> if not.</returns>
///  <remarks><c>S</c> must represent a non-negative integer that is
///  representable as a <c>Cardinal</c>.</remarks>
function TryStrToCardinal(const S: string; out Value: Cardinal): Boolean;

///  <summary>Attempts to convert string <c>S</c> into a <c>Word</c> value.
///  </summary>
///  <param name="S">[in] String to be converted.</param>
///  <param name="W">[out] Value of converted string. Undefined if conversion
///  fails.</param>
///  <returns><c>True</c> if conversion succeeds, <c>False</c> if not.</returns>
///  <remarks><c>S</c> must represent a non-negative integer that is
///  representable as a <c>Word</c>.</remarks>
function TryStrToWord(const S: string; out Value: Word): Boolean;

implementation

uses
  // Delphi
  System.SysUtils,
  System.DateUtils;

function TryParseSQLDateTime(const SQLDateTime: string; out Value: TDateTime):
  Boolean;
begin
  var Year, Month, Day, Hour, Min, Sec: Word;
  if not TryStrToWord(Copy(SQLDateTime, 1, 4), Year) then
    Exit(False);
  if not TryStrToWord(Copy(SQLDateTime, 6, 2), Month) then
    Exit(False);
  if not TryStrToWord(Copy(SQLDateTime, 9, 2), Day) then
    Exit(False);
  if not TryStrToWord(Copy(SQLDateTime, 12, 2), Hour) then
    Exit(False);
  if not TryStrToWord(Copy(SQLDateTime, 15, 2), Min) then
    Exit(False);
  if not TryStrToWord(Copy(SQLDateTime, 18, 2), Sec) then
    Exit(False);
  Result := TryEncodeDateTime(Year, Month, Day, Hour, Min, Sec, 0, Value);
end;

function TryStrToCardinal(const S: string; out Value: Cardinal): Boolean;
begin
  var Value64: Int64;
  Result := TryStrToInt64(S, Value64) and (Int64Rec(Value64).Hi = 0);
  if Result then
    Value := Int64Rec(Value64).Lo;
end;

function TryStrToWord(const S: string; out Value: Word): Boolean;
begin
  var Value32: Integer;
  if not TryStrToInt(S, Value32) then
    Exit(False);
  if (Value32 < 0) or (Value32 > High(Word)) then
    Exit(False);
  Value := Word(Value32);
  Result := True;
end;

end.

