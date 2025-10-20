(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original code:  Softacom (https://www.softacom.com)                    *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 These are the types for the ONNX Runtime detection.     *)
(***************************************************************************)

unit ONNXRT.Types;

interface
uses
  System.Types;

type
  TModelType = (mtYolo); //Default model is first
  TProcessStatus = (psNone, psInitialization, psInitialized, psProcessing, psFinished, psError);
  TIntTime = type Int64;

  TProcessStatusHelper = record helper for TProcessStatus
  public
    function AsInteger: Integer;
    function AsString: string;
    function IsComplete: Boolean;
    function StatusBy(aValue: Boolean): TProcessStatus;
    class function StatusOf(aValue: string): TProcessStatus; static;
  end;

  TModelTypeHelper = record helper for TModelType
  public
    function AsInteger: Integer;
    function AsString: string;
    class function TypeOf(aValue: Integer): TModelType; overload; static;
    class function TypeOf(aValue: string): TModelType; overload; static;
  end;

  TIntTimeHelper = record helper for TIntTime
  public
    function AsString(const aFormat: string = ''): string;
  end;

  {Record for access to metadata of ONNX}
  TMetadata = record
    model_description: string;
    model_domain: string;
    graph_description: string;
    graph_name: string;
    producer_name: string;
    model_version: string;
    { Custom metadata map }
    date: string;
    description: string;
    author: string;
    version: string;
    task: string;
    license: string;
    docs: string;
    stride: string;
    batch: string;
    imgsz: string;
    names: string;

    inputs: TArray<string>;
    outputs: TArray<string>;
  public
    procedure AddInput(const aInput: string);
    procedure AddOutput(const aOutput: string);
    procedure Clear;
  end;

implementation

uses
  System.SysUtils, System.TypInfo, ONNXRT.Utils;

{ TDetectionStatusHeler }

function TProcessStatusHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TProcessStatusHelper.AsString: string;
begin
  if not GetEnumTypeName(TypeInfo(TProcessStatus), Ord(Self), Result, 'ps') then
    Result := EmptyStr;
end;

function TProcessStatusHelper.IsComplete: Boolean;
begin
  Result := (Self = psInitialized) or (Self = psFinished) or (Self = psError);
end;

class function TProcessStatusHelper.StatusOf(aValue: string): TProcessStatus;
var
  LValue: Integer;
begin
  if GetEnumTypeValue(TypeInfo(TProcessStatus), aValue.Trim, LValue, 'ps') then
    Result := TProcessStatus(LValue)
  else
    Result := psNone;
end;

function TProcessStatusHelper.StatusBy(aValue: Boolean): TProcessStatus;
begin
  if aValue then
  begin
    case Self of
      psInitialization: Result := psInitialized;
    else
      Result := psFinished;
    end;
  end
  else
    Result := psError;
end;

{ TModelTypeHelper }

function TModelTypeHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TModelTypeHelper.AsString: string;
begin
  if not GetEnumTypeName(TypeInfo(TModelType), Ord(Self), Result, 'mt') then
    Result := EmptyStr;
end;

class function TModelTypeHelper.TypeOf(aValue: Integer): TModelType;
begin
  if (aValue < Low(TModelType).AsInteger) then
    Result := Low(TModelType)
  else
  if (aValue > High(TModelType).AsInteger) then
    Result := High(TModelType)
  else
    Result := TModelType(aValue);
end;

class function TModelTypeHelper.TypeOf(aValue: string): TModelType;
var
  LValue: Integer;
begin
  if GetEnumTypeValue(TypeInfo(TModelType), aValue.Trim, LValue, 'mt') then
    Result := TModelType.TypeOf(LValue)
  else
    Result := Low(TModelType);
end;

{ TMetadata }

procedure TMetadata.AddInput(const aInput: string);
begin
  TOnnxRTU.AppendArray<string>(inputs, aInput);
end;

procedure TMetadata.AddOutput(const aOutput: string);
begin
  TOnnxRTU.AppendArray<string>(outputs, aOutput);
end;

procedure TMetadata.Clear;
begin
    model_description := EmptyStr;
    model_domain := EmptyStr;
    graph_description := EmptyStr;
    graph_name := EmptyStr;
    producer_name := EmptyStr;
    model_version := EmptyStr;
    { Custom metadata map }
    date := EmptyStr;
    description := EmptyStr;
    author := EmptyStr;
    version := EmptyStr;
    task := EmptyStr;
    license := EmptyStr;
    docs := EmptyStr;
    stride := EmptyStr;
    batch := EmptyStr;
    imgsz := EmptyStr;
    names := EmptyStr;

    inputs := nil;
    outputs := nil;
end;

{ TIntTimeHelper }

function TIntTimeHelper.AsString(const aFormat: string): string;
const
  defTimeFormat = 'h"h" n"m" s"s" z"ms"';
begin
  var MS := Self mod 1000;
  var S := Self div 1000 mod 60;
  var M := Self div 60000 mod 60;
  var H := Self div 3600000 mod 60;
  if aFormat.Trim.IsEmpty then
    Result := FormatDateTime(defTimeFormat, EncodeTime(H, M, S, MS))
  else
    Result := FormatDateTime(aFormat, EncodeTime(H, M, S, MS));
end;

end.
