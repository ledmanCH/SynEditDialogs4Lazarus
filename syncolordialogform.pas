{-------------------------------------------------------------------------------
Lazarus port of the Delphi SynColorDialogForm unit.

Edits the colors and font styles of the attributes of the highlighter of a
SynEdit. The highlighter is copied, edited with a live preview, and assigned
back to the editor's highlighter on OK.

Differences imposed by Lazarus:
  - TJvColorComboBox (JVCL) is replaced by the LCL TColorBox (standard,
    extended, system colors, None and Custom...). Delete still sets clNone.
  - Highlighters without a sample source (e.g. TSynPasSyn in Lazarus) show
    the text of the edited SynEdit instead of an empty preview.
-------------------------------------------------------------------------------}

UNIT SynColorDialogForm;

{$mode delphi}{$H+}

INTERFACE

USES
  Classes, SysUtils, LCLType, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  StdCtrls, ColorBox, SynEdit, SynEditHighlighter;

TYPE
  TSynColorDialog = CLASS(TComponent)
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    FUNCTION Execute(SynEdit: TCustomSynEdit): Boolean; OVERLOAD;
    FUNCTION Execute(AHighlighter: TSynCustomHighlighter; CONST ASample: STRING = '';
      AFont: TFont = NIL): Boolean; OVERLOAD;
  END;

  { TfrmSynColorDialog }

  TfrmSynColorDialog = CLASS(TForm)
    Label1: TLabel;
    ListBox1: TListBox;
    SynEdit1: TSynEdit;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    PROCEDURE FormDestroy(Sender: TObject);
    PROCEDURE ListBox1Click(Sender: TObject);
    PROCEDURE ColorBox1Change(Sender: TObject);
    PROCEDURE ColorBox2Change(Sender: TObject);
    PROCEDURE ColorBox1KeyDown(Sender: TObject; VAR Key: Word; Shift: TShiftState);
    PROCEDURE CheckBox1Click(Sender: TObject);
    PROCEDURE CheckBox2Click(Sender: TObject);
    PROCEDURE CheckBox3Click(Sender: TObject);
    PROCEDURE CheckBox4Click(Sender: TObject);
  PRIVATE
    fSynH: TSynCustomHighlighter;
    fLoading: Boolean;
    PROCEDURE EnableItems(aenable: Boolean);
    PROCEDURE SetFontStyle;
    PROCEDURE SetBoxColor(ABox: TColorBox; AColor: TColor);
  PUBLIC
    PROCEDURE SetHighlighter(SynH: TSynCustomHighlighter; CONST AFallbackSample: STRING = '');
    FUNCTION GetHighlighter: TSynCustomHighlighter;
  END;

PROCEDURE Register;

IMPLEMENTATION

{$R *.lfm}

RESOURCESTRING
  SColorDefinitions = '%s Color Definitions';
  SNoSynEdit = 'SynEdit has not been properly assigned';
  SNoHighlighter = 'SynEdit.Highlighter has not been properly assigned';

TYPE
  TSynHClass = CLASS OF TSynCustomHighlighter;

PROCEDURE TfrmSynColorDialog.SetHighlighter(SynH: TSynCustomHighlighter;
  CONST AFallbackSample: STRING);
// Work on a copy of SynH, shown in the preview
VAR
  loop: Integer;
  wSynClass: TSynHClass;
BEGIN
  FreeAndNil(fSynH);
  wSynClass := TSynHClass(SynH.ClassType);
  fSynH := wSynClass.Create(NIL);
  fSynH.Assign(SynH);
  fLoading := True;
  ListBox1.Items.BeginUpdate;
  TRY
    ListBox1.Items.Clear;
    ListBox1.ItemIndex := -1;
    CheckBox1.Checked := False;
    CheckBox2.Checked := False;
    CheckBox3.Checked := False;
    CheckBox4.Checked := False;
    ColorBox1.ItemIndex := -1;
    ColorBox2.ItemIndex := -1;
    FOR loop := 0 TO fSynH.AttrCount - 1 DO
      ListBox1.Items.Add(fSynH.Attribute[loop].Caption^);
    SynEdit1.Highlighter := fSynH;
    IF fSynH.SampleSource <> '' THEN
      SynEdit1.Lines.Text := fSynH.SampleSource
    ELSE
      SynEdit1.Lines.Text := AFallbackSample;
    Caption := Format(SColorDefinitions, [fSynH.LanguageName]);
  FINALLY
    ListBox1.Items.EndUpdate;
    fLoading := False;
  END;
  EnableItems(False);
END;

PROCEDURE TfrmSynColorDialog.FormDestroy(Sender: TObject);
// Free the copy
BEGIN
  SynEdit1.Highlighter := NIL;
  IF Assigned(fSynH) THEN
    FreeAndNil(fSynH);
END;

FUNCTION TfrmSynColorDialog.GetHighlighter: TSynCustomHighlighter;
// Edited copy
BEGIN
  Result := fSynH;
END;

PROCEDURE TfrmSynColorDialog.SetBoxColor(ABox: TColorBox; AColor: TColor);
// Select a color (TColorBox shows unlisted colors as custom color)
BEGIN
  ABox.Selected := AColor;
END;

PROCEDURE TfrmSynColorDialog.ListBox1Click(Sender: TObject);
// Show the selected attribute
VAR
  wSynAttr: TSynHighlighterAttributes;
BEGIN
  IF ListBox1.ItemIndex <> -1 THEN
  BEGIN
    EnableItems(True);
    wSynAttr := fSynH.Attribute[ListBox1.ItemIndex];
    fLoading := True;
    TRY
      CheckBox1.Checked := (fsBold IN wSynAttr.Style);
      CheckBox2.Checked := (fsItalic IN wSynAttr.Style);
      CheckBox3.Checked := (fsUnderline IN wSynAttr.Style);
      CheckBox4.Checked := (fsStrikeOut IN wSynAttr.Style);
      SetBoxColor(ColorBox1, wSynAttr.Foreground);
      SetBoxColor(ColorBox2, wSynAttr.Background);
    FINALLY
      fLoading := False;
    END;
  END
  ELSE
    EnableItems(False);
END;

PROCEDURE TfrmSynColorDialog.EnableItems(aenable: Boolean);
// Attribute editors usable only with a selected element
BEGIN
  ColorBox1.Enabled := aenable;
  ColorBox2.Enabled := aenable;
  CheckBox1.Enabled := aenable;
  CheckBox2.Enabled := aenable;
  CheckBox3.Enabled := aenable;
  CheckBox4.Enabled := aenable;
END;

PROCEDURE TfrmSynColorDialog.ColorBox1Change(Sender: TObject);
// Foreground
VAR
  wSynAttr: TSynHighlighterAttributes;
BEGIN
  IF fLoading OR (ListBox1.ItemIndex < 0) THEN
    Exit;
  wSynAttr := fSynH.Attribute[ListBox1.ItemIndex];
  wSynAttr.Foreground := ColorBox1.Selected;
  SynEdit1.Invalidate;
END;

PROCEDURE TfrmSynColorDialog.ColorBox2Change(Sender: TObject);
// Background
VAR
  wSynAttr: TSynHighlighterAttributes;
BEGIN
  IF fLoading OR (ListBox1.ItemIndex < 0) THEN
    Exit;
  wSynAttr := fSynH.Attribute[ListBox1.ItemIndex];
  wSynAttr.Background := ColorBox2.Selected;
  SynEdit1.Invalidate;
END;

PROCEDURE TfrmSynColorDialog.ColorBox1KeyDown(Sender: TObject; VAR Key: Word;
  Shift: TShiftState);
// Delete = no color (clNone)
BEGIN
  IF (Key = VK_DELETE) AND (Shift = []) THEN
  BEGIN
    Key := 0;
    SetBoxColor(TColorBox(Sender), clNone); // fires OnChange
  END;
END;

PROCEDURE TfrmSynColorDialog.CheckBox1Click(Sender: TObject);
// Bold
BEGIN
  SetFontStyle;
END;

PROCEDURE TfrmSynColorDialog.CheckBox2Click(Sender: TObject);
// Italic
BEGIN
  SetFontStyle;
END;

PROCEDURE TfrmSynColorDialog.CheckBox3Click(Sender: TObject);
// Underline
BEGIN
  SetFontStyle;
END;

PROCEDURE TfrmSynColorDialog.CheckBox4Click(Sender: TObject);
// Strike out
BEGIN
  SetFontStyle;
END;

PROCEDURE TfrmSynColorDialog.SetFontStyle;
// Check boxes -> attribute style
VAR
  wfs: TFontStyles;
  wSynAttr: TSynHighlighterAttributes;
BEGIN
  IF fLoading OR (ListBox1.ItemIndex < 0) THEN
    Exit;
  wfs := [];
  wSynAttr := fSynH.Attribute[ListBox1.ItemIndex];
  IF CheckBox1.Checked THEN
    Include(wfs, fsBold);
  IF CheckBox2.Checked THEN
    Include(wfs, fsItalic);
  IF CheckBox3.Checked THEN
    Include(wfs, fsUnderline);
  IF CheckBox4.Checked THEN
    Include(wfs, fsStrikeOut);
  wSynAttr.Style := wfs;
  SynEdit1.Invalidate;
END;

CONSTRUCTOR TSynColorDialog.Create(AOwner: TComponent);
// Nothing special
BEGIN
  INHERITED Create(AOwner);
END;

FUNCTION TSynColorDialog.Execute(SynEdit: TCustomSynEdit): Boolean;
// Edit the highlighter colors of SynEdit, True on OK
BEGIN
  IF NOT Assigned(SynEdit) THEN
    RAISE EInvalidOperation.Create(SNoSynEdit);
  IF NOT Assigned(SynEdit.Highlighter) THEN
    RAISE EInvalidOperation.Create(SNoHighlighter);
  // Highlighter sample first, text of the editor when there is none
  IF SynEdit.Highlighter.SampleSource <> '' THEN
    Result := Execute(SynEdit.Highlighter, '', SynEdit.Font)
  ELSE
    Result := Execute(SynEdit.Highlighter, SynEdit.Lines.Text, SynEdit.Font);
END;

FUNCTION TSynColorDialog.Execute(AHighlighter: TSynCustomHighlighter;
  CONST ASample: STRING; AFont: TFont): Boolean;
// Edit the colors of a highlighter (all the editors using it are updated)
// ASample: preview text; when empty, the highlighter sample source is shown
// AFont: preview font (optional)
VAR
  wFrm: TfrmSynColorDialog;
BEGIN
  Result := False;
  IF NOT Assigned(AHighlighter) THEN
    RAISE EInvalidOperation.Create(SNoHighlighter);
  wFrm := TfrmSynColorDialog.Create(Self);
  TRY
    IF Assigned(AFont) THEN
      wFrm.SynEdit1.Font.Assign(AFont);
    wFrm.SetHighlighter(AHighlighter, ASample);
    IF ASample <> '' THEN
      wFrm.SynEdit1.Lines.Text := ASample;
    Result := (wFrm.ShowModal = mrOK);
    IF Result THEN
      AHighlighter.Assign(wFrm.GetHighlighter);
  FINALLY
    wFrm.Free;
  END;
END;

PROCEDURE Register;
// Component palette
BEGIN
  RegisterComponents('SynEdit', [TSynColorDialog]);
END;

END.
