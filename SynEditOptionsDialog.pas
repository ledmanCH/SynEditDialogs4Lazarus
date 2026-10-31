{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEditOptionsDialog.pas (Delphi SynEdit project).

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL").

Lazarus port of the Delphi SynEdit options dialog.

Differences imposed by Lazarus SynEdit:
  - Gutter: the Lazarus TSynGutter belongs to an editor and cannot be created
    alone, so the container uses TSynEditorOptionsGutter (same properties as
    the Delphi gutter used by the dialog).
  - Gutter font: the Lazarus gutter always uses the editor font; when
    UseFontStyle is set, the gutter font color and style are applied to the
    line number part.
  - eoEnhanceEndKey lives in Options2 in Lazarus (container.Options2).
  - MaxScrollWidth does not exist in Lazarus: the value is kept, not applied.
  - TSynHotKey does not exist in Lazarus: implemented here.
-------------------------------------------------------------------------------}

UNIT SynEditOptionsDialog;

{$mode delphi}{$H+}

INTERFACE

USES
  Classes, SysUtils, Types, LCLType, LCLIntf, LMessages, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, LCLProc,
  SynEdit, SynEditTypes, SynEditMiscClasses, SynEditKeyCmds, SynGutter,
  SynGutterLineNumber, SynGutterBase, SynEditPointClasses;

TYPE
  TColorPopup = (cpGutter, cpRightEdge);

  TSynEditorOptionsUserCommand = PROCEDURE(AUserCommand: Integer;
    VAR ADescription: STRING) OF OBJECT;

  //NOTE: in order for the user commands to be recorded correctly, you must
  //      put the command itself in the object property.
  //      you can do this like so:
  //
  //      StringList.AddObject('ecSomeCommand', TObject(PtrInt(ecSomeCommand)))
  //
  //      where ecSomeCommand is the command that you want to add

  TSynEditorOptionsAllUserCommands = PROCEDURE(ACommands: TStrings) OF OBJECT;

  TSynEditorOptionsContainer = CLASS;

  { Hot key edit (Delphi TSynHotKey equivalent) }

  TSynHKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  TSynHKInvalidKeys = SET OF TSynHKInvalidKey;
  TSynHKModifier = (hkShift, hkCtrl, hkAlt);
  TSynHKModifiers = SET OF TSynHKModifier;

  TSynHotKey = CLASS(TCustomEdit)
  PRIVATE
    FHotKey: TShortCut;
    FInvalidKeys: TSynHKInvalidKeys;
    FModifiers: TSynHKModifiers;
    PROCEDURE SetHotKey(CONST Value: TShortCut);
    PROCEDURE ShowShift(AShift: TShiftState);
    PROCEDURE WMGetDlgCode(VAR Message: TLMessage); MESSAGE LM_GETDLGCODE;
  PROTECTED
    PROCEDURE KeyDown(VAR Key: Word; Shift: TShiftState); OVERRIDE;
    PROCEDURE KeyUp(VAR Key: Word; Shift: TShiftState); OVERRIDE;
    PROCEDURE KeyPress(VAR Key: Char); OVERRIDE;
    PROCEDURE UTF8KeyPress(VAR UTF8Key: TUTF8Char); OVERRIDE;
    PROCEDURE DoEnter; OVERRIDE;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
  PUBLISHED
    PROPERTY HotKey: TShortCut READ FHotKey WRITE SetHotKey DEFAULT 0;
    PROPERTY InvalidKeys: TSynHKInvalidKeys READ FInvalidKeys WRITE FInvalidKeys;
    PROPERTY Modifiers: TSynHKModifiers READ FModifiers WRITE FModifiers;
    PROPERTY Align;
    PROPERTY Anchors;
    PROPERTY Enabled;
    PROPERTY Font;
    PROPERTY TabOrder;
    PROPERTY TabStop;
    PROPERTY Visible;
  END;

  { TfmEditorOptionsDialog }

  TfmEditorOptionsDialog = CLASS(TForm)
    btnAddKey: TButton;
    btnCancel: TButton;
    btnFont: TButton;
    btnGutterColor: TPanel;
    btnGutterFont: TButton;
    btnOk: TButton;
    btnRemKey: TButton;
    btnRightEdge: TPanel;
    btnUpdateKey: TButton;
    cbGutterFont: TCheckBox;
    cInsertCaret: TComboBox;
    ckAltSetsColumnMode: TCheckBox;
    ckAutoIndent: TCheckBox;
    ckAutoSizeMaxWidth: TCheckBox;
    ckBookmarkKeys: TCheckBox;
    ckBookmarkVisible: TCheckBox;
    ckDisableScrollArrows: TCheckBox;
    ckDragAndDropEditing: TCheckBox;
    ckEnhanceEndKey: TCheckBox;
    ckEnhanceHomeKey: TCheckBox;
    cKeyCommand: TComboBox;
    ckGroupUndo: TCheckBox;
    ckGutterAutosize: TCheckBox;
    ckGutterShowLeaderZeros: TCheckBox;
    ckGutterShowLineNumbers: TCheckBox;
    ckGutterStartAtZero: TCheckBox;
    ckGutterVisible: TCheckBox;
    ckHalfPageScroll: TCheckBox;
    ckHideShowScrollbars: TCheckBox;
    ckKeepCaretX: TCheckBox;
    ckRightMouseMoves: TCheckBox;
    ckScrollByOneLess: TCheckBox;
    ckScrollHintFollows: TCheckBox;
    ckScrollPastEOF: TCheckBox;
    ckScrollPastEOL: TCheckBox;
    ckShowScrollHint: TCheckBox;
    ckShowSpecialChars: TCheckBox;
    ckSmartTabDelete: TCheckBox;
    ckSmartTabs: TCheckBox;
    ckTabIndent: TCheckBox;
    ckTabsToSpaces: TCheckBox;
    ckTrimTrailingSpaces: TCheckBox;
    ckWantTabs: TCheckBox;
    ColorDialog: TColorDialog;
    ColorPopup: TPopupMenu;
    cOverwriteCaret: TComboBox;
    Display: TTabSheet;
    eLineSpacing: TEdit;
    eRightEdge: TEdit;
    eTabWidth: TEdit;
    FontDialog: TFontDialog;
    gbBookmarks: TGroupBox;
    gbCaret: TGroupBox;
    gbEditorFont: TGroupBox;
    gbGutter: TGroupBox;
    gbKeyStrokes: TGroupBox;
    gbLineSpacing: TGroupBox;
    gbOptions: TGroupBox;
    gbRightEdge: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    ImageList: TImageList;
    KeyList: TListView;
    Keystrokes: TTabSheet;
    lblCommand: TLabel;
    lblEdgeColor: TLabel;
    lblEdgeColumn: TLabel;
    lblExtraLines: TLabel;
    lblFont: TLabel;
    lblGutterColor: TLabel;
    lblGutterFont: TLabel;
    lblInsertCaret: TLabel;
    lblKeystroke: TLabel;
    lblKeystroke2: TLabel;
    lblOverwriteCaret: TLabel;
    lblTabWidth: TLabel;
    Menu2: TMenuItem;
    mnu3dDarkShadow: TMenuItem;
    mnu3DLight: TMenuItem;
    mnuActiveBorder: TMenuItem;
    mnuActiveCaption: TMenuItem;
    mnuApplicationWorkspace: TMenuItem;
    mnuBackground: TMenuItem;
    mnuButtonFace: TMenuItem;
    mnuButtonShadow: TMenuItem;
    mnuButtonText: TMenuItem;
    mnuCaptionText: TMenuItem;
    mnuGrayText: TMenuItem;
    mnuHighlight: TMenuItem;
    mnuHighlight2: TMenuItem;
    mnuHighlightText: TMenuItem;
    mnuInactiveBorder: TMenuItem;
    mnuInactiveCaption: TMenuItem;
    mnuInactiveCaptionText: TMenuItem;
    mnuInfoTipBackground: TMenuItem;
    mnuInfoTipText: TMenuItem;
    mnuMenu: TMenuItem;
    mnuNone: TMenuItem;
    mnuScrollBar: TMenuItem;
    mnuWindow: TMenuItem;
    mnuWindowFrame: TMenuItem;
    mnuWindowText: TMenuItem;
    Options: TTabSheet;
    PageControl: TPageControl;
    pnlGutterBack: TPanel;
    pnlGutterColor: TPanel;
    pnlCommands: TPanel;
    pnlEditorFont: TPanel;
    pnlGutterFontDisplay: TPanel;
    pnlRightEdgeBack: TPanel;
    pnlRightEdgeColor: TPanel;
    PROCEDURE PopupMenuClick(Sender: TObject);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE pnlGutterColorClick(Sender: TObject);
    PROCEDURE pnlRightEdgeColorClick(Sender: TObject);
    PROCEDURE btnFontClick(Sender: TObject);
    PROCEDURE KeyListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    PROCEDURE btnUpdateKeyClick(Sender: TObject);
    PROCEDURE btnAddKeyClick(Sender: TObject);
    PROCEDURE btnRemKeyClick(Sender: TObject);
    PROCEDURE FormShow(Sender: TObject);
    PROCEDURE KeyListEditing(Sender: TObject; Item: TListItem;
      VAR AllowEdit: Boolean);
    PROCEDURE btnOkClick(Sender: TObject);
    PROCEDURE btnGutterFontClick(Sender: TObject);
    PROCEDURE cbGutterFontClick(Sender: TObject);
    PROCEDURE btnRightEdgeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    PROCEDURE btnGutterColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    PROCEDURE cKeyCommandExit(Sender: TObject);
    PROCEDURE cKeyCommandKeyPress(Sender: TObject; VAR Key: Char);
    PROCEDURE cKeyCommandKeyUp(Sender: TObject; VAR Key: Word;
      Shift: TShiftState);
  PRIVATE
    FSynEdit: TSynEditorOptionsContainer;
    FKeys: TSynEditKeyStrokes;
    FPoppedFrom: TColorPopup;
    FUserCommand: TSynEditorOptionsUserCommand;
    FAllUserCommands: TSynEditorOptionsAllUserCommands;
    FOldSelected: TListItem;
    FInChanging: Boolean;
    FExtended: Boolean;
    FUNCTION GetColor(Item: TMenuItem): TColor;
    PROCEDURE GetData;
    PROCEDURE PutData;
    PROCEDURE EditStrCallback(CONST S: STRING);
    PROCEDURE FillInKeystrokeInfo(AKey: TSynEditKeyStroke; AItem: TListItem);
    PROCEDURE UpdateKey(AItem: TListItem);
    PROCEDURE DrawArrow(AImage: TImage);
    PROCEDURE ShowFontCaption(ALabel: TLabel);
  PUBLIC
    eKeyShort2: TSynHotKey;
    eKeyShort1: TSynHotKey;
    FUNCTION Execute(EditOptions: TSynEditorOptionsContainer): Boolean;
    PROPERTY GetUserCommandNames: TSynEditorOptionsUserCommand READ FUserCommand
      WRITE FUserCommand;
    PROPERTY GetAllUserCommands: TSynEditorOptionsAllUserCommands
      READ FAllUserCommands WRITE FAllUserCommands;
    PROPERTY UseExtendedStrings: Boolean READ FExtended WRITE FExtended;
  END;

  { TSynEditOptionsDialog }

  TSynEditOptionsDialog = CLASS(TComponent)
  PRIVATE
    FForm: TfmEditorOptionsDialog;
    FUNCTION GetUserCommandNames: TSynEditorOptionsUserCommand;
    PROCEDURE SetUserCommandNames(CONST Value: TSynEditorOptionsUserCommand);
    FUNCTION GetUserCommands: TSynEditorOptionsAllUserCommands;
    PROCEDURE SetUserCommands(CONST Value: TSynEditorOptionsAllUserCommands);
    FUNCTION GetExtended: Boolean;
    PROCEDURE SetExtended(CONST Value: Boolean);
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    FUNCTION Execute(EditOptions: TSynEditorOptionsContainer): Boolean;
    PROPERTY Form: TfmEditorOptionsDialog READ FForm;
  PUBLISHED
    PROPERTY GetUserCommand: TSynEditorOptionsUserCommand
      READ GetUserCommandNames WRITE SetUserCommandNames;
    PROPERTY GetAllUserCommands: TSynEditorOptionsAllUserCommands
      READ GetUserCommands WRITE SetUserCommands;
    PROPERTY UseExtendedStrings: Boolean READ GetExtended WRITE SetExtended;
  END;

  { TSynEditorOptionsGutter }

  TSynEditorOptionsGutter = CLASS(TPersistent)
  PRIVATE
    FAutoSize: Boolean;
    FColor: TColor;
    FDigitCount: Integer;
    FFont: TFont;
    FLeadingZeros: Boolean;
    FShowLineNumbers: Boolean;
    FUseFontStyle: Boolean;
    FVisible: Boolean;
    FWidth: Integer;
    FZeroStart: Boolean;
    PROCEDURE SetFont(CONST Value: TFont);
  PUBLIC
    CONSTRUCTOR Create;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
    PROCEDURE AssignTo(Dest: TPersistent); OVERRIDE;
  PUBLISHED
    PROPERTY AutoSize: Boolean READ FAutoSize WRITE FAutoSize DEFAULT True;
    PROPERTY Color: TColor READ FColor WRITE FColor DEFAULT clBtnFace;
    PROPERTY DigitCount: Integer READ FDigitCount WRITE FDigitCount DEFAULT 2;
    PROPERTY Font: TFont READ FFont WRITE SetFont;
    PROPERTY LeadingZeros: Boolean READ FLeadingZeros WRITE FLeadingZeros DEFAULT False;
    PROPERTY ShowLineNumbers: Boolean READ FShowLineNumbers WRITE FShowLineNumbers DEFAULT True;
    PROPERTY UseFontStyle: Boolean READ FUseFontStyle WRITE FUseFontStyle DEFAULT False;
    PROPERTY Visible: Boolean READ FVisible WRITE FVisible DEFAULT True;
    PROPERTY Width: Integer READ FWidth WRITE FWidth DEFAULT 30;
    PROPERTY ZeroStart: Boolean READ FZeroStart WRITE FZeroStart DEFAULT False;
  END;

  { TSynEditorOptionsContainer }

  //This class is assignable to a SynEdit without modifying key properties that affect function
  TSynEditorOptionsContainer = CLASS(TComponent)
  PRIVATE
    FHideSelection: Boolean;
    FWantTabs: Boolean;
    FMaxUndo: Integer;
    FExtraLineSpacing: Integer;
    FTabWidth: Integer;
    FMaxScrollWidth: Integer;
    FRightEdge: Integer;
    FSelectedColor: TSynSelectedColor;
    FRightEdgeColor: TColor;
    FFont: TFont;
    FBookmarks: TSynBookMarkOpt;
    FOverwriteCaret: TSynEditCaretType;
    FInsertCaret: TSynEditCaretType;
    FKeystrokes: TSynEditKeyStrokes;
    FOptions: TSynEditorOptions;
    FOptions2: TSynEditorOptions2;
    FSynGutter: TSynEditorOptionsGutter;
    FColor: TColor;
    PROCEDURE SetBookMarks(CONST Value: TSynBookMarkOpt);
    PROCEDURE SetFont(CONST Value: TFont);
    PROCEDURE SetKeystrokes(CONST Value: TSynEditKeyStrokes);
    PROCEDURE SetOptions(CONST Value: TSynEditorOptions);
    PROCEDURE SetSelectedColor(CONST Value: TSynSelectedColor);
    PROCEDURE SetSynGutter(CONST Value: TSynEditorOptionsGutter);
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;
    PROCEDURE Assign(Source: TPersistent); OVERRIDE;
    PROCEDURE AssignTo(Dest: TPersistent); OVERRIDE;
  PUBLISHED
    PROPERTY Options: TSynEditorOptions READ FOptions WRITE SetOptions;
    PROPERTY Options2: TSynEditorOptions2 READ FOptions2 WRITE FOptions2;
    PROPERTY BookMarkOptions: TSynBookMarkOpt READ FBookmarks WRITE SetBookMarks;
    PROPERTY Color: TColor READ FColor WRITE FColor;
    PROPERTY Font: TFont READ FFont WRITE SetFont;
    PROPERTY ExtraLineSpacing: Integer READ FExtraLineSpacing WRITE FExtraLineSpacing;
    PROPERTY Gutter: TSynEditorOptionsGutter READ FSynGutter WRITE SetSynGutter;
    PROPERTY RightEdge: Integer READ FRightEdge WRITE FRightEdge;
    PROPERTY RightEdgeColor: TColor READ FRightEdgeColor WRITE FRightEdgeColor;
    PROPERTY WantTabs: Boolean READ FWantTabs WRITE FWantTabs;
    PROPERTY InsertCaret: TSynEditCaretType READ FInsertCaret WRITE FInsertCaret;
    PROPERTY OverwriteCaret: TSynEditCaretType READ FOverwriteCaret WRITE FOverwriteCaret;
    PROPERTY HideSelection: Boolean READ FHideSelection WRITE FHideSelection;
    PROPERTY MaxScrollWidth: Integer READ FMaxScrollWidth WRITE FMaxScrollWidth;
    PROPERTY MaxUndo: Integer READ FMaxUndo WRITE FMaxUndo;
    PROPERTY SelectedColor: TSynSelectedColor READ FSelectedColor WRITE SetSelectedColor;
    PROPERTY TabWidth: Integer READ FTabWidth WRITE FTabWidth;
    PROPERTY Keystrokes: TSynEditKeyStrokes READ FKeystrokes WRITE SetKeystrokes;
  END;

FUNCTION ConvertCodeStringToExtended(AString: STRING): STRING;
FUNCTION ConvertExtendedToCodeString(AString: STRING): STRING;
FUNCTION ConvertCodeStringToCommand(AString: STRING): TSynEditorCommand;
FUNCTION ConvertExtendedToCommand(AString: STRING): TSynEditorCommand;
PROCEDURE GetEditorCommandExtended(Proc: TGetStrProc);

PROCEDURE Register;

IMPLEMENTATION

{$R *.lfm}

RESOURCESTRING
  SUserCommand = 'User Command';
  SFontCaption = '%s %dpt';

{ Extended command names }

TYPE
  TExtendedCollector = CLASS
    Target, Code: STRING;
    Proc: TGetStrProc;
    PROCEDURE Find(CONST S: STRING);
    PROCEDURE Emit(CONST S: STRING);
  END;

PROCEDURE TExtendedCollector.Find(CONST S: STRING);
// Remember the code string whose extended form matches Target
BEGIN
  IF (Code = '') AND SameText(ConvertCodeStringToExtended(S), Target) THEN
    Code := S;
END;

PROCEDURE TExtendedCollector.Emit(CONST S: STRING);
// Forward the extended form of S
BEGIN
  Proc(ConvertCodeStringToExtended(S));
END;

FUNCTION ConvertCodeStringToExtended(AString: STRING): STRING;
// 'ecSelLineStart' -> 'Select Line Start'
VAR
  I: Integer;
  WorkStr: STRING;
BEGIN
  IF Pos('ec', AString) <> 1 THEN
    Exit(AString);
  Delete(AString, 1, 2);
  WorkStr := '';
  FOR I := 1 TO Length(AString) DO
  BEGIN
    IF (I > 1) AND (AString[I] IN ['A'..'Z', '0'..'9'])
       AND NOT (AString[I - 1] IN ['A'..'Z', '0'..'9']) THEN
      WorkStr := WorkStr + ' ';
    WorkStr := WorkStr + AString[I];
  END;
  WorkStr := Trim(WorkStr);
  IF Pos('Sel ', WorkStr) = 1 THEN
    WorkStr := 'Select ' + Copy(WorkStr, 5, MaxInt);
  WorkStr := StringReplace(WorkStr, ' Sel ', ' Select ', [rfReplaceAll]);
  Result := WorkStr;
END;

FUNCTION ConvertExtendedToCodeString(AString: STRING): STRING;
// Reverse of ConvertCodeStringToExtended, looked up in the command list
VAR
  C: TExtendedCollector;
BEGIN
  IF Pos('ec', AString) = 1 THEN
    Exit(AString);
  C := TExtendedCollector.Create;
  TRY
    C.Target := AString;
    GetEditorCommandValues(C.Find);
    IF C.Code <> '' THEN
      Result := C.Code
    ELSE
      Result := 'ec' + StringReplace(AString, ' ', '', [rfReplaceAll]);
  FINALLY
    C.Free;
  END;
END;

FUNCTION ConvertCodeStringToCommand(AString: STRING): TSynEditorCommand;
// Command value of a code string, ecNone if unknown
VAR
  Cmd: LongInt;
BEGIN
  Cmd := ecNone;
  IF NOT IdentToEditorCommand(AString, Cmd) THEN
    Cmd := ecNone;
  Result := Cmd;
END;

FUNCTION ConvertExtendedToCommand(AString: STRING): TSynEditorCommand;
// Command value of an extended string
BEGIN
  Result := ConvertCodeStringToCommand(ConvertExtendedToCodeString(AString));
END;

PROCEDURE GetEditorCommandExtended(Proc: TGetStrProc);
// Same as GetEditorCommandValues with extended strings
VAR
  C: TExtendedCollector;
BEGIN
  C := TExtendedCollector.Create;
  TRY
    C.Proc := Proc;
    GetEditorCommandValues(C.Emit);
  FINALLY
    C.Free;
  END;
END;

{ TSynHotKey }

CONSTRUCTOR TSynHotKey.Create(AOwner: TComponent);
// Edit used to capture a key combination
BEGIN
  INHERITED Create(AOwner);
  FHotKey := 0;
  FInvalidKeys := [];
  FModifiers := [];
  Text := '';
END;

PROCEDURE TSynHotKey.SetHotKey(CONST Value: TShortCut);
// Store and display the shortcut
BEGIN
  FHotKey := Value;
  IF Value = 0 THEN
    Text := ''
  ELSE
    Text := ShortCutToText(Value);
  SelStart := Length(Text);
END;

PROCEDURE TSynHotKey.ShowShift(AShift: TShiftState);
// Display the modifiers being pressed (e.g. 'Ctrl+')
VAR
  S: STRING;
BEGIN
  S := '';
  IF ssCtrl IN AShift THEN S := S + 'Ctrl+';
  IF ssShift IN AShift THEN S := S + 'Shift+';
  IF ssAlt IN AShift THEN S := S + 'Alt+';
  IF ssMeta IN AShift THEN S := S + 'Meta+';
  Text := S;
  SelStart := Length(Text);
END;

PROCEDURE TSynHotKey.WMGetDlgCode(VAR Message: TLMessage);
// Receive Tab, arrows, Enter and Escape as normal keys
BEGIN
  Message.Result := DLGC_WANTTAB OR DLGC_WANTARROWS OR DLGC_WANTALLKEYS;
END;

PROCEDURE TSynHotKey.KeyDown(VAR Key: Word; Shift: TShiftState);
// Build the shortcut from the key and the modifiers
VAR
  Combo: TSynHKInvalidKey;
BEGIN
  Shift := Shift * [ssShift, ssCtrl, ssAlt, ssMeta];
  IF Key IN [VK_SHIFT, VK_CONTROL, VK_MENU, VK_LSHIFT, VK_RSHIFT,
             VK_LCONTROL, VK_RCONTROL, VK_LMENU, VK_RMENU, VK_LWIN, VK_RWIN] THEN
  BEGIN
    ShowShift(Shift);
    Key := 0;
    Exit;
  END;
  // Apply the invalid combinations / default modifiers rules
  Combo := TSynHKInvalidKey(Ord(ssShift IN Shift) + 2 * Ord(ssCtrl IN Shift)
    + 4 * Ord(ssAlt IN Shift));
  IF Combo IN FInvalidKeys THEN
  BEGIN
    Shift := Shift - [ssShift, ssCtrl, ssAlt];
    IF hkShift IN FModifiers THEN Include(Shift, ssShift);
    IF hkCtrl IN FModifiers THEN Include(Shift, ssCtrl);
    IF hkAlt IN FModifiers THEN Include(Shift, ssAlt);
  END;
  HotKey := Menus.ShortCut(Key, Shift);
  Key := 0;
END;

PROCEDURE TSynHotKey.KeyUp(VAR Key: Word; Shift: TShiftState);
// Restore the shortcut text when only modifiers were pressed
BEGIN
  IF Shift * [ssShift, ssCtrl, ssAlt, ssMeta] = [] THEN
    SetHotKey(FHotKey)
  ELSE IF FHotKey = 0 THEN
    ShowShift(Shift);
  SelStart := Length(Text);
  Key := 0;
END;

PROCEDURE TSynHotKey.KeyPress(VAR Key: Char);
// No typed text
BEGIN
  IF Key <> #0 THEN
    Key := #0;
END;

PROCEDURE TSynHotKey.UTF8KeyPress(VAR UTF8Key: TUTF8Char);
// No typed text
BEGIN
  IF UTF8Key <> '' THEN
    UTF8Key := '';
END;

PROCEDURE TSynHotKey.DoEnter;
// Caret at the end
BEGIN
  INHERITED DoEnter;
  SelStart := Length(Text);
END;

{ TSynEditOptionsDialog }

CONSTRUCTOR TSynEditOptionsDialog.Create(AOwner: TComponent);
// Create the hidden form
BEGIN
  INHERITED Create(AOwner);
  FForm := TfmEditorOptionsDialog.Create(Self);
END;

DESTRUCTOR TSynEditOptionsDialog.Destroy;
// Free the form
BEGIN
  FForm.Free;
  INHERITED Destroy;
END;

FUNCTION TSynEditOptionsDialog.Execute(EditOptions: TSynEditorOptionsContainer): Boolean;
// Show the dialog
BEGIN
  Result := FForm.Execute(EditOptions);
END;

FUNCTION TSynEditOptionsDialog.GetUserCommands: TSynEditorOptionsAllUserCommands;
// Event getter
BEGIN
  Result := FForm.GetAllUserCommands;
END;

FUNCTION TSynEditOptionsDialog.GetUserCommandNames: TSynEditorOptionsUserCommand;
// Event getter
BEGIN
  Result := FForm.GetUserCommandNames;
END;

PROCEDURE TSynEditOptionsDialog.SetUserCommands(
  CONST Value: TSynEditorOptionsAllUserCommands);
// Event setter
BEGIN
  FForm.GetAllUserCommands := Value;
END;

PROCEDURE TSynEditOptionsDialog.SetUserCommandNames(
  CONST Value: TSynEditorOptionsUserCommand);
// Event setter
BEGIN
  FForm.GetUserCommandNames := Value;
END;

FUNCTION TSynEditOptionsDialog.GetExtended: Boolean;
// Property getter
BEGIN
  Result := FForm.UseExtendedStrings;
END;

PROCEDURE TSynEditOptionsDialog.SetExtended(CONST Value: Boolean);
// Property setter
BEGIN
  FForm.UseExtendedStrings := Value;
END;

{ TSynEditorOptionsGutter }

CONSTRUCTOR TSynEditorOptionsGutter.Create;
// Defaults of the Delphi gutter
BEGIN
  INHERITED Create;
  FFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 8;
  FAutoSize := True;
  FColor := clBtnFace;
  FDigitCount := 2;
  FShowLineNumbers := True;
  FVisible := True;
  FWidth := 30;
END;

DESTRUCTOR TSynEditorOptionsGutter.Destroy;
// Free the font
BEGIN
  FFont.Free;
  INHERITED Destroy;
END;

PROCEDURE TSynEditorOptionsGutter.SetFont(CONST Value: TFont);
// Copy the font
BEGIN
  FFont.Assign(Value);
END;

PROCEDURE TSynEditorOptionsGutter.Assign(Source: TPersistent);
// Copy from another options gutter or from a Lazarus TSynGutter
VAR
  Src: TSynEditorOptionsGutter;
  G: TSynGutter;
  LN: TSynGutterLineNumber;
BEGIN
  IF Source IS TSynEditorOptionsGutter THEN
  BEGIN
    Src := TSynEditorOptionsGutter(Source);
    FAutoSize := Src.FAutoSize;
    FColor := Src.FColor;
    FDigitCount := Src.FDigitCount;
    FFont.Assign(Src.FFont);
    FLeadingZeros := Src.FLeadingZeros;
    FShowLineNumbers := Src.FShowLineNumbers;
    FUseFontStyle := Src.FUseFontStyle;
    FVisible := Src.FVisible;
    FWidth := Src.FWidth;
    FZeroStart := Src.FZeroStart;
  END
  ELSE IF Source IS TSynGutter THEN
  BEGIN
    G := TSynGutter(Source);
    FAutoSize := G.AutoSize;
    FVisible := G.Visible;
    FWidth := G.Width;
    FColor := G.Color;
    LN := G.LineNumberPart;
    IF Assigned(LN) THEN
    BEGIN
      FShowLineNumbers := LN.Visible;
      FLeadingZeros := LN.LeadingZeros;
      FZeroStart := LN.ZeroStart;
      FDigitCount := LN.DigitCount;
      IF LN.MarkupInfo.Background <> clNone THEN
        FColor := LN.MarkupInfo.Background;
      FUseFontStyle := (LN.MarkupInfo.Foreground <> clNone)
        OR (LN.MarkupInfo.Style <> []);
      IF LN.MarkupInfo.Foreground <> clNone THEN
        FFont.Color := LN.MarkupInfo.Foreground;
      FFont.Style := LN.MarkupInfo.Style;
    END
    ELSE
      FShowLineNumbers := False;
  END
  ELSE
    INHERITED Assign(Source);
END;

PROCEDURE TSynEditorOptionsGutter.AssignTo(Dest: TPersistent);
// Apply to a Lazarus TSynGutter
VAR
  G: TSynGutter;
  LN: TSynGutterLineNumber;
  I: Integer;
BEGIN
  IF Dest IS TSynEditorOptionsGutter THEN
    TSynEditorOptionsGutter(Dest).Assign(Self)
  ELSE IF Dest IS TSynGutter THEN
  BEGIN
    G := TSynGutter(Dest);
    BEGIN
      G.Visible := FVisible;
      G.AutoSize := FAutoSize;
      IF NOT FAutoSize THEN
        G.Width := FWidth;
      IF FColor = clNone THEN
        G.Color := clBtnFace
      ELSE
        G.Color := FColor;
      // Parts paint their own background in Lazarus
      FOR I := 0 TO G.Parts.Count - 1 DO
        IF NOT (G.Parts[I] IS TSynGutterSeparator) THEN
          G.Parts[I].MarkupInfo.Background := FColor;
      LN := G.LineNumberPart;
      IF Assigned(LN) THEN
      BEGIN
        LN.Visible := FShowLineNumbers;
        LN.LeadingZeros := FLeadingZeros;
        LN.ZeroStart := FZeroStart;
        LN.DigitCount := FDigitCount;
        IF FUseFontStyle THEN
        BEGIN
          LN.MarkupInfo.Foreground := FFont.Color;
          LN.MarkupInfo.Style := FFont.Style;
        END
        ELSE
        BEGIN
          LN.MarkupInfo.Foreground := clNone;
          LN.MarkupInfo.Style := [];
        END;
      END;
    END;
  END
  ELSE
    INHERITED AssignTo(Dest);
END;

{ TSynEditorOptionsContainer }

PROCEDURE CopyBookMarks(Dest, Src: TSynBookMarkOpt);
// TSynBookMarkOpt has no Assign in Lazarus
BEGIN
  Dest.BookmarkImages := Src.BookmarkImages;
  Dest.DrawBookmarksFirst := Src.DrawBookmarksFirst;
  Dest.EnableKeys := Src.EnableKeys;
  Dest.GlyphsVisible := Src.GlyphsVisible;
  Dest.LeftMargin := Src.LeftMargin;
  Dest.Xoffset := Src.Xoffset;
END;

PROCEDURE TSynEditorOptionsContainer.Assign(Source: TPersistent);
// Read the options of a SynEdit or of another container
VAR
  Src: TSynEditorOptionsContainer;
BEGIN
  IF Assigned(Source) AND (Source IS TCustomSynEdit) THEN
  BEGIN
    Self.Font.Assign(TCustomSynEdit(Source).Font);
    CopyBookMarks(Self.BookMarkOptions, TCustomSynEdit(Source).BookMarkOptions);
    Self.Gutter.Assign(TCustomSynEdit(Source).Gutter);
    Self.Keystrokes.Assign(TCustomSynEdit(Source).Keystrokes);
    Self.SelectedColor.Assign(TCustomSynEdit(Source).SelectedColor);

    Self.Color := TCustomSynEdit(Source).Color;
    Self.Options := TCustomSynEdit(Source).Options;
    Self.Options2 := TCustomSynEdit(Source).Options2;
    Self.ExtraLineSpacing := TCustomSynEdit(Source).ExtraLineSpacing;
    Self.HideSelection := TCustomSynEdit(Source).HideSelection;
    Self.InsertCaret := TCustomSynEdit(Source).InsertCaret;
    Self.OverwriteCaret := TCustomSynEdit(Source).OverwriteCaret;
    Self.MaxUndo := TCustomSynEdit(Source).MaxUndo;
    Self.RightEdge := TCustomSynEdit(Source).RightEdge;
    Self.RightEdgeColor := TCustomSynEdit(Source).RightEdgeColor;
    Self.TabWidth := TCustomSynEdit(Source).TabWidth;
    Self.WantTabs := TCustomSynEdit(Source).WantTabs;
  END
  ELSE IF Assigned(Source) AND (Source IS TSynEditorOptionsContainer) THEN
  BEGIN
    Src := TSynEditorOptionsContainer(Source);
    Font.Assign(Src.Font);
    CopyBookMarks(BookMarkOptions, Src.BookMarkOptions);
    Gutter.Assign(Src.Gutter);
    Keystrokes.Assign(Src.Keystrokes);
    SelectedColor.Assign(Src.SelectedColor);
    Color := Src.Color;
    Options := Src.Options;
    Options2 := Src.Options2;
    ExtraLineSpacing := Src.ExtraLineSpacing;
    HideSelection := Src.HideSelection;
    InsertCaret := Src.InsertCaret;
    OverwriteCaret := Src.OverwriteCaret;
    MaxScrollWidth := Src.MaxScrollWidth;
    MaxUndo := Src.MaxUndo;
    RightEdge := Src.RightEdge;
    RightEdgeColor := Src.RightEdgeColor;
    TabWidth := Src.TabWidth;
    WantTabs := Src.WantTabs;
  END
  ELSE
    INHERITED Assign(Source);
END;

PROCEDURE TSynEditorOptionsContainer.AssignTo(Dest: TPersistent);
// Apply the options to a SynEdit
BEGIN
  IF Assigned(Dest) AND (Dest IS TCustomSynEdit) THEN
  BEGIN
    TCustomSynEdit(Dest).BeginUpdate;
    TRY
      TCustomSynEdit(Dest).Font.Assign(Self.Font);
      CopyBookMarks(TCustomSynEdit(Dest).BookMarkOptions, Self.BookMarkOptions);
      Self.Gutter.AssignTo(TCustomSynEdit(Dest).Gutter);
      TCustomSynEdit(Dest).Keystrokes.Assign(Self.Keystrokes);
      TCustomSynEdit(Dest).SelectedColor.Assign(Self.SelectedColor);

      TCustomSynEdit(Dest).Color := Self.Color;
      TCustomSynEdit(Dest).Options := Self.Options;
      TCustomSynEdit(Dest).Options2 := Self.Options2;
      TCustomSynEdit(Dest).ExtraLineSpacing := Self.ExtraLineSpacing;
      TCustomSynEdit(Dest).HideSelection := Self.HideSelection;
      TCustomSynEdit(Dest).InsertCaret := Self.InsertCaret;
      TCustomSynEdit(Dest).OverwriteCaret := Self.OverwriteCaret;
      TCustomSynEdit(Dest).MaxUndo := Self.MaxUndo;
      TCustomSynEdit(Dest).RightEdge := Self.RightEdge;
      TCustomSynEdit(Dest).RightEdgeColor := Self.RightEdgeColor;
      TCustomSynEdit(Dest).TabWidth := Self.TabWidth;
      TCustomSynEdit(Dest).WantTabs := Self.WantTabs;
    FINALLY
      TCustomSynEdit(Dest).EndUpdate;
    END;
  END
  ELSE
    INHERITED AssignTo(Dest);
END;

CONSTRUCTOR TSynEditorOptionsContainer.Create(AOwner: TComponent);
// Same defaults as the Delphi container
BEGIN
  INHERITED Create(AOwner);
  FBookmarks := TSynBookMarkOpt.Create(Self);
  FKeystrokes := TSynEditKeyStrokes.Create(Self);
  FSynGutter := TSynEditorOptionsGutter.Create;
  FSelectedColor := TSynSelectedColor.Create;
  FSelectedColor.Foreground := clHighlightText;
  FSelectedColor.Background := clHighlight;
  FFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 8;
  Color := clWindow;
  Keystrokes.ResetDefaults;
  Options := [eoAutoIndent, eoDragDropEditing, eoDropFiles, eoScrollPastEol,
    eoShowScrollHint, eoSmartTabs, eoAltSetsColumnMode, eoTabsToSpaces,
    eoTrimTrailingSpaces, eoKeepCaretX];
  Options2 := [];
  ExtraLineSpacing := 0;
  HideSelection := False;
  InsertCaret := ctVerticalLine;
  OverwriteCaret := ctBlock;
  MaxScrollWidth := 1024;
  MaxUndo := 1024;
  RightEdge := 80;
  RightEdgeColor := clSilver;
  TabWidth := 8;
  WantTabs := True;
END;

DESTRUCTOR TSynEditorOptionsContainer.Destroy;
// Free owned objects
BEGIN
  FBookmarks.Free;
  FKeystrokes.Free;
  FSynGutter.Free;
  FSelectedColor.Free;
  FFont.Free;
  INHERITED Destroy;
END;

PROCEDURE TSynEditorOptionsContainer.SetBookMarks(CONST Value: TSynBookMarkOpt);
// Copy bookmark options
BEGIN
  CopyBookMarks(FBookmarks, Value);
END;

PROCEDURE TSynEditorOptionsContainer.SetFont(CONST Value: TFont);
// Copy the font
BEGIN
  FFont.Assign(Value);
END;

PROCEDURE TSynEditorOptionsContainer.SetKeystrokes(CONST Value: TSynEditKeyStrokes);
// Copy the keystrokes
BEGIN
  FKeystrokes.Assign(Value);
END;

PROCEDURE TSynEditorOptionsContainer.SetOptions(CONST Value: TSynEditorOptions);
// Store the options
BEGIN
  FOptions := Value;
END;

PROCEDURE TSynEditorOptionsContainer.SetSelectedColor(CONST Value: TSynSelectedColor);
// Copy the selection colors
BEGIN
  FSelectedColor.Assign(Value);
END;

PROCEDURE TSynEditorOptionsContainer.SetSynGutter(CONST Value: TSynEditorOptionsGutter);
// Copy the gutter options
BEGIN
  FSynGutter.Assign(Value);
END;

{ TfmEditorOptionsDialog }

FUNCTION TfmEditorOptionsDialog.Execute(EditOptions: TSynEditorOptionsContainer): Boolean;
// Load, show, and store on OK
BEGIN
  IF EditOptions = NIL THEN
  BEGIN
    Result := False;
    Exit;
  END;
  //Assign the Containers
  FSynEdit := EditOptions;
  //Get Data
  GetData;
  //Show the form
  Result := ShowModal = mrOk;
  //PutData
  IF Result THEN
    PutData;
END;

PROCEDURE TfmEditorOptionsDialog.ShowFontCaption(ALabel: TLabel);
// 'Courier New 10pt'
BEGIN
  ALabel.Caption := Format(SFontCaption, [ALabel.Font.Name, ALabel.Font.Size]);
END;

PROCEDURE TfmEditorOptionsDialog.GetData;
// Container -> controls
VAR
  I: Integer;
  Item: TListItem;
BEGIN
  //Gutter
  ckGutterVisible.Checked := FSynEdit.Gutter.Visible;
  ckGutterAutosize.Checked := FSynEdit.Gutter.AutoSize;
  ckGutterShowLineNumbers.Checked := FSynEdit.Gutter.ShowLineNumbers;
  ckGutterShowLeaderZeros.Checked := FSynEdit.Gutter.LeadingZeros;
  ckGutterStartAtZero.Checked := FSynEdit.Gutter.ZeroStart;
  cbGutterFont.Checked := FSynEdit.Gutter.UseFontStyle;
  cbGutterFontClick(cbGutterFont);
  pnlGutterColor.Color := FSynEdit.Gutter.Color;
  lblGutterFont.Font.Assign(FSynEdit.Gutter.Font);
  ShowFontCaption(lblGutterFont);
  //Right Edge
  eRightEdge.Text := IntToStr(FSynEdit.RightEdge);
  pnlRightEdgeColor.Color := FSynEdit.RightEdgeColor;
  //Line Spacing
  eLineSpacing.Text := IntToStr(FSynEdit.ExtraLineSpacing);
  eTabWidth.Text := IntToStr(FSynEdit.TabWidth);
  //Bookmarks
  ckBookmarkKeys.Checked := FSynEdit.BookMarkOptions.EnableKeys;
  ckBookmarkVisible.Checked := FSynEdit.BookMarkOptions.GlyphsVisible;
  //Font
  lblFont.Font.Assign(FSynEdit.Font);
  ShowFontCaption(lblFont);
  //Options
  ckAutoIndent.Checked := eoAutoIndent IN FSynEdit.Options;
  ckAutoSizeMaxWidth.Checked := eoAutoSizeMaxScrollWidth IN FSynEdit.Options;
  ckDragAndDropEditing.Checked := eoDragDropEditing IN FSynEdit.Options;
  ckWantTabs.Checked := FSynEdit.WantTabs;
  ckSmartTabs.Checked := eoSmartTabs IN FSynEdit.Options;
  ckAltSetsColumnMode.Checked := eoAltSetsColumnMode IN FSynEdit.Options;
  ckHalfPageScroll.Checked := eoHalfPageScroll IN FSynEdit.Options;
  ckScrollByOneLess.Checked := eoScrollByOneLess IN FSynEdit.Options;
  ckScrollPastEOF.Checked := eoScrollPastEof IN FSynEdit.Options;
  ckScrollPastEOL.Checked := eoScrollPastEol IN FSynEdit.Options;
  ckShowScrollHint.Checked := eoShowScrollHint IN FSynEdit.Options;
  ckScrollHintFollows.Checked := eoScrollHintFollows IN FSynEdit.Options;
  ckTabsToSpaces.Checked := eoTabsToSpaces IN FSynEdit.Options;
  ckTrimTrailingSpaces.Checked := eoTrimTrailingSpaces IN FSynEdit.Options;
  ckKeepCaretX.Checked := eoKeepCaretX IN FSynEdit.Options;
  ckSmartTabDelete.Checked := eoSmartTabDelete IN FSynEdit.Options;
  ckRightMouseMoves.Checked := eoRightMouseMovesCursor IN FSynEdit.Options;
  ckEnhanceHomeKey.Checked := eoEnhanceHomeKey IN FSynEdit.Options;
  ckEnhanceEndKey.Checked := eoEnhanceEndKey IN FSynEdit.Options2;
  ckGroupUndo.Checked := eoGroupUndo IN FSynEdit.Options;
  ckTabIndent.Checked := eoTabIndent IN FSynEdit.Options;
  ckDisableScrollArrows.Checked := eoDisableScrollArrows IN FSynEdit.Options;
  ckHideShowScrollbars.Checked := eoHideShowScrollbars IN FSynEdit.Options;
  ckShowSpecialChars.Checked := eoShowSpecialChars IN FSynEdit.Options;

  //Caret (ctCostum has no entry in the combo)
  IF FSynEdit.InsertCaret <= ctBlock THEN
    cInsertCaret.ItemIndex := Ord(FSynEdit.InsertCaret)
  ELSE
    cInsertCaret.ItemIndex := -1;
  IF FSynEdit.OverwriteCaret <= ctBlock THEN
    cOverwriteCaret.ItemIndex := Ord(FSynEdit.OverwriteCaret)
  ELSE
    cOverwriteCaret.ItemIndex := -1;

  //Keystrokes: edited on a copy, stored on OK only
  FKeys.Assign(FSynEdit.Keystrokes);
  FOldSelected := NIL;
  FInChanging := True;
  KeyList.Items.BeginUpdate;
  TRY
    KeyList.Items.Clear;
    FOR I := 0 TO FKeys.Count - 1 DO
    BEGIN
      Item := KeyList.Items.Add;
      FillInKeystrokeInfo(FKeys.Items[I], Item);
      Item.Data := FKeys.Items[I];
    END;
  FINALLY
    KeyList.Items.EndUpdate;
    FInChanging := False;
  END;
  IF KeyList.Items.Count > 0 THEN
    KeyList.Items[0].Selected := True;
END;

PROCEDURE TfmEditorOptionsDialog.PutData;
// Controls -> container
VAR
  vOptions: TSynEditorOptions;
  vOptions2: TSynEditorOptions2;

  PROCEDURE SetFlag(aOption: TSynEditorOption; aValue: Boolean);
  // Include or exclude one option
  BEGIN
    IF aValue THEN
      Include(vOptions, aOption)
    ELSE
      Exclude(vOptions, aOption);
  END;

BEGIN
  //Gutter
  FSynEdit.Gutter.Visible := ckGutterVisible.Checked;
  FSynEdit.Gutter.AutoSize := ckGutterAutosize.Checked;
  FSynEdit.Gutter.ShowLineNumbers := ckGutterShowLineNumbers.Checked;
  FSynEdit.Gutter.LeadingZeros := ckGutterShowLeaderZeros.Checked;
  FSynEdit.Gutter.ZeroStart := ckGutterStartAtZero.Checked;
  FSynEdit.Gutter.Color := pnlGutterColor.Color;
  FSynEdit.Gutter.UseFontStyle := cbGutterFont.Checked;
  FSynEdit.Gutter.Font.Assign(lblGutterFont.Font);
  //Right Edge
  FSynEdit.RightEdge := StrToIntDef(eRightEdge.Text, 80);
  FSynEdit.RightEdgeColor := pnlRightEdgeColor.Color;
  //Line Spacing
  FSynEdit.ExtraLineSpacing := StrToIntDef(eLineSpacing.Text, 0);
  FSynEdit.TabWidth := StrToIntDef(eTabWidth.Text, 8);
  //Bookmarks
  FSynEdit.BookMarkOptions.EnableKeys := ckBookmarkKeys.Checked;
  FSynEdit.BookMarkOptions.GlyphsVisible := ckBookmarkVisible.Checked;
  //Font
  FSynEdit.Font.Assign(lblFont.Font);
  //Options
  FSynEdit.WantTabs := ckWantTabs.Checked;
  vOptions := FSynEdit.Options; //Keep old values for unsupported options
  SetFlag(eoAutoIndent, ckAutoIndent.Checked);
  SetFlag(eoAutoSizeMaxScrollWidth, ckAutoSizeMaxWidth.Checked);
  SetFlag(eoDragDropEditing, ckDragAndDropEditing.Checked);
  SetFlag(eoSmartTabs, ckSmartTabs.Checked);
  SetFlag(eoAltSetsColumnMode, ckAltSetsColumnMode.Checked);
  SetFlag(eoHalfPageScroll, ckHalfPageScroll.Checked);
  SetFlag(eoScrollByOneLess, ckScrollByOneLess.Checked);
  SetFlag(eoScrollPastEof, ckScrollPastEOF.Checked);
  SetFlag(eoScrollPastEol, ckScrollPastEOL.Checked);
  SetFlag(eoShowScrollHint, ckShowScrollHint.Checked);
  SetFlag(eoScrollHintFollows, ckScrollHintFollows.Checked);
  SetFlag(eoTabIndent, ckTabIndent.Checked);
  SetFlag(eoTabsToSpaces, ckTabsToSpaces.Checked);
  SetFlag(eoTrimTrailingSpaces, ckTrimTrailingSpaces.Checked);
  SetFlag(eoKeepCaretX, ckKeepCaretX.Checked);
  SetFlag(eoSmartTabDelete, ckSmartTabDelete.Checked);
  SetFlag(eoRightMouseMovesCursor, ckRightMouseMoves.Checked);
  SetFlag(eoEnhanceHomeKey, ckEnhanceHomeKey.Checked);
  SetFlag(eoGroupUndo, ckGroupUndo.Checked);
  SetFlag(eoDisableScrollArrows, ckDisableScrollArrows.Checked);
  SetFlag(eoHideShowScrollbars, ckHideShowScrollbars.Checked);
  SetFlag(eoShowSpecialChars, ckShowSpecialChars.Checked);
  FSynEdit.Options := vOptions;
  vOptions2 := FSynEdit.Options2;
  IF ckEnhanceEndKey.Checked THEN
    Include(vOptions2, eoEnhanceEndKey)
  ELSE
    Exclude(vOptions2, eoEnhanceEndKey);
  FSynEdit.Options2 := vOptions2;
  //Caret
  IF cInsertCaret.ItemIndex >= 0 THEN
    FSynEdit.InsertCaret := TSynEditCaretType(cInsertCaret.ItemIndex);
  IF cOverwriteCaret.ItemIndex >= 0 THEN
    FSynEdit.OverwriteCaret := TSynEditCaretType(cOverwriteCaret.ItemIndex);
  //Keystrokes
  FSynEdit.Keystrokes.Assign(FKeys);
END;

FUNCTION TfmEditorOptionsDialog.GetColor(Item: TMenuItem): TColor;
// Menu tag -> system color (-1 = None)
BEGIN
  IF (Item.Tag = -1) OR (Item.Tag > 24) THEN
    Result := clNone
  ELSE
    Result := TColor(SYS_COLOR_BASE OR Byte(Item.Tag));
END;

PROCEDURE TfmEditorOptionsDialog.PopupMenuClick(Sender: TObject);
// Set the color based on where it was "popped from"
VAR
  C: TColor;
BEGIN
  C := GetColor(TMenuItem(Sender));
  IF FPoppedFrom = cpGutter THEN
    pnlGutterColor.Color := C
  ELSE IF FPoppedFrom = cpRightEdge THEN
    pnlRightEdgeColor.Color := C;
END;

PROCEDURE TfmEditorOptionsDialog.DrawArrow(AImage: TImage);
// Small down arrow of the color buttons
BEGIN
  AImage.Picture.Bitmap.SetSize(5, 5);
  AImage.Picture.Bitmap.Transparent := True;
  WITH AImage.Picture.Bitmap.Canvas DO
  BEGIN
    Brush.Color := clFuchsia;
    FillRect(0, 0, 5, 5);
    Pen.Color := clBlack;
    MoveTo(0, 1); LineTo(5, 1);
    MoveTo(1, 2); LineTo(4, 2);
    MoveTo(2, 3); LineTo(3, 3);
  END;
  AImage.Picture.Bitmap.TransparentColor := clFuchsia;
END;

PROCEDURE TfmEditorOptionsDialog.FormCreate(Sender: TObject);
// Color images, arrows and hot key edits
VAR
  I: Integer;
  C: TColor;
  B: TBitmap;
BEGIN
  FInChanging := False;
  FKeys := TSynEditKeyStrokes.Create(Self);
  B := TBitmap.Create;
  TRY
    B.SetSize(16, 16);
    //Loop through and create colored images
    FOR I := 0 TO ColorPopup.Items.Count - 1 DO
    BEGIN
      IF ColorPopup.Items[I].Tag = -1 THEN
        Continue;
      C := GetColor(ColorPopup.Items[I]);
      B.Canvas.Brush.Color := C;
      B.Canvas.Brush.Style := bsSolid;
      B.Canvas.Pen.Style := psSolid;
      B.Canvas.Pen.Color := clBlack;
      B.Canvas.Rectangle(0, 0, 16, 16);
      ColorPopup.Items[I].ImageIndex := ImageList.Add(B, NIL);
    END;
  FINALLY
    B.Free;
  END;
  DrawArrow(Image1);
  DrawArrow(Image2);

  eKeyShort1 := TSynHotKey.Create(Self);
  WITH eKeyShort1 DO
  BEGIN
    Parent := gbKeyStrokes;
    Left := 120;
    Top := 55;
    Width := 185;
    Height := 21;
    HotKey := 0;
    InvalidKeys := [];
    Modifiers := [];
    TabOrder := 1;
  END;

  eKeyShort2 := TSynHotKey.Create(Self);
  WITH eKeyShort2 DO
  BEGIN
    Parent := gbKeyStrokes;
    Left := 120;
    Top := 87;
    Width := 185;
    Height := 21;
    HotKey := 0;
    InvalidKeys := [];
    Modifiers := [];
    TabOrder := 2;
  END;
END;

PROCEDURE TfmEditorOptionsDialog.FormDestroy(Sender: TObject);
// Keystroke copy is owned by the form
BEGIN
  FreeAndNil(FKeys);
END;

PROCEDURE TfmEditorOptionsDialog.pnlGutterColorClick(Sender: TObject);
// Custom gutter color
BEGIN
  ColorDialog.Color := pnlGutterColor.Color;
  IF ColorDialog.Execute THEN
    pnlGutterColor.Color := ColorDialog.Color;
END;

PROCEDURE TfmEditorOptionsDialog.pnlRightEdgeColorClick(Sender: TObject);
// Custom right edge color
BEGIN
  ColorDialog.Color := pnlRightEdgeColor.Color;
  IF ColorDialog.Execute THEN
    pnlRightEdgeColor.Color := ColorDialog.Color;
END;

PROCEDURE TfmEditorOptionsDialog.btnFontClick(Sender: TObject);
// Editor font
BEGIN
  FontDialog.Font.Assign(lblFont.Font);
  IF FontDialog.Execute THEN
  BEGIN
    lblFont.Font.Assign(FontDialog.Font);
    ShowFontCaption(lblFont);
  END;
END;

PROCEDURE TfmEditorOptionsDialog.KeyListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
// Save the item being left, then show the selected one
BEGIN
  IF FInChanging THEN
    Exit;
  IF NOT Selected THEN
  BEGIN
    //make sure that it's saved (Delphi OnChanging)
    IF Visible AND (Item = FOldSelected) AND Assigned(Item) AND Assigned(Item.Data)
       AND ((Item.Caption <> cKeyCommand.Text)
         OR (TSynEditKeyStroke(Item.Data).ShortCut <> eKeyShort1.HotKey)
         OR (TSynEditKeyStroke(Item.Data).ShortCut2 <> eKeyShort2.HotKey)) THEN
    BEGIN
      FInChanging := True;
      TRY
        UpdateKey(Item);
      FINALLY
        FInChanging := False;
      END;
    END;
    Exit;
  END;
  IF KeyList.Selected = NIL THEN
    Exit;
  cKeyCommand.Text := KeyList.Selected.Caption;
  cKeyCommand.ItemIndex := cKeyCommand.Items.IndexOf(KeyList.Selected.Caption);
  eKeyShort1.HotKey := TSynEditKeyStroke(KeyList.Selected.Data).ShortCut;
  eKeyShort2.HotKey := TSynEditKeyStroke(KeyList.Selected.Data).ShortCut2;
  FOldSelected := Item;
END;

PROCEDURE TfmEditorOptionsDialog.UpdateKey(AItem: TListItem);
// Store command and shortcuts into the keystroke of AItem
VAR
  Cmd: Integer;
  K: TSynEditKeyStroke;
BEGIN
  IF (AItem = NIL) OR (AItem.Data = NIL) THEN
    Exit;
  IF cKeyCommand.ItemIndex < 0 THEN
    Exit;
  Cmd := Integer(PtrInt(cKeyCommand.Items.Objects[cKeyCommand.ItemIndex]));
  K := TSynEditKeyStroke(AItem.Data);
  K.Command := Cmd;
  TRY
    IF eKeyShort1.HotKey <> 0 THEN
      K.ShortCut := eKeyShort1.HotKey;
    IF eKeyShort2.HotKey <> 0 THEN
      K.ShortCut2 := eKeyShort2.HotKey;
  EXCEPT
    ON E: ESynKeyError DO
      MessageDlg(E.Message, mtError, [mbOK], 0);
  END;
  FillInKeystrokeInfo(K, AItem);
END;

PROCEDURE TfmEditorOptionsDialog.btnUpdateKeyClick(Sender: TObject);
// Update the selected keystroke (adds one if none is selected)
BEGIN
  IF (KeyList.Selected = NIL) AND (Sender <> btnAddKey) THEN
  BEGIN
    btnAddKey.Click;
    Exit;
  END;
  IF KeyList.Selected = NIL THEN
    Exit;
  FOldSelected := KeyList.Selected;
  UpdateKey(KeyList.Selected);
END;

PROCEDURE TfmEditorOptionsDialog.btnAddKeyClick(Sender: TObject);
// Add a keystroke
VAR
  Item: TListItem;
BEGIN
  FInChanging := True;
  TRY
    Item := KeyList.Items.Add;
    Item.Data := FKeys.Add;
    Item.Selected := True;
    Item.MakeVisible(False);
  FINALLY
    FInChanging := False;
  END;
  FOldSelected := Item;
  btnUpdateKeyClick(btnAddKey);
END;

PROCEDURE TfmEditorOptionsDialog.btnRemKeyClick(Sender: TObject);
// Remove the selected keystroke
VAR
  Item: TListItem;
BEGIN
  Item := KeyList.Selected;
  IF Item = NIL THEN
    Exit;
  FInChanging := True;
  TRY
    TSynEditKeyStroke(Item.Data).Free;
    Item.Data := NIL;
    IF FOldSelected = Item THEN
      FOldSelected := NIL;
    Item.Delete;
  FINALLY
    FInChanging := False;
  END;
END;

PROCEDURE TfmEditorOptionsDialog.EditStrCallback(CONST S: STRING);
// Add one command to the combo
BEGIN
  IF FExtended THEN
    cKeyCommand.Items.AddObject(ConvertCodeStringToExtended(S),
      TObject(PtrInt(ConvertCodeStringToCommand(S))))
  ELSE
    cKeyCommand.Items.AddObject(S, TObject(PtrInt(ConvertCodeStringToCommand(S))));
END;

PROCEDURE TfmEditorOptionsDialog.FormShow(Sender: TObject);
// Fill the command list (user commands are only known now)
VAR
  Commands: TStringList;
  I: Integer;
BEGIN
  cKeyCommand.Items.BeginUpdate;
  TRY
    cKeyCommand.Items.Clear;
    //Start the callback to add the strings
    GetEditorCommandValues(EditStrCallback);
    //Now add in the user defined ones if they have any
    IF Assigned(FAllUserCommands) THEN
    BEGIN
      Commands := TStringList.Create;
      TRY
        FAllUserCommands(Commands);
        FOR I := 0 TO Commands.Count - 1 DO
          IF Commands.Objects[I] <> NIL THEN
            cKeyCommand.Items.AddObject(Commands[I], Commands.Objects[I]);
      FINALLY
        Commands.Free;
      END;
    END;
  FINALLY
    cKeyCommand.Items.EndUpdate;
  END;
  //Refresh captions now that user command names are available
  FOR I := 0 TO KeyList.Items.Count - 1 DO
    IF Assigned(KeyList.Items[I].Data) THEN
      FillInKeystrokeInfo(TSynEditKeyStroke(KeyList.Items[I].Data), KeyList.Items[I]);
  IF (KeyList.Selected = NIL) AND (KeyList.Items.Count > 0) THEN
  BEGIN
    FInChanging := True;
    KeyList.Items[0].Selected := True;
    KeyList.ItemFocused := KeyList.Items[0];
    FInChanging := False;
  END;
  IF Assigned(KeyList.Selected) THEN
    KeyListSelectItem(KeyList, KeyList.Selected, True);

  PageControl.ActivePage := PageControl.Pages[0];
END;

PROCEDURE TfmEditorOptionsDialog.KeyListEditing(Sender: TObject;
  Item: TListItem; VAR AllowEdit: Boolean);
// The list is read-only
BEGIN
  AllowEdit := (Item = NIL) AND AllowEdit AND False;
END;

PROCEDURE TfmEditorOptionsDialog.btnOkClick(Sender: TObject);
// Save the current keystroke then close
BEGIN
  IF KeyList.Selected <> NIL THEN
    btnUpdateKey.Click;
  ModalResult := mrOk;
END;

PROCEDURE TfmEditorOptionsDialog.btnGutterFontClick(Sender: TObject);
// Gutter font
BEGIN
  FontDialog.Font.Assign(lblGutterFont.Font);
  IF FontDialog.Execute THEN
  BEGIN
    lblGutterFont.Font.Assign(FontDialog.Font);
    ShowFontCaption(lblGutterFont);
  END;
END;

PROCEDURE TfmEditorOptionsDialog.cbGutterFontClick(Sender: TObject);
// Enable the gutter font controls
BEGIN
  lblGutterFont.Enabled := cbGutterFont.Checked;
  btnGutterFont.Enabled := cbGutterFont.Checked;
END;

PROCEDURE TfmEditorOptionsDialog.btnRightEdgeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Right edge color popup
VAR
  P: TPoint;
BEGIN
  IF (Button <> mbLeft) OR (Shift * [ssShift, ssCtrl] <> []) OR (X < 0) OR (Y < 0) THEN
    Exit;
  FPoppedFrom := cpRightEdge;
  P := pnlRightEdgeColor.ClientToScreen(Point(-1, pnlRightEdgeColor.Height - 1));
  btnRightEdge.BevelOuter := bvLowered;
  ColorPopup.PopUp(P.X, P.Y);
  btnRightEdge.BevelOuter := bvNone;
END;

PROCEDURE TfmEditorOptionsDialog.btnGutterColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
// Gutter color popup
VAR
  P: TPoint;
BEGIN
  IF (Button <> mbLeft) OR (Shift * [ssShift, ssCtrl] <> []) OR (X < 0) OR (Y < 0) THEN
    Exit;
  FPoppedFrom := cpGutter;
  P := pnlGutterColor.ClientToScreen(Point(-1, pnlGutterColor.Height - 1));
  btnGutterColor.BevelOuter := bvLowered;
  ColorPopup.PopUp(P.X, P.Y);
  btnGutterColor.BevelOuter := bvNone;
END;

PROCEDURE TfmEditorOptionsDialog.FillInKeystrokeInfo(
  AKey: TSynEditKeyStroke; AItem: TListItem);
// Command name and shortcut text of a list item
VAR
  TmpString: STRING;
BEGIN
  IF AKey.Command >= ecUserFirst THEN
  BEGIN
    TmpString := SUserCommand;
    IF Assigned(GetUserCommandNames) THEN
      GetUserCommandNames(AKey.Command, TmpString);
  END
  ELSE
  BEGIN
    IF FExtended THEN
      TmpString := ConvertCodeStringToExtended(EditorCommandToCodeString(AKey.Command))
    ELSE
      TmpString := EditorCommandToCodeString(AKey.Command);
  END;

  AItem.Caption := TmpString;
  AItem.SubItems.Clear;

  TmpString := '';
  IF AKey.ShortCut <> 0 THEN
    TmpString := ShortCutToText(AKey.ShortCut);

  IF (TmpString <> '') AND (AKey.ShortCut2 <> 0) THEN
    TmpString := TmpString + ' ' + ShortCutToText(AKey.ShortCut2);

  AItem.SubItems.Add(TmpString);
END;

PROCEDURE TfmEditorOptionsDialog.cKeyCommandExit(Sender: TObject);
// Force a valid command (ecNone if the text is unknown)
VAR
  TmpIndex: Integer;
BEGIN
  TmpIndex := cKeyCommand.Items.IndexOf(cKeyCommand.Text);
  IF TmpIndex = -1 THEN
  BEGIN
    IF FExtended THEN
      cKeyCommand.ItemIndex := cKeyCommand.Items.IndexOf(ConvertCodeStringToExtended('ecNone'))
    ELSE
      cKeyCommand.ItemIndex := cKeyCommand.Items.IndexOf('ecNone');
  END
  ELSE
    cKeyCommand.ItemIndex := TmpIndex; //need to force it incase they just typed something in
END;

PROCEDURE TfmEditorOptionsDialog.cKeyCommandKeyPress(Sender: TObject;
  VAR Key: Char);
// Incremental completion on the command names
VAR
  WorkStr: STRING;
  I: Integer;
BEGIN
  IF Key < ' ' THEN
    Exit;
  WorkStr := UpperCase(Copy(cKeyCommand.Text, 1, cKeyCommand.SelStart) + Key);
  I := 0;
  WHILE I < cKeyCommand.Items.Count DO
  BEGIN
    IF Pos(WorkStr, UpperCase(cKeyCommand.Items[I])) = 1 THEN
    BEGIN
      cKeyCommand.Text := cKeyCommand.Items[I];
      cKeyCommand.SelStart := Length(WorkStr);
      cKeyCommand.SelLength := Length(cKeyCommand.Text) - cKeyCommand.SelStart;
      Key := #0;
      Break;
    END
    ELSE
      Inc(I);
  END;
END;

PROCEDURE TfmEditorOptionsDialog.cKeyCommandKeyUp(Sender: TObject;
  VAR Key: Word; Shift: TShiftState);
// Enter = Update
BEGIN
  IF (Key = VK_RETURN) AND (Shift = []) THEN
    btnUpdateKey.Click;
END;

PROCEDURE Register;
// Component palette
BEGIN
  RegisterComponents('SynEdit', [TSynEditOptionsDialog, TSynEditorOptionsContainer]);
END;

END.
