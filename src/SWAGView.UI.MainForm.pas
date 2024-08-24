{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023-2024, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements the application's main window and core functionality.
}


unit SWAGView.UI.MainForm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Actions,
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.Forms,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.TreeView,
  FMX.Types,
  FMX.StdCtrls,
  SWAGView.SWAG,
  SWAGView.SWAG.Types;

type
  ///  <summary>Form class that implements the application's main window and
  ///  core functionality.</summary>
  TMainForm = class(TForm)
    TopPanel: TPanel;
    BottomPanel: TPanel;
    TreeView: TTreeView;
    Splitter: TSplitter;
    DetailContainer: TPanel;
    MetaPanel: TPanel;
    MetaTitle: TLabel;
    MetaAuthorLbl: TLabel;
    MetaIDsLbl: TLabel;
    MetaFileNameLbl: TLabel;
    MetaAuthor: TLabel;
    MetaIDs: TLabel;
    MetaFileName: TLabel;
    LoadDataTimer: TTimer;
    Content: TMemo;
    MetaDateLbl: TLabel;
    MetaDate: TLabel;
    HelpLbl: TLabel;
    VersionLbl: TLabel;
    InstallBtn: TButton;
    EmptyDBNoticeLbl: TLabel;
    HelpBtn: TButton;
    CopyBtn: TButton;
    ActionList: TActionList;
    CopyAction: TAction;
    InstallDBAction: TAction;
    HelpAction: TAction;
    procedure LoadDataTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TreeViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure TreeViewMouseLeave(Sender: TObject);
    procedure TreeViewChange(Sender: TObject);
    procedure TreeViewKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure CopyActionExecute(Sender: TObject);
    procedure CopyActionUpdate(Sender: TObject);
    procedure InstallDBActionExecute(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
  strict private
    var
      fSWAG: TSWAG;
      fCurrentPacket: TSWAGPacket;   // Auto-initialised to null
    class function EscapeAmpersands(const AText: string): string;
    class procedure ErrorMessageDlg(const AMsg: string);
    function InstallDatabase(const AZipFilePath: string): Boolean;
    procedure LoadDatabase;
    procedure ClearDatabase;
    procedure AddTreeViewItemToParent(const AParent: TFmxObject;
      const AText: string; const AID: Cardinal);
    procedure DisplayCurrentPacket;
    procedure PopulateTopLevelTreeView;
    procedure PopulateCategoryNode(const Node: TTreeViewItem);
    procedure HandleSelectedTVItemInteraction;
    procedure DisplayVersionInformation;
    procedure ShowInstallBtn(const ACaption: string);
    procedure UpdateEmptyDBNotice(const Show: Boolean);
    procedure UpdateTVItemHelp(const AItem: TTreeViewItem);
  end;

  EMain = class(Exception);

var
  MainForm: TMainForm;

implementation

uses
  System.UITypes,
  FMX.DialogService,
  FMX.Platform,
  Winapi.Windows,
  Winapi.ShellAPI,
  SWAGView.UI.DBSetupDlg,
  SWAGView.UI.WaitDlg,
  SWAGView.SWAG.Version,
  SWAGView.SWAG.Installer,
  SWAGView.VersionInfo;

{$R *.fmx}

procedure TMainForm.AddTreeViewItemToParent(const AParent: TFmxObject;
  const AText: string; const AID: Cardinal);
begin
  var TVItem := TTreeViewItem.Create(Self);
  TVItem.Text := EscapeAmpersands(AText);
  TVItem.Tag := NativeInt(AID);
  TVItem.Parent := AParent;
end;

procedure TMainForm.ClearDatabase;
begin
  TreeView.BeginUpdate;
  try
    TreeView.Clear;
  finally
    TreeView.EndUpdate;
  end;
  Content.Lines.Clear;
  UpdateEmptyDBNotice(True);
  FreeAndNil(fSWAG);
  ShowInstallBtn('Install SWAG &Database...');
end;

procedure TMainForm.CopyActionExecute(Sender: TObject);
resourcestring
  sBadCatID = 'Invalid snippet category ID %0:d for snippet ID %1:d';
  sFmtStr =
    '''
    {
      SWAG Metadata:
        Title     : %0:s
        Author    : %1:s
        Category  : %2:d: %3:s
        Packet ID : %4:d
        File name : %5:s
        Date      : %6:s
    }

    %7:s
    ''';
begin
  var CB : IFMXClipboardService;
  TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService, CB
  );
  Assert(Assigned(CB));
  Assert(Assigned(fSWAG));
  Assert(not fCurrentPacket.IsNull);

  var Category: TSWAGCategory;
  if not fSWAG.TryLookupCategoryByID(fCurrentPacket.Category, Category) then
    raise EMain.CreateFmt(
      sBadCatID, [fCurrentPacket.Category, fCurrentPacket.ID]
    );
  var CBContent := Format(
    sFmtStr,
    [
      fCurrentPacket.Title,
      fCurrentPacket.Author,
      Category.ID,
      Category.Title,
      fCurrentPacket.ID,
      fCurrentPacket.FileName,
      fCurrentPacket.DateStampAsString,
      fCurrentPacket.SourceCode
    ]
  );
  CB.SetClipboard(CBContent);
end;

procedure TMainForm.CopyActionUpdate(Sender: TObject);
begin
  var CBAvailable := TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService
  );
  CopyAction.Enabled := CBAvailable and not fCurrentPacket.IsNull
end;

procedure TMainForm.DisplayCurrentPacket;
begin
  MetaTitle.Text := EscapeAmpersands(fCurrentPacket.Title);
  MetaAuthor.Text := fCurrentPacket.Author;
  MetaIDs.Text := Format(
    '%0:d (%1:d)', [fCurrentPacket.ID, fCurrentPacket.Category]
  );
  MetaFileName.Text := fCurrentPacket.FileName;
  MetaDate.Text := fCurrentPacket.DateStampAsString;
  Content.BeginUpdate;
  try
    Content.Text := fCurrentPacket.SourceCode;
  finally
    Content.EndUpdate;
  end;
end;

procedure TMainForm.DisplayVersionInformation;
begin
  // Get program & SWAG version numbers
  var ProgVer := TVersionInfo.ProductVersionStr;
  if TSWAGInstaller.IsInstalled then
  begin
    var SWAGVer := TSWAGVersion.GetVersion(TSWAGInstaller.SWAGDataDir);
    VersionLbl.Text := Format(
      'SWAG version: %0:s | Program version: %1:s',
      [SWAGVer.ToString, ProgVer]
    );
  end
  else
    VersionLbl.Text := Format(
      'Program version: %0:s', [ProgVer]
    );
end;

class procedure TMainForm.ErrorMessageDlg(const AMsg: string);
begin
  TDialogService.MessageDialog(
    AMsg, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil
  );
end;

class function TMainForm.EscapeAmpersands(const AText: string): string;
begin
  Result := AText.Replace('&', '&&', [rfReplaceAll]);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InstallBtn.Visible := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fSWAG.Free;
end;

procedure TMainForm.HandleSelectedTVItemInteraction;
begin
  var Selected := TreeView.Selected;
  if not Assigned(Selected) then
    Exit;
  case Selected.Level of
    1:
    begin
      if Selected.Count = 0 then
      begin
        PopulateCategoryNode(Selected);
        Selected.Expand;
      end
      else if Selected.IsExpanded then
        Selected.Collapse
      else
        Selected.Expand;
    end;
    2:
    begin
      Assert(Assigned(fSWAG));
      var Packet := fSWAG.Packet(Cardinal(Selected.Tag));
      fCurrentPacket := Packet;
      DisplayCurrentPacket;
    end;
    // >= 3 should never happen
  end;
  UpdateTVItemHelp(Selected);
end;

procedure TMainForm.HelpActionExecute(Sender: TObject);
begin
  const ExecVerb: PChar = 'open';
  const HelpURL: PChar = 'https://delphidabbler.com/help/swagview/0.0/index';
  ShellExecute(0, ExecVerb, HelpURL, nil, nil, SW_SHOW);
end;

function TMainForm.InstallDatabase(const AZipFilePath: string): Boolean;
const
  BadInstallMsg = 'Installation failed.' + sLineBreak + sLineBreak + '%s';
  BadDatabaseMsg = 'Installation failed.' + sLineBreak + sLineBreak
    + '.zip file does not contain a SWAG installation.';

begin
  var Installer := TSWAGInstaller.Create(AZipFilePath);
  try
    var WaitDlg := TWaitDlg.Create(Self);
    try
      WaitDlg.WaitMessage := 'Installing SWAG database ... please wait';
      WaitDlg.Show;

      Result := Installer.Execute;
      if Result then
      begin
        try
          TSWAGVersion.ValidateVersionFile(TSWAGInstaller.SWAGDataDir);
        except
          on E: ESWAGVersion do
          begin
            ErrorMessageDlg(Format(BadInstallMsg, [E.Message]));
            Result := False;
          end;
        end;
      end
      else
        ErrorMessageDlg(BadDatabaseMsg);

      if not Result then
        Installer.RemoveInstallation;

    finally
      WaitDlg.Close;
      WaitDlg.Free;
    end;
  finally
    Installer.Free;
  end;
end;

procedure TMainForm.InstallDBActionExecute(Sender: TObject);
begin
  var ZipFilePath: string;
  if TDBSetupDlg.GetDBFilePath(Self, ZipFilePath) then
  begin
    if InstallDatabase(ZipFilePath) then
      LoadDatabase
    else
    begin
      ClearDatabase;
      DisplayVersionInformation;
    end;
  end;
end;

procedure TMainForm.LoadDatabase;
begin
  Cursor := crHourGlass;
  try
    Application.ProcessMessages;

    FreeAndNil(fSWAG);  // recreate fSWAG if database read more than once
    fSWAG := TSWAG.Create(TSWAGInstaller.SWAGDataDir);

    DisplayVersionInformation;
    PopulateTopLevelTreeView;
    ShowInstallBtn('Update SWAG &Database...');
    UpdateEmptyDBNotice(False);
  finally
    Cursor := crDefault;
  end;
end;

procedure TMainForm.LoadDataTimerTimer(Sender: TObject);
begin
  // Used to provide a brief delay to allow main window to draw before loading
  // SWAG data
  LoadDataTimer.Enabled := False;
  if TSWAGInstaller.IsInstalled then
    LoadDatabase
  else
    ClearDatabase;
end;

procedure TMainForm.PopulateCategoryNode(const Node: TTreeViewItem);
begin
  Assert(Assigned(fSWAG));
  Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    var CatID := Cardinal(Node.Tag);
    var Packets := fSWAG.PartialPackets(CatID);
    for var Packet in Packets do
      AddTreeViewItemToParent(Node, Packet.Title, Packet.ID);
  finally
    Cursor := crDefault;
  end;
end;

procedure TMainForm.PopulateTopLevelTreeView;
begin
  Assert(Assigned(fSWAG));
  TreeView.Clear;
  for var Cat in fSWAG.AllCategories do
    AddTreeViewItemToParent(TreeView, Cat.Title, Cat.ID);
  TreeView.Selected := TreeView.Items[0];
  SetFocused(TreeView);
end;

procedure TMainForm.ShowInstallBtn(const ACaption: string);
begin
  InstallBtn.Text := ACaption;
  InstallBtn.Visible := True;
end;

procedure TMainForm.TreeViewChange(Sender: TObject);
begin
  UpdateTVItemHelp(TreeView.Selected);
end;

procedure TMainForm.TreeViewDblClick(Sender: TObject);
begin
  HandleSelectedTVItemInteraction;
end;

procedure TMainForm.TreeViewKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = [])
    or (Key = VK_RIGHT) and (Shift = []) then
  begin
    Key := 0;
    HandleSelectedTVItemInteraction;
  end;
end;

procedure TMainForm.TreeViewKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  UpdateTVItemHelp(TreeView.Selected);
end;

procedure TMainForm.TreeViewMouseLeave(Sender: TObject);
begin
  HelpLbl.Text := string.Empty;
end;

procedure TMainForm.TreeViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  UpdateTVItemHelp(TreeView.ItemByPoint(X, Y));
end;

procedure TMainForm.UpdateEmptyDBNotice(const Show: Boolean);
begin
  EmptyDBNoticeLbl.Visible := Show;
end;

procedure TMainForm.UpdateTVItemHelp(const AItem: TTreeViewItem);
const
  CatNotLoadedHelp: array[Boolean] of string = (
    'Category not yet loaded. '
      + 'Double click or select then press ENTER or → to load and expand',
    'Category not yet loaded. '
      + 'Double click or press ENTER or → to load and expand'
  );
  CatLoadedCollapsedHelp: array[Boolean] of string = (
    'Double click or select and press ENTER or → to expand category',
    'Double click or press ENTER or → to expand category'
  );
  CatLoadedExpandedHelp: array[Boolean] of string = (
    'Double click or select and press ENTER or ← to collapse category',
    'Double click or press ENTER or ← to collapse category'
  );
  PacketHelp: array[Boolean] of string = (
    'Double click or select and press ENTER or → to display packet '
      + 'or ← to select category',
    'Double click or press ENTER or → to display packet or ← to select category'
  );
begin
  var Msg := string.Empty;
  if Assigned(AItem) then
  begin
    case AItem.Level of
      1:
      begin
        // Category level
        if AItem.Count = 0 then
        begin
          // Not loaded
          Msg := CatNotLoadedHelp[AItem = TreeView.Selected];
        end
        else
        begin
          // Loaded
          if AItem.IsExpanded then
            Msg := CatLoadedExpandedHelp[AItem = TreeView.Selected]
          else
            Msg := CatLoadedCollapsedHelp[AItem = TreeView.Selected];
        end;
      end;
      2:
      begin
        // Packet level
        Msg := PacketHelp[AItem = TreeView.Selected];
      end;
    end;
  end;
  HelpLbl.Text := Msg;
end;

end.

