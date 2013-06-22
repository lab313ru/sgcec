unit uScriptThread;

interface

uses
  System.Classes, uScripts, Winapi.Windows;

type
  TScriptThread = class(TThread)
  protected
    fSCR: TScript;
    procedure Execute; override;
  public
    constructor Create(const Script: string; Printer, Dialog, Progress: Pointer);
  end;

implementation

{ TScriptThread }

constructor TScriptThread.Create(const Script: string; Printer, Dialog, Progress: Pointer);
begin
  inherited Create(True);

  fSCR := TScript.Create;
  fSCR.init(fSCR.LuaInstance, Script, Printer, Dialog, Progress);
  fSCR.RegisterFunction('print');
end;

procedure TScriptThread.Execute;
begin
  NameThreadForDebugging('ScriptThread');
  { Place thread code here }

  if fSCR.connect(fSCR.LuaInstance) then
    fSCR.DoString(fSCR.LuaInstance);

  fSCR.disconnect(fSCR.LuaInstance);
  fSCR.Destroy;
end;

end.
