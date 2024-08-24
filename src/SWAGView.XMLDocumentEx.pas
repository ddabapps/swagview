{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2008-2024, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Based on code extracted from Src/UXMLDocumentEx.pas, copied from
 * https://github.com/delphidabbler/codesnip master branch as of commit 7482558.
 *
 * Implements extensions to TXMLDocument and IXMLDocument that provide some
 * helper methods. Also provides a simple list object that can contain XML
 * nodes with enumerator.
}


unit SWAGView.XMLDocumentEx;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Xml.XMLIntf,
  Xml.XMLDoc,
  Xml.XMLDom;

type
  ///  <summary>Interface to a simple list of XML nodes. This interface is
  ///  designed to enable creation and manipulation of a list of <c>IXMLNode</c>
  ///  objects without reference to XML document.</summary>
  IXMLSimpleNodeList = interface(IInterface)
    ['{FF9FA906-BE3F-4372-85E7-89FA14EA2301}']
    ///  <summary>Retrieves a node from the list by index.</summary>
    function GetItem(Idx: Integer): IXMLNode;
    ///  <summary>Adds a given node to the list and returns index of new node
    ///  in list.</summary>
    function Add(const Node: IXMLNode): Integer;
    ///  <summary>Returns number of items in list.</summary>
    function Count: Integer;
    ///  <summary>Creates list enumerator.</summary>
    function GetEnumerator: TEnumerator<IXMLNode>;
    ///  <summary>Indexed access to list items.</summary>
    property Items[Idx: Integer]: IXMLNode read GetItem; default;
  end;

type
  ///  <summary>Extension of <c>Xml.XMLIntf.IXMLDocument</c> to provide some
  ///  useful additional methods.</summary>
  IXMLDocumentEx = interface(IXMLDocument)
    ['{B7E2BFE1-6708-4D6E-B277-C4E538CA76DF}']

    ///  <summary>Checks if the XML document has a valid XML processing
    ///  instruction.</summary>
    ///  <retuns><c>True</c> if a valid processing instruction is found,
    ///  <c>False</c> if not.</returns>
    function HasValidProcessingInstr: Boolean;

    ///  <summary>Finds a node specified by a path from, and including the
    ///  document's root node.</summary>
    ///  <param name="PathToNode">[in] Path to node from root node.</param>
    ///  <returns><c>IXMLNode</c>. Reference to required node or <c>nil</c> if
    ///  node not found.</returns>
    ///  <remarks>Nodes in path are separated by backslashes, e.g.
    ///  <c>root\node1\node2</c></remarks>
    function FindNode(PathToNode: DOMString): IXMLNode;

    ///  <summary>Finds all child nodes of a parent node that are elements and
    ///  have a specified name.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="NodeName">[in] Name of required element nodes.</param>
    ///  <returns><c>IXMLSimpleNodeList</c>. List of matching nodes.</returns>
    function FindChildElementsByName(const ParentNode: IXMLNode;
      const NodeName: DOMString): IXMLSimpleNodeList;

    ///  <summary>Finds first child node that is an element and has a given name
    ///  and attribute value.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="NodeName">[in] Name of required element node.</param>
    ///  <param name="AttribName">[in] Name of required attribute.</param>
    ///  <param name="AttribValue">[in] Value of attribute <c>AttribName</c>.
    ///  </param>
    ///  <returns><c>IXMLNode</c>. Reference to found node or <c>nil</c> if no
    ///  node found.</returns>
    function FindFirstChildNodeByNameAndAttr(const ParentNode: IXMLNode;
      const NodeName, AttribName: DOMString;
      const AttribValue: OleVariant): IXMLNode;

    ///  <summary>Gets text of a named child node of a given parent node.
    ///  </summary>
    ///  <param name="ParentNode">[in] Parent of child node.</param>
    ///  <param name="ChildNodeName">[in] Name of child node.</param>
    ///  <returns><c>DOMString</c>. Sub tag's text if sub tag exists and is a
    ///  text node, or empty string otherwise.</param>
    function GetChildNodeText(const ParentNode: IXMLNode;
      const ChildNodeName: DOMString): DOMString;

    ///  <summary>Loads XML document from data stored in byte array.</summary>
    ///  <param name="Bytes">[in] Array of bytes to load.</param>
    procedure LoadFromBytes(const Bytes: TBytes);
  end;

type
  ///  <summary>Implementation of a simple list of XML nodes that can be created
  ///  and manipulated without reference to XML document.</summary>
  TXMLSimpleNodeList = class(TInterfacedObject,
    IXMLSimpleNodeList
  )
  strict private
    var
      ///  <summary>List of nodes.</summary>
      fList: TList<IXMLNode>;
  public
    ///  <summary>Object constructor. Creates object with empty list.</summary>
    constructor Create;
    ///  <summary>Object destructor. Tears down object.</summary>
    destructor Destroy; override;

    // IXMLSimpleNodeList methods

    ///  <summary>Retrieves a node from the list by index.</summary>
    function GetItem(Idx: Integer): IXMLNode;
    ///  <summary>Adds a given node to the list and returns index of new node
    ///  in list.</summary>
    function Add(const Node: IXMLNode): Integer;
    ///  <summary>Returns number of items in list.</summary>
    function Count: Integer;
    ///  <summary>Creates list enumerator.</summary>
    function GetEnumerator: TEnumerator<IXMLNode>;
  end;

type
  ///  <summary>Extension of <c>TXMLDocument</c> from <c>XML.XMLDoc</c> unit
  ///  that implements the methods of <c>IXMLDocumentEx</c>.</summary>
  TXMLDocumentEx = class(TXMLDocument,
    IXMLDocument, IXMLDocumentEx
  )
  strict private
    ///  <summary>Find all child nodes of a parent node that match specified
    ///  criteria.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="Predicate">[in] Closure that determines whether a given
    ///  child node is to be included in the list of found nodes.</param>
    ///  <returns><c>IXMLSimpleNodeList</c>. List of found nodes.</returns>
    function FindChildElements(const ParentNode: IXMLNode;
      const Predicate: TFunc<IXMLNode,Boolean>): IXMLSimpleNodeList;

    ///  <summary>Finds all child nodes of a parent node that are elements, have
    ///  a specified name and have a specified attribute value.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="NodeName">[in] Name of required element nodes.</param>
    ///  <param name="AttribName">[in] Name of required attribute.</param>
    ///  <param name="AttribValue">OleVariant [in] Value of attribute.</param>
    ///  <returns><c>IXMLSimpleNodeList</c>. List of matching nodes.</returns>
    function FindChildElementsByNameAndAttr(const ParentNode: IXMLNode;
      const NodeName, AttribName: DOMString;
      const AttribValue: OleVariant): IXMLSimpleNodeList;

    ///  <summary>Finds first child node that has a given name.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be
    ///  searched.</param>
    ///  <param name="NodeName">[in] Name of required element node.</param>
    ///  <returns><c>IXMLNode</c>. Reference to found node or <c>nil</c> if no
    ///  node found.</returns>
    function FindFirstChildNodeByName(const ParentNode: IXMLNode;
      const NodeName: DOMString): IXMLNode;
  public
    // IXMLDocumentEx methods

    ///  <summary>Checks if the XML document has a valid XML processing
    ///  instruction.</summary>
    ///  <returns><c>True</c> if a valid processing instruction is found,
    ///  <c>False</c> if not.</returns>
    function HasValidProcessingInstr: Boolean;

    ///  <summary>Finds a node specified by a path from, and including the
    ///  document's root node.</summary>
    ///  <param name="PathToNode">[in] Path to node from root node.</param>
    ///  <returns><c>IXMLNode</c>. Reference to required node or <c>nil</c> if
    ///  node not found.</returns>
    ///  <remarks>Nodes in path are separated by backslashes, e.g.
    ///  <c>root\node1\node2</c></remarks>
    function FindNode(PathToNode: DOMString): IXMLNode;

    ///  <summary>Finds all child nodes of a parent node that are elements and
    ///  have a specified name.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="NodeName">[in] Name of required element nodes.</param>
    ///  <returns><c>IXMLSimpleNodeList</c>. List of matching nodes.</returns>
    function FindChildElementsByName(const ParentNode: IXMLNode;
      const NodeName: DOMString): IXMLSimpleNodeList;

    ///  <summary>Finds first child node that is an element and has a given name
    ///  and attribute value.</summary>
    ///  <param name="ParentNode">[in] Node containing child nodes to be found.
    ///  </param>
    ///  <param name="NodeName">[in] Name of required element node.</param>
    ///  <param name="AttribName">[in] Name of required attribute.</param>
    ///  <param name="AttribValue">[in] Value of attribute <c>AttribName</c>.
    ///  </param>
    ///  <returns><c>IXMLNode</c>. Reference to found node or <c>nil</c> if no
    ///  node found.</returns>
    function FindFirstChildNodeByNameAndAttr(const ParentNode: IXMLNode;
      const NodeName, AttribName: DOMString;
      const AttribValue: OleVariant): IXMLNode;

    ///  <summary>Gets text of a named child node of a given parent node.
    ///  </summary>
    ///  <param name="ParentNode">[in] Parent of child node.</param>
    ///  <param name="ChildNodeName">[in] Name of child node.</param>
    ///  <returns><c>DOMString</c>. Sub tag's text if sub tag exists and is a
    ///  text node, or empty string otherwise.</param>
    function GetChildNodeText(const ParentNode: IXMLNode;
      const ChildNodeName: DOMString): DOMString;

    ///  <summary>Loads XML document from data stored in byte array.</summary>
    ///  <param name="Bytes">[in] Array of bytes to load.</param>
    procedure LoadFromBytes(const Bytes: TBytes);
  end;

implementation

uses
  System.Classes;

{ TXMLDocumentEx }

function TXMLDocumentEx.FindChildElements(const ParentNode: IXMLNode;
  const Predicate: TFunc<IXMLNode, Boolean>): IXMLSimpleNodeList;
begin
  Assert(Assigned(ParentNode),
    ClassName + '.FindChildElements: ParentNode is nil');
  Result := TXMLSimpleNodeList.Create;
  var NodeList := ParentNode.ChildNodes;
  for var Idx := 0 to Pred(NodeList.Count) do
  begin
    var Node := NodeList[Idx];
    if Predicate(Node) then
      Result.Add(Node);
  end;
end;

function TXMLDocumentEx.FindChildElementsByName(const ParentNode: IXMLNode;
  const NodeName: DOMString): IXMLSimpleNodeList;
begin
  Result := FindChildElements(
    ParentNode,
    function (ChildNode: IXMLNode): Boolean
    begin
      Result := (ChildNode.NodeType = ntElement)
        and (ChildNode.NodeName = NodeName);
    end
  );
end;

function TXMLDocumentEx.FindChildElementsByNameAndAttr(
  const ParentNode: IXMLNode; const NodeName, AttribName: DOMString;
  const AttribValue: OleVariant): IXMLSimpleNodeList;
begin
  Result := FindChildElements(
    ParentNode,
    function (ChildNode: IXMLNode): Boolean
    begin
      Result := (ChildNode.NodeType = ntElement)
        and (ChildNode.NodeName = NodeName)
        and (ChildNode.Attributes[AttribName] = AttribValue);
    end
  );
end;

function TXMLDocumentEx.FindFirstChildNodeByName(const ParentNode: IXMLNode;
  const NodeName: DOMString): IXMLNode;
begin
  Assert(Assigned(ParentNode),
    ClassName + '.FindFirstChildNodeByName: ParentNode is nil');
  Result := ParentNode.ChildNodes.FindNode(NodeName);
end;

function TXMLDocumentEx.FindFirstChildNodeByNameAndAttr(
  const ParentNode: IXMLNode; const NodeName, AttribName: DOMString;
  const AttribValue: OleVariant): IXMLNode;
begin
  Assert(Assigned(ParentNode),
    ClassName + 'FindFirstChildNodeByNameAndAttr: ParentNode is nil');
  var Nodes := FindChildElementsByNameAndAttr(
    ParentNode, NodeName, AttribName, AttribValue
  );
  if Nodes.Count > 0 then
    Result := Nodes[0]
  else
    Result := nil;
end;

function TXMLDocumentEx.FindNode(PathToNode: DOMString): IXMLNode;
begin
  var Node: IXMLNode := nil;
  var NodeList := Self.ChildNodes;
  var NodeNames := PathToNode.Split(['\']);
  for var NodeName in NodeNames do
  begin
    Node := NodeList.FindNode(NodeName);
    if not Assigned(Node) then
      Break;
    NodeList := Node.ChildNodes;
  end;
  Result := Node;
end;

function TXMLDocumentEx.GetChildNodeText(const ParentNode: IXMLNode;
  const ChildNodeName: DOMString): DOMString;
begin
  Assert(Assigned(ParentNode),
    ClassName + 'GetChildNodeText: ParentNode is nil');
  Result := '';
  var ChildNode := FindFirstChildNodeByName(ParentNode, ChildNodeName);
  if Assigned(ChildNode) and (ChildNode.IsTextElement) then
    Result := ChildNode.Text;
end;

function TXMLDocumentEx.HasValidProcessingInstr: Boolean;
const
  ProcInstNodeName = 'xml';
begin
  // Must have correct processing instruction (<?xml .... ?>)
  var ProcInstNode: IXMLNode := nil;  // xml processing node
  for var Idx := 0 to Pred(ChildNodes.Count) do
  begin
    if ChildNodes.Nodes[Idx].NodeType = ntProcessingInstr then
    begin
      ProcInstNode := ChildNodes.Nodes[Idx];
      Break;
    end;
  end;
  if not Assigned(ProcInstNode) then
    Exit(False);
  if ProcInstNode.NodeName <> ProcInstNodeName then
    Exit(False);
  Result := True;
end;

procedure TXMLDocumentEx.LoadFromBytes(const Bytes: TBytes);
begin
  var Stm := TBytesStream.Create(Bytes);
  try
    LoadFromStream(Stm);
  finally
    Stm.Free;
  end;
end;

{ TXMLSimpleNodeList }

function TXMLSimpleNodeList.Add(const Node: IXMLNode): Integer;
begin
  Result := fList.Add(Node);
end;

function TXMLSimpleNodeList.Count: Integer;
begin
  Result := fList.Count;
end;

constructor TXMLSimpleNodeList.Create;
begin
  inherited;
  fList := TList<IXMLNode>.Create;
end;

destructor TXMLSimpleNodeList.Destroy;
begin
  fList.Free;
  inherited;
end;

function TXMLSimpleNodeList.GetEnumerator: TEnumerator<IXMLNode>;
begin
  Result := fList.GetEnumerator;
end;

function TXMLSimpleNodeList.GetItem(Idx: Integer): IXMLNode;
begin
  Result := fList[Idx];
end;

end.

