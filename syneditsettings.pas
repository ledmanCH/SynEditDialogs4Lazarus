UNIT SynEditSettings;

{$mode delphi}{$H+}

// Editor settings stored in the ini file:
//   - highlighter colors and styles (one section per highlighter);
//   - editor options of TSynEditorOptionsContainer (font, gutter, options,
//     caret, keystrokes...), applied to every SynEdit of the application.

INTERFACE

USES
  Classes, SysUtils, StrUtils, Graphics, IniFiles, TypInfo, SynEdit, SynEditTypes,
  SynEditKeyCmds, SynEditHighlighter, SynEditOptionsDialog;

PROCEDURE SaveHighlighter(AIni: TIniFile; CONST ASection: STRING; AHighlighter: TSynCustomHighlighter);
PROCEDURE LoadHighlighter(AIni: TIniFile; CONST ASection: STRING; AHighlighter: TSynCustomHighlighter);
PROCEDURE SaveEditorOptions(AIni: TIniFile; CONST ASection: STRING; AOptions: TSynEditorOptionsContainer);
FUNCTION LoadEditorOptions(AIni: TIniFile; CONST ASection: STRING; AOptions: TSynEditorOptionsContainer): Boolean;

IMPLEMENTATION

CONST
  KEYS_SUFFIX = '.Keystrokes';

{ Highlighters }

PROCEDURE SaveHighlighter(AIni: TIniFile; CONST ASection: STRING; AHighlighter: TSynCustomHighlighter);
// Colors and styles of every attribute: <StoredName>.Foreground / .Background / .Style
VAR
  I: Integer;
  A: TSynHighlighterAttributes;
BEGIN
  AIni.EraseSection(ASection);
  FOR I := 0 TO AHighlighter.AttrCount - 1 DO
  BEGIN
    A := AHighlighter.Attribute[I];
    AIni.WriteString(ASection, A.StoredName + '.Foreground', ColorToString(A.Foreground));
    AIni.WriteString(ASection, A.StoredName + '.Background', ColorToString(A.Background));
    AIni.WriteInteger(ASection, A.StoredName + '.Style', A.IntegerStyle);
  END;
END;

PROCEDURE LoadHighlighter(AIni: TIniFile; CONST ASection: STRING; AHighlighter: TSynCustomHighlighter);
// Attributes missing from the ini keep their default values
VAR
  I: Integer;
  A: TSynHighlighterAttributes;
BEGIN
  FOR I := 0 TO AHighlighter.AttrCount - 1 DO
  BEGIN
    A := AHighlighter.Attribute[I];
    IF AIni.ValueExists(ASection, A.StoredName + '.Foreground') THEN
      A.Foreground := StringToColor(AIni.ReadString(ASection, A.StoredName + '.Foreground', 'clNone'));
    IF AIni.ValueExists(ASection, A.StoredName + '.Background') THEN
      A.Background := StringToColor(AIni.ReadString(ASection, A.StoredName + '.Background', 'clNone'));
    IF AIni.ValueExists(ASection, A.StoredName + '.Style') THEN
      A.IntegerStyle := AIni.ReadInteger(ASection, A.StoredName + '.Style', 0);
  END;
END;

{ Option sets as readable lists: 'eoAutoIndent,eoSmartTabs' }

FUNCTION OptionsToStr(CONST AOptions: TSynEditorOptions): STRING;
// Names of the options in the set
VAR
  O: TSynEditorOption;
BEGIN
  Result := '';
  FOR O := Low(TSynEditorOption) TO High(TSynEditorOption) DO
    IF O IN AOptions THEN
      Result := Result + IfThen(Result <> '', ',', '') + GetEnumName(TypeInfo(TSynEditorOption), Ord(O));
END;

FUNCTION StrToOptions(CONST AText: STRING): TSynEditorOptions;
// Unknown names (option renamed or removed) are ignored
VAR
  Name: STRING;
  V: Integer;
BEGIN
  Result := [];
  FOR Name IN AText.Split([',']) DO
  BEGIN
    V := GetEnumValue(TypeInfo(TSynEditorOption), Trim(Name));
    IF V >= 0 THEN
      Include(Result, TSynEditorOption(V));
  END;
END;

FUNCTION Options2ToStr(CONST AOptions: TSynEditorOptions2): STRING;
// Names of the options in the set
VAR
  O: TSynEditorOption2;
BEGIN
  Result := '';
  FOR O := Low(TSynEditorOption2) TO High(TSynEditorOption2) DO
    IF O IN AOptions THEN
      Result := Result + IfThen(Result <> '', ',', '') + GetEnumName(TypeInfo(TSynEditorOption2), Ord(O));
END;

FUNCTION StrToOptions2(CONST AText: STRING): TSynEditorOptions2;
// Unknown names (option renamed or removed) are ignored
VAR
  Name: STRING;
  V: Integer;
BEGIN
  Result := [];
  FOR Name IN AText.Split([',']) DO
  BEGIN
    V := GetEnumValue(TypeInfo(TSynEditorOption2), Trim(Name));
    IF V >= 0 THEN
      Include(Result, TSynEditorOption2(V));
  END;
END;

FUNCTION StyleToInt(AStyle: TFontStyles): Integer;
// Bold = 1, Italic = 2, Underline = 4, StrikeOut = 8
BEGIN
  Result := 0;
  IF fsBold IN AStyle THEN Inc(Result, 1);
  IF fsItalic IN AStyle THEN Inc(Result, 2);
  IF fsUnderline IN AStyle THEN Inc(Result, 4);
  IF fsStrikeOut IN AStyle THEN Inc(Result, 8);
END;

FUNCTION IntToStyle(AValue: Integer): TFontStyles;
// Reverse of StyleToInt
BEGIN
  Result := [];
  IF AValue AND 1 <> 0 THEN Include(Result, fsBold);
  IF AValue AND 2 <> 0 THEN Include(Result, fsItalic);
  IF AValue AND 4 <> 0 THEN Include(Result, fsUnderline);
  IF AValue AND 8 <> 0 THEN Include(Result, fsStrikeOut);
END;

{ Editor options }

PROCEDURE SaveEditorOptions(AIni: TIniFile; CONST ASection: STRING; AOptions: TSynEditorOptionsContainer);
// Options in ASection, keystrokes in ASection + '.Keystrokes' (Command=ShortCut,ShortCut2)
VAR
  I: Integer;
  K: TSynEditKeyStroke;
BEGIN
  AIni.EraseSection(ASection);
  // Font
  AIni.WriteString(ASection, 'FontName', AOptions.Font.Name);
  AIni.WriteInteger(ASection, 'FontSize', AOptions.Font.Size);
  AIni.WriteInteger(ASection, 'FontStyle', StyleToInt(AOptions.Font.Style));
  AIni.WriteString(ASection, 'FontColor', ColorToString(AOptions.Font.Color));
  // Gutter
  AIni.WriteBool(ASection, 'GutterVisible', AOptions.Gutter.Visible);
  AIni.WriteBool(ASection, 'GutterAutoSize', AOptions.Gutter.AutoSize);
  AIni.WriteBool(ASection, 'GutterShowLineNumbers', AOptions.Gutter.ShowLineNumbers);
  AIni.WriteBool(ASection, 'GutterLeadingZeros', AOptions.Gutter.LeadingZeros);
  AIni.WriteBool(ASection, 'GutterZeroStart', AOptions.Gutter.ZeroStart);
  AIni.WriteString(ASection, 'GutterColor', ColorToString(AOptions.Gutter.Color));
  AIni.WriteBool(ASection, 'GutterUseFontStyle', AOptions.Gutter.UseFontStyle);
  AIni.WriteString(ASection, 'GutterFontColor', ColorToString(AOptions.Gutter.Font.Color));
  AIni.WriteInteger(ASection, 'GutterFontStyle', StyleToInt(AOptions.Gutter.Font.Style));
  // Right edge, spacing, bookmarks
  AIni.WriteInteger(ASection, 'RightEdge', AOptions.RightEdge);
  AIni.WriteString(ASection, 'RightEdgeColor', ColorToString(AOptions.RightEdgeColor));
  AIni.WriteInteger(ASection, 'ExtraLineSpacing', AOptions.ExtraLineSpacing);
  AIni.WriteInteger(ASection, 'TabWidth', AOptions.TabWidth);
  AIni.WriteBool(ASection, 'BookmarkKeys', AOptions.BookMarkOptions.EnableKeys);
  AIni.WriteBool(ASection, 'BookmarkVisible', AOptions.BookMarkOptions.GlyphsVisible);
  // Options and caret
  AIni.WriteBool(ASection, 'WantTabs', AOptions.WantTabs);
  AIni.WriteString(ASection, 'Options', OptionsToStr(AOptions.Options));
  AIni.WriteString(ASection, 'Options2', Options2ToStr(AOptions.Options2));
  AIni.WriteInteger(ASection, 'InsertCaret', Ord(AOptions.InsertCaret));
  AIni.WriteInteger(ASection, 'OverwriteCaret', Ord(AOptions.OverwriteCaret));
  // Keystrokes
  AIni.EraseSection(ASection + KEYS_SUFFIX);
  FOR I := 0 TO AOptions.Keystrokes.Count - 1 DO
  BEGIN
    K := AOptions.Keystrokes[I];
    AIni.WriteString(ASection + KEYS_SUFFIX, IntToStr(I),
      Format('%s,%d,%d', [EditorCommandToCodeString(K.Command), K.ShortCut, K.ShortCut2]));
  END;
END;

FUNCTION LoadEditorOptions(AIni: TIniFile; CONST ASection: STRING; AOptions: TSynEditorOptionsContainer): Boolean;
// False when the ini has no editor settings (AOptions unchanged)
VAR
  Keys: TStringList;
  Parts: TStringArray;
  I: Integer;
  Cmd: LongInt;
  K: TSynEditKeyStroke;
BEGIN
  Result := AIni.SectionExists(ASection);
  IF NOT Result THEN
    Exit;
  // Font
  AOptions.Font.Name := AIni.ReadString(ASection, 'FontName', AOptions.Font.Name);
  AOptions.Font.Size := AIni.ReadInteger(ASection, 'FontSize', AOptions.Font.Size);
  AOptions.Font.Style := IntToStyle(AIni.ReadInteger(ASection, 'FontStyle', StyleToInt(AOptions.Font.Style)));
  AOptions.Font.Color := StringToColor(AIni.ReadString(ASection, 'FontColor', ColorToString(AOptions.Font.Color)));
  // Gutter
  AOptions.Gutter.Visible := AIni.ReadBool(ASection, 'GutterVisible', AOptions.Gutter.Visible);
  AOptions.Gutter.AutoSize := AIni.ReadBool(ASection, 'GutterAutoSize', AOptions.Gutter.AutoSize);
  AOptions.Gutter.ShowLineNumbers := AIni.ReadBool(ASection, 'GutterShowLineNumbers', AOptions.Gutter.ShowLineNumbers);
  AOptions.Gutter.LeadingZeros := AIni.ReadBool(ASection, 'GutterLeadingZeros', AOptions.Gutter.LeadingZeros);
  AOptions.Gutter.ZeroStart := AIni.ReadBool(ASection, 'GutterZeroStart', AOptions.Gutter.ZeroStart);
  AOptions.Gutter.Color := StringToColor(AIni.ReadString(ASection, 'GutterColor', ColorToString(AOptions.Gutter.Color)));
  AOptions.Gutter.UseFontStyle := AIni.ReadBool(ASection, 'GutterUseFontStyle', AOptions.Gutter.UseFontStyle);
  AOptions.Gutter.Font.Color := StringToColor(AIni.ReadString(ASection, 'GutterFontColor',
    ColorToString(AOptions.Gutter.Font.Color)));
  AOptions.Gutter.Font.Style := IntToStyle(AIni.ReadInteger(ASection, 'GutterFontStyle',
    StyleToInt(AOptions.Gutter.Font.Style)));
  // Right edge, spacing, bookmarks
  AOptions.RightEdge := AIni.ReadInteger(ASection, 'RightEdge', AOptions.RightEdge);
  AOptions.RightEdgeColor := StringToColor(AIni.ReadString(ASection, 'RightEdgeColor',
    ColorToString(AOptions.RightEdgeColor)));
  AOptions.ExtraLineSpacing := AIni.ReadInteger(ASection, 'ExtraLineSpacing', AOptions.ExtraLineSpacing);
  AOptions.TabWidth := AIni.ReadInteger(ASection, 'TabWidth', AOptions.TabWidth);
  AOptions.BookMarkOptions.EnableKeys := AIni.ReadBool(ASection, 'BookmarkKeys', AOptions.BookMarkOptions.EnableKeys);
  AOptions.BookMarkOptions.GlyphsVisible := AIni.ReadBool(ASection, 'BookmarkVisible',
    AOptions.BookMarkOptions.GlyphsVisible);
  // Options and caret
  AOptions.WantTabs := AIni.ReadBool(ASection, 'WantTabs', AOptions.WantTabs);
  IF AIni.ValueExists(ASection, 'Options') THEN
    AOptions.Options := StrToOptions(AIni.ReadString(ASection, 'Options', ''));
  IF AIni.ValueExists(ASection, 'Options2') THEN
    AOptions.Options2 := StrToOptions2(AIni.ReadString(ASection, 'Options2', ''));
  AOptions.InsertCaret := TSynEditCaretType(AIni.ReadInteger(ASection, 'InsertCaret', Ord(AOptions.InsertCaret)));
  AOptions.OverwriteCaret := TSynEditCaretType(AIni.ReadInteger(ASection, 'OverwriteCaret',
    Ord(AOptions.OverwriteCaret)));
  // Keystrokes (kept as they are when the section is missing or empty)
  Keys := TStringList.Create;
  TRY
    AIni.ReadSectionValues(ASection + KEYS_SUFFIX, Keys);
    IF Keys.Count > 0 THEN
    BEGIN
      AOptions.Keystrokes.Clear;
      FOR I := 0 TO Keys.Count - 1 DO
      BEGIN
        Parts := Keys.ValueFromIndex[I].Split([',']);
        IF Length(Parts) <> 3 THEN
          Continue;
        Cmd := ecNone;
        IF NOT IdentToEditorCommand(Trim(Parts[0]), Cmd) THEN
          Continue;
        K := AOptions.Keystrokes.Add;
        TRY
          K.Command := Cmd;
          K.ShortCut := StrToIntDef(Parts[1], 0);
          K.ShortCut2 := StrToIntDef(Parts[2], 0);
        EXCEPT
          // Duplicate shortcut: entry dropped
          ON ESynKeyError DO
            K.Free;
        END;
      END;
    END;
  FINALLY
    Keys.Free;
  END;
END;

END.
