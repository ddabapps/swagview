{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2020-2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Based on code extracted from Src/SWAG.UXMLProcessor.pas copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Defines a class that reads and parses the XML and source code files inluded
 * in a local copy of the DelphiDabbler version of the SWAG database.
}


unit SWAGView.SWAG.XMLProcessor;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Xml.XMLIntf,
  SWAGView.SWAG.Types,
  SWAGView.XMLDocumentEx;

type

  ///  <summary>Class that reads and parses the XML and source code files
  ///  inluded in a local copy of the DelphiDabbler version of the SWAG database
  ///  and retrieves packet and category information.</summary>
  ///  <remarks>The database meta data is stored in the XML file and source code
  ///  is stored in text files.</remarks>
  TSWAGXMLProcessor = class(TObject)
  strict private
    const
      // Name of SWAG XML file
      cSWAGXMLFile = 'swag.xml';
      // Supported DelphiDabbler SWAG versions on GitHub
      cSupportedSWAGVersion   = 1;
      // XML nodes and attributes used in DelphiDabbler master SWAG file on
      // GitHub
      cSWAGRootNode           = 'swag';
      cRootVersionAttr        = 'version';
      cCategoriesNode         = 'categories';
      cCategoryNode           = 'category';
      cCategoryIDAttr         = 'id';
      cCategoryTitleNode      = 'title';
      cPacketsNode            = 'packets';
      cPacketNode             = 'packet';
      cPacketIDAttr           = 'id';
      cPacketCatIdNode        = 'category-id';
      cPacketFileNameNode     = 'file-name';
      cPacketDateNode         = 'date';
      cPacketAuthorNode       = 'author';
      cPacketIsDocumentNode   = 'is-document';
      cPacketTitleNode        = 'title';
      // End of file marker
      EOF = #26;
    var
      ///  <summary>Object used to access and search SWAG XML meta data file.
      ///  </summary>
      fXMLDoc: IXMLDocumentEx;
      ///  <summary>Directory storing downloaded SWAG files.</summary>
      fSWAGRootDir: string;

    ///  <summary>Converts an array of tags into a path suitable for use with
    ///  <c>IXMLDocumentEx.FindNode</c>.</summary>
    class function NodePath(const Tags: array of string): string;

    ///  <summary>Validates XML document as a valid DelphiDabbler SWAG XML
    ///  document.</summary>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if document fails
    ///  validation.</exception>
    procedure ValidateXMLDoc;

    ///  <summary>Validates fields of given packet record as read from XML and
    ///  source code files.</summary>
    ///  <param name="Packet">[in] Packet record to be validated.</param>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if packet fails validation.
    ///  </exception>
    procedure ValidatePacket(const Packet: TSWAGPacket);

    ///  <summary>Validates fields of given partial packet record as read from
    ///  XML.</summary>
    ///  <param name="Packet">[in] Packet record to be validated.</param>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if packet fails validation.
    ///  </exception>
    procedure ValidatePartialPacket(const Packet: TSWAGPacket);

    ///  <summary>Gets source code for a packet from file and stores it in the
    ///  packet record.</summary>
    ///  <param name="Packet">[in/out] Packet for which source code is required.
    ///  Packet is updated with required source code.</param>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if packet source code
    ///  can&#39;t be loaded.</exception>
    procedure GetPacketSourceCode(var Packet: TSWAGPacket);

    ///  <summary>Read and validate a positive integer value from a node
    ///  attribute</summary>
    ///  <param name="Node">[in] Node whose attribute is to be read.</param>
    ///  <param name="Attr">[in] Name of attribute.</param>
    ///  <param name="ErrMsg">[in] Exception error messsage to be used on error.
    ///  </param>
    ///  <returns>Required postive integer value.</returns>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if attribute value is
    ///  missing or is not a positive integer.</exception>
    function GetPositiveIntAttribute(Node: IXMLNode; const Attr: string;
      const ErrMsg: string): Cardinal;

  public
    ///  <summary>Constructor that sets up object ready to to process XML.
    ///  </summary>
    constructor Create;

    ///  <summary>Tears down object.</summary>
    destructor Destroy; override;

    ///  <summary>Initialises processor to read database data from the given
    ///  directory.</summary>
    ///  <remarks>Must be called before any other methods.</remarks>
    procedure Initialise(const SWAGDirName: string);

    ///  <summary>Gets a list of all categories from the SWAG XML file.
    ///  </summary>
    ///  <param name="CatList">[in] Receives required list of categories.
    ///  </param>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if categories can't be read
    ///  or are invalid.</exception>
    procedure GetCategories(CatList: TList<TSWAGCategory>);

    ///  <summary>Gets partial information about all packets belonging to a
    ///  category from the SWAG XML file.</summary>
    ///  <param name="CatID">[in] ID of category for which packets are required.
    ///  </param>
    ///  <param name="PacketList">[in] Receives list of packets read.</param>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if partial packets can't be
    ///  read or are invalid.</exception>
    procedure GetPartialPackets(const CatID: Cardinal;
      PacketList: TList<TSWAGPacket>);

    ///  <summary>Gets a single packet from the SWAG XML file.</summary>
    ///  <param name="PacketID">[in] Unique ID of the required packet.</param>
    ///  <returns><c>TSWAGPacket</c>. Details of the required packet.</returns>
    ///  <exception><c>ESWAGXMLProcessor</c> raised if packet can't be read or
    ///  is invalid.</exception>
    function GetPacket(const PacketID: Cardinal): TSWAGPacket;
  end;

  ///  <summary>Class of exception raised when expected errors are found in
  ///  methods of <c>TSWAGXMLProcessor</c>.</summary>
  ESWAGXMLProcessor = class(Exception);

implementation

uses
  System.Classes,
  System.DateUtils,
  System.IOUtils,
  Winapi.ActiveX,
  SWAGView.Utils.StringParsers,
  SWAGView.Utils.IO;

{ TSWAGXMLProcessor }

constructor TSWAGXMLProcessor.Create;
begin
  inherited Create;
  OleInitialize(nil);
end;

destructor TSWAGXMLProcessor.Destroy;
begin
  if Assigned(fXMLDoc) then
    fXMLDoc.Active := False;
  fXMLDoc := nil;
  OleUninitialize;
  inherited;
end;

procedure TSWAGXMLProcessor.GetCategories(CatList: TList<TSWAGCategory>);
resourcestring
  sMissingNode = 'Invalid SWAG XML file: no categories information found';
  sMissingID = 'Invalid SWAG XML file: missing category ID';
  sMissingTitle = 'Invalid SWAG XML file: missing title for category "%s"';
  sBadSourceID = 'Invalid SWAG XML file: invalid or missing category ID';
begin
  var CategoriesNode := fXMLDoc.FindNode(
    NodePath([cSWAGRootNode, cCategoriesNode])
  );
  if not Assigned(CategoriesNode) then
    raise ESWAGXMLProcessor.CreateFmt(sMissingNode, [cCategoriesNode]);
  var CategoryNodes := fXMLDoc.FindChildElementsByName(
    CategoriesNode, cCategoryNode
  );
  for var CategoryNode in CategoryNodes do
  begin
    var Category: TSWAGCategory;
    Category.ID := GetPositiveIntAttribute(
      CategoryNode, cCategoryIDAttr, sBadSourceID
    );
    Category.Title := fXMLDoc.GetChildNodeText(
      CategoryNode, cCategoryTitleNode
    );
    if Category.Title.Trim.IsEmpty then
      raise ESWAGXMLProcessor.CreateFmt(sMissingTitle, [Category.ID]);
    CatList.Add(Category);
  end;
end;

function TSWAGXMLProcessor.GetPacket(const PacketID: Cardinal): TSWAGPacket;
resourcestring
  sPacketsNodeMissing = 'Invalid SWAG XML file: no packet information found';
  sPacketNotFound = 'Invalid SWAG XML file: packet with ID %d not found';
  sBadPacketCategory = 'Invalid SWAG XML file: packet has invalid or missing '
    + 'category ID';
begin
  // Find required Packet node
  var AllPacketsNode := fXMLDoc.FindNode(
    NodePath([cSWAGRootNode, cPacketsNode])
  );
  if not Assigned(AllPacketsNode) then
    raise ESWAGXMLProcessor.Create(sPacketsNodeMissing);
  var PacketNode := fXMLDoc.FindFirstChildNodeByNameAndAttr(
    AllPacketsNode, cPacketNode, cPacketIDAttr, PacketID
  );
  if not Assigned(PacketNode) then
    raise ESWAGXMLProcessor.CreateFmt(sPacketNotFound, [PacketID]);
  // Get Packet info from Packet node
  Result.ID := PacketID;
  if not TryStrToCardinal(
    fXMLDoc.GetChildNodeText(PacketNode, cPacketCatIdNode), Result.Category
  ) then
    raise ESWAGXMLProcessor.Create(sBadPacketCategory);
  Result.FileName := fXMLDoc.GetChildNodeText(PacketNode, cPacketFileNameNode);
  var DateStr := fXMLDoc.GetChildNodeText(PacketNode, cPacketDateNode);
  if not TryParseSQLDateTime(DateStr, Result.DateStamp) then
    Result.DateStamp := 0.0;
  Result.Title := fXMLDoc.GetChildNodeText(PacketNode, cPacketTitleNode);
  Result.Author := fXMLDoc.GetChildNodeText(PacketNode, cPacketAuthorNode);
  Result.IsDocument :=
    string.Compare(
      fXMLDoc.GetChildNodeText(PacketNode, cPacketIsDocumentNode), '1'
    ) = 0;
  GetPacketSourceCode(Result);
  ValidatePacket(Result);
end;

procedure TSWAGXMLProcessor.GetPacketSourceCode(var Packet: TSWAGPacket);
resourcestring
  sSourceCodeNotFound = 'Invalid SWAG database: '
    + 'source code file for packet %d not found';
begin
  Assert(Packet.ID > 0, ClassName + '.GetPacketSourceCode: '
    + 'Packet.ID not set');
  Assert(not Packet.FileName.Trim.IsEmpty,
    ClassName + '.GetPacketSourceCode: Packet.FileName not set');
  var FilePath := TPath.Combine(fSWAGRootDir, Packet.FileName);
  if not TFile.Exists(FilePath, False) then
    raise ESWAGXMLProcessor.CreateFmt(sSourceCodeNotFound, [Packet.ID]);
  var Code := TFileIO.ReadAllText(FilePath, TEncoding.Default);
  // Some, if not all, the source code files end in the EOF (SUB) character
  if (Length(Code) > 0) and (Code[Length(Code)] = EOF) then
    Code := Code.Substring(0, Length(Code) - 1);
  Packet.SourceCode := Code;
end;

procedure TSWAGXMLProcessor.GetPartialPackets(const CatID: Cardinal;
  PacketList: TList<TSWAGPacket>);
resourcestring
  sPacketsNodeMissing = 'Invalid SWAG XML file: no packet information found';
  sBadSourceID = 'Invalid SWAG XML file: missing or invalid packet ID';
begin
  var AllPacketsNode := fXMLDoc.FindNode(
    NodePath([cSWAGRootNode, cPacketsNode])
  );
  if not Assigned(AllPacketsNode) then
    raise ESWAGXMLProcessor.Create(sPacketsNodeMissing);
  var PacketNodes := fXMLDoc.FindChildElementsByName(
    AllPacketsNode, cPacketNode
  );
  if not Assigned(PacketNodes) then
    Exit;
  for var PacketNode in PacketNodes do
  begin
    var CatIDFromNode: Cardinal;
    if TryStrToCardinal(
      fXMLDoc.GetChildNodeText(PacketNode, cPacketCatIdNode), CatIDFromNode
    ) and (CatIDFromNode > 0) and (CatIDFromNode = CatID) then
    begin
      var Packet: TSWAGPacket;
      Packet.ID := GetPositiveIntAttribute(
        PacketNode, cPacketIDAttr, sBadSourceID
      );
      Packet.Title := fXMLDoc.GetChildNodeText(PacketNode, cPacketTitleNode);
      ValidatePartialPacket(Packet);
      PacketList.Add(Packet);
    end;
  end;
end;

function TSWAGXMLProcessor.GetPositiveIntAttribute(Node: IXMLNode; const Attr,
  ErrMsg: string): Cardinal;
begin
  if not TryStrToCardinal(Node.Attributes[Attr], Result) or (Result = 0) then
    raise ESWAGXMLProcessor.Create(ErrMsg);
end;

procedure TSWAGXMLProcessor.Initialise(const SWAGDirName: string);
resourcestring
  sFileReadError = 'Can''t read SWAG database file "%0:s"'
    + sLineBreak
    + sLineBreak
    + 'Reported error is: "%1:s"';
  sXMLReadError = 'Error parsing XML in "%0:s"'
    + sLineBreak
    + sLineBreak
    + 'Reported error is: "%1:s"';
var
  Content: TBytes;
  XMLFilePath: string;
begin
  fSWAGRootDir := ExcludeTrailingPathDelimiter(SWAGDirName);
  XMLFilePath := fSWAGRootDir + PathDelim + cSWAGXMLFile;
  try
    Content := TFileIO.ReadAllBytes(XMLFilePath);
  except
    on E: EStreamError do
      raise ESWAGXMLProcessor.CreateFmt(
        sFileReadError, [XMLFilePath, E.Message]
      );
    else
      raise;
  end;
  if Assigned(fXMLDoc) then
    fXMLDoc.Active := False;
  fXMLDoc := TXMLDocumentEx.Create(nil);
  fXMLDoc.Options := [doNodeAutoIndent];
  fXMLDoc.ParseOptions := [poPreserveWhiteSpace];
  try
    fXMLDoc.LoadFromBytes(Content);
    fXMLDoc.Active := True;
  except
    on E: Exception do
      raise ESWAGXMLProcessor.CreateFmt(
        sXMLReadError, [XMLFilePath, E.Message]
      );
  end;
  ValidateXMLDoc;
end;

class function TSWAGXMLProcessor.NodePath(const Tags: array of string): string;
begin
  Result := string.Join('\', Tags);
end;

procedure TSWAGXMLProcessor.ValidatePacket(const Packet: TSWAGPacket);
resourcestring
  sBadCatID = 'Invalid SWAG XML file: packet %d has invalid category';
  sBadFileName = 'Invalid SWAG XML file: packet %d has no file name';
  sBadDateStamp = 'Invalid SWAG XML file: packet %d has no date stamp';
  sBadAuthor = 'Invalid SWAG XML file: packet %d has no author';
  sBadSourceCode = 'Invalid SWAG XML file: packet %d has no source code';
begin
  ValidatePartialPacket(Packet);
  if Packet.Category = 0 then
    raise ESWAGXMLProcessor.CreateFmt(sBadCatID, [Packet.ID]);
  if Packet.FileName.Trim.IsEmpty then
    raise ESWAGXMLProcessor.CreateFmt(sBadFileName, [Packet.ID]);
  if System.DateUtils.SameDateTime(Packet.DateStamp, 0.0) then
    raise ESWAGXMLProcessor.CreateFmt(sBadDateStamp, [Packet.ID]);
  if Packet.Author.Trim.IsEmpty then
    raise ESWAGXMLProcessor.CreateFmt(sBadAuthor, [Packet.ID]);
  if Packet.SourceCode.Trim.IsEmpty then
    raise ESWAGXMLProcessor.CreateFmt(sBadSourceCode, [Packet.ID]);
end;

procedure TSWAGXMLProcessor.ValidatePartialPacket(const Packet: TSWAGPacket);
resourcestring
  sBadID = 'Invalid SWAG XML file: packet ID not set';
  sBadTitle = 'Invalid SWAG XML file: packet %d has no title';
begin
  if Packet.ID < 1 then
    raise ESWAGXMLProcessor.Create(sBadID);
  if Packet.Title.Trim.IsEmpty then
    raise ESWAGXMLProcessor.CreateFmt(sBadTitle, [Packet.ID]);
end;

procedure TSWAGXMLProcessor.ValidateXMLDoc;
resourcestring
  // Error messages
  sNoXMLProcInst = 'Invalid SWAG XML file: no XML processing present';
  sNoRootNode = 'Invalid SWAG XML file: no root element present';
  sBadRootName = 'Invalid SWAG XML file: root element must be named <%s>';
  sBadVersion = 'Invalid SWAG XML file: invalid version attribute of <%s>';
  sUnknownVersion = 'Invalid SWAG XML file: unsupported document version %d';
  sMissingNode = 'Invalid SWAG XML file: no <%s> node present';
begin
  // Check for valid <?xml> processing instruction
  if not fXMLDoc.HasValidProcessingInstr then
    raise ESWAGXMLProcessor.Create(sNoXMLProcInst);

  // Check for valid <swag> root node with valid & supported version attribute
  var RootNode := fXMLDoc.DocumentElement;
  if not Assigned(RootNode) then
    raise ESWAGXMLProcessor.Create(sNoRootNode);
  if RootNode.NodeName <> cSWAGRootNode then
    raise ESWAGXMLProcessor.CreateFmt(sBadRootName, [cSWAGRootNode]);
  var VersionStr := RootNode.Attributes[cRootVersionAttr];
  var Version: Integer;
  if not TryStrToInt(VersionStr, Version) then
    raise ESWAGXMLProcessor.CreateFmt(sBadVersion, [cSWAGRootNode]);
  if Version <> cSupportedSWAGVersion then
    raise ESWAGXMLProcessor.CreateFmt(sUnknownVersion, [Version]);

  // Check for compulsory <categories> node
  var CategoriesNode := fXMLDoc.FindNode(
    NodePath([cSWAGRootNode, cCategoriesNode])
  );
  if not Assigned(CategoriesNode) then
    raise ESWAGXMLProcessor.CreateFmt(sMissingNode, [cCategoriesNode]);

  // Check for compulsory <packets> node
  var SourcesNode := fXMLDoc.FindNode(
    NodePath([cSWAGRootNode, cPacketsNode])
  );
  if not Assigned(SourcesNode) then
    raise ESWAGXMLProcessor.CreateFmt(sMissingNode, [cPacketsNode]);
end;

end.

