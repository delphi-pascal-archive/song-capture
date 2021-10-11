program Project1;

uses
  Forms,
  UPrincipale in 'UPrincipale.pas' {FrmPincipale},
  AMixer in 'AMixer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPincipale, FrmPincipale);
  Application.Run;
end.
