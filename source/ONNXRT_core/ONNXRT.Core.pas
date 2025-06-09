(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original code:  Softacom (https://www.softacom.com)                    *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality: This is base class and interface of the detection.      *)
(*                                                                         *)
(***************************************************************************)

unit ONNXRT.Core;

interface
uses
  System.SysUtils, System.Generics.Collections, System.Diagnostics,
  VarPyth, PythonEngine, Python.Manager,
  ONNXRT.Types, ONNXRT.Classes;

type
  IOnnxrtWrapper = interface
  ['{FB9318CB-1BE2-4731-8B12-E82BCAB542F0}']
    function GetPythonDll: string;
    procedure SetProcessStatus(aStatus: TProcessStatus);
    function GetProcessStatus: TProcessStatus;
    function GetFunctionTime: TIntTime;
    function GetProcessTime: TIntTime;
    function GetLastError: string;
    procedure SetDetectionValue(const aKey, aValue: string);
    function GetDetectionValue(const aKey: string): string;
    function GetDetectionValues: TDictionary<string, string>;
    function GetDetectionResults: IDetectionResults;
    function Initialize(const aDllName: string = ''): Boolean;
    function IsInitialized: Boolean;
    {detection}
    /// <summary> Registering a status change event. </summary>
    procedure RegisterStatusEvent(aStatusEvent: TProc<TObject, Integer, string, Boolean>);
    /// <summary> Unregistering a status change event. </summary>
    procedure UnRegisterStatusEvent(aStatusEvent: TProc<TObject, Integer, string, Boolean>);
    /// <summary> Getting a list of supported providers. </summary>
    function GetProviders(aAll: Boolean = False): string;
    /// <summary> Getting the metadata record. </summary>
    function GetMetadata(const aModelFile: string = ''): TMetadata;
    /// <summary>
    ///   Getting the list of model classes from metadata record.
    ///   Format is: "Index: 'ClassName'".
    /// </summary>
    function GetModelClasses(const aMeta: TMetadata): string;
    /// <summary> Creating a Dictionary of Detection Values. </summary>
    function CreateDetectionValues(const aModelFile, aImagefile : string;
      const aOutImagefile: string = '';
      const aProviders: string = '';
      const aFilterClasses: string = '';
      const acfThreshold: string = '';
      const aiouThreshold: string = '';
      const aModelType: string = ''): TDictionary<string, string>;
    /// <summary> Generating a python code by options and internal detection values. </summary>
    /// <param name="aOptions">
    ///   Options for code generation.
    ///   One or a combination of:
    ///     pcDrawDetected = 1; //Generate draw code
    ///     pcLoad = 2; //Generate code to open image
    ///     pcSave = 4; //Generate code to save processed image
    ///     pcEnableIO = 7; //Mask options - only lad and save section
    ///     pcDisableIO = High(Word) - pcEnableIO; //Mask options - exclude load and save section
    ///     pcAddImport = 8; //Add import code
    ///     pcAddDefinitions = 16; //Add definitions to code
    ///     pcFullCode = High(Word);
    ///   If the options are zero, pcFullCode is used.
    /// </param>
    function BuildDetectionCode(aOptions: Word): string; overload;
    /// <summary> Generating a python code by options and external detection values. </summary>
    function BuildDetectionCode(aOptions: Word;
      aValues: TDictionary<string, string>): string; overload;
    /// <summary>
    ///   Main detection procedure.
    /// </summary>
    /// <param name="aValues">
    ///   Detection values used.
    ///   If not assigned, the internal detection values are used.
    ///   If the output image file name is set, the image will be saved.
    /// </param>
    /// <return> True when success. </return>
    function Predict(aValues: TDictionary<string, string> = nil): Boolean; overload;
    /// <summary>
    ///   Main detection procedure.
    ///   Parameters are detection values.
    ///   If the output image file name "aOutImagefile" is set, the image will be saved.
    /// </summary>
    /// <return> True when success. </return>
    function Predict(const aModelFile, aImagefile : string;
      const aOutImagefile: string = '';
      const aProviders: string = '';
      const aFilterClasses: string = '';
      const acfThreshold: string = '';
      const aiouThreshold: string = '';
      const aModelType: string = ''): Boolean; overload;
    {prop}
    /// <summary> The status of current process. </summary>
    property ProcessStatus: TProcessStatus read GetProcessStatus write SetProcessStatus;
    /// <summary> Elapsed time of Python code execution. </summary>
    property FunctionTime: TIntTime read GetFunctionTime;
    /// <summary> Elapsed time of current process. </summary>
    property ProcessTime: TIntTime read GetProcessTime;
    /// <summary> Getting the last operation error text. </summary>
    property LastError: string read GetLastError;
    /// <summary> Selecting detection values by keys. </summary>
    property DetectionValue[const aKey: string]: string read GetDetectionValue write SetDetectionValue;
    /// <summary> Getting a dictionary of detection values. </summary>
    property DetectionValues: TDictionary<string, string> read GetDetectionValues;
    /// <summary> Interface for accessing the detection result values. </summary>
    property DetectionResults: IDetectionResults read GetDetectionResults;
    property PythonDll: string read GetPythonDll;
  end;

  TOnnxrtWrapper = class(TInterfacedObject, IOnnxrtWrapper)
  strict private
    fLastError: string;
    fStopWatch: TStopwatch;
    fProcessTime: TIntTime;  //msec, time of process
    fFunctionTime: TIntTime;  //msec, time of python function
  private
    fIsInitialized: Boolean;
    fInitializedModels: TList<string>;
    fDetectionResults: IDetectionResults;
    fDetectionValues: TDictionary<string, string>;
    fProcessStatus: TProcessStatus;
    fStatusEvents: TList<TProc<TObject, Integer, string, Boolean>>;
    class var fInstance: IOnnxrtWrapper;
    class function GetInstance: IOnnxrtWrapper; static;
    function DoInitialization: Boolean;
    function DoModelInitialization(aModelType: TModelType): Boolean;
    function IsModelInitialized(aModelType: TModelType): Boolean; overload;
    function IsModelInitialized(aModelType: string): Boolean; overload;
    function ExtractModelType(aValues: TDictionary<string, string>): TModelType;
  protected
    function PyInputCode: string;
    function BuildModelDefinitionCode(const aModelType: TModelType): string;
    function BuildMainDefinitionCode: string;
    function BuildMainDetectionCode(aOptions: Word;
      aValues: TDictionary<string, string> = nil): string;
    function ReplaceCodeValue(const aSourceCode, aKey, aValue: string): string;
    function ReplaceCodeValues(const aSourceCode: string;
      aValues: TDictionary<string, string>): string;
  public
    constructor Create;
    destructor Destroy; override;
    class property Instance: IOnnxrtWrapper read GetInstance;
    class procedure ReleaseInstance; static;
    function GetPythonDll: string;
    procedure SetProcessStatus(aStatus: TProcessStatus);
    function GetProcessStatus: TProcessStatus;
    function GetFunctionTime: TIntTime;
    function GetProcessTime: TIntTime;
    function GetLastError: string;
    procedure SetDetectionValue(const aKey, aValue: string);
    function GetDetectionValue(const aKey: string): string;
    function GetDetectionValues: TDictionary<string, string>;
    function GetDetectionResults: IDetectionResults;
    function Initialize(const aDllName: string = ''): Boolean;
    function IsInitialized: Boolean;
    {detection}
    procedure RegisterStatusEvent(aStatusEvent: TProc<TObject, Integer, string, Boolean>);
    procedure UnRegisterStatusEvent(aStatusEvent: TProc<TObject, Integer, string, Boolean>);
    function GetProviders(aAll: Boolean = False): string;
    function GetMetadata(const aModelFile: string = ''): TMetadata;
    function GetModelClasses(const aMeta: TMetadata): string;
    function CreateDetectionValues(const aModelFile, aImagefile : string;
      const aOutImagefile: string = '';
      const aProviders: string = '';
      const aFilterClasses: string = '';
      const acfThreshold: string = '';
      const aiouThreshold: string = '';
      const aModelType: string = ''): TDictionary<string, string>;
    function BuildDetectionCode(aOptions: Word): string; overload;
    function BuildDetectionCode(aOptions: Word;
      aValues: TDictionary<string, string>): string; overload;
    function Predict(aValues: TDictionary<string, string> = nil): Boolean; overload;
    function Predict(const aModelFile, aImagefile : string;
      const aOutImagefile: string = '';
      const aProviders: string = '';
      const aFilterClasses: string = '';
      const acfThreshold: string = '';
      const aiouThreshold: string = '';
      const aModelType: string = ''): Boolean; overload;
    {prop}
    property ProcessStatus: TProcessStatus read GetProcessStatus write SetProcessStatus;
    property FunctionTime: TIntTime read GetFunctionTime;
    property ProcessTime: TIntTime read GetProcessTime;
    property LastError: string read GetLastError;
    property DetectionValue[const aKey: string]: string read GetDetectionValue write SetDetectionValue;
    property DetectionValues: TDictionary<string, string> read GetDetectionValues;
    property DetectionResults: IDetectionResults read GetDetectionResults;
    property PythonDll: string read GetPythonDll;
  end;

  function OnnxrtWrapper: IOnnxrtWrapper;

implementation

uses
  System.Variants, Python.ONNXRT.Code, Python.Yolo.Code,
  ONNXRT.Constants, ONNXRT.Utils;

function OnnxrtWrapper: IOnnxrtWrapper;
begin
  Result := TOnnxrtWrapper.Instance;
end;

{ TPyONNXRT }

class function TOnnxrtWrapper.GetInstance: IOnnxrtWrapper;
begin
  if fInstance = nil then
    fInstance := TOnnxrtWrapper.Create;
  Result := fInstance;
end;

constructor TOnnxrtWrapper.Create;
begin
  inherited;
  fLastError := EmptyStr;
  fIsInitialized := False;
  fInitializedModels := TList<string>.Create;
  fDetectionResults := TDetectionResults.Create;
  fStatusEvents := TList<TProc<TObject, Integer, string, Boolean>>.Create;
  fDetectionValues := TDictionary<string, string>.Create;
  EnumerateStrings(ONNXRT_VALUES, procedure (aStr: string)
    begin
      DetectionValue[aStr] := EmptyStr;
    end);
  DetectionValue[S_CONFIDENCE_THRESHOLD] := FormatFloat(C_FLOATFORMAT, C_DEFAULT_CONFIDENCE_THRESHOLD);
  DetectionValue[S_IOU_THRESHOLD] := FormatFloat(C_FLOATFORMAT, C_DEFAULT_IOU_THRESHOLD);
  DetectionValue[S_MODELTYPE] := Low(TModelType).AsString;
end;

function TOnnxrtWrapper.CreateDetectionValues(const aModelFile, aImagefile, aOutImagefile,
  aProviders, aFilterClasses, acfThreshold, aiouThreshold,
  aModelType: string): TDictionary<string, string>;
var
  LVar: Double;
begin
  Result := TDictionary<string, string>.Create;
  Result.AddOrSetValue(S_INPUT_IMAGEFILE, aImagefile);
  Result.AddOrSetValue(S_OUT_IMAGEFILE, aOutImagefile);
  Result.AddOrSetValue(S_MODELFILE, aModelFile);
  Result.AddOrSetValue(S_PROVIDERS, aProviders);
  Result.AddOrSetValue(S_FILTERCLASSES, aFilterClasses);

  if TryStrToFloat(acfThreshold, LVar) then
    Result.AddOrSetValue(S_CONFIDENCE_THRESHOLD, FormatFloat(C_FLOATFORMAT, LVar))
  else
    Result.AddOrSetValue(S_CONFIDENCE_THRESHOLD, FormatFloat(C_FLOATFORMAT, C_DEFAULT_CONFIDENCE_THRESHOLD));
  if TryStrToFloat(aiouThreshold, LVar) then
    Result.AddOrSetValue(S_IOU_THRESHOLD, FormatFloat(C_FLOATFORMAT, LVar))
  else
    Result.AddOrSetValue(S_IOU_THRESHOLD, FormatFloat(C_FLOATFORMAT, C_DEFAULT_IOU_THRESHOLD));

  Result.AddOrSetValue(S_MODELTYPE, TModelType.TypeOf(aModelType).AsString);
end;

destructor TOnnxrtWrapper.Destroy;
begin
  fDetectionResults := nil;
  FreeAndNil(fInitializedModels);
  FreeAndNil(fStatusEvents);
  FreeAndNil(fDetectionValues);
  inherited;
end;

function TOnnxrtWrapper.DoInitialization: Boolean;
begin
  Result := fIsInitialized;
  fLastError := EmptyStr;
  if not Result then
  begin
    try
      ProcessStatus := psInitialization;
      var LScript := pyInputCode + BuildMainDefinitionCode;
      fIsInitialized := PythonManager.RunCode(LScript);
      if not fIsInitialized then
        fLastError := SNoInitialization + sLineBreak + PythonManager.GetLastError;
    finally
      Result := fIsInitialized;
      ProcessStatus := ProcessStatus.StatusBy(Result);
    end;
  end;
end;

function TOnnxrtWrapper.DoModelInitialization(aModelType: TModelType): Boolean;
begin
  Result := IsModelInitialized(aModelType);
  fLastError := EmptyStr;
  if not Result then
  begin
    ProcessStatus := psInitialization;
    if PythonManager.RunCode(BuildModelDefinitionCode(aModelType)) then
    begin
      Result := (fInitializedModels.Add(aModelType.AsString) >= 0);
    end
    else
    begin
      fLastError := Format(SNoModelInitialization, [aModelType.AsString])
        + sLineBreak + PythonManager.GetLastError;
    end;
    ProcessStatus := ProcessStatus.StatusBy(Result);
  end;
end;

function TOnnxrtWrapper.ExtractModelType(aValues: TDictionary<string, string>): TModelType;
var
  LValue: string;
begin
  if Assigned(aValues) and aValues.TryGetValue(S_MODELTYPE, LValue) then
    Result := TModelType.TypeOf(LValue)
  else
    Result := Low(TModelType);
end;

function TOnnxrtWrapper.PyInputCode: string;
begin
  Result := ONNXRT_IMPORT + sLineBreak + sLineBreak;
end;

function TOnnxrtWrapper.BuildModelDefinitionCode(const aModelType: TModelType): string;
begin
  //Adding definitions by model type
  case aModelType of
    mtYolo:
      begin
        Result := Result + GetCodeText(YOLO_DEFINES);
      end;
    else
      Result := EmptyStr;
  end;
end;

function TOnnxrtWrapper.BuildMainDefinitionCode: string;
begin
  Result := GetCodeText(ONNXRT_DEFINES);
end;

function TOnnxrtWrapper.BuildMainDetectionCode(aOptions: Word;
  aValues: TDictionary<string, string>): string;
begin
  //Detection code
  Result := ONNXRT_MODELDETECTION + LF + ONNXRT_DETECTION;
  //Adding image loading code
  if (aOptions and pcLoad) <> 0 then
    Result := ONNXRT_CV2_OPENIMAGE + sLineBreak + Result;
  //Adding image drawing code
  if (aOptions and (pcSave or pcDrawDetected)) <> 0 then
    Result := Result + sLineBreak + ONNXRT_DRAWDETECTION
  else
    Result := Result + sLineBreak + ONNXRT_EMPTYIMAGE;
  //Adding image saving code
  if (aOptions and pcSave) <> 0 then
    Result := Result + sLineBreak + ONNXRT_CV2_SAVEIMAGE;
  //Replacing tags with values
  if Assigned(aValues) then
  begin
    Result := ReplaceCodeValues(Result, aValues);
    Result := Result.Replace('\', '\\');
  end;
end;

function TOnnxrtWrapper.BuildDetectionCode(aOptions: Word): string;
begin
  Result := BuildDetectionCode(aOptions, DetectionValues);
end;

function TOnnxrtWrapper.BuildDetectionCode(aOptions: Word;
  aValues: TDictionary<string, string>): string;
begin
  Result := BuildMainDetectionCode(aOptions, aValues);
  if (aOptions and pcAddDefinitions) <> 0 then
  begin
    Result := BuildMainDefinitionCode
      + BuildModelDefinitionCode(ExtractModelType(aValues))
      + sLineBreak + Result;
    if (aOptions and pcAddImport) <> 0 then
      Result := PyInputCode + Result;
  end;
end;

function TOnnxrtWrapper.GetProviders(aAll: Boolean = False): string;
var
  LScript: string;
begin
  if not Initialize then
    Exit;
  fLastError := EmptyStr;
  ProcessStatus := psProcessing;
  if aAll then
    LScript := ONNXRT_ALL_PROVIDERS
  else
    LScript := ONNXRT_AVAILABLE_PROVIDERS;
  var Res := PythonManager.RunCode(LScript, True);
  if Res then
  begin
    try
      for var V in VarPyIterate(MainModule.providers) do
      begin
        if not Result.IsEmpty then
          Result := Result + sLineBreak;
        Result := Result + V;
      end;
    except
      Res := False;
    end;
  end;
  if not Res then
  begin
    fLastError := SResultsObtainingError + sLineBreak + PythonManager.GetLastError;
  end;
  ProcessStatus := ProcessStatus.StatusBy(Res);
end;

function TOnnxrtWrapper.GetPythonDll: string;
begin
  Result := TPythonManager.PythonDll;
end;

function TOnnxrtWrapper.GetDetectionResults: IDetectionResults;
begin
  Result := fDetectionResults;
end;

function TOnnxrtWrapper.GetProcessStatus: TProcessStatus;
begin
  Result := fProcessStatus;
end;

function TOnnxrtWrapper.GetProcessTime: TIntTime;
begin
  Result := fProcessTime;
end;

function TOnnxrtWrapper.GetLastError: string;
begin
  Result := fLastError;
end;

function TOnnxrtWrapper.Initialize(const aDllName: string = ''): Boolean;
begin
  Result := IsInitialized or (PythonManager.PythonConnect(aDllName) and DoInitialization);
end;

function TOnnxrtWrapper.IsInitialized: Boolean;
begin
  Result := fIsInitialized;
end;

function TOnnxrtWrapper.IsModelInitialized(aModelType: string): Boolean;
begin
  Result := fInitializedModels.IndexOf(aModelType) >= 0;
end;

function TOnnxrtWrapper.IsModelInitialized(aModelType: TModelType): Boolean;
begin
  Result := IsModelInitialized(aModelType.AsString);
end;

function TOnnxrtWrapper.GetDetectionValue(const aKey: string): string;
begin
  if aKey.Trim.IsEmpty or (not fDetectionValues.TryGetValue(aKey, Result)) then
    Result := EmptyStr;
end;

function TOnnxrtWrapper.GetDetectionValues: TDictionary<string, string>;
begin
  Result := fDetectionValues;
end;

function TOnnxrtWrapper.GetFunctionTime: TIntTime;
begin
  Result := fFunctionTime;
end;

function TOnnxrtWrapper.GetMetadata(const aModelFile: string): TMetadata;
begin
  if not Initialize then
    Exit;
  fLastError := EmptyStr;
  ProcessStatus := psProcessing;
  var LScript := ONNXRT_MODELINFO;
  if aModelFile.Trim.IsEmpty then
    LScript := ReplaceCodeValues(LScript, DetectionValues)
  else
    LScript := ReplaceCodeValue(LScript, S_MODELFILE, aModelFile);
  var Res := PythonManager.RunCode(LScript, True);
  if Res then
  begin
    try
      Result.model_description := MainModule.model_meta.description;
      Result.model_domain := MainModule.model_meta.domain;
      Result.graph_description := MainModule.model_meta.graph_description;
      Result.graph_name := MainModule.model_meta.graph_name;
      Result.producer_name := MainModule.model_meta.producer_name;
      Result.model_version := MainModule.model_meta.version;
      { Custom metadata map }
      Result.date := MainModule.model_meta.custom_metadata_map['date'];
      Result.description := MainModule.model_meta.custom_metadata_map['description'];
      Result.author := MainModule.model_meta.custom_metadata_map['author'];
      Result.version := MainModule.model_meta.custom_metadata_map['version'];
      Result.task := MainModule.model_meta.custom_metadata_map['task'];
      Result.license := MainModule.model_meta.custom_metadata_map['license'];
      Result.docs := MainModule.model_meta.custom_metadata_map['docs'];
      Result.stride := MainModule.model_meta.custom_metadata_map['stride'];
      Result.batch := MainModule.model_meta.custom_metadata_map['batch'];
      Result.imgsz := MainModule.model_meta.custom_metadata_map['imgsz'];
      Result.names := MainModule.model_meta.custom_metadata_map['names'];

      for var V in VarPyIterate(MainModule.model_inputs) do
        Result.AddInput(V);
      for var V in VarPyIterate(MainModule.model_outputs) do
        Result.AddOutput(V);
    except
      Res := False;
    end;
  end;
  if not Res then
  begin
    fLastError := SResultsObtainingError + sLineBreak + PythonManager.GetLastError;
  end;
  ProcessStatus := ProcessStatus.StatusBy(Res);
end;

function TOnnxrtWrapper.GetModelClasses(const aMeta: TMetadata): string;
begin
  Result := EmptyStr;
  var LNames := aMeta.names.Trim;
  if LNames.IsEmpty then
    Exit;
  if (aMeta.names.IndexOf('{') = 0)
    and (aMeta.names.LastIndexOf('}') = Pred(aMeta.names.Length)) then
  begin
    LNames := aMeta.names.Substring(1, aMeta.names.Length - 2);
  end;
  var LClasses := LNames.Split([',']);
  try
    for var V in LClasses do
    begin
      if not Result.IsEmpty then
        Result := Result + sLineBreak;
      Result := Result + V.Trim;
    end;
  finally
    LClasses := nil;
  end;
end;

function TOnnxrtWrapper.Predict(aValues: TDictionary<string, string>): Boolean;
var
  LOptions: Word;
  LOutFile: string;
begin
  fLastError := EmptyStr;
  DetectionResults.Clear;
  ProcessStatus := psNone;
  if not Initialize then
    Exit(False);
  if not Assigned(aValues) then
    aValues := DetectionValues;
  var LModelType := ExtractModelType(aValues);
  if not IsModelInitialized(LModelType) and not DoModelInitialization(LModelType) then
    Exit(False);
  if aValues.TryGetValue(S_OUT_IMAGEFILE, LOutFile) and (not LOutFile.Trim.IsEmpty) then
    LOptions := pcEnableIO
  else
    LOptions := pcLoad;
  ProcessStatus := psProcessing;
  Result := PythonManager.RunCode(BuildDetectionCode(LOptions, aValues), True);
  if Result then
  begin
    Result := DetectionResults.FetchFromPyVariants(MainModule.boxes, MainModule.scores,
      MainModule.indices, MainModule.classes, MainModule.colors);
  end;
  if not Result then
    fLastError := SResultsObtainingError + sLineBreak + PythonManager.GetLastError;
  ProcessStatus := ProcessStatus.StatusBy(Result);
end;

function TOnnxrtWrapper.Predict(const aModelFile, aImagefile, aOutImagefile,
  aProviders, aFilterClasses, acfThreshold, aiouThreshold, aModelType: string): Boolean;
begin
  var LDict := CreateDetectionValues(aModelFile, aImagefile, aOutImagefile,
    aProviders, aFilterClasses, acfThreshold, aiouThreshold, aModelType);
  try
    Result := Predict(LDict);
  finally
    LDict.Free;
  end;
end;

function TOnnxrtWrapper.ReplaceCodeValue(const aSourceCode, aKey, aValue: string): string;
begin
  Result := aSourceCode.Replace(WrapString(aKey, ChTagLeft, ChTagRight), aValue,
    [rfReplaceAll, rfIgnoreCase]);
end;

function TOnnxrtWrapper.ReplaceCodeValues(const aSourceCode: string;
  aValues: TDictionary<string, string>): string;
begin
  Result := aSourceCode;
  if aSourceCode.Trim.IsEmpty or not Assigned(aValues) then
    Exit;
  for var Enum in aValues do
    Result := ReplaceCodeValue(Result, Enum.Key, Enum.Value);
end;

procedure TOnnxrtWrapper.SetProcessStatus(aStatus: TProcessStatus);
begin
  if fProcessStatus <> aStatus then
  begin
    fStopWatch.Stop;
    fProcessStatus := aStatus;
    if fProcessStatus.IsComplete then
    begin
      fFunctionTime := PythonManager.ExecTime;
      fProcessTime := fStopWatch.ElapsedMilliseconds;
    end
    else
    begin
      fFunctionTime := 0;
      fProcessTime := 0;
    end;
    fStopWatch := TStopwatch.StartNew;
    for var Event in fStatusEvents do
      Event(Self, fProcessStatus.AsInteger, fProcessStatus.AsString, fProcessStatus.IsComplete);
  end;
end;

procedure TOnnxrtWrapper.SetDetectionValue(const aKey, aValue: string);
begin
  if not aKey.Trim.IsEmpty then
    fDetectionValues.AddOrSetValue(aKey, aValue);
end;

procedure TOnnxrtWrapper.RegisterStatusEvent(
  aStatusEvent: TProc<TObject, Integer, string, Boolean>);
begin
  fStatusEvents.Add(aStatusEvent);
end;

procedure TOnnxrtWrapper.UnRegisterStatusEvent(
  aStatusEvent: TProc<TObject, Integer, string, Boolean>);
begin
  fStatusEvents.Remove(aStatusEvent);
end;

class procedure TOnnxrtWrapper.ReleaseInstance;
begin
  fInstance := nil;
end;

initialization

finalization
  TOnnxrtWrapper.ReleaseInstance;

end.
