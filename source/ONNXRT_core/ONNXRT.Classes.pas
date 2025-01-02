(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original code:  Softacom (https://www.softacom.com)                    *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*              These are classes and interfaces of the detection results. *)
(***************************************************************************)

unit ONNXRT.Classes;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes;

type
  IDetectedObject = interface
  ['{7524CD35-F2E3-4CBC-9E23-F052606FF0DB}']
    {setters/getters}
    procedure SetBox(const aValue: TRectF);
    function GetBox: TRectF;
    procedure SetScore(const aValue: Double);
    function GetScore: Double;
    procedure SetClassIndex(const aValue: Integer);
    function GetClassIndex: Integer;
    procedure SetClassLabel(const aValue: string);
    function GetClassLabel: string;
    procedure SetColor(const aValue: TAlphaColor);
    function GetColor: TAlphaColor;
    procedure SetChangeEvent(const aValue: TNotifyEvent);
    function GetChangeEvent: TNotifyEvent;
    {main}
    /// <summary> Initialization of result values without calling the change event. </summary>
    procedure InitValues(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor);
    /// <summary> Setting the values of the results. A change event will be triggered. </summary>
    procedure SetValues(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor);
    /// <summary> Setting all values to empty. </summary>
    procedure Clear;
    /// <summary> Checking for no values. </summary>
    function IsEmpty: Boolean;
    {prop}
    /// <summary> Detected class boundaries. </summary>
    property Box: TRectF read GetBox write SetBox;
    /// <summary> Detected class score. </summary>
    property Score: Double read GetScore write SetScore;
    /// <summary> Detected class index. </summary>
    property ClassIndex: Integer read GetClassIndex write SetClassIndex;
    /// <summary> Detected class name. </summary>
    property ClassLabel: string read GetClassLabel write SetClassLabel;
    /// <summary> Generated color for detected class. </summary>
    property Color: TAlphaColor read GetColor write SetColor;
    /// <summary> Event when a detected class is changed. </summary>
    property OnChangeEvent: TNotifyEvent read GetChangeEvent write SetChangeEvent;
  end;

  TDetectedObject = class(TInterfacedObject, IDetectedObject)
  private
    fBox: TRectF;
    fScore: Double;
    fClassIndex: Integer;
    fClassLabel: string;
    fColor: TAlphaColor;
    fOnChange: TNotifyEvent;
    procedure DoEmpty;
    procedure DoChange;
  public
    constructor Create(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor);
    { IDetectedObject }
    procedure SetBox(const aValue: TRectF);
    function GetBox: TRectF;
    procedure SetScore(const aValue: Double);
    function GetScore: Double;
    procedure SetClassIndex(const aValue: Integer);
    function GetClassIndex: Integer;
    procedure SetClassLabel(const aValue: string);
    function GetClassLabel: string;
    procedure SetColor(const aValue: TAlphaColor);
    function GetColor: TAlphaColor;
    procedure SetChangeEvent(const aValue: TNotifyEvent);
    function GetChangeEvent: TNotifyEvent;
    {main}
    procedure InitValues(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor);
    procedure SetValues(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor);
    procedure Clear;
    function IsEmpty: Boolean;
    {prop}
    property Box: TRectF read GetBox write SetBox;
    property Score: Double read GetScore write SetScore;
    property ClassIndex: Integer read GetClassIndex write SetClassIndex;
    property ClassLabel: string read GetClassLabel write SetClassLabel;
    property Color: TAlphaColor read GetColor write SetColor;
    property OnChangeEvent: TNotifyEvent read GetChangeEvent write SetChangeEvent;
  end;

  TDetectionResultsEnumerator = class;

  IDetectionResults = interface(IInterfaceList)
  ['{D8AAE2D9-9B48-4812-8D4D-4465D6B19D31}']
    procedure SetOnAddDetected(const aValue: TProc<TObject, IDetectedObject>);
    function GetOnAddDetected: TProc<TObject, IDetectedObject>;
    procedure SetOnDetectedChange(const aValue: TNotifyEvent);
    function GetOnDetectedChange: TNotifyEvent;
    function GetDetectedObject(aIndex: Integer): IDetectedObject;
    function GetEnumerator: TDetectionResultsEnumerator;
    /// <summary> Adding detected class values. </summary>
    function AddDetectedObject(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor): Integer;
    /// <summary> Checking for no values. </summary>
    function IsEmpty: Boolean;
    /// <summary> Retrieving result values from python variants. </summary>
    function FetchFromPyVariants(aBoxes, aScores, aIndices, aClasses,
      aColors: Variant): Boolean;
    /// <summary> Obtaining an object of a detected class. </summary>
    property DetectedObject[aIndex: Integer]: IDetectedObject read GetDetectedObject;
    /// <summary> Event when a detected class is added. </summary>
    property OnAddDetected: TProc<TObject, IDetectedObject> read GetOnAddDetected
      write SetOnAddDetected;
    /// <summary> Event when a detected class is changed. </summary>
    property OnDetectedChange: TNotifyEvent read GetOnDetectedChange
      write SetOnDetectedChange;
  end;

  TDetectionResults = class;

  TDetectionResultsEnumerator = class
  private
    fIndex: Integer;
    fInterfaceList: TDetectionResults;
  public
    constructor Create(aInterfaceList: TDetectionResults);
    function GetCurrent: IDetectedObject; inline;
    function MoveNext: Boolean; inline;
    property Current: IDetectedObject read GetCurrent;
  end;

  TDetectionResults = class(TInterfaceList, IDetectionResults)
  private
    fOnDetectedChange: TNotifyEvent;
    fOnAddDetected: TProc<TObject, IDetectedObject>;
    function DoAddDetectedObject(const aDetectedObject: IDetectedObject): Integer;
  public
    procedure SetOnAddDetected(const aValue: TProc<TObject, IDetectedObject>);
    function GetOnAddDetected: TProc<TObject, IDetectedObject>;
    procedure SetOnDetectedChange(const aValue: TNotifyEvent);
    function GetOnDetectedChange: TNotifyEvent;
    function GetDetectedObject(aIndex: Integer): IDetectedObject;
    function GetEnumerator: TDetectionResultsEnumerator;
    function AddDetectedObject(aBox: TRectF; aScore: Double; aClassIndex: Integer;
      const aClassLabel: string; aColor: TAlphaColor): Integer;
    function IsEmpty: Boolean;
    function FetchFromPyVariants(aBoxes, aScores, aIndices, aClasses,
      aColors: Variant): Boolean;
    property DetectedObject[aIndex: Integer]: IDetectedObject read GetDetectedObject;
    property OnAddDetected: TProc<TObject, IDetectedObject> read GetOnAddDetected
      write SetOnAddDetected;
    property OnDetectedChange: TNotifyEvent read GetOnDetectedChange
      write SetOnDetectedChange;
  end;

implementation

uses
  System.Math, System.Variants, System.Generics.Collections,
  VarPyth, PythonEngine, ONNXRT.Utils;

{ TDetectedObject }

constructor TDetectedObject.Create(aBox: TRectF; aScore: Double; aClassIndex: Integer;
  const aClassLabel: string; aColor: TAlphaColor);
begin
  inherited Create;
  InitValues(aBox, aScore, aClassIndex, aClassLabel, aColor);
end;

procedure TDetectedObject.Clear;
begin
  DoEmpty;
end;

procedure TDetectedObject.DoChange;
begin
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

procedure TDetectedObject.DoEmpty;
begin
  InitValues(TRect.Empty, 0.0, -1, EmptyStr, 0);
end;

function TDetectedObject.GetBox: TRectF;
begin
  Result := fBox;
end;

function TDetectedObject.GetChangeEvent: TNotifyEvent;
begin
  Result := fOnChange;
end;

function TDetectedObject.GetClassIndex: Integer;
begin
  Result := fClassIndex;
end;

function TDetectedObject.GetColor: TAlphaColor;
begin
  Result := fColor;
end;

function TDetectedObject.GetClassLabel: string;
begin
  Result := fClassLabel;
end;

function TDetectedObject.GetScore: Double;
begin
  Result := fScore;
end;

procedure TDetectedObject.InitValues(aBox: TRectF; aScore: Double;
  aClassIndex: Integer; const aClassLabel: string; aColor: TAlphaColor);
begin
  fBox := aBox;
  fScore  := aScore;
  fClassIndex := aClassIndex;
  fClassLabel := aClassLabel;
  fColor := aColor;
end;

function TDetectedObject.IsEmpty: Boolean;
begin
  Result := fBox.IsEmpty and (fClassIndex < 0) and IsZero(fScore)
    and fClassLabel.IsEmpty and (fColor = 0);
end;

procedure TDetectedObject.SetBox(const aValue: TRectF);
begin
  if aValue <> fBox then
  begin
    fBox := aValue;
    DoChange;
  end;
end;

procedure TDetectedObject.SetChangeEvent(const aValue: TNotifyEvent);
begin
  fOnChange := aValue;
end;

procedure TDetectedObject.SetClassIndex(const aValue: Integer);
begin
  if aValue <> fClassIndex then
  begin
    fClassIndex := aValue;
    DoChange;
  end;
end;

procedure TDetectedObject.SetColor(const aValue: TAlphaColor);
begin
  if aValue <> fColor then
  begin
    fColor := aValue;
    DoChange;
  end;
end;

procedure TDetectedObject.SetClassLabel(const aValue: string);
begin
  if not aValue.Equals(fClassLabel) then
  begin
    fClassLabel := aValue;
    DoChange;
  end;
end;

procedure TDetectedObject.SetScore(const aValue: Double);
begin
  if CompareValue(aValue, fScore) <> 0 then
  begin
    fScore := aValue;
    DoChange;
  end;
end;

procedure TDetectedObject.SetValues(aBox: TRectF; aScore: Double;
  aClassIndex: Integer; const aClassLabel: string; aColor: TAlphaColor);
begin
  var LIsChanged := (fScore <> aScore)  or (fClassIndex <> aClassIndex)
    or (fClassLabel <> aClassLabel) or (fColor <> aColor);
  InitValues(aBox, aScore, aClassIndex, aClassLabel, aColor);
  if LIsChanged then
    DoChange;
end;

{ TDetectionResult }

function TDetectionResults.AddDetectedObject(aBox: TRectF; aScore: Double;
  aClassIndex: Integer; const aClassLabel: string; aColor: TAlphaColor): Integer;
begin
  Result := DoAddDetectedObject(TDetectedObject.Create(aBox, aScore, aClassIndex,
    aClassLabel, aColor));
end;

function TDetectionResults.GetDetectedObject(aIndex: Integer): IDetectedObject;
begin
  if not Supports(Items[aIndex], IDetectedObject, Result) then
    Result := nil;
end;

function TDetectionResults.GetEnumerator: TDetectionResultsEnumerator;
begin
  Result := TDetectionResultsEnumerator.Create(Self);
end;

function TDetectionResults.GetOnAddDetected: TProc<TObject, IDetectedObject>;
begin
  Result := fOnAddDetected;
end;

function TDetectionResults.GetOnDetectedChange: TNotifyEvent;
begin
  Result := fOnDetectedChange;
end;

function TDetectionResults.IsEmpty: Boolean;
begin
  Result := (Count = 0);
end;

procedure TDetectionResults.SetOnAddDetected(
  const aValue: TProc<TObject, IDetectedObject>);
begin
  fOnAddDetected := aValue;
end;

procedure TDetectionResults.SetOnDetectedChange(const aValue: TNotifyEvent);
begin
  fOnDetectedChange := aValue;
  for var V in Self do
    V.OnChangeEvent := fOnDetectedChange;
end;

function TDetectionResults.DoAddDetectedObject(
  const aDetectedObject: IDetectedObject): Integer;
begin
  if aDetectedObject = nil then
    Exit(-1);
  aDetectedObject.OnChangeEvent := fOnDetectedChange;
  Result := Add(aDetectedObject);
  if Assigned(fOnAddDetected) then
    fOnAddDetected(Self, aDetectedObject);
end;

function TDetectionResults.FetchFromPyVariants(aBoxes, aScores, aIndices,
  aClasses, aColors: Variant): Boolean;
var
  LBoxes: TList<TRectF>;
  LScores: TList<Double>;
  LIndices: TList<Integer>;
  LClasses: TList<string>;
  LColors: TList<TAlphaColor>;
begin
  LBoxes := TList<TRectF>.Create;
  LScores := TList<Double>.Create;
  LIndices := TList<Integer>.Create;
  LClasses := TList<string>.Create;
  LColors := TList<TAlphaColor>.Create;
  try
    try
      for var V in VarPyIterate(aBoxes) do
      begin
        var x: TArray<Double> := [];
        for var VV in VarPyIterate(V) do
        begin
          TOnnxRTU.AppendArray<Double>(x, StrToFloatDef(VV, 0.0));
        end;
        LBoxes.Add(TRectF.Create(PointF(x[0], x[1]), x[2], x[3]));
      end;

      for var V in VarPyIterate(aScores) do
        LScores.Add(StrToFloatDef(V, 0.0));

      for var V in VarPyIterate(aIndices) do
        LIndices.Add(StrToIntDef(V, 0));

      for var V in VarPyIterate(aClasses) do
        LClasses.Add(V);

      for var V in VarPyIterate(aColors) do
      begin
        var LColor: TArray<Double> := [];
        for var VV in VarPyIterate(V) do
        begin
          TOnnxRTU.AppendArray<Double>(LColor, StrToFloatDef(VV, 0.0));
        end;
        LColors.Add(TAlphaColorF.Create(LColor[0], LColor[1], LColor[2]).ToAlphaColor);
      end;

      var Len := MinIntValue([LBoxes.Count, LScores.Count, LIndices.Count,
        LClasses.Count, LColors.Count]);
      for var i := 0 to Pred(Len) do
      begin
        AddDetectedObject(LBoxes[i], LScores[i], LIndices[i],
          LClasses[i], LColors[i]);
      end;

      Result := True;
    except
      Result := False;
    end;
  finally
    LBoxes.Free;
    LScores.Free;
    LIndices.Free;
    LClasses.Free;
    LColors.Free;
  end;
end;

{ TDetectionResultsEnumerator }

constructor TDetectionResultsEnumerator.Create(aInterfaceList: TDetectionResults);
begin
  inherited Create;
  fIndex := -1;
  fInterfaceList := aInterfaceList;
end;

function TDetectionResultsEnumerator.GetCurrent: IDetectedObject;
begin
  if not Supports(FInterfaceList[FIndex], IDetectedObject, Result) then
    Result := nil;
end;

function TDetectionResultsEnumerator.MoveNext: Boolean;
begin
  Inc(fIndex);
  Result := fIndex < FInterfaceList.Count;
end;

end.
