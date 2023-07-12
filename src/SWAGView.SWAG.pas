{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Defines a class that provides top level, cached, access to the SWAG database.
}


unit SWAGView.SWAG;

interface

uses
  System.Generics.Collections,
  SWAGView.SWAG.Types,
  SWAGView.SWAG.Reader;

type

  ///  <summary>Class that provides top level access to the SWAG database.
  ///  </summary>
  ///  <remarks>The class delays loading of data until it is requested. Once
  ///  loaded the data is cached so that subsequent accesses to the same data is
  ///  much quicker.</remarks>
  TSWAG = class
  strict private
    var
      ///  <summary>Intermediate object used to read from database.</summary>
      fReader: TSWAGReader;
      ///  <summary>Cached list of all categories in database.</summary>
      ///  <remarks>List is fully populated in full the first time the
      ///  <c>AllCategories</c> method is called.</remarks>
      fCategories: TList<TSWAGCategory>;
      ///  <summary>Dictionary cache mapping category IDs to a list of packets
      ///  that belong to the category.</summary>
      ///  <remarks>Dictionary caches the all partial packets belonging to a
      ///  given category the first time the <c>PartialPackets</c> is called for
      ///  that category.</remarks>
      fPartialPackets: TObjectDictionary<Cardinal,TList<TSWAGPacket>>;
      ///  <summary>Dictionary cache that maps a packet ID to the packet
      ///  content.</summary>
      ///  <remarks>Each packet is cached in the dictionary the first time the
      ///  <c>Packet</c> method is called for that packet.</remarks>
      fPackets: TDictionary<Cardinal,TSWAGPacket>;

  public
    ///  <summary>Object constructor. Sets up object for accessing a given SWAG
    ///  database.</summary>
    ///  <param name="SWAGDBDir">[in] Directory containing the SWAG database.
    ///  </param>
    constructor Create(const SWAGDBDir: string);

    ///  <summary>Object destructor.</summary>
    destructor Destroy; override;

    ///  <summary>Returns a list of all the categories in the database.
    ///  </summary>
    ///  <returns><c>TList&lt;TSWAGCategory&gt;</c>. Required list.</returns>
    ///  <remarks>The list is cached and is managed by this object. Callers must
    ///  not free the list.</remarks>
    function AllCategories: TList<TSWAGCategory>;

    ///  <summary>Returns a list of partial (i.e. summary) packets that belong
    ///  to a given category.</summary>
    ///  <param name="ACatID">[in] ID of category containing required packets.
    ///  </param>
    ///  <returns><c>TList&lt;TSWAGPacket&gt;</c>. List of partial packets
    ///  belonging to given category.</returns>
    ///  <remarks>The list is cached and is managed by this object. Callers must
    ///  not free the list.</remarks>
    function PartialPackets(const ACatID: Cardinal): TList<TSWAGPacket>;

    ///  <summary>Returns the packet with the given packet ID.</summary>
    ///  <param name="APacketID">[in] ID of required packet.</param>
    ///  <returns><c>TSWAGPacket</c>. Full details of required packet.</returns>
    function Packet(const APacketID: Cardinal): TSWAGPacket;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Defaults;

{ TSWAG }

function TSWAG.AllCategories: TList<TSWAGCategory>;
begin
  if fCategories.Count = 0 then
  begin
    fReader.GetCategories(fCategories);
    fCategories.Sort;
  end;
  Result := fCategories;
end;

constructor TSWAG.Create(const SWAGDBDir: string);
begin
  inherited Create;
  fCategories := TList<TSWAGCategory>.Create(
    TDelegatedComparer<TSWAGCategory>.Create(
      function (const Left, Right: TSWAGCategory): Integer
      begin
        Result := string.Compare(Left.Title, Right.Title);
      end
    )
  );
  fPartialPackets := TObjectDictionary<Cardinal,TList<TSWAGPacket>>.Create(
    [doOwnsValues]
  );
  fPackets := TDictionary<Cardinal,TSWAGPacket>.Create;
  fReader := TSWAGReader.Create(SWAGDBDir);
end;

destructor TSWAG.Destroy;
begin
  fReader.Free;
  fPackets.Free;
  fPartialPackets.Free;
  fCategories.Free;
  inherited;
end;

function TSWAG.Packet(const APacketID: Cardinal): TSWAGPacket;
begin
  if not fPackets.TryGetValue(APacketID, Result) then
  begin
    Result := fReader.GetCompletePacket(APacketID);
    fPackets.Add(APacketID, Result);
  end;
end;

function TSWAG.PartialPackets(const ACatID: Cardinal): TList<TSWAGPacket>;
begin
  if not fPartialPackets.TryGetValue(ACatID, Result) then
  begin
    Result := TList<TSWAGPacket>.Create(
      TDelegatedComparer<TSWAGPacket>.Create(
        function (const Left, Right: TSWAGPacket): Integer
        begin
          Result := string.Compare(Left.Title, Right.Title, [coIgnoreCase]);
          if (Result = 0) and (Left.ID <> Right.ID) then
            Result := Integer(Left.ID) - Integer(Right.ID);
        end
      )
    );
    fReader.GetPartialPackets(ACatID, Result);
    Result.Sort;
    fPartialPackets.Add(ACatID, Result);
  end;
end;

end.

