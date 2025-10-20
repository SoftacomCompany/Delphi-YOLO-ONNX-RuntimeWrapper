(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original Authors:  Softacom (https://www.softacom.com)                 *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 This is a wrapper for the Python4Delphi library,        *)
(*                 as a singleton pattern.                                 *)
(*                 This allows to run Python code through Delphi functions *)
(***************************************************************************)

unit Python.Manager;

interface
uses
  System.Classes, System.SysUtils, PythonEngine;

type
  IPythonManager = interface
  ['{48C74DE3-BA90-4A96-9E0E-F1076B9EDE79}']
    function GetExecTime: Int64;
    function GetLastError: string;
    function GetEngine: TPythonEngine;
    function GetModule(const aModuleName: string): TPythonModule;
    function PythonConnect(const aDllName: string = ''): Boolean;
    function PythonDisconnect: Boolean;
    function AddModule(aModule: TPythonModule): Boolean;
    function NewModule(const aModuleName: string; aInitProc: TNotifyEvent = nil): Boolean;
    function IsPythonConnected: Boolean;
    function RunCode(const aCode: string; const aDict: PPyObject = nil): Boolean; overload;
    function RunCode(const aCode: string; aNew_dict: Boolean): Boolean; overload;
    procedure SetBuffer(ABuffer: Pointer; ALen: Integer);
    procedure ClearBuffer;

    property ExecTime: Int64 read GetExecTime;
    property Engine: TPythonEngine read GetEngine;
    property Module[const aModuleName: string]: TPythonModule read GetModule;
  end;

  TPythonManager = class(TInterfacedObject, IPythonManager)
  private
    fExecTime: Int64;
    fLastError: string;
    fBuffer: Pointer;
    fBufferLen: Integer;
    fRawBuffer: PPyObject;
    class var fInstance: IPythonManager;
    class function GetInstance: IPythonManager; static;
    function FindModule(const aModuleName: string): TPythonModule;
    function HasModule(const aModuleName: string): Boolean;
    function CheckModuleName(const aModuleName: string): Boolean;
  public
    destructor Destroy; override;
    class property Instance: IPythonManager read GetInstance;
    class procedure ReleaseInstance; static;
    class procedure ResetEngine; static;
    class function GetPythonDll: string; static;
    class function IsPythonReady: Boolean; static;
    { TPythonManager }
    function GetExecTime: Int64;
    function GetLastError: string;
    function GetEngine: TPythonEngine;
    function GetModule(const aModuleName: string): TPythonModule;
    function PythonConnect(const aDllName: string = ''): Boolean;
    function PythonDisconnect: Boolean;
    function AddModule(aModule: TPythonModule): Boolean;
    function NewModule(const aModuleName: string; aInitProc: TNotifyEvent = nil): Boolean;
    function IsPythonConnected: Boolean;
    function RunCode(const aCode: string; const aDict: PPyObject = nil): Boolean; overload;
    function RunCode(const aCode: string; aNew_dict: Boolean): Boolean; overload;
    procedure SetBuffer(ABuffer: Pointer; ALen: Integer);
    procedure PrepareRawBuffer;
    procedure ClearBuffer;
    {prop}
    property ExecTime: Int64 read GetExecTime;
    property Engine: TPythonEngine read GetEngine;
    property Module[const aModuleName: string]: TPythonModule read GetModule;
    class property PythonDll: string read GetPythonDll;
  end;

  function PythonManager: IPythonManager; overload;
  function PythonManager(aResetEngine: Boolean): IPythonManager; overload;
  procedure PythonManagerRelease;

implementation

uses
  System.Diagnostics, VarPyth;

const
  S_PYTHONISNOTCONNECTED = 'Python is not connected.';

function PythonManager: IPythonManager;
begin
  Result := TPythonManager.Instance;
end;

function PythonManager(aResetEngine: Boolean): IPythonManager;
begin
  if aResetEngine then
    TPythonManager.ResetEngine;
  Result := TPythonManager.Instance;
end;

procedure PythonManagerRelease;
begin
  TPythonManager.ReleaseInstance;
end;

{ TPythonManager }

function TPythonManager.AddModule(aModule: TPythonModule): Boolean;
begin
  if (not IsPythonConnected) or (not Assigned(aModule)) or (not CheckModuleName(aModule.Name)) then
    Exit(False);
  Result := HasModule(aModule.Name);
  if not Result then
  begin
    aModule.Engine := Engine;
    if not aModule.Initialized then
      aModule.Initialize;
    Result := HasModule(aModule.Name);
  end;
end;

function TPythonManager.CheckModuleName(const aModuleName: string): Boolean;
begin
  Result := (not aModuleName.Trim.IsEmpty);
end;

procedure TPythonManager.ClearBuffer;
begin
  fBuffer := nil;
  fBufferLen := 0;
  fRawBuffer := nil;
end;

destructor TPythonManager.Destroy;
begin
  PythonDisconnect;
  inherited;
end;

function TPythonManager.FindModule(const aModuleName: string): TPythonModule;
begin
  if (not aModuleName.Trim.IsEmpty) and IsPythonConnected then
  begin
    for var i := 0 to Engine.ClientCount - 1 do
    begin
      if (Engine.Clients[i] is TPythonModule)
        and SameText(TPythonModule(Engine.Clients[i]).Name, aModuleName) then
      begin
        Exit(TPythonModule(Engine.Clients[i]));
      end;
    end;
  end;
  Result := nil;
end;

function TPythonManager.GetEngine: TPythonEngine;
begin
  if PythonOk then
    Result := GetPythonEngine
  else
    Result := nil;
end;

function TPythonManager.GetExecTime: Int64;
begin
  Result := fExecTime;
end;

class function TPythonManager.GetInstance: IPythonManager;
begin
  if fInstance = nil then
    fInstance := TPythonManager.Create;
  Result := fInstance;
end;

function TPythonManager.GetLastError: string;
begin
  Result := fLastError;
end;

function TPythonManager.GetModule(const aModuleName: string): TPythonModule;
begin
  Result := FindModule(aModuleName);
end;

class function TPythonManager.GetPythonDll: string;
begin
  if IsPythonReady then
  begin
    if GetPythonEngine.DllPath.IsEmpty then
      Result := GetPythonEngine.PythonHome + GetPythonEngine.DllName
    else
      Result := GetPythonEngine.DllPath + GetPythonEngine.DllName;
  end
  else
    Result := EmptyStr;
end;

function TPythonManager.HasModule(const aModuleName: string): Boolean;
begin
  Result := Assigned(FindModule(aModuleName));
end;

function TPythonManager.IsPythonConnected: Boolean;
begin
  Result := IsPythonReady;
end;

class function TPythonManager.IsPythonReady: Boolean;
begin
  Result := PythonOK and (GetPythonEngine <> Nil);
end;

function TPythonManager.NewModule(const aModuleName: string; aInitProc: TNotifyEvent): Boolean;
begin
  if (not IsPythonConnected) or (not CheckModuleName(aModuleName)) or HasModule(aModuleName) then
    Exit(False);
  var LModule := TPythonModule.Create(nil);
  LModule.Name := aModuleName;
  LModule.OnInitialization := aInitProc;
  Result := AddModule(LModule);
end;

procedure TPythonManager.PrepareRawBuffer;
begin
  if Assigned(fBuffer) then
    fRawBuffer := Engine.PyBytes_FromStringAndSize(PAnsiChar(fBuffer), fBufferLen)
  else
    fRawBuffer := nil;
end;

function TPythonManager.PythonConnect(const aDllName: string): Boolean;
var
  LEngine: TPythonEngine;
begin
  Result := IsPythonConnected;
  fLastError := EmptyStr;
  if not Result then
  begin
    LEngine := TPythonEngine.Create(nil);
    try
      try
        LEngine.FatalAbort := False;
        LEngine.UseLastKnownVersion := aDllName.Trim.IsEmpty;
        LEngine.AutoLoad := LEngine.UseLastKnownVersion;
        if not LEngine.UseLastKnownVersion then
        begin
          LEngine.DllName := ExtractFileName(aDllName);
          LEngine.DllPath := ExtractFilePath(aDllName);
          LEngine.OpenDll(LEngine.DllName);
        end
        else
          LEngine.LoadDll;
        Result := IsPythonConnected;
      except
        on E: Exception do
          begin
            Result := False;
            fLastError := E.Message;
          end;
      end;
    finally
      if not Result then
        FreeAndNil(LEngine);
    end;
  end;
end;

function TPythonManager.PythonDisconnect: Boolean;
begin
  Result := IsPythonConnected;
  fLastError := EmptyStr;
  if Result then
  begin
    try
      if not Engine.AutoFinalize then
        Engine.Py_Finalize;
      if not Engine.AutoUnload then
        Engine.UnloadDll;
      FreeAndNil(Engine);
    except
      on E: Exception do
        begin
          Result := False;
          fLastError := E.Message;
        end;
    end;
  end;
end;

class procedure TPythonManager.ReleaseInstance;
begin
  fInstance := nil;
end;

class procedure TPythonManager.ResetEngine;
begin
  if IsPythonReady then
    GetPythonEngine.Py_NewInterpreter;
end;

function TPythonManager.RunCode(const aCode: string; const aDict: PPyObject): Boolean;
var
  LStopWatch: TStopwatch;
begin
  fExecTime := 0;
  fLastError := S_PYTHONISNOTCONNECTED;
  if not IsPythonConnected then
    Exit(False);
  fLastError := EmptyStr;
  LStopWatch := TStopWatch.StartNew;
  try
    with Engine do
    begin
      if Assigned(fBuffer) then
      begin
        if not Assigned(fRawBuffer) then
          PrepareRawBuffer;
        if Assigned(fRawBuffer) then
        begin
          PyDict_SetItemString(PyModule_GetDict(GetMainModule),
            PAnsiChar(AnsiString('raw_buffer')), fRawBuffer);
          GetPythonEngine.Py_DecRef(fRawBuffer);
          fRawBuffer := nil;
        end;
      end;

      if aDict <> nil then
      begin
        ExecString(UTF8Encode(aCode), PyModule_GetDict(GetMainModule), aDict);
      end
      else
        ExecString(UTF8Encode(aCode));
    end;
    Result := True;
 except
    on E: Exception do
      begin
        Result := False;
        fLastError := E.Message;
      end;
  end;
  LStopWatch.Stop;
  fExecTime := LStopWatch.ElapsedMilliseconds;
end;

function TPythonManager.RunCode(const aCode: string; aNew_dict: Boolean): Boolean;
begin
  if aNew_dict then
    Result := RunCode(aCode, Engine.PyDict_New)
  else
    Result := RunCode(aCode)
end;

procedure TPythonManager.SetBuffer(ABuffer: Pointer; ALen: Integer);
begin
  if (ABuffer <> nil) and (ALen > 0) then
  begin
    fBuffer := ABuffer;
    fBufferLen := ALen;
  end
  else
    ClearBuffer;
end;

initialization

finalization
  PythonManagerRelease;
end.
