unit UPrincipale;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AMixer, Menus, Shlobj, FileCtrl, ShellAPI, MPlayer,
  ComCtrls;

type
  TFrmPincipale = class(TForm)
    GroupBoxFichierCapture: TGroupBox;
    Label1: TLabel;
    EditChemin: TEdit;
    BtnParcourir: TButton;
    Label2: TLabel;
    EditNomFichier: TEdit;
    LabelChemin: TLabel;
    GroupBoxControleEnregistrement: TGroupBox;
    ComboBoxSource: TComboBox;
    BtnCtrlEnregistrement: TButton;
    GroupBoxOptionsAudio: TGroupBox;
    Label3: TLabel;
    ComboBoxStereo: TComboBox;
    Label4: TLabel;
    ComboBoxFrequence: TComboBox;
    Label5: TLabel;
    ComboBoxBit: TComboBox;
    GroupBoxEnregistrement: TGroupBox;
    BtnDemarreEnregistrement: TButton;
    BtnStoppeEnregistrement: TButton;
    MediaPlayer1: TMediaPlayer;
    StatusBar1: TStatusBar;
    function chemin:string;
    function RaccourciChemin(str:string):string;
    Procedure ListeDestinations(IDDestination:integer);
    Procedure RetrouveControl(IDDestination:integer);
    procedure ListeMixers;
    procedure BtnParcourirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditCheminChange(Sender: TObject);
    procedure EditNomFichierChange(Sender: TObject);
    procedure BtnCtrlEnregistrementClick(Sender: TObject);
    procedure ComboBoxSourceChange(Sender: TObject);
    procedure ComboBoxStereoChange(Sender: TObject);
    procedure ComboBoxFrequenceChange(Sender: TObject);
    procedure ComboBoxBitChange(Sender: TObject);
    procedure BtnDemarreEnregistrementClick(Sender: TObject);
    procedure BtnStoppeEnregistrementClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPincipale: TFrmPincipale;
  Freq,Bit,Stereo,IDDestination:integer;
  mixer:TAudioMixer;

implementation

{$R *.dfm}

//Fonction permettant de retrouver les chemins speciaux de Windows
function SpecialFolder(Folder: Integer): String;
var
  SFolder : pItemIDList;
  SpecialPath : Array[0..MAX_PATH] Of Char;
  Handle:THandle;
begin
  SHGetSpecialFolderLocation(Handle, Folder, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := StrPas(SpecialPath);
end;

//Fonction permettant de créer un .wav
procedure CreateWav(channels : word; resolution : word; rate : longint; fn : string);
type
TWavHeader = record
rId : longint;
rLen : longint;
wId : longint;
fId : longint;
fLen : longint;
wFormatTag : word;
nChannels : word;
nSamplesPerSec : longint;
nAvgBytesPerSec : longint;
nBlockAlign : word;
wBitsPerSample : word;
dId : longint;
wSampleLength : longint;
end;
var
wf : file of TWavHeader;
wh : TWavHeader;
begin
wh.rId := $46464952;
wh.rLen := 36;
wh.wId := $45564157;
wh.fId := $20746d66;
wh.fLen := 16;
wh.wFormatTag := 1;
wh.nChannels := channels;
wh.nSamplesPerSec := rate;
wh.nAvgBytesPerSec := channels*rate*(resolution div 8);
wh.nBlockAlign := channels*(resolution div 8);
wh.wBitsPerSample := resolution;
wh.dId := $61746164;
wh.wSampleLength := 0;

assignfile(wf,fn);
rewrite(wf);
write(wf,wh);
closefile(wf);
end;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                   ENREGISTREMENT DU FICHIER CAPTURE                       //
//Cette partie correspond au paramétrage du nom et chemin du fichier capturé //                                                                     //
///////////////////////////////////////////////////////////////////////////////
procedure TFrmPincipale.BtnParcourirClick(Sender: TObject);
var
ChoixRepertoire:string;
begin
If SelectDirectory('Choisissez le dossier d''enregistrement',SpecialFolder(CSIDL_DESKTOP),ChoixRepertoire)
    Then EditChemin.Text:= ChoixRepertoire;
end;

//Fonction permettant de tronquer le chemin du fichier qui est affiché dans le
// labelChemin si il est trop grand
function TFrmPincipale.RaccourciChemin(str:string):string;
var
i,j,nb:integer;
substr:string;
Drive : Char;
PathPart, FileName : String;
begin
//Si le label est plus petit ou egal au GroupBox on ne fait rien sinon on tronque
if LabelChemin.Width<=GroupBoxFichierCapture.Width-(2*(LabelChemin.left)) then result := str else
  begin
   result:= ExtractFiledrive(str)+'\...\'+ExtractFileName(str); // Extrait l'extensio
   end;
end;

function TFrmPincipale.chemin:string;
begin
result:=IncludeTrailingPathDelimiter(EditChemin.Text)+EditNomFichier.Text+'.wav';
end;

//Quand les edits changent on met à jour le label affichant le chemin du fichier
procedure TFrmPincipale.EditCheminChange(Sender: TObject);
begin
LabelChemin.caption:=RaccourciChemin(chemin);
LabelChemin.caption:=RaccourciChemin(chemin);
end;

procedure TFrmPincipale.EditNomFichierChange(Sender: TObject);
begin
LabelChemin.caption:=RaccourciChemin(chemin);
LabelChemin.caption:=RaccourciChemin(chemin);
end;




///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                   CONTROLE D'ENREGISTREMENT                               //
// Cette partie permet de retrouver et sélectionner le contrôle              //
//  d'enregistrement de la carte son                                         //                                    //
///////////////////////////////////////////////////////////////////////////////

//Il faut en premier lieu lister les mixers de la carte son
procedure TFrmPincipale.ListeMixers;
var i,j:integer;
begin
//s'il n'y a pas de mixer on s'en va :D
if Mixer.MixerCount=0 then
begin
MessageDlg('Aucun mixer présent dans le system',mtError,[mbOk],0);
exit;
end;
//S'il y en a, il faut rechercher celui contenant le "Contrôle d'enregistrement"
for i := 0 to Mixer.MixerCount - 1 do
  begin
    mixer.MixerId:=i;
    for j := 0 to Mixer.Destinations.Count - 1 do
      begin
        //Si le dwType=2 (MIXERLINE_TARGETTYPE_WAVEIN) alors c'est le contrôle d'enregistrement
         if mixer.Destinations[j].Data.target.dwType=2 then
            begin
            IDDestination:=j;
            //le contrôle d'enregistrement posséde plusieurs sources (Volume CD, Micro, Mixage stéréo... selon les cartes)
            //il faut les lister
            ListeDestinations(j);
            //Et on cherche celle qui est sélectionnée par le system et on le sélectionne dans notre combobox
            RetrouveControl(j);
            exit;
            end;
      end;
  end;
MessageDlg('Le contrôle d''enregistrement n''a pas été trouvé',mtError,[mbOk],0);
end;

//Procedure permettant de lister les sources du contrôle d'enregistrement
//Volume CD, Micro, Mixage stéréo... selon les cartes
Procedure TFrmPincipale.ListeDestinations(IDDestination:integer);
var A:Integer;
begin
  ComboBoxSource.Items.Clear;
  For A:=0 to Mixer.Destinations[IDDestination].Connections.Count-1 do
    begin
    ComboBoxSource.Items.Add(Mixer.Destinations[IDDestination].Connections[A].Data.szName);
    //showmessage(inttostr(Mixer.Destinations[IDDestination].Connections[A].Data.Target.dwtype));
    end;
  If ComboBoxSource.Items.Count>0 then
  begin
    ComboBoxSource.ItemIndex:=0;
  end;
end;

//Procedure permettant de retrouver la sources sélectionnée dans le contrôle d'enregistrement
Procedure TFrmPincipale.RetrouveControl(IDDestination:integer);
var
  i,L,R,M: Integer;
  VD,MD : boolean;
  stereo : boolean;
  IsSelect:Boolean;
begin
//On cherche les infos de toutes les sources, si le MuteDisable est false et
// si le Mute n'est pas à zero c'est que c'est celui qui est sélectionné
for i := 1 to ComboboxSource.items.Count do
  begin
  Mixer.GetVolume(IDDestination, i, L, R, M, Stereo, VD, MD, IsSelect);
  if (not MD) and (m<>0) then ComboboxSource.ItemIndex:=i;
  end;
end;

//Le changement de la combobox permet de sélectionner une source d'enregistrement
//Pour ce faire on récupére les infos de la source (volume gauche, volume droit, stéréo etc...
//Puis on utilise la fonction setVolume pour mettre le Mute à 1 permettant de le sélectionner
//Si on ouvre à côté la fenetre du controle d'enregistrement on voit que la sélection se fait instantanement
procedure TFrmPincipale.ComboBoxSourceChange(Sender: TObject);
var L,R,M:Integer;
    VD,MD:Boolean;
    Stereo:Boolean;
    IsSelect:Boolean;
begin
Mixer.GetVolume (IDDestination,ComboBoxSource.ItemIndex,L,R,M,Stereo,VD,MD,IsSelect);
Mixer.SetVolume (IDDestination,ComboBoxSource.ItemIndex,L,L,1);
end;

//Procedure permettant d'ouvrir la fenetre du controle d'enregistrement
//fenêtre accessible par le panneau de configuration -> Son et périphérique audio
//  |-> Onglet "audio" -> boutton "volume" de l'enregistrement audio
procedure TFrmPincipale.BtnCtrlEnregistrementClick(Sender: TObject);
var commande:string;
begin
commande:=PAnsiChar(concat('/k "sndvol32.exe /r&&exit"'));
shellexecute(handle,nil,'cmd',pchar(commande),nil,SW_HIDE);
end;



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                         OPTIONS AUDIO                                     //
// Cette partie permet de paramétrer le fichier audio que l'on va capturer   //
///////////////////////////////////////////////////////////////////////////////
procedure TFrmPincipale.ComboBoxStereoChange(Sender: TObject);
begin
if ComboBoxStereo.ItemIndex = 0 then Stereo := 1;
if ComboBoxStereo.ItemIndex = 1 then Stereo := 2;
end;

procedure TFrmPincipale.ComboBoxFrequenceChange(Sender: TObject);
begin
if ComboBoxFrequence.ItemIndex = 0 then Freq := 11025;
if ComboBoxFrequence.ItemIndex = 1 then Freq := 22050;
if ComboBoxFrequence.ItemIndex = 2 then Freq := 44100;
end;

procedure TFrmPincipale.ComboBoxBitChange(Sender: TObject);
begin
if ComboBoxBit.ItemIndex = 0 then Bit := 8;
if ComboBoxBit.ItemIndex = 1 then Bit := 16;
end;



///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                         ENREGISTREMENT                                    //
// Cette partie permet de démarrer et stopper l'enregistrement               //
///////////////////////////////////////////////////////////////////////////////

//Démarrer l'enregistrement
procedure TFrmPincipale.BtnDemarreEnregistrementClick(Sender: TObject);
Label fin;
begin
if (editChemin.text='') or (editNomFichier.Text='') then
begin
  showmessage('Le chemin ou le nom entré est incorrect');
  goto fin;
  end;

//On créer le .wav avec les paramétres audio et le chemin
CreateWav(Stereo,Bit,Freq,chemin);

//On utilise le MediaPlayer pour enregistrer le son
MediaPlayer1.DeviceType := dtAutoSelect;
MediaPlayer1.FileName :=chemin;
MediaPlayer1.Open;
MediaPlayer1.StartRecording;

BtnDemarreEnregistrement.Enabled := false;
BtnStoppeEnregistrement.Enabled := true;
fin:
end;

//Stopper l'enregistrement
procedure TFrmPincipale.BtnStoppeEnregistrementClick(Sender: TObject);
begin
MediaPlayer1.Stop;
MediaPlayer1.Save;
MediaPlayer1.Close;

BtnDemarreEnregistrement.Enabled := true;
BtnStoppeEnregistrement.Enabled := false;
end;


procedure TFrmPincipale.FormCreate(Sender: TObject);
begin
//Empêche le redimmensionnement de la fiche
DeleteMenu(GetSystemMenu(Handle,False),SC_SIZE,MF_BYCOMMAND);
//Retrouve le chemin "Mes Documents" qui sera le chemin par defaut de l'enregistrement
EditChemin.Text:=SpecialFolder(CSIDL_PERSONAL);
//On initialise le TAudioMixer
Mixer:=TAudioMixer.Create(self);
//On paramêtre les options audio par défaut
Freq := 44100;
Bit := 16;
Stereo := 2;
//On place dans le StatusBar le type de la carte son
StatusBar1.Panels[0].Text:=(Mixer.ProductName);
//Et on liste les sources de notre carte son
ListeMixers;
end;


end.
