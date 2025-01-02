program OnnxDetectionTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormOnnxDetection in 'FormOnnxDetection.pas' {frmONNXDetection},
  Python.Manager in '..\source\python_common\Python.Manager.pas',
  Python.ONNXRT.Code in '..\source\python_common\Python.ONNXRT.Code.pas',
  Python.Yolo.Code in '..\source\python_common\Python.Yolo.Code.pas',
  ONNXRT.Classes in '..\source\ONNXRT_core\ONNXRT.Classes.pas',
  ONNXRT.Constants in '..\source\ONNXRT_core\ONNXRT.Constants.pas',
  ONNXRT.Core in '..\source\ONNXRT_core\ONNXRT.Core.pas',
  ONNXRT.Types in '..\source\ONNXRT_core\ONNXRT.Types.pas',
  ONNXRT.Utils in '..\source\ONNXRT_core\ONNXRT.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmONNXDetection, frmONNXDetection);
  Application.Run;
end.
