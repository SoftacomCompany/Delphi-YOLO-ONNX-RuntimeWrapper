unit FormOnnxDetection;

interface

uses
  System.SysUtils, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Objects, FMX.Memo.Types, FMX.Memo,
  FMX.TabControl, FMX.Layouts, FMX.ScrollBox, FMX.EditBox, FMX.SpinBox,
  FMX.ExtCtrls, FMX.ListBox;

type
  TfrmONNXDetection = class(TForm)
    dlgOpenModel: TOpenDialog;
    dlgOpenImage: TOpenDialog;
    lyCommon: TLayout;
    spltLogImage: TSplitter;
    tcDetection: TTabControl;
    tiOriginalImage: TTabItem;
    tiResultImage: TTabItem;
    imgOriginal: TImage;
    lyImage: TLayout;
    sbarDetection: TStatusBar;
    lyModel: TLayout;
    lyInputImage: TLayout;
    edModel: TEdit;
    btnModel: TButton;
    lblModel: TLabel;
    edImage: TEdit;
    btnImage: TButton;
    lblImage: TLabel;
    lyProviders: TLayout;
    edProviders: TEdit;
    btnProviders: TButton;
    lblProviders: TLabel;
    lyOutPath: TLayout;
    edOutPath: TEdit;
    btnOutPath: TButton;
    lblOutPath: TLabel;
    lyLoadSaveOptions: TLayout;
    gplDetectOptions: TGridPanelLayout;
    lyDetectionParameters: TLayout;
    expDetectOptions: TExpander;
    tbarDetection: TToolBar;
    btnDetect: TButton;
    pnlOriginalImageStatus: TPanel;
    pnlDetectedImageStatus: TPanel;
    imgDetectedImage: TImage;
    expDetectionLog: TExpander;
    memoLog: TMemo;
    lblStatus: TLabel;
    lblStatusName: TLabel;
    btnCodeGenerate: TButton;
    dlgSaveCode: TSaveDialog;
    btnModelprop: TButton;
    lblProcessTime: TLabel;
    lblTimeValue: TLabel;
    lblFunctionTimeValue: TLabel;
    lblFunctionTime: TLabel;
    lyCfThreshold: TLayout;
    lblCfThreshold: TLabel;
    sbCfThreshold: TSpinBox;
    lyIouThreshold: TLayout;
    lblIouThreshold: TLabel;
    sbIouThreshold: TSpinBox;
    lyClassFilter: TLayout;
    edClassFilter: TEdit;
    btnClassFilter: TButton;
    lblClassFilter: TLabel;
    popupClassFilter: TPopup;
    lbClasses: TListBox;
    lyFilterButtons: TLayout;
    btnFilterOk: TButton;
    btnFilterCancel: TButton;
    popupProviders: TPopup;
    lbProviders: TListBox;
    lyProvidersButtons: TLayout;
    btnProvidersOk: TButton;
    btnProvidersCancel: TButton;
    btnSetPython: TButton;
    dlgOpenPython: TOpenDialog;
    procedure btnModelClick(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure btnDetectClick(Sender: TObject);
    procedure edModelChange(Sender: TObject);
    procedure btnOutPathClick(Sender: TObject);
    procedure expDetectionLogExpandedChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnModelpropClick(Sender: TObject);
    procedure btnCodeGenerateClick(Sender: TObject);
    procedure expDetectOptionsClick(Sender: TObject);
    procedure sbCfThresholdChange(Sender: TObject);
    procedure sbIouThresholdChange(Sender: TObject);
    procedure btnClassFilterClick(Sender: TObject);
    procedure edClassFilterChange(Sender: TObject);
    procedure btnProvidersClick(Sender: TObject);
    procedure btnSetPythonClick(Sender: TObject);
  private
    { Private declarations }
    fIsDetected: Boolean;
    function MakeOutImageFile(const aInputImageFile, aOutImagePath: string): string;
    procedure ResetDetection;
    procedure ShowDetection;
    procedure OnStatusChange(Sender: TObject; aIntStatus: Integer;
      aStrStatus: string; aComplete: Boolean);
  public
    { Public declarations }
  end;

var
  frmONNXDetection: TfrmONNXDetection;

implementation
uses
  ONNXRT.Core, ONNXRT.Classes, ONNXRT.Constants, ONNXRT.Types;

{$R *.fmx}

procedure TfrmONNXDetection.btnClassFilterClick(Sender: TObject);
begin
  if lbClasses.Count = 0 then
  begin
    var LMeta := OnnxrtWrapper.GetMetadata;
    if OnnxrtWrapper.ProcessStatus <> psError then
      lbClasses.Items.Text := OnnxrtWrapper.GetModelClasses(LMeta);
  end;
  if popupClassFilter.PopupModal = mrOk then
  begin
    edClassFilter.Text := EmptyStr;
    for var i := 0 to Pred(lbClasses.Count) do
    begin
      if lbClasses.ListItems[i].IsChecked then
      begin
        if not edClassFilter.Text.IsEmpty then
          edClassFilter.Text := edClassFilter.Text + ',';
        edClassFilter.Text := edClassFilter.Text + lbClasses.ListItems[i].Text.Split([':'])[1];
      end;
    end;
  end;
end;

procedure TfrmONNXDetection.btnCodeGenerateClick(Sender: TObject);
begin
  memoLog.Lines.Clear;
  memoLog.Lines.Add(OnnxrtWrapper.BuildDetectionCode(pcFullCode));
  expDetectionLog.IsExpanded := True;
end;

procedure TfrmONNXDetection.btnDetectClick(Sender: TObject);
begin
  ResetDetection;
  OnnxrtWrapper.DetectionValue[S_OUT_IMAGEFILE] := MakeOutImageFile(edImage.Text,
    edOutPath.Text);
  Cursor := crHourGlass;
  if OnnxrtWrapper.Predict then
  begin
    memoLog.Lines.Add(EmptyStr);
    memoLog.Lines.Add('DETECTED:');
    for var V in OnnxrtWrapper.DetectionResults do
    begin
      memoLog.Lines.Add(EmptyStr);
      memoLog.Lines.Add('  box (x,y,w,h) = [' + V.Box.Left.ToString
        + ', ' + V.Box.Top.ToString
        + ', ' + V.Box.Width.ToString
        + ', ' + V.Box.Height.ToString + ']');
      memoLog.Lines.Add('  score = ' + V.Score.ToString);
      memoLog.Lines.Add('  class index = ' + V.ClassIndex.ToString);
      memoLog.Lines.Add('  class name = ' + V.ClassLabel);
    end;
    ShowDetection;
  end;
  Cursor := crDefault;
end;

procedure TfrmONNXDetection.btnImageClick(Sender: TObject);
begin
  dlgOpenImage.FileName := edImage.Text;
  if dlgOpenImage.Execute then
  begin
    edImage.Text := dlgOpenImage.FileName;
    OnnxrtWrapper.DetectionValue[S_INPUT_IMAGEFILE] := edImage.Text;
    OnnxrtWrapper.DetectionValue[S_OUT_IMAGEFILE] := MakeOutImageFile(edImage.Text,
      edOutPath.Text);
    imgOriginal.Bitmap.LoadFromFile(edImage.Text);
    ResetDetection;
  end;
end;

procedure TfrmONNXDetection.btnModelClick(Sender: TObject);
begin
  if dlgOpenModel.Execute then
  begin
    edModel.Text := dlgOpenModel.FileName;
    OnnxrtWrapper.DetectionValue[S_MODELFILE] := edModel.Text;
    ResetDetection;
  end;
end;

procedure TfrmONNXDetection.btnOutPathClick(Sender: TObject);
var
  LPath: string;
begin
  if SelectDirectory('Selecting an output image path', edOutPath.Text, LPath) then
  begin
    edOutPath.Text := LPath;
    OnnxrtWrapper.DetectionValue[S_OUT_IMAGEFILE] := MakeOutImageFile(edImage.Text,
      edOutPath.Text);
  end;
end;

procedure TfrmONNXDetection.btnProvidersClick(Sender: TObject);
begin
  if lbProviders.Count = 0 then
    lbProviders.Items.Text := OnnxrtWrapper.GetProviders;
  if popupProviders.PopupModal = mrOk then
  begin
    edProviders.Text := EmptyStr;
    for var i := 0 to Pred(lbProviders.Count) do
    begin
      if lbProviders.ListItems[i].IsChecked then
      begin
        if not edProviders.Text.IsEmpty then
          edProviders.Text := edProviders.Text + ', ';
        edProviders.Text := edProviders.Text + lbProviders.ListItems[i].Text;
      end;
    end;
  end;
end;

procedure TfrmONNXDetection.btnSetPythonClick(Sender: TObject);
begin
  if (not OnnxrtWrapper.IsInitialized) and dlgOpenPython.Execute then
  begin
    OnnxrtWrapper.Initialize(dlgOpenPython.FileName);
  end;
end;

procedure TfrmONNXDetection.btnModelpropClick(Sender: TObject);
begin
  memoLog.Text := EmptyStr;
  var LMeta := OnnxrtWrapper.GetMetadata;
  if OnnxrtWrapper.ProcessStatus <> psError then
  begin
    memoLog.Lines.Add(EmptyStr);
    memoLog.Lines.Add('METADATA:');
    memoLog.Lines.Add('  model_description = ' + LMeta.model_description);
    memoLog.Lines.Add('  model_domain = ' + LMeta.model_domain);
    memoLog.Lines.Add('  graph_description = ' + LMeta.graph_description);
    memoLog.Lines.Add('  graph_name = ' + LMeta.graph_name);
    memoLog.Lines.Add('  producer_name = ' + LMeta.producer_name);
    memoLog.Lines.Add('  model_version = ' + LMeta.model_version);
    memoLog.Lines.Add('  date = ' + LMeta.date);
    memoLog.Lines.Add('  description = ' + LMeta.description);
    memoLog.Lines.Add('  author = ' + LMeta.author);
    memoLog.Lines.Add('  version = ' + LMeta.version);
    memoLog.Lines.Add('  task = ' + LMeta.task);
    memoLog.Lines.Add('  license = ' + LMeta.license);
    memoLog.Lines.Add('  docs = ' + LMeta.docs);
    memoLog.Lines.Add('  stride = ' + LMeta.stride);
    memoLog.Lines.Add('  batch = ' + LMeta.batch);
    memoLog.Lines.Add('  imgsz = ' + LMeta.imgsz);
    memoLog.Lines.Add('  names = ' + LMeta.names);
    memoLog.Lines.Add('INPUTS:');
    for var i := Low(LMeta.inputs) to High(LMeta.inputs) do
      memoLog.Lines.Add('  input[' + i.ToString + '] = ' + LMeta.inputs[i]);
    memoLog.Lines.Add('OUTPUTS:');
    for var i := Low(LMeta.outputs) to High(LMeta.outputs) do
      memoLog.Lines.Add('  output[' + i.ToString + '] = ' + LMeta.outputs[i]);
    lbClasses.Items.Text := OnnxrtWrapper.GetModelClasses(LMeta);
  end;
  expDetectionLog.IsExpanded := True;
end;

procedure TfrmONNXDetection.edClassFilterChange(Sender: TObject);
begin
  OnnxrtWrapper.DetectionValue[S_FILTERCLASSES] := edClassFilter.Text;
end;

procedure TfrmONNXDetection.edModelChange(Sender: TObject);
begin
  btnDetect.Enabled := FileExists(edModel.Text) and FileExists(edImage.Text);
  btnModelprop.Enabled := FileExists(edModel.Text);
  edClassFilter.Text := EmptyStr;
  lbClasses.Clear;
end;

procedure TfrmONNXDetection.expDetectionLogExpandedChanged(Sender: TObject);
begin
  spltLogImage.Visible := expDetectionLog.IsExpanded;
end;

procedure TfrmONNXDetection.expDetectOptionsClick(Sender: TObject);
begin
  if Sender is TExpander then
    TExpander(Sender).IsExpanded := not TExpander(Sender).IsExpanded;
end;

procedure TfrmONNXDetection.FormCreate(Sender: TObject);
begin
  //Registering a status changing event
  OnnxrtWrapper.RegisterStatusEvent(OnStatusChange);
  //Registering a result addition event
  OnnxrtWrapper.DetectionResults.OnAddDetected :=
    procedure(Sender: TObject; aObject: IDetectedObject)
      begin
        memoLog.Lines.Add(EmptyStr);
        memoLog.Lines.Add('DetectionResults.OnAddDetected');
        memoLog.Lines.Add('  box (x,y,w,h) = [' + aObject.Box.Left.ToString
          + ', ' + aObject.Box.Top.ToString
          + ', ' + aObject.Box.Width.ToString
          + ', ' + aObject.Box.Height.ToString + ']');
        memoLog.Lines.Add('  score = ' + aObject.Score.ToString);
        memoLog.Lines.Add('  class index = ' + aObject.ClassIndex.ToString);
        memoLog.Lines.Add('  class name = ' + aObject.ClassLabel);
      end;

  sbCfThreshold.Text := OnnxrtWrapper.DetectionValue[S_CONFIDENCE_THRESHOLD];
  sbIouThreshold.Text := OnnxrtWrapper.DetectionValue[S_IOU_THRESHOLD];
end;

function TfrmONNXDetection.MakeOutImageFile(const aInputImageFile,
  aOutImagePath: string): string;
var
  LFileName, LFileExt, DTCode: string;
begin
  LFileExt := ExtractFileExt(aInputImageFile);
  LFileName := ExtractFileName(aInputImageFile).Replace(LFileExt, EmptyStr);
  DateTimeToString(DTCode, 'mmddyyhhnnss', now);
  Result := aOutImagePath + '\'+ LFileName + '-dt' + DTCode + LFileExt;
end;

procedure TfrmONNXDetection.OnStatusChange(Sender: TObject; aIntStatus: Integer;
  aStrStatus: string; aComplete: Boolean);
begin
  memoLog.Lines.Add(EmptyStr);
  memoLog.Lines.Add(lblStatus.Text + aStrStatus);
  if aStrStatus.Equals('error') then
    memoLog.Lines.Add(OnnxrtWrapper.LastError);
  lblStatusName.Text := aStrStatus;
  lblTimeValue.Text := OnnxrtWrapper.ProcessTime.AsString;
  lblFunctionTimeValue.Text := OnnxrtWrapper.FunctionTime.AsString;
  if aComplete then
  begin
    btnSetPython.Visible := not OnnxrtWrapper.IsInitialized;
    memoLog.Lines.Add(lblProcessTime.Text + lblTimeValue.Text);
    memoLog.Lines.Add(lblFunctionTime.Text + lblFunctionTimeValue.Text);
  end;
  Application.ProcessMessages;
end;

procedure TfrmONNXDetection.ResetDetection;
begin
  if fIsDetected then
  begin
    imgDetectedImage.Bitmap.Clear(TAlphaColorRec.White);
    tcDetection.TabIndex := 0;
    fIsDetected := False;
    memoLog.Lines.Clear;
  end;
end;

procedure TfrmONNXDetection.sbCfThresholdChange(Sender: TObject);
begin
  OnnxrtWrapper.DetectionValue[S_CONFIDENCE_THRESHOLD] := sbCfThreshold.Text;
end;

procedure TfrmONNXDetection.sbIouThresholdChange(Sender: TObject);
begin
  OnnxrtWrapper.DetectionValue[S_IOU_THRESHOLD] := sbIouThreshold.Text;
end;

procedure TfrmONNXDetection.ShowDetection;
begin
  if FileExists(OnnxrtWrapper.DetectionValue[S_OUT_IMAGEFILE]) then
  begin
    imgDetectedImage.Bitmap.LoadFromFile(OnnxrtWrapper.DetectionValue[S_OUT_IMAGEFILE]);
    tcDetection.TabIndex := 1;
    fIsDetected := True;
  end;
end;

end.
