PROGRAM SynDialogsDemo;

{$mode delphi}{$H+}

USES
  Interfaces, Forms, uDemo;

{$R *.res}

BEGIN
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmDemo, frmDemo);
  Application.Run;
END.
