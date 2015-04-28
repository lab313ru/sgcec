unit uScripts;

interface

{$M+}

uses
  Lua, LuaLib, synaser, Vcl.StdCtrls, Winapi.Windows, Winapi.Messages,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.Graphics;

  type
    TScript = class(TLua)
    private
      Serial: TBlockSerial;
      fScript: AnsiString;
      fPrint: ^TMemo;
      fSaveDialog: ^TSaveDialog;
      fProgress: ^TProgressBar;
      function LineWidth(const Text: string): Integer;
      function get_port: Integer;
      procedure read_string(L: TLuaState);
      procedure trimmer(L: TLuaState);
    public
      procedure init(L: TLuaState; const Script: string; pMemo, pSaveDialog, pProgress: Pointer);
      function connect(L: TLuaState): boolean;
      procedure disconnect(L: TLuaState);
      procedure DoString(L: TLuaState);
    published
      function rom_read_byte(L: TLuaState): Integer;
      function rom_write_byte(L: TLuaState): Integer;
      function rom_read_word(L: TLuaState): Integer;
      function rom_write_word(L: TLuaState): Integer;
      function rom_saveto(L: TLuaState): Integer;
      function rom_size(L: TLuaState): Integer;
      function rom_dump(L: TLuaState): Integer;
      function rom_name_d(L: TLuaState): Integer;
      function rom_name_o(L: TLuaState): Integer;
      function rom_name_g(L: TLuaState): Integer;
      function rom_country(L: TLuaState): Integer;
      function rom_revision(L: TLuaState): Integer;
      function rom_checksum(L: TLuaState): Integer;
      function dev_delay(L: TLuaState): Integer;
      function dev_set_delay(L: TLuaState): Integer;
      function dev_reset_low(L: TLuaState): Integer;
      function dev_reset_high(L: TLuaState): Integer;
      function dev_time_low(L: TLuaState): Integer;
      function dev_time_high(L: TLuaState): Integer;
      function dev_info(L: TLuaState): Integer;
      function dev_send(L: TLuaState): Integer;
      function dev_reset(L: TLuaState): Integer;
      function print(L: TLuaState): Integer;
    end;

implementation

{ TScript }

uses
  System.SysUtils, Registry, Classes;

type
  PBytesArray = ^TBytesArray;
  TBytesArray = array[0..$13FFFFF] of Byte;

const
  TIMEOUT = 1000;
  NONE = 1;
  ASCII = 2;
  HEX = 3;

function TScript.rom_read_byte(L: TLuaState): Integer;
var
  OFFSET, SIZE: lua_Integer;
  S: AnsiString;
  SHOW: Boolean;
  Params: Integer;
begin
  Params := lua_gettop(L);
  case Params of
    2: SHOW := False;
    3:
    begin
      SHOW := lua_toboolean(L, lua_gettop(L));
      Lua_Pop(L, 1);
    end;
  else
    Result := 0;
    Exit;
  end;

  OFFSET := Lua_ToInteger(L, lua_gettop(L) - 1);
  SIZE := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 2);

  S := Format('READ_BYTE %X %X', [OFFSET, SIZE]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);

  if SHOW then
  begin
    read_string(L);
    Result := 1;
  end
  else
  begin
    while Serial.CanRead(TIMEOUT) do
      Serial.RecvPacket(0);
    Result := 0;
  end;
end;

function TScript.rom_read_word(L: TLuaState): Integer;
var
  OFFSET, SIZE: lua_Integer;
  S: AnsiString;
  SHOW: Boolean;
  Params: Integer;
begin
  Params := lua_gettop(L);
  case Params of
    2: SHOW := False;
    3:
    begin
      SHOW := lua_toboolean(L, lua_gettop(L));
      Lua_Pop(L, 1);
    end;
  else
    Result := 0;
    Exit;
  end;

  OFFSET := Lua_ToInteger(L, lua_gettop(L) - 1);
  SIZE := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 2);

  S := Format('READ_WORD %X %X', [OFFSET, SIZE]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);

  if SHOW then
  begin
    read_string(L);
    Result := 1;
  end
  else
  begin
    while Serial.CanRead(TIMEOUT) do
      Serial.RecvPacket(0);
    Result := 0;
  end;
end;

function TScript.rom_write_byte(L: TLuaState): Integer;
var
  OFFSET, VALUE: lua_Integer;
  S: AnsiString;
  Params: Integer;
begin
  Result := 0;
  Params := lua_gettop(L);
  if Params in [0..1] then Exit;

  OFFSET := Lua_ToInteger(L, lua_gettop(L) - 1);
  VALUE := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 2);

  S := Format('WRITE_BYTE %X %X', [OFFSET, VALUE]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);
end;

function TScript.rom_write_word(L: TLuaState): Integer;
var
  OFFSET, VALUE: lua_Integer;
  S: AnsiString;
  Params: Integer;
begin
  Result := 0;
  Params := lua_gettop(L);
  if Params in [0..1] then Exit;

  OFFSET := Lua_ToInteger(L, lua_gettop(L) - 1);
  VALUE := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 2);

  S := Format('WRITE_WORD %X %X', [OFFSET, VALUE]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);
end;

function TScript.rom_checksum(L: TLuaState): Integer;
const
  name = 'READ_WORD 18E 1';
begin
  lua_pushlstring(L, name, Length(name));
  dev_send(L);
  read_string(L);
  Result := 1;
end;

function TScript.connect(L: TLuaState): boolean;
var
  PORT: integer;
begin
  if Serial <> nil then disconnect(L);
  Serial := TBlockSerial.Create;
  PORT := GET_PORT;

  Result := False;

  if PORT = -1 then
  begin
    disconnect(L);
    Exit;
  end;

  Serial.Connect(Format('COM%d', [PORT]));
  Serial.Config(115200, 8, 'N', SB1, False, False);

  Result := True;
end;

function TScript.rom_country(L: TLuaState): Integer;
const
  name = 'READ_WORD 1F0 8';
begin
  lua_pushlstring(L, name, Length(name));
  dev_send(L);
  read_string(L);
  trimmer(L);
  Result := 1;
end;

function TScript.dev_delay(L: TLuaState): Integer;
var
  S: AnsiString;
  DEL: Integer;
begin
  Result := 0;
  if lua_gettop(L) = 0 then Exit;

  DEL := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 1);

  S := Format('DELAY %X', [DEL]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);
end;

procedure TScript.disconnect(L: TLuaState);
begin
  lua_pop(L, lua_gettop(L));

  if Serial = nil then Exit;

  Serial.Purge;
  Serial.CloseSocket;
  Serial.Destroy;
  Serial := nil;
end;

procedure TScript.DoString(L: TLuaState);
begin
  luaL_dostring(L, PAnsiChar(fScript));
end;

function TScript.rom_dump(L: TLuaState): Integer;
const
  BUFSIZE = 16384;
var
  ROMSIZE, ReadedSize, ToRead, Readed: Integer;
  S: AnsiString;
  buf: PBytesArray;
begin
  Result := 0;
  if lua_gettop(L) = 0 then Exit;

  ROMSIZE := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 1);

  if ROMSIZE = 0 then Exit;

  S := Format('READ_WORD %X %X', [0, ROMSIZE div 2]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);

  S := '';
  buf := GetMemory(ROMSIZE);
  ToRead := ROMSIZE;
  ReadedSize := 0;

  fProgress^.Position := 0;
  fProgress^.Max := ROMSIZE;

  while (ReadedSize < ROMSIZE) do
  begin
    if ToRead >= BUFSIZE then
      Readed := Serial.RecvBufferEx(@buf^[ReadedSize], BUFSIZE, TIMEOUT)
    else
      Readed := Serial.RecvBufferEx(@buf^[ReadedSize], ToRead, TIMEOUT);

    ToRead := ToRead - Readed;

    ReadedSize := ReadedSize + Readed;
    fProgress^.Position := ReadedSize;
  end;

  SetLength(S, ROMSIZE);
  Move(buf^[0], S[1], ROMSIZE);
  FreeMemory(buf);
  lua_pushlstring(L, PAnsiChar(S), ROMSIZE);
  fProgress^.Position := 0;

  Result := 1;
end;

function TScript.rom_name_g(L: TLuaState): Integer;
var
  nameo, countr, rev: PAnsiChar;
  len: Cardinal;
  name: AnsiString;
begin
  rom_name_o(L);
  nameo := lua_tolstring(L, lua_gettop(L), len);

  rom_country(L);
  countr := lua_tolstring(L, lua_gettop(L), len);

  rom_revision(L);
  rev := lua_tolstring(L, lua_gettop(L), len);

  name := Format('%s (%s) (REV%s).bin', [StrUpper(nameo),
                                         StrUpper(countr),
                                         StrUpper(rev)]);
  name := StringReplace(name, ':', '_', []);
  lua_pop(L, 3);
  lua_pushlstring(L, PAnsiChar(name), Length(name));
  Result := 1;
end;

function TScript.dev_info(L: TLuaState): Integer;
const
  INFO_ = 'INFO';
begin
  lua_pushlstring(L, INFO_, Length(INFO_));
  dev_send(L);
  read_string(L);
  trimmer(L);
  Result := 1;
end;

procedure TScript.init(L: TLuaState; const Script: string; pMemo, pSaveDialog, pProgress: Pointer);
begin
  lua_pop(L, lua_gettop(L));

  fPrint := pMemo;
  fSaveDialog := pSaveDialog;
  fProgress := pProgress;
  luaL_openlibs(L);

  lua_pushinteger(L, NONE);
  lua_setglobal(L, 'none');
  lua_pushinteger(L, ASCII);
  lua_setglobal(L, 'ascii');
  lua_pushinteger(L, HEX);
  lua_setglobal(L, 'hex');

  lua_newtable(L);
  lua_setglobal(L, 'rom');
  luaL_dostring(L, 'rom[''write_byte'']=rom_write_byte');
  luaL_dostring(L, 'rom[''read_byte'']=rom_read_byte');
  luaL_dostring(L, 'rom[''write_word'']=rom_write_word');
  luaL_dostring(L, 'rom[''read_word'']=rom_read_word');
  luaL_dostring(L, 'rom[''size'']=rom_size');
  luaL_dostring(L, 'rom[''dump'']=rom_dump');

  lua_newtable(L);
  lua_setglobal(L, 'rom_name');
  luaL_dostring(L, 'rom_name[''dom'']=rom_name_d');
  luaL_dostring(L, 'rom_name[''ovr'']=rom_name_o');
  luaL_dostring(L, 'rom_name[''good'']=rom_name_g');
  luaL_dostring(L, 'rom[''name'']=rom_name');

  luaL_dostring(L, 'rom[''country'']=rom_country');
  luaL_dostring(L, 'rom[''revision'']=rom_revision');
  luaL_dostring(L, 'rom[''checksum'']=rom_checksum');
  luaL_dostring(L, 'rom[''saveto'']=rom_saveto');

  lua_newtable(L);
  lua_setglobal(L, 'dev');
  luaL_dostring(L, 'dev[''reset'']=dev_reset');
  luaL_dostring(L, 'dev[''reset_low'']=dev_reset_low');
  luaL_dostring(L, 'dev[''reset_high'']=dev_reset_high');
  luaL_dostring(L, 'dev[''delay'']=dev_delay');
  luaL_dostring(L, 'dev[''set_delay'']=dev_set_delay');
  luaL_dostring(L, 'dev[''time_low'']=dev_time_low');
  luaL_dostring(L, 'dev[''time_high'']=dev_time_high');
  luaL_dostring(L, 'dev[''info'']=dev_info');


  fScript := Script;
  fPrint^.Lines.Clear;
end;

function TScript.rom_name_d(L: TLuaState): Integer;
const
  name = 'READ_WORD 120 18';
begin
  lua_pushlstring(L, name, Length(name));
  dev_send(L);
  read_string(L);
  trimmer(L);
  Result := 1;
end;

function TScript.rom_name_o(L: TLuaState): Integer;
const
  name = 'READ_WORD 150 18';
begin
  lua_pushlstring(L, name, Length(name));
  dev_send(L);
  read_string(L);
  trimmer(L);
  Result := 1;
end;

function TScript.print(L: TLuaState): Integer;
var
  S: PBytesArray;
  len, I: Cardinal;
  MODE, Params: Integer;
  printf, Line: AnsiString;
  C: AnsiChar;
begin
  Result := 0;
  MODE := NONE;
  Params := lua_gettop(L);

  case Params of
    0: Exit;
    2:
    begin
      MODE := lua_tointeger(L, lua_gettop(L));
      lua_pop(L, 1);
      if (MODE = 0) or (MODE > 3) then Exit;
    end;
  end;

  S := Pointer(lua_tolstring(L, lua_gettop(L), len));
  Lua_Pop(L, 1);

  if S = nil then Exit;

  printf := '';
  Line := '';

  for I := 1 to len do
  begin
    case MODE of
      NONE:
      begin
        SetLength(printf, len);
        Move(S^[0], printf[1], len);
        Break;
      end;
      ASCII:
      begin
        if S^[I - 1] in [$20..$7E] then
          C := AnsiChar(S^[I - 1])
        else
          C := '.';

        printf := printf + C;
        Line := Line + C;

        if LineWidth(Line) >= (fPrint^.Width - 50) then
        begin
          printf := printf + #13#10;
          Line := '';
        end;
      end;
      HEX: printf := printf + Format('%.2X', [S^[I - 1]]);
    end;
  end;

  if printf <> '' then
    fPrint^.Lines.Add(printf + #13#10);
end;

procedure TScript.read_string(L: TLuaState);
var
  S: AnsiString;
begin
  S := '';

  while Serial.CanRead(TIMEOUT) do
    S := S + Serial.RecvPacket(0);

  lua_pushlstring(L, PAnsiChar(S), Length(S));
end;

function TScript.dev_reset(L: TLuaState): Integer;
const
  RESET = 'RESET';
begin
  lua_pushlstring(L, RESET, Length(RESET));
  dev_send(L);
  Result := 0;
end;

function TScript.rom_revision(L: TLuaState): Integer;
const
  name = 'READ_WORD 18C 1';
begin
  lua_pushlstring(L, name, Length(name));
  dev_send(L);
  read_string(L);
  trimmer(L);
  Result := 1;
end;

function TScript.rom_size(L: TLuaState): Integer;
const
  GET_GENESIS_ROMSIZE = 'ROMSIZE';
var
  S: AnsiString;
begin
  lua_pushlstring(L, GET_GENESIS_ROMSIZE, Length(GET_GENESIS_ROMSIZE));
  dev_send(L);

  S := Serial.Recvstring(TIMEOUT);
  lua_pushinteger(L, StrToIntDef(S, 0));
  Result := 1;
end;

function TScript.rom_saveto(L: TLuaState): Integer;
var
  S: PAnsiChar;
  len: Cardinal;
  S_: AnsiString;
begin
  Result := 0;

  rom_name_g(L);
  S := lua_tolstring(L, lua_gettop(L), len);
  lua_pop(L, 1);
  S_ := S;

  fSaveDialog^.InitialDir := GetCurrentDir;
  fSaveDialog^.FileName := StringReplace(S_, ':', '_', [rfReplaceAll]);

  if not fSaveDialog^.Execute then
  begin
    fSaveDialog^.InitialDir := '';
    Exit;
  end;

  fSaveDialog^.InitialDir := '';
  S_ := fSaveDialog^.FileName;
  lua_pushlstring(L, PAnsiChar(S_), Length(S_));

  Result := 1;
end;

function TScript.dev_send(L: TLuaState): Integer;
var
  S: PAnsiChar;
  len: Cardinal;
begin
  Result := 0;
  if lua_gettop(L) = 0 then Exit;

  S := lua_tolstring(L, lua_gettop(L), len);
  S := PAnsiChar(S + CR);
  Lua_Pop(L, 1);
  Serial.SendString(S);
end;

function TScript.dev_set_delay(L: TLuaState): Integer;
var
  S: AnsiString;
  DEL: Integer;
begin
  Result := 0;
  if lua_gettop(L) = 0 then Exit;

  DEL := Lua_ToInteger(L, lua_gettop(L));
  Lua_Pop(L, 1);

  S := Format('SET_DELAY %X', [DEL]);
  lua_pushlstring(L, PAnsiChar(S), Length(S));
  dev_send(L);
end;

function TScript.dev_time_high(L: TLuaState): Integer;
const
  TIME_HIGH_ = 'TIME_HIGH';
begin
  lua_pushlstring(L, TIME_HIGH_, Length(TIME_HIGH_));
  dev_send(L);
  Result := 0;
end;

function TScript.dev_time_low(L: TLuaState): Integer;
const
  TIME_LOW_ = 'TIME_LOW';
begin
  lua_pushlstring(L, TIME_LOW_, Length(TIME_LOW_));
  dev_send(L);
  Result := 0;
end;

function TScript.dev_reset_high(L: TLuaState): Integer;
const
  RESET_HIGH_ = 'RESET_HIGH';
begin
  lua_pushlstring(L, RESET_HIGH_, Length(RESET_HIGH_));
  dev_send(L);
  Result := 0;
end;

function TScript.dev_reset_low(L: TLuaState): Integer;
const
  RESET_LOW_ = 'RESET_LOW';
begin
  lua_pushlstring(L, RESET_LOW_, Length(RESET_LOW_));
  dev_send(L);
  Result := 0;
end;

procedure TScript.trimmer(L: TLuaState);
var
  S: PAnsiChar;
  len: Cardinal;
  S_: AnsiString;
begin
  if lua_gettop(L) = 0 then Exit;

  S := lua_tolstring(L, lua_gettop(L), len);
  lua_pop(L, 1);
  S_ := S;
  S_ := Trim(S_);
  lua_pushlstring(L, PAnsiChar(S_), Length(S_));
end;

function TScript.get_port: Integer;
var
  reg: TRegistry;
  st: Tstrings;
  i: Integer;
  num: string;
begin
  Result := -1;
  reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    reg.OpenKey('hardware\devicemap\serialcomm', False);
    st := TstringList.Create;
    try
      reg.GetValueNames(st);
      for i := 0 to st.Count - 1 do
        if Pos('USBSER', st.Strings[I]) > 0 then
        begin
          num := reg.Readstring(st.strings[i]);
          Result := StrToInt(Copy(num, 4, Length(num) - 3));
          Break;
        end;
    finally
      st.Free;
    end;
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

function TScript.LineWidth(const Text: string): Integer;
var
  BM: TBitmap;
begin
  BM := TBitmap.Create;
  try
    BM.Canvas.Font := fPrint^.Font;
    Result := BM.Canvas.TextWidth(Text);
  finally
    BM.Free;
  end;

end;

end.
