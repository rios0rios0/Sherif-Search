program SS;

uses
  SysUtils,
  Forms,
  USS in 'USS.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Sherif Search';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
