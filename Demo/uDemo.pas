UNIT uDemo;

{$mode delphi}{$H+}

INTERFACE

USES
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, SynEdit, SynHighlighterPas,
  SynEditOptionsDialog, SynColorDialogForm;

TYPE

  { TfrmDemo }

  TfrmDemo = CLASS(TForm)
    pnlTop: TPanel;
    btnOptions: TButton;
    btnColors: TButton;
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    SynEditOptionsDialog1: TSynEditOptionsDialog;
    SynColorDialog1: TSynColorDialog;
    PROCEDURE btnOptionsClick(Sender: TObject);
    PROCEDURE btnColorsClick(Sender: TObject);
    PROCEDURE FormCreate(Sender: TObject);
  END;

VAR
  frmDemo: TfrmDemo;

IMPLEMENTATION

{$R *.lfm}

PROCEDURE TfrmDemo.FormCreate(Sender: TObject);
// Components created in code: no package registration needed
BEGIN
  SynEditOptionsDialog1 := TSynEditOptionsDialog.Create(Self);
  SynColorDialog1 := TSynColorDialog.Create(Self);
  // A SynEdit loaded from a form without streamed keystrokes has none
  IF SynEdit1.Keystrokes.Count = 0 THEN
    SynEdit1.Keystrokes.ResetDefaults;
  SynEdit1.Lines.Text :=
    'PROGRAM Demo;' + LineEnding +
    '{ Comment }' + LineEnding +
    'VAR' + LineEnding +
    '  I: Integer;' + LineEnding +
    'BEGIN' + LineEnding +
    '  FOR I := 1 TO 10 DO' + LineEnding +
    '    WriteLn(''Hello '', I, #13, $FF);' + LineEnding +
    'END.';
END;

PROCEDURE TfrmDemo.btnOptionsClick(Sender: TObject);
// Editor options window
VAR
  Opt: TSynEditorOptionsContainer;
BEGIN
  Opt := TSynEditorOptionsContainer.Create(NIL);
  TRY
    Opt.Assign(SynEdit1);
    IF SynEditOptionsDialog1.Execute(Opt) THEN
      Opt.AssignTo(SynEdit1);
  FINALLY
    Opt.Free;
  END;
END;

PROCEDURE TfrmDemo.btnColorsClick(Sender: TObject);
// Highlighter colors window
BEGIN
  SynColorDialog1.Execute(SynEdit1);
END;

END.
