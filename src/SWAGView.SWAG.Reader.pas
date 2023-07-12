{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2013-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Based on code extracted from Src/SWAG.UReader.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Implements a class that reads specified information from the SWAG database.
}


unit SWAGView.SWAG.Reader;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  SWAGView.SWAG.Types,
  SWAGView.SWAG.XMLProcessor;

type
  ///  <summary>Class that reads specified information from the SWAG database.
  ///  </summary>
  ///  <remarks>All accesses to the database are indirected via this class to
  ///  decouple the interface in <c>TSWAG</c> from the back end implementation.
  ///  </remarks>
  TSWAGReader = class
  strict private
    var
      ///  <summary>Object used to interogate SWAG XML file.</summary>
      fXMLProcessor: TSWAGXMLProcessor;

    ///  <summary>Handles exception <c>E</c> by converting expected exceptions
    ///  into <c>ESWAGReader</c> exceptions and re-raising unexpected
    ///  exceptions.</summary>
    ///  <exception>Always raises an exception of either original type if
    ///  <c>E</c> is an unexpected type or <c>ESWAGReader</c> if <c>E</c> is an
    ///  expected type.</exception>
    procedure HandleException(E: Exception);

  public
    ///  <summary>Creates a new object instance.</summary>
    ///  <param name="SWAGDBDir">[in] Directory where SWAG database is located
    ///  on the local system.</param>
    constructor Create(const SWAGDBDir: string);

    ///  <summary>Destroys object instance.</summary>
    destructor Destroy; override;

    ///  <summary>Gets a list of all the categories in the SWAG database.
    ///  </summary>
    ///  <param name="Cats">[in] Receives the required list of categories.
    ///  </param>
    procedure GetCategories(const Cats: TList<TSWAGCategory>);

    ///  <summary>Gets summaries of all the packets contained in a given SWAG
    ///  category.</summary>
    ///  <param name="CatID">[in] ID of the required category.</param>
    ///  <param name="Packets">[in] Receives the required list of packet
    ///  summaries.</param>
    procedure GetPartialPackets(const CatID: Cardinal;
      const Packets: TList<TSWAGPacket>);

    ///  <summary>Gets full details a packet from the SWAG database.</summary>
    ///  <param name="ID">[in] Unique ID of the required packet.</param>
    function GetCompletePacket(const ID: Cardinal): TSWAGPacket;
  end;

type
  ///  <summary>Class of exception raised by <c>TSWAGReader</c>.</summary>
  ESWAGReader = class(Exception);

implementation

uses
  System.Generics.Defaults,
  Xml.XMLDom,
  Xml.XMLIntf;

{ TSWAGReader }

constructor TSWAGReader.Create(const SWAGDBDir: string);
begin
  inherited Create;
  fXMLProcessor := TSWAGXMLProcessor.Create;
  fXMLProcessor.Initialise(SWAGDBDir);
end;

destructor TSWAGReader.Destroy;
begin
  fXMLProcessor.Free;
  inherited;
end;

procedure TSWAGReader.GetCategories(const Cats: TList<TSWAGCategory>);
begin
  Cats.Clear;
  try
    fXMLProcessor.GetCategories(Cats);
  except
    on E: Exception do
      HandleException(E);
  end;
end;

function TSWAGReader.GetCompletePacket(const ID: Cardinal): TSWAGPacket;
begin
  try
    Result := fXMLProcessor.GetPacket(ID);
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TSWAGReader.GetPartialPackets(const CatID: Cardinal;
  const Packets: TList<TSWAGPacket>);
begin
  try
    fXMLProcessor.GetPartialPackets(CatID, Packets);
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TSWAGReader.HandleException(E: Exception);
begin
  if E is EXMLDocError then
    raise ESWAGReader.Create(E.Message);
  if E is EDOMParseError then
    raise ESWAGReader.Create(E.Message);
  raise E;
end;

end.

