{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2013-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Code based on Src/SWAG.UCommon.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Defines records that encapsulate SWAG database categories and packets.
}

unit SWAGView.SWAG.Types;

interface

type

  ///  <summary>Record that encapsulates the data of a SWAG category.</summary>
  TSWAGCategory = record
    ///  <summary>Number that uniquely identifies a SWAG category.</summary>
    ID: Cardinal;
    ///  <summary>SWAG category title.</summary>
    Title: string;
  end;

  // TODO: Create a separate record to use for partial (summary) packets

  ///  <summary>Record that encapsulates the data that defines a SWAG packet
  ///  </summary>
  TSWAGPacket = record
    strict private
      const NullMarker = High(Cardinal);
    public
      ///  <summary>Number that uniquely identifies a SWAG packet.</summary>
      ID: Cardinal;
      ///  <summary>ID of SWAG category that packet belongs to.</summary>
      Category: Cardinal;
      ///  <summary>File name of packet in original SWAG archive.</summary>
      FileName: string;
      ///  <summary>Date and time packet was added to or updated in the SWAG
      ///  archive.</summary>
      DateStamp: TDateTime;
      ///  <summary>SWAG packet title.</summary>
      Title: string;
      ///  <summary>Name(s) of author(s) of SWAG packet.</summary>
      Author: string;
      ///  <summary>Source code of SWAG packet.</summary>
      ///  <remarks>Strictly speaking this is the text of the packet since not
      ///  all packets are pure source code - some are text documents.</remarks>
      SourceCode: string;
      ///  <summary>Flag that indicates if SWAG packet is a text document
      ///  (<c>True</c>) or is Pascal source code (<c>False</c>).</summary>
      IsDocument: Boolean;
      ///  <summary>Record initialiser: flags record as null.</summary>
      class operator Initialize(out Dest: TSWAGPacket);
      ///  <summary>Checks if record is null.</summary>
      function IsNull: Boolean;
      ///  <summary>Returns date and time packey was added or updated in
      ///  original SWAG archive, formatted as a valid date/time value in the
      ///  current locale.</summary>
      function DateStampAsString: string;
  end;

implementation

uses
  System.SysUtils;

{ TSWAGPacket }

function TSWAGPacket.DateStampAsString: string;
const
  ShortDateFmtStr = 'ddddd';
begin
  Result := FormatDateTime(
    ShortDateFmtStr, DateStamp, TFormatSettings.Create
  );
end;

class operator TSWAGPacket.Initialize(out Dest: TSWAGPacket);
begin
  Dest.ID := NullMarker;
end;

function TSWAGPacket.IsNull: Boolean;
begin
  Result := ID = NullMarker;
end;

end.

