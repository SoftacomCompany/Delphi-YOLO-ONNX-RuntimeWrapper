unit frmVideoDetectMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Media,
  System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList, FMX.Ani,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, FMX.ListBox,
  FMX.Memo.Types, FMX.Memo, ONNXRT.Classes, ONNXRT.Types;

const
  C_stPrefix = 'st';
  C_DefCamera = 'Default camera';

  C_SourceType = 0;
  C_Source = 1;
  C_Model = 2;
  C_Providers = 3;
  C_ClassFilter = 4;

type
  TSourceType = (stImage, stCamera);

  TSourceTypeHelper = record helper for TSourceType
  public
    function AsInteger: Integer;
    function AsString: string;
    class function TypeOf(aValue: Integer): TSourceType; overload; static;
    class function TypeOf(aValue: string): TSourceType; overload; static;
  end;

  TAppSettings = record
    SourceType: TSourceType;
    Camera: string;
    ImageFile: string;
    ModelFile: string;
    Providers: string;
    ClassFilter: string;
  public
    procedure SetByIndex(AIndex: Integer; const AValue: string);
    function GetByIndex(AIndex: Integer): string;
    procedure Save(const FileName: string);
    procedure Load(const FileName: string);
  end;

  TFormVideoDetectMain = class(TForm)
    lyDisplay: TLayout;
    Camera: TCameraComponent;
    imgDisplay: TImage;
    rectHeader: TRectangle;
    btnMenu: TSpeedButton;
    imMenu: TImage;
    lyControl: TLayout;
    ppmSys: TPopupMenu;
    miSettings: TMenuItem;
    miExit: TMenuItem;
    alSys: TActionList;
    acSettings: TAction;
    acClose: TAction;
    acMinimize: TAction;
    miSeparator1: TMenuItem;
    tmrHideControl: TTimer;
    acMaximize: TAction;
    miMinimize: TMenuItem;
    miMaximize: TMenuItem;
    miSeparator2: TMenuItem;
    faShowHideControl: TFloatAnimation;
    rrectControl: TRoundRect;
    lblCamera: TLabel;
    swRunCamera: TSwitch;
    lblRecognition: TLabel;
    swRecognition: TSwitch;
    rectSettings: TRectangle;
    lblSettings: TLabel;
    acRestore: TAction;
    miRestore: TMenuItem;
    grdSettings: TStringGrid;
    clSettings: TStringColumn;
    clSettingValues: TStringColumn;
    dlgLoadModel: TOpenDialog;
    ppFilter: TPopup;
    lbFilter: TListBox;
    lyFilterButtons: TLayout;
    btnFilterOk: TButton;
    btnFilterCancel: TButton;
    cbSelect: TComboBox;
    dlgLoadImage: TOpenDialog;
    gbProviders: TGroupBox;
    gbClassFilter: TGroupBox;
    splProviders: TSplitter;
    splClasses: TSplitter;
    splSettings: TSplitter;
    memProviders: TMemo;
    memClassFilter: TMemo;
    lyRecognitionFixed: TLayout;
    tmrStartRecognition: TTimer;
    lblHead: TLabel;
    lyCameraFixed: TLayout;
    lblCameraFixed: TLabel;
    swRunCameraFixed: TSwitch;
    lblRecognitionFixed: TLabel;
    swRecognitionFixed: TSwitch;
    sbStatus: TStatusBar;
    lblStatus: TLabel;
    lblStatusName: TLabel;
    lblProcessTime: TLabel;
    lblTimeValue: TLabel;
    procedure CameraSampleBufferReady(Sender: TObject; const ATime: TMediaTime);
    procedure rectHeaderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure acCloseExecute(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure imgDisplayMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure tmrHideControlTimer(Sender: TObject);
    procedure lyControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure acMaximizeExecute(Sender: TObject);
    procedure acMinimizeExecute(Sender: TObject);
    procedure faShowHideControlFinish(Sender: TObject);
    procedure imgDisplayClick(Sender: TObject);
    procedure swRunCameraSwitch(Sender: TObject);
    procedure acSettingsExecute(Sender: TObject);
    procedure acRestoreExecute(Sender: TObject);
    procedure ppmSysPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure grdSettingsDrawColumnBackground(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
      const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure grdSettingsDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure grdSettingsCellClick(const Column: TColumn; const Row: Integer);
    procedure cbSelectPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure cbSelectClosePopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure grdSettingsResized(Sender: TObject);
    procedure memProvidersPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure memProvidersClick(Sender: TObject);
    procedure swRecognitionSwitch(Sender: TObject);
    procedure tmrStartRecognitionTimer(Sender: TObject);
  private
    { Private declarations }
    FIsCameraActive: Boolean;
    FIsRecognition: Boolean;
    FIsProcessing: Boolean;
    FSettings: TAppSettings;
    FOriginalImage: FMX.Graphics.TBitmap;
    FOriginalImageFile: string;
    FMetaData: TMetaData;
    FAbort: Boolean;
    function GetIsRecognition: Boolean;
    procedure SetIsRecognition(AValue: Boolean);
    procedure SetIsProcessing(AValue: Boolean);
    procedure SetIsCameraActive(AValue: Boolean);
    procedure InitCombobox(ACombo: TComboBox; AType: Integer);
    procedure RestartHideTimer;
    procedure ShowComboAtCell(ACombo: TComboBox; const ACellRect: TRectF;
      ARow: Integer; const AValue: string);
    procedure EnableControls;
    procedure ApplySetting(AIndex: Integer);
  protected
    function IsImageMode: Boolean;
    function IsCameraMode: Boolean;
    function IsImageAvailable: Boolean;
    function IsCameraAvailable: Boolean;
    function IsRecognitionAvailable: Boolean;
    procedure UpdateSettings;

    function ContrastingColor(AColor: TAlphaColor): TAlphaColor;
    procedure DrawDetections(const ABitmap: FMX.Graphics.TBitmap;
      const ADetected: IDetectionResults);
    function Predict(const ABitmap: FMX.Graphics.TBitmap): FMX.Graphics.TBitmap;
    procedure Recognize(const ABitmap: FMX.Graphics.TBitmap = nil);
    procedure OnStatusChange(Sender: TObject; aIntStatus: Integer;
      aStrStatus: string; aComplete: Boolean);
  public
    { Public declarations }
    procedure BitmapToCHWFloat(const ABitmap: FMX.Graphics.TBitmap);
    property IsCameraActive: Boolean read FIsCameraActive write SetIsCameraActive;
    property IsRecognition: Boolean read GetIsRecognition write SetIsRecognition;
    property IsProcessing: Boolean read FIsProcessing write SetIsProcessing;
  end;

var
  FormVideoDetectMain: TFormVideoDetectMain;

implementation

uses
  System.TypInfo, System.IniFiles, System.IOUtils, System.Threading,
  Winapi.Windows, FMX.Platform.Win,
  ONNXRT.Core, ONNXRT.Constants;

{$R *.fmx}

const
  C_Settings: TArray<string> = ['Source type', 'Source', 'Model'];
  C_NameColumn = 0;
  C_ValueColumn = 1;

procedure TFormVideoDetectMain.acCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormVideoDetectMain.CameraSampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
var
  src: FMX.Graphics.TBitmap;
begin
  if not IsCameraMode or not IsCameraActive then
    Exit;
  TThread.Synchronize(nil,
    procedure
    begin
      src := FMX.Graphics.TBitmap.Create;
      Camera.SampleBufferToBitmap(src, True);
      if (src.Width > 0) and (src.Height > 0) then
      begin
        if IsRecognition then
        begin
          TThread.Queue(nil,
            procedure
            begin
              Recognize(src);
              FreeAndNil(src);
            end);
        end
        else
        begin
          TThread.Queue(nil,
            procedure
            begin
              imgDisplay.Bitmap.Assign(src);
              FreeAndNil(src);
            end);
        end;
      end
      else
        FreeAndNil(src);
    end);
end;

procedure TFormVideoDetectMain.cbSelectClosePopup(Sender: TObject);
var
 LCombo: TComboBox;
begin
  if Sender is TComboBox then
  begin
    LCombo := TComboBox(Sender);
    FSettings.SetByIndex(LCombo.Tag, LCombo.Text);
    UpdateSettings;
    LCombo.Visible := False;
  end;
end;

procedure TFormVideoDetectMain.cbSelectPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  TextRect: TRectF;
begin
  if Sender is TComboBox then
  begin
    TextRect := ARect;
    TextRect.Inflate(-6, -2);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.Black;
    Canvas.FillRect(ARect, 0, 0, [], 1);
    Canvas.Fill.Color := TAlphaColors.White;
    Canvas.FillText(TextRect, TComboBox(Sender).Text, False, 1, [],
      TTextAlign.Leading, TTextAlign.Center);
  end;
end;

function TFormVideoDetectMain.ContrastingColor(AColor: TAlphaColor): TAlphaColor;
var
  Luminance: Single;
begin
  Luminance := (0.299 * TAlphaColorRec(AColor).R +
                0.587 * TAlphaColorRec(AColor).G +
                0.114 * TAlphaColorRec(AColor).B) / 255;

  if Luminance > 0.5 then
    Result := TAlphaColors.Black
  else
    Result := TAlphaColors.White;
end;

procedure TFormVideoDetectMain.faShowHideControlFinish(Sender: TObject);
begin
  lyControl.Visible := faShowHideControl.Inverse;
end;

procedure TFormVideoDetectMain.FormCreate(Sender: TObject);
begin
  FMetaData.Clear;
  grdSettings.RowCount := 0;
  for var i := Low(C_Settings) to High(C_Settings) do
  begin
    grdSettings.RowCount := grdSettings.RowCount + 1;
    grdSettings.Cells[C_NameColumn, i] := C_Settings[i];
    grdSettings.Cells[C_ValueColumn, i] := FSettings.GetByIndex(i);
  end;
  FSettings.Load(ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini'));
  UpdateSettings;
  OnnxrtWrapper.RegisterStatusEvent(OnStatusChange);
end;

procedure TFormVideoDetectMain.FormDestroy(Sender: TObject);
begin
  Camera.Active := False;
  FAbort := True;
  FSettings.Save(ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini'));
  FreeAndNil(FOriginalImage);
end;

function TFormVideoDetectMain.GetIsRecognition: Boolean;
begin
  FIsRecognition := FIsRecognition and IsRecognitionAvailable and not FAbort;
  Result := FIsRecognition;
end;

procedure TFormVideoDetectMain.imgDisplayClick(Sender: TObject);
begin
  IsCameraActive := not IsCameraActive;
end;

procedure TFormVideoDetectMain.imgDisplayMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  tmrHideControl.Enabled := False;
  if not lyControl.Visible then
  begin
    lyControl.Visible := True;
    faShowHideControl.StartValue := imgDisplay.Height - lyControl.Height;
    faShowHideControl.StopValue := imgDisplay.Height;
    faShowHideControl.Inverse := True;
    faShowHideControl.Start;
  end;
  tmrHideControl.Enabled := True;
end;

procedure TFormVideoDetectMain.InitCombobox(ACombo: TComboBox; AType: Integer);
begin
  ACombo.Items.Clear;
  case AType of
    C_SourceType:
      begin
        for var i := Low(TSourceType) to High(TSourceType) do
          ACombo.Items.Add(i.AsString);
      end;
    C_Source:
      begin
        ACombo.Items.Add(C_DefCamera);
      end;
  end;
end;

function TFormVideoDetectMain.IsCameraAvailable: Boolean;
begin
  Result := IsCameraMode;
end;

function TFormVideoDetectMain.IsCameraMode: Boolean;
begin
  Result := (FSettings.SourceType = stCamera);
end;

function TFormVideoDetectMain.IsImageAvailable: Boolean;
begin
  Result := IsImageMode and FileExists(FSettings.ImageFile);
end;

function TFormVideoDetectMain.IsImageMode: Boolean;
begin
  Result := (FSettings.SourceType = stImage);
end;

function TFormVideoDetectMain.IsRecognitionAvailable: Boolean;
begin
  Result := (not FSettings.ModelFile.Trim.IsEmpty) and FileExists(FSettings.ModelFile)
    and (IsCameraAvailable or IsImageAvailable);
end;

procedure TFormVideoDetectMain.lyControlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  RestartHideTimer;
end;

procedure TFormVideoDetectMain.memProvidersClick(Sender: TObject);
var
  sText, sItem: string;
  LSelected: TArray<string>;
  LMemo: TMemo;
  LProviders: Boolean;
begin
  if Sender is TMemo then
  begin
    LProviders := False;
    LMemo := TMemo(Sender);
    case LMemo.Tag of
      C_Providers:
        begin
          lbFilter.Items.Text := OnnxrtWrapper.GetProviders;
          lbFilter.Columns := 1;
          LProviders := True;
        end;
      C_ClassFilter:
        begin
          lbFilter.Items.Text := OnnxrtWrapper.GetModelClasses(FMetaData);
          if lbFilter.Items.Text.Trim.IsEmpty then
            Exit;
          lbFilter.Columns := 3;
        end;
    end;

    ppFilter.PlacementTarget := TControl(LMemo.Parent);
    if LProviders then
      LSelected := LMemo.Text.Replace('"', '', [rfReplaceAll]).Split([', '])
    else
      LSelected := LMemo.Text.Split([', ']);
    for var i := Low(LSelected) to High(LSelected) do
    begin
      sText := LSelected[i].Trim;
      for var j := 0 to Pred(lbFilter.Count) do
      begin
        if LProviders then
          sItem := lbFilter.ListItems[j].Text.Trim
        else
          sItem := lbFilter.ListItems[j].Text.Split([':'])[1].Trim;
        if SameText(sText, sItem) then
        begin
          lbFilter.ListItems[j].IsChecked := True;
          Break;
        end;
      end;
    end;
    if ppFilter.PopupModal = mrOk then
    begin
      sText := EmptyStr;
      for var i := 0 to Pred(lbFilter.Count) do
      begin
        if lbFilter.ListItems[i].IsChecked then
        begin
          if not sText.IsEmpty then
            sText := sText + ', ';
          case LMemo.Tag of
            C_Providers: sText := sText + Format('"%s"', [lbFilter.ListItems[i].Text]);
            C_ClassFilter: sText := sText + lbFilter.ListItems[i].Text.Split([':'])[1];
          end;
        end;
      end;
      LMemo.Text := sText;
      FSettings.SetByIndex(LMemo.Tag, sText);
      UpdateSettings;
    end;
  end;
end;

procedure TFormVideoDetectMain.memProvidersPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  TextRect: TRectF;
begin
  if not (Sender is TMemo) then
    Exit;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := Fill.Color;
  Canvas.FillRect(ARect, 0, 0, [], 1);
  TextRect := ARect;
  TextRect.Inflate(-6, 0);

  Canvas.Fill.Color := TMemo(Sender).TextSettings.FontColor;
  Canvas.FillText(TextRect, TMemo(Sender).Text, True, 0.5, [],
    TTextAlign.Leading, TTextAlign.Leading);
end;

procedure TFormVideoDetectMain.OnStatusChange(Sender: TObject; aIntStatus: Integer;
  aStrStatus: string; aComplete: Boolean);
begin
  TThread.Queue(nil,
    procedure
    begin
      lblStatusName.Text := aStrStatus;
      lblTimeValue.Text := OnnxrtWrapper.ProcessTime.AsString;
    end);
    Application.ProcessMessages;
end;

procedure TFormVideoDetectMain.ppmSysPopup(Sender: TObject);
begin
  acMaximize.Visible := WindowState <> TWindowState.wsMaximized;
  acRestore.Visible := not acMaximize.Visible;
end;

function TFormVideoDetectMain.Predict(const ABitmap: FMX.Graphics.TBitmap): FMX.Graphics.TBitmap;
var
  Surf: TBitmapData;
  NumChannels: Integer;
  IsSuccess: Boolean;
begin
  Result := FMX.Graphics.TBitmap.Create;
  Self.Cursor := crHourGlass;
  imgDisplay.Cursor := crHourGlass;
  try
    Application.ProcessMessages;
    Result.Assign(ABitmap);
    if not Result.Map(TMapAccess.Read, Surf) then
      Exit;
    try
      if Surf.PixelFormat = TPixelFormat.BGRA then
        NumChannels := 4
      else
        NumChannels := 3;

      IsSuccess := OnnxrtWrapper.Predict(FSettings.ModelFile,
      Surf.Data, Surf.Width, Surf.Height, NumChannels,
      EmptyStr, FSettings.Providers, FSettings.ClassFilter);
    finally
      Result.Unmap(Surf);
    end;
    if IsSuccess then
      DrawDetections(Result, OnnxrtWrapper.DetectionResults);
  finally
    imgDisplay.Cursor := crDefault;
    Self.Cursor := crDefault;
  end;
end;

procedure TFormVideoDetectMain.Recognize(const ABitmap: FMX.Graphics.TBitmap);
var
  LBmp: FMX.Graphics.TBitmap;
begin
  if IsProcessing then
    Exit;
  IsProcessing := True;
  if not IsRecognitionAvailable then
    Exit;
  try
     if Assigned(ABitmap) then
       LBmp := Predict(ABitmap)
     else
       LBmp := Predict(imgDisplay.Bitmap);
  finally
    TThread.Queue(nil,
      procedure
      begin
        imgDisplay.Bitmap.Assign(LBmp);
        FreeAndNil(LBmp);
      end);
    IsProcessing := False;
  end;
end;

procedure TFormVideoDetectMain.rectHeaderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
const
  WM_SYSCOMMAND = $0112;
  SC_DRAGMOVE   = $F012;
var
  Wnd: HWND;
begin
  if Button = TMouseButton.mbLeft then
  begin
    Wnd := FmxHandleToHWND(Handle);
    ReleaseCapture;
    SendMessage(Wnd, WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TFormVideoDetectMain.RestartHideTimer;
begin
  if tmrHideControl.Enabled then
  begin
    tmrHideControl.Enabled := False;
    tmrHideControl.Enabled := True;
  end;
end;

procedure TFormVideoDetectMain.SetIsCameraActive(AValue: Boolean);
begin
  if FIsCameraActive <> AValue then
  begin
    FIsCameraActive := IsCameraAvailable and AValue;
    EnableControls;
    Camera.Kind := TCameraKind.Default;
    Camera.Active := FIsCameraActive;
  end;
end;

procedure TFormVideoDetectMain.SetIsProcessing(AValue: Boolean);
begin
  if FIsProcessing <> AValue then
  begin
    FIsProcessing := AValue;
    FAbort := FAbort and FIsProcessing
  end;
end;

procedure TFormVideoDetectMain.SetIsRecognition(AValue: Boolean);
begin
  if FIsRecognition <> AValue then
  begin
    FIsRecognition := IsRecognitionAvailable and AValue and (not FAbort);
    FAbort := False;
    EnableControls;
    if IsImageMode then
      imgDisplay.Bitmap.Assign(FOriginalImage);
    tmrStartRecognition.Enabled := IsRecognition;
    if not IsRecognition then
      OnnxrtWrapper.ProcessStatus := psNone;
  end;
end;

procedure TFormVideoDetectMain.ShowComboAtCell(ACombo: TComboBox; const ACellRect: TRectF;
  ARow: Integer; const AValue: string);
begin
  ACombo.Tag := ARow;
  ACombo.Position.Point := ACellRect.TopLeft;
  ACombo.Width := ACellRect.Width;
  ACombo.Height := ACellRect.Height;
  ACombo.Visible := True;
  ACombo.BringToFront;
  ACombo.ItemIndex := ACombo.Items.IndexOf(AValue);
  ACombo.DropDown;
end;

procedure TFormVideoDetectMain.grdSettingsCellClick(const Column: TColumn;
  const Row: Integer);
var
  LRectF: TRectF;
  sText: string;
begin
  if Column = clSettingValues then
  begin
    sText := FSettings.GetByIndex(Row);
    case Row of
      C_SourceType:
        begin
          LRectF := grdSettings.CellRect(Column.Index, Row);
          LRectF.Inflate(-2, -2);
          LRectF.Offset(grdSettings.Position.X + 1, grdSettings.Position.Y + 2);
          InitCombobox(cbSelect, C_SourceType);
          ShowComboAtCell(cbSelect, LRectF, Row, sText);
        end;

      C_Source:
        begin
          case FSettings.SourceType of
            stImage:
              begin
                if not FSettings.ImageFile.IsEmpty then
                  dlgLoadImage.FileName := FSettings.ImageFile;
                if dlgLoadImage.Execute then
                begin
                  FSettings.SetByIndex(C_Source, dlgLoadImage.FileName);
                  UpdateSettings;
                end;
              end;
            stCamera:
              begin
                LRectF := grdSettings.CellRect(Column.Index, Row);
                LRectF.Inflate(-2, -2);
                LRectF.Offset(grdSettings.Position.X + 1, grdSettings.Position.Y + 2);
                InitCombobox(cbSelect, C_Source);
                ShowComboAtCell(cbSelect, LRectF, Row, sText);
              end;
          end;
        end;

      C_Model:
        begin
          if not FSettings.ModelFile.IsEmpty then
            dlgLoadModel.FileName := FSettings.ModelFile;
          if dlgLoadModel.Execute then
          begin
            FSettings.SetByIndex(C_Model, dlgLoadModel.FileName);
            UpdateSettings;
          end;
        end;
    end;
  end;
end;

procedure TFormVideoDetectMain.grdSettingsDrawColumnBackground(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  LRect: TRectF;
begin
  LRect := Bounds;
  LRect.Inflate(-1, -1);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := Fill.Color;
  Canvas.FillRect(Bounds, 0, 0, [], 1);

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := TAlphaColors.White;
  Canvas.Stroke.Thickness := 1;

  Canvas.DrawLine(PointF(LRect.Right, LRect.Top), PointF(LRect.Right, LRect.Bottom), 0.5);
  Canvas.DrawLine(PointF(LRect.Left, LRect.Bottom), PointF(LRect.Right, LRect.Bottom), 0.5);

  if Row = 0 then
    Canvas.DrawLine(PointF(LRect.Left, LRect.Top), PointF(LRect.Right, LRect.Top), 0.5);
  if Column.Index = C_NameColumn then
    Canvas.DrawLine(PointF(LRect.Left, LRect.Top), PointF(LRect.Left, LRect.Bottom), 0.5);
end;

procedure TFormVideoDetectMain.grdSettingsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  TextRect: TRectF;
begin
  TextRect := Bounds;
  TextRect.Inflate(-6, -2);

  if Column = clSettings then
    Canvas.Fill.Color := gbProviders.TextSettings.FontColor
  else
    Canvas.Fill.Color := grdSettings.TextSettings.FontColor;
  Canvas.FillText(TextRect, Value.ToString, False, 0.5, [], TTextAlign.Leading,
    TTextAlign.Center);
end;

procedure TFormVideoDetectMain.grdSettingsResized(Sender: TObject);
const
  C_WidthDiff = 6;
begin
  if Assigned(grdSettings.VScrollBar) then
    grdSettings.VScrollBar.Visible := False;
  if Assigned(grdSettings.HScrollBar) then
    grdSettings.HScrollBar.Visible := False;
  grdSettings.Columns[C_ValueColumn].Width := grdSettings.Width
    - grdSettings.Columns[C_NameColumn].Width - C_WidthDiff;
end;

procedure TFormVideoDetectMain.acMaximizeExecute(Sender: TObject);
begin
  WindowState := TWindowState.wsMaximized;
end;

procedure TFormVideoDetectMain.acMinimizeExecute(Sender: TObject);
begin
  WindowState := TWindowState.wsMinimized;
end;

procedure TFormVideoDetectMain.acRestoreExecute(Sender: TObject);
begin
  WindowState := TWindowState.wsNormal
end;

procedure TFormVideoDetectMain.acSettingsExecute(Sender: TObject);
begin
  rectSettings.Visible := acSettings.Checked;
end;

procedure TFormVideoDetectMain.ApplySetting(AIndex: Integer);
begin
  case AIndex of
    C_Source:
      begin
        EnableControls;
        if not SameText(FSettings.ImageFile, FOriginalImageFile) then
        begin
          FreeAndNil(FOriginalImage);
          FOriginalImageFile := FSettings.ImageFile;
          if not FOriginalImageFile.IsEmpty then
          begin
            FOriginalImage := FMX.Graphics.TBitmap.Create;
            FOriginalImage.LoadFromFile(FOriginalImageFile);
          end;
        end;
        if IsImageMode then
        begin
          imgDisplay.Bitmap.Assign(FOriginalImage);
          if IsRecognition then
          begin
            tmrStartRecognition.Enabled := True;
          end;
        end
        else
        begin
          imgDisplay.Bitmap.Clear(Fill.Color);
        end;
        //To call the recognition function (OnnxRT.Predict) without parameters
        OnnxrtWrapper.DetectionValue[S_INPUT_IMAGEFILE] := FSettings.ImageFile;
      end;
    C_Model:
      begin
        if OnnxrtWrapper.DetectionValue[S_MODELFILE] <> FSettings.ModelFile then
        begin
          OnnxrtWrapper.DetectionValue[S_MODELFILE] := FSettings.ModelFile;
          if not FSettings.ModelFile.IsEmpty and FileExists(FSettings.ModelFile) then
            FMetaData := OnnxrtWrapper.GetMetadata
          else
            FMetaData.Clear;
        end;
      end;
    C_Providers: OnnxrtWrapper.DetectionValue[S_PROVIDERS] := FSettings.Providers;
    C_ClassFilter: OnnxrtWrapper.DetectionValue[S_FILTERCLASSES] := FSettings.ClassFilter;
  end;
  OnnxrtWrapper.ProcessStatus := psNone;
end;

procedure TFormVideoDetectMain.btnMenuClick(Sender: TObject);
var
  P: TPointF;
begin
  P := btnMenu.LocalToAbsolute(PointF(0, btnMenu.Height + 1));

  btnMenu.PopupMenu.Popup(P.X + Self.Left, P.Y + Self.Top);
end;

procedure TFormVideoDetectMain.swRecognitionSwitch(Sender: TObject);
begin
  if Sender is TSwitch then
  begin
    FAbort := IsProcessing;
    IsRecognition := TSwitch(Sender).IsChecked;
  end;
end;

procedure TFormVideoDetectMain.swRunCameraSwitch(Sender: TObject);
begin
  if Sender is TSwitch then
  begin
    FAbort := IsProcessing;
    IsCameraActive := TSwitch(Sender).IsChecked;
  end;
end;

procedure TFormVideoDetectMain.tmrStartRecognitionTimer(Sender: TObject);
begin
  if Sender is TTimer then
    TTimer(Sender).Enabled := False;
  if IsRecognition then
  begin
    TThread.Queue(nil,
      procedure
      begin
        Recognize;
      end);
  end;
end;

procedure TFormVideoDetectMain.tmrHideControlTimer(Sender: TObject);
begin
  if (Sender is TTimer) then
  begin
    TTimer(Sender).Enabled := False;
    faShowHideControl.StartValue := imgDisplay.Height - lyControl.Height;
    faShowHideControl.StopValue := imgDisplay.Height;
    faShowHideControl.Inverse := False;
    faShowHideControl.Enabled := True;
    faShowHideControl.Start;
  end;
end;

procedure TFormVideoDetectMain.UpdateSettings;
begin
  for var i := 0 to grdSettings.RowCount - 1 do
  begin
    grdSettings.Cells[C_ValueColumn, i] := FSettings.GetByIndex(i);
    ApplySetting(i);
  end;
  memProviders.Text := FSettings.GetByIndex(C_Providers);
  ApplySetting(C_Providers);
  memClassFilter.Text := FSettings.GetByIndex(C_ClassFilter);
  ApplySetting(C_ClassFilter);
end;

procedure TFormVideoDetectMain.DrawDetections(const ABitmap: FMX.Graphics.TBitmap; const ADetected: IDetectionResults);
const
  C_Thickness = 2;
  C_DThickness = 2 * C_Thickness;
var
  LRect: TRectF;
  LLabelRect: TRectF;
  LabelWidth, LabelHeight: Single;
  LScale: Single;
  LClassLabel: string;
begin
  if not Assigned(ABitmap) or (ADetected = nil) then
    Exit;
  if ABitmap.BitmapScale <> 0 then
    LScale := 1 / ABitmap.BitmapScale
  else
    LScale := 1;
  ABitmap.Canvas.BeginScene;
  try
    for var V in ADetected do
    begin
      LRect.Left := V.Box.Left * LScale;
      LRect.Top := V.Box.Top * LScale;
      LRect.Width := V.Box.Width * LScale;
      LRect.Height := V.Box.Height * LScale;
      // Frame
      ABitmap.Canvas.Stroke.Kind := TBrushKind.Solid;
      ABitmap.Canvas.Stroke.Thickness := C_Thickness;
      ABitmap.Canvas.Stroke.Color := V.Color;
      ABitmap.Canvas.DrawRect(LRect, 0, 0, [], 1);

      // Class label
      LClassLabel := Format('%s: %.2f', [V.ClassLabel, V.Score]);
      LabelWidth := ABitmap.Canvas.TextWidth(LClassLabel);
      LabelHeight := ABitmap.Canvas.TextHeight(LClassLabel);

      if (LRect.Top - LabelHeight - C_DThickness) < 0 then
        LLabelRect.Top := LRect.Top - C_Thickness / 2
      else
        LLabelRect.Top := LRect.Top - LabelHeight - C_DThickness;

      LLabelRect.Left := LRect.Left - C_Thickness / 2;
      LLabelRect.Width := LabelWidth + C_DThickness;
      LLabelRect.Height := LabelHeight + C_DThickness;

      ABitmap.Canvas.Fill.Color := V.Color;
      ABitmap.Canvas.Fill.Kind := TBrushKind.Solid;
      ABitmap.Canvas.FillRect(LLabelRect, 0, 0, [], 1);

     // Text
      ABitmap.Canvas.Fill.Color := ContrastingColor(V.Color);
      ABitmap.Canvas.Fill.Kind := TBrushKind.Solid;
      ABitmap.Canvas.FillText(LLabelRect, LClassLabel,
        False, 1, [], TTextAlign.Center, TTextAlign.Center
      );
    end;
  finally
    ABitmap.Canvas.EndScene;
  end;
end;

procedure TFormVideoDetectMain.EnableControls;
var
  LOnSwitch: TNotifyEvent;
begin
  swRunCamera.Visible := IsCameraMode;
  swRunCamera.Enabled := swRunCamera.Visible;
  lblCamera.Visible := swRunCamera.Visible;
  lblCamera.Enabled := swRunCamera.Enabled;
  swRunCamera.IsChecked := IsCameraActive;

  swRunCameraFixed.Visible := swRunCamera.Visible;
  swRunCameraFixed.Enabled := swRunCamera.Enabled;
  lblCameraFixed.Visible := swRunCamera.Visible;
  lblCameraFixed.Enabled := swRunCamera.Enabled;
  swRunCameraFixed.IsChecked := IsCameraActive;

  swRecognition.Enabled := IsRecognitionAvailable;
  lblRecognition.Enabled := swRecognition.Enabled;
  LOnSwitch := swRecognition.OnSwitch;
  swRecognition.OnSwitch := nil;
  swRecognition.IsChecked := IsRecognition;
  swRecognition.OnSwitch := LOnSwitch;

  swRecognitionFixed.Enabled := swRecognition.Enabled;
  lblRecognitionFixed.Enabled := swRecognition.Enabled;
  LOnSwitch := swRecognition.OnSwitch;
  swRecognitionFixed.OnSwitch := nil;
  swRecognitionFixed.IsChecked := IsRecognition;
  swRecognitionFixed.OnSwitch := LOnSwitch;
end;

procedure TFormVideoDetectMain.BitmapToCHWFloat(const ABitmap: FMX.Graphics.TBitmap);
var
  FInputW: Integer;
  FInputH: Integer;
  FInputTensor: TArray<Single>;

  Data: TBitmapData;
  x, y: Integer;
  px: PAlphaColorRec;
  idxR, idxG, idxB, base: Integer;
  r, g, b: Single;
begin
  if not ABitmap.Map(TMapAccess.Read, Data) then
    Exit;
  try
    FInputW := 640;
    FInputH := 640;
    SetLength(FInputTensor, 3 * FInputW * FInputH);

    for y := 0 to ABitmap.Height - 1 do
    begin
      px := Data.GetScanline(y);
      for x := 0 to ABitmap.Width - 1 do
      begin
        r := px^.R / 255.0;
        g := px^.G / 255.0;
        b := px^.B / 255.0;

        base := y * FInputW + x;
        idxR := base;
        idxG := base + FInputW * FInputH;
        idxB := base + 2 * FInputW * FInputH;

        FInputTensor[idxR] := r;
        FInputTensor[idxG] := g;
        FInputTensor[idxB] := b;

        Inc(px);
      end;
    end;
  finally
    ABitmap.Unmap(Data);
  end;
end;

{ TAppSettings }

function TAppSettings.GetByIndex(AIndex: Integer): string;
begin
  case AIndex of
    C_SourceType: Result := Self.SourceType.AsString;
    C_Source:
      begin
        case Self.SourceType of
          stImage: Result := Self.ImageFile;
          stCamera: Result := Self.Camera;
        end;
      end;
    C_Model: Result := Self.ModelFile;
    C_Providers: Result := Self.Providers;
    C_ClassFilter: Result := Self.ClassFilter;
  end;
end;

procedure TAppSettings.SetByIndex(AIndex: Integer; const AValue: string);
begin
  case AIndex of
    C_SourceType:
      begin
        Self.SourceType := TSourceType.TypeOf(AValue);
      end;
    C_Source:
      begin
        case Self.SourceType of
          stImage: Self.ImageFile := AValue;
          stCamera: Self.Camera := AValue;
        end;
      end;
    C_Model:
      begin
        Self.ModelFile := AValue;
      end;
    C_Providers:
      begin
        Self.Providers := AValue;
      end;
    C_ClassFilter:
      begin
        Self.ClassFilter := AValue;
      end;
  end;
end;

const
  INI_SECTION = 'Settings';

procedure TAppSettings.Save(const FileName: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FileName);
  try
    Ini.WriteString(INI_SECTION, 'SourceType', Ord(SourceType).ToString);
    Ini.WriteString(INI_SECTION, 'Camera', Camera);
    Ini.WriteString(INI_SECTION, 'ImageFile', ImageFile);
    Ini.WriteString(INI_SECTION, 'ModelFile', ModelFile);
    Ini.WriteString(INI_SECTION, 'Providers', Providers);
    Ini.WriteString(INI_SECTION, 'ClassFilter', ClassFilter);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TAppSettings.Load(const FileName: string);
var
  Ini: TMemIniFile;
  SrcTypeInt: Integer;
begin
  if not FileExists(FileName) then Exit;

  Ini := TMemIniFile.Create(FileName);
  try
    SrcTypeInt := Ini.ReadInteger(INI_SECTION, 'SourceType', Ord(stImage));
    if (SrcTypeInt < Ord(Low(TSourceType))) or (SrcTypeInt > Ord(High(TSourceType))) then
      SrcTypeInt := Ord(stImage);
    SourceType := TSourceType(SrcTypeInt);

    Camera := Ini.ReadString(INI_SECTION, 'Camera', '');
    ImageFile := Ini.ReadString(INI_SECTION, 'ImageFile', '');
    ModelFile := Ini.ReadString(INI_SECTION, 'ModelFile', '');
    Providers := Ini.ReadString(INI_SECTION, 'Providers', '');
    ClassFilter := Ini.ReadString(INI_SECTION, 'ClassFilter', '');
  finally
    Ini.Free;
  end;
end;

{ TSourceTypeHelper }

function TSourceTypeHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TSourceTypeHelper.AsString: string;
begin
  Result := GetEnumName(TypeInfo(TSourceType), Ord(Self));
  if Result.IndexOf(C_stPrefix) = 0 then
    Result := Result.Substring(C_stPrefix.Length);
end;

class function TSourceTypeHelper.TypeOf(aValue: Integer): TSourceType;
begin
  if (aValue < Low(TSourceType).AsInteger) then
    Result := Low(TSourceType)
  else
  if (aValue > High(TSourceType).AsInteger) then
    Result := High(TSourceType)
  else
    Result := TSourceType(aValue);
end;

class function TSourceTypeHelper.TypeOf(aValue: string): TSourceType;
var
  sName: string;
  i: Integer;
begin
  sName := aValue;
  if (not aValue.Trim.IsEmpty) and (aValue.IndexOf(C_stPrefix) <> 0) then
    sName := C_stPrefix + sName;

  i := GetEnumValue(TypeInfo(TSourceType), sName);
  if i < 0 then
    Result := Low(TSourceType)
  else
    Result := TSourceType(i);
end;

end.
