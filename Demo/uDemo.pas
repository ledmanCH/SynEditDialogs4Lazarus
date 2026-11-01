UNIT uDemo;

{$mode delphi}{$H+}

// Demo of the SynEdit dialogs:
//   - Options...: editor options applied to both editors;
//   - Colors...: popup menu, one entry per highlighter (Pascal, SQL);
//   - settings saved in SynDialogsDemo.ini on close and restored at startup.

INTERFACE

USES
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Menus, IniFiles,
  SynEdit, SynHighlighterPas, SynHighlighterSQL, SynEditOptionsDialog,
  SynColorDialogForm, SynEditSettings;

TYPE

  { TfrmDemo }

  TfrmDemo = CLASS(TForm)
    pnlTop: TPanel;
    btnOptions: TButton;
    btnColors: TButton;
    splEditors: TSplitter;
    SynEdit1: TSynEdit;
    SynEdit2: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    SynSQLSyn1: TSynSQLSyn;
    pmColors: TPopupMenu;
    mnuColorPascal: TMenuItem;
    mnuColorSQL: TMenuItem;
    PROCEDURE btnOptionsClick(Sender: TObject);
    PROCEDURE btnColorsClick(Sender: TObject);
    PROCEDURE mnuColorClick(Sender: TObject);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
  PRIVATE
    FIniFile: STRING;
    PROCEDURE ApplyEditorOptions(AOptions: TSynEditorOptionsContainer);
    PROCEDURE LoadSettings;
    PROCEDURE SaveSettings;
  END;

VAR
  frmDemo: TfrmDemo;

IMPLEMENTATION

{$R *.lfm}

CONST
  PASCAL_SAMPLE =
    '{ Syntax highlighting }'#13#10 +
    'procedure TForm1.Button1Click(Sender: TObject);'#13#10 +
    'var'#13#10 +
    '  Number, I, X: Integer;'#13#10 +
    'begin'#13#10 +
    '  Number := 123456;'#13#10 +
    '  Caption := ''The Number is'' + #32 + IntToStr(Number);'#13#10 +
    '  for I := 0 to Number do'#13#10 +
    '  begin'#13#10 +
    '    Inc(X);'#13#10 +
    '    Dec(X);'#13#10 +
    '    X := X + 1.0;'#13#10 +
    '    X := X - $5E;'#13#10 +
    '  end;'#13#10 +
    '  {$R+}'#13#10 +
    '  asm'#13#10 +
    '    mov AX, 1234H'#13#10 +
    '    mov Number, AX'#13#10 +
    '  end;'#13#10 +
    '  {$R-}'#13#10 +
    'end;';

  SQL_SAMPLE =
    '-- Syntax highlighting'#13#10 +
    'SELECT c.id, c.name, COUNT(o.id) AS orders'#13#10 +
    '  FROM customer c'#13#10 +
    '  LEFT JOIN orders o ON o.customer_id = c.id'#13#10 +
    ' WHERE c.country = ''CH'''#13#10 +
    '   AND c.created >= DATE ''2026-01-01'''#13#10 +
    ' GROUP BY c.id, c.name'#13#10 +
    'HAVING COUNT(o.id) > 10'#13#10 +
    ' ORDER BY orders DESC;';

PROCEDURE TfrmDemo.FormCreate(Sender: TObject);
// Editors filled, keystrokes restored, settings loaded
VAR
  I: Integer;
BEGIN
  FIniFile := ChangeFileExt(Application.ExeName, '.ini');
  // A SynEdit loaded from a form without streamed keystrokes has none
  FOR I := 0 TO ComponentCount - 1 DO
    IF (Components[I] IS TSynEdit) AND (TSynEdit(Components[I]).Keystrokes.Count = 0) THEN
      TSynEdit(Components[I]).Keystrokes.ResetDefaults;
  SynEdit1.Lines.Text := PASCAL_SAMPLE;
  SynEdit2.Lines.Text := SQL_SAMPLE;
  LoadSettings;
END;

PROCEDURE TfrmDemo.FormClose(Sender: TObject; VAR CloseAction: TCloseAction);
// Settings saved on close
BEGIN
  IF CloseAction <> caNone THEN
    SaveSettings;
END;

PROCEDURE TfrmDemo.ApplyEditorOptions(AOptions: TSynEditorOptionsContainer);
// Same editor options for every SynEdit of the window
VAR
  I: Integer;
BEGIN
  FOR I := 0 TO ComponentCount - 1 DO
    IF Components[I] IS TSynEdit THEN
      AOptions.AssignTo(Components[I]);
END;

PROCEDURE TfrmDemo.LoadSettings;
// Highlighter colors and editor options from the ini file
VAR
  Ini: TIniFile;
  Opt: TSynEditorOptionsContainer;
BEGIN
  Ini := TIniFile.Create(FIniFile);
  Opt := TSynEditorOptionsContainer.Create(NIL);
  TRY
    LoadHighlighter(Ini, 'Pascal', SynPasSyn1);
    LoadHighlighter(Ini, 'SQL', SynSQLSyn1);
    Opt.Assign(SynEdit1);
    IF LoadEditorOptions(Ini, 'Editor', Opt) THEN
      ApplyEditorOptions(Opt);
  FINALLY
    Opt.Free;
    Ini.Free;
  END;
END;

PROCEDURE TfrmDemo.SaveSettings;
// Highlighter colors and editor options to the ini file
VAR
  Ini: TIniFile;
  Opt: TSynEditorOptionsContainer;
BEGIN
  Ini := TIniFile.Create(FIniFile);
  Opt := TSynEditorOptionsContainer.Create(NIL);
  TRY
    SaveHighlighter(Ini, 'Pascal', SynPasSyn1);
    SaveHighlighter(Ini, 'SQL', SynSQLSyn1);
    Opt.Assign(SynEdit1);
    SaveEditorOptions(Ini, 'Editor', Opt);
  FINALLY
    Opt.Free;
    Ini.Free;
  END;
END;

PROCEDURE TfrmDemo.btnOptionsClick(Sender: TObject);
// Editor options window: read from SynEdit1, applied to both editors
VAR
  Opt: TSynEditorOptionsContainer;
  Dlg: TSynEditOptionsDialog;
BEGIN
  Opt := TSynEditorOptionsContainer.Create(NIL);
  Dlg := TSynEditOptionsDialog.Create(NIL);
  TRY
    Opt.Assign(SynEdit1);
    IF Dlg.Execute(Opt) THEN
      ApplyEditorOptions(Opt);
  FINALLY
    Dlg.Free;
    Opt.Free;
  END;
END;

PROCEDURE TfrmDemo.btnColorsClick(Sender: TObject);
// Highlighter choice under the button
VAR
  P: TPoint;
BEGIN
  P := btnColors.ClientToScreen(Point(0, btnColors.Height));
  pmColors.PopUp(P.X, P.Y);
END;

PROCEDURE TfrmDemo.mnuColorClick(Sender: TObject);
// Highlighter colors window: Tag 1 = Pascal, 2 = SQL
VAR
  Dlg: TSynColorDialog;
BEGIN
  Dlg := TSynColorDialog.Create(NIL);
  TRY
    CASE (Sender AS TComponent).Tag OF
      1: Dlg.Execute(SynPasSyn1, PASCAL_SAMPLE, SynEdit1.Font);
      2: Dlg.Execute(SynSQLSyn1, SQL_SAMPLE, SynEdit2.Font);
    END;
  FINALLY
    Dlg.Free;
  END;
END;

END.
