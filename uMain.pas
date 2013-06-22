unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons,
  Vcl.XPMan, uScriptThread, ioutils, System.Types;

type
  TfrmMain = class(TForm)
    grpConfig: TGroupBox;
    lblScript: TLabel;
    cbbScript: TComboBox;
    mmoLog: TMemo;
    xpMan: TXPManifest;
    btnRefreshScripts: TButton;
    btnRun: TButton;
    btnAbout: TButton;
    btnSaveLua: TButton;
    dlgSaveBin: TSaveDialog;
    pbProgress: TProgressBar;
    btnDevInfo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnRefreshScriptsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbbScriptChange(Sender: TObject);
    procedure btnSaveLuaClick(Sender: TObject);
    procedure btnDevInfoClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
    Stop: boolean;
    Timer: Integer;
    procedure RefreshScriptsList;
    procedure Disable(Sender: TObject);
    procedure Enable(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

const
  TIMEOUT = 1000;
  PROGNAME = '-= SGCE Client (Public Release) v1.4 =-';

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  MessageBox(Handle, PROGNAME + #13#10#13#10
  + 'Original idea and SGCE by: Bruno Freitas;' + #13#10 +
  'Software and modified firmware by: Dr. MefistO;', 'Information', MB_OK +
  MB_ICONINFORMATION + MB_TOPMOST);
end;

procedure TfrmMain.btnDevInfoClick(Sender: TObject);
var
  SCR: TScriptThread;
begin
  mmoLog.Lines.Clear;

  SCR := TScriptThread.Create('print(dev.info());', @mmoLog, @dlgSaveBin,
                              @pbProgress);
  SCR.FreeOnTerminate := True;
  SCR.Start;
end;

procedure TfrmMain.btnRefreshScriptsClick(Sender: TObject);
begin
  RefreshScriptsList;
end;

procedure TfrmMain.btnRunClick(Sender: TObject);
var
  SCR: TScriptThread;
begin
  Disable(Self);

  SCR := TScriptThread.Create(mmoLog.Text, @mmoLog, @dlgSaveBin, @pbProgress);
  SCR.FreeOnTerminate := True;
  SCR.OnTerminate := Enable;
  SCR.Start;
end;

procedure TfrmMain.btnSaveLuaClick(Sender: TObject);
begin
  if cbbScript.Items.Count = 0 then Exit;

  mmoLog.Lines.SaveToFile(GetCurrentDir + '\scripts\' +
                            cbbScript.Items.Strings[cbbScript.ItemIndex]);
end;

procedure TfrmMain.cbbScriptChange(Sender: TObject);
begin
  if cbbScript.Items.Count = 0 then Exit;

  mmoLog.Lines.Clear;

  if cbbScript.ItemIndex = -1 then cbbScript.ItemIndex := 0;

  mmoLog.Lines.LoadFromFile(GetCurrentDir + '\scripts\' +
                            cbbScript.Items.Strings[cbbScript.ItemIndex]);
end;

procedure TfrmMain.Disable(Sender: TObject);
begin
  btnRun.Enabled := False;
  btnSaveLua.Enabled := False;
  cbbScript.Enabled := False;
end;

procedure TfrmMain.Enable(Sender: TObject);
begin
  btnRun.Enabled := True;
  btnSaveLua.Enabled := True;
  cbbScript.Enabled := True;
  mmoLog.SelStart := 0;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Stop := False;
  Timer := 0;
  UseLatestCommonDialogs := False;
  Caption := PROGNAME;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  RefreshScriptsList;
end;

procedure TfrmMain.RefreshScriptsList;
var
  path, dir : string;
begin
  cbbScript.Items.Clear;
  dir := GetCurrentDir + '\scripts';

  if not DirectoryExists(dir) then CreateDir(dir);

  for path in TDirectory.GetFiles(dir) do
    if LowerCase(ExtractFileExt(path)) = '.lua' then
      cbbScript.Items.Add(ExtractFileName(path));

  btnRun.Enabled := cbbScript.Items.Count > 0;
  btnSaveLua.Enabled := cbbScript.Items.Count > 0;
  cbbScript.Enabled := btnRun.Enabled;
  cbbScriptChange(Self);
end;

end.
