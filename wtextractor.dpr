program wtextractor;

uses
  Vcl.Forms,
  main in 'main.pas' {Form1},
  VromFSClasses in 'VromFSClasses.pas',
  DXPClasses in 'DXPClasses.pas',
  WTExtractorClass in 'WTExtractorClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
