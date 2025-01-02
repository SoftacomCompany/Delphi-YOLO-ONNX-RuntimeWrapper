(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original code:  Softacom (https://www.softacom.com)                    *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 These are the common functions                          *)
(*                 used by the ONNX Runtime wrapper library classes.       *)
(***************************************************************************)

unit ONNXRT.Utils;

interface

uses
  System.SysUtils, System.TypInfo;

type

  TOnnxRTU = class
  public
    class procedure EnumerateStrings(const aSource: array of string; aProc: TProc<string>);
    class function GetCodeText(const aSource: array of string; aBlocks: Boolean = True): string;
    class function WrapString(const aSource: string; const aLeft: string; const aRight: string = ''): string;
    class function WrapPath(const aPath: string): string;
    class function GetEnumTypeName(aTypeInfo: PTypeInfo; aValue: Integer; out aName: string;
      const aPrefix: string = ''): Boolean;
    class function GetEnumTypeValue(aTypeInfo: PTypeInfo; const aName: string; out aValue: Integer;
      const aPrefix: string = ''): Boolean;
    class function AppendArray<T>(var aArr: TArray<T>; aValue: T): Integer;
  end;

  procedure EnumerateStrings(const aSource: array of string; aProc: TProc<string>);
  function GetCodeText(const aSource: array of string; aBlocks: Boolean = True): string;
  function WrapString(const aSource: string; const aLeft: string; const aRight: string = ''): string;
  function WrapPath(const aPath: string): string;
  function GetEnumTypeName(aTypeInfo: PTypeInfo; aValue: Integer; out aName: string;
    const aPrefix: string = ''): Boolean;
  function GetEnumTypeValue(aTypeInfo: PTypeInfo; const aName: string; out aValue: Integer;
    const aPrefix: string = ''): Boolean;

implementation

uses
  ONNXRT.Constants;

procedure EnumerateStrings(const aSource: array of string; aProc: TProc<string>);
begin
  TOnnxRTU.EnumerateStrings(aSource, aProc);
end;

function GetCodeText(const aSource: array of string; aBlocks: Boolean = True): string;
begin
  Result := TOnnxRTU.GetCodeText(aSource, aBlocks);
end;

function WrapString(const aSource: string; const aLeft: string; const aRight: string = ''): string;
begin
  Result := TOnnxRTU.WrapString(aSource, aLeft, aRight);
end;

function WrapPath(const aPath: string): string;
begin
  Result := TOnnxRTU.WrapPath(aPath);
end;

function GetEnumTypeName(aTypeInfo: PTypeInfo; aValue: Integer; out aName: string;
  const aPrefix: string): Boolean;
begin
  Result := TOnnxRTU.GetEnumTypeName(aTypeInfo, aValue, aName, aPrefix);
end;

function GetEnumTypeValue(aTypeInfo: PTypeInfo; const aName: string; out aValue: Integer;
  const aPrefix: string): Boolean;
begin
  Result := TOnnxRTU.GetEnumTypeValue(aTypeInfo, aName, aValue, aPrefix);
end;

{ TOnnxRTU }

class function TOnnxRTU.AppendArray<T>(var aArr: TArray<T>; aValue: T): Integer;
begin
  Result := Length(aArr);
  SetLength(aArr, Result + 1);
  aArr[Result] := aValue;
end;

class procedure TOnnxRTU.EnumerateStrings(const aSource: array of string;
  aProc: TProc<string>);
begin
  if not Assigned(aProc) or (Length(aSource) = 0)  then
    Exit;
  for var str in aSource do
    aProc(str);
end;

class function TOnnxRTU.GetEnumTypeName(aTypeInfo: PTypeInfo; aValue: Integer;
  out aName: string; const aPrefix: string): Boolean;
begin
  aName := GetEnumName(aTypeInfo, aValue);
  Result := aName.Length > aPrefix.Length;
  if Result then
    aName := aName.ToLower.Substring(aPrefix.Length);
end;

class function TOnnxRTU.GetEnumTypeValue(aTypeInfo: PTypeInfo; const aName: string;
  out aValue: Integer; const aPrefix: string): Boolean;
begin
  aValue := GetEnumValue(aTypeInfo, aPrefix + aName);
  Result := aValue >= 0;
end;

class function TOnnxRTU.GetCodeText(const aSource: array of string; aBlocks: Boolean): string;
var
  LBlockSeparator: string;
begin
  Result := EmptyStr;
  if Length(aSource) > 0 then
  begin
    if aBlocks then
      LBlockSeparator := sLineBreak
    else
      LBlockSeparator := EmptyStr;

    for var i := Low(aSource) to High(aSource) do
      Result := Result + aSource[i] + sLineBreak + LBlockSeparator;
  end;
end;

class function TOnnxRTU.WrapString(const aSource, aLeft,
  aRight: string): string;
var
  LR: string;
begin
  if aRight.Trim.IsEmpty then
    LR := aLeft
  else
    LR := aRight;
  Result := aLeft + aSource + LR;
end;

class function TOnnxRTU.WrapPath(const aPath: string): string;
begin
  if aPath.IndexOf(ChQuote) <> 0 then
    Result := ChQuote + aPath;
  if aPath.LastIndexOf(ChQuote) < Pred(Length(aPath)) then
    Result := aPath + ChQuote;
end;

end.
