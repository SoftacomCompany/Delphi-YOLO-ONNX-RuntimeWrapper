(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Original code:  Softacom (https://www.softacom.com)                    *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 These are the constants for the ONNX Runtime detection. *)
(***************************************************************************)

unit ONNXRT.Constants;

interface

const
  LF = #10;

  ChQuote = '"';
  ChTagLeft = '<';
  ChTagRight = '>';

  C_FLOATFORMAT = '0.##';
  C_DEFAULT_CONFIDENCE_THRESHOLD = 0.5;
  C_DEFAULT_IOU_THRESHOLD = 0.5;

  {OnnxRT detection value names}
  S_INPUT_IMAGEFILE = 'input_imagefile';
  S_OUT_IMAGEFILE = 'out_imagefile';
  S_MODELFILE = 'modelfile';
  S_PROVIDERS = 'providers';
  S_FILTERCLASSES = 'filterclasses';
  S_CONFIDENCE_THRESHOLD = 'cf_threshold';
  S_IOU_THRESHOLD ='iou_threshold';
  S_MODELTYPE = 'modeltype';
  S_IMAGEWIDTH = 'imwidth';
  S_IMAGEHEIGHT = 'imheight';
  S_IMAGECHANNELS = 'imchannels';

  {options for python code generating}
  pcDrawDetected = 1; //Generate draw code
  pcLoad = 2; //Generate code to open image
  pcSave = 4; //Generate code to save processed image
  pcEnableIO = 7; //Mask options - only lad and save section
  pcDisableIO = High(Word) - pcEnableIO; //Mask options - exclude load and save section
  pcAddImport = 8; //Add import code
  pcAddDefinitions = 16; //Add definitions to code
  pcFullCode = High(Word);

resourcestring
  //Exceptions
  SNoInitialization ='01: Environment not initialized.';
  SNoModelInitialization ='02: Model % not initialized.';
  SResultsObtainingError ='03: Error in obtaining results.';

implementation

end.
