(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Code Maintainer:  Softacom (https://www.softacom.com)                  *)
(*  Original code:  Ultralytics (https://www.ultralytics.com/)             *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 These are python code functions                         *)
(*                 used for detection by the ONNX Runtime.                 *)
(***************************************************************************)

unit Python.ONNXRT.Code;

interface

uses
  ONNXRT.Constants;

const
  /// <summary> Importing required python modules.</summary>
  ONNXRT_IMPORT =
    'import onnxruntime' + LF +
    'import numpy as np' + LF +
    'import cv2' + LF +
    'import ast';

  /// <summary> Getting information about ONNX model.</summary>
  /// <param name="modelfile"> Path and file name of model. </param>
  /// <return>
  ///   model_inputs - inputs of model,
  ///   model_outputs - outputs of model,
  ///   model_meta - metadata of model.
  /// </return>
  ONNXRT_MODELINFO_DEF =
    'def modelinfo(modelfile):' + LF +
    '    session = onnxruntime.InferenceSession(modelfile, providers=[])' + LF +
    '    model_inputs = session.get_inputs()' + LF +
    '    model_outputs = session.get_outputs()' + LF +
    '    model_meta = session.get_modelmeta()' + LF +
    '    return model_inputs, model_outputs, model_meta';

  /// <summary> Getting model classes.</summary>
  /// <param name="session"> Current onnx runtime session. </param>
  /// <return> modelclasses - class name dictionary (class index : class name). </return>
  ONNXRT_MODELCLASSES_DEF =
    'def getmodelclasses(session):' + LF +
    '    modelclasses = ast.literal_eval(session.get_modelmeta().custom_metadata_map["names"])' + LF +
    '    return modelclasses';

  /// <summary> Generating random colors for model classes.</summary>
  /// <param name="array_size"> Number of array elements. </param>
  /// <return> colors - array with random RGB values ([[R, G, B]...[Rn, Gn, Bn]]). </return>
  ONNXRT_GENERATECOLORS_DEF =
    'def gencolors(array_size):' + LF +
    '    colors = np.random.uniform(0, 255, size=(array_size, 3))' + LF +
    '    return colors';

  /// <summary> Filtering overlapping bounding boxes. </summary>
  /// <param name="boxes"> list of detected class boundaries.</param>
  /// <param name="scores"> List of detected class scores.</param>
  /// <param name="indices"> List of detected class indices.</param>
  /// <param name="confidence_threshold">
  ///   A float value representing the minimum confidence score
  ///   required for a bounding box to be considered.
  ///   Bounding boxes with confidence scores below this threshold are discarded..
  /// </param>
  /// <param name="iou_threshold">
  ///   A float value representing the Intersection over Union (IoU)
  ///   threshold for determining whether two bounding boxes overlap.
  ///   If the IoU of two bounding boxes is greater than this threshold,
  ///   the one with a lower confidence score is discarded.
  /// </param>
  /// <return>
  ///   out_boxes - list of detected class boundaries,
  ///   out_scores - list of detected class scores,
  ///   out_indices - list of detected class indices.
  /// </return>
  ONNXRT_FILTEROUTOVERLAPPING_DEF =
    'def filterout_overlapping(boxes, scores, indices, confidence_threshold, iou_threshold):' + LF +
    '    # Apply non-maximum suppression to filter out overlapping bounding boxes' + LF +
    '    nms_indices = cv2.dnn.NMSBoxes(boxes, scores, confidence_threshold, iou_threshold)' + LF +
    '    out_boxes = []' + LF +
    '    out_scores = []' + LF +
    '    out_indices = []' + LF +
    '    # Iterate over the selected indices after non-maximum suppression' + LF +
    '    for i in nms_indices:' + LF +
    '        out_boxes.append(boxes[i])' + LF +
    '        out_scores.append(scores[i])' + LF +
    '        out_indices.append(indices[i])' + LF +
    '    return out_boxes, out_scores, out_indices';

  /// <summary> Binding of names and colors with detected classes. </summary>
  /// <param name="filterclasses"> list of classes to select.</param>
  /// <param name="boxes"> list of detected class boundaries.</param>
  /// <param name="scores"> List of detected class scores.</param>
  /// <param name="indices"> List of detected class indices.</param>
  /// <return>
  ///   boxes - list of detected class boundaries.</param>
  ///   scores - List of detected class scores.</param>
  ///   indices - List of detected class indices.</param>
  ///   classes - list of detected classes.
  ///   colors - list of RGB values for detected classes.
  /// </return>
  ONNXRT_MARKDETECTED_DEF =
    'def markdetected(filterclasses, boxes, scores, indices, session):' + LF +
    '    modelclasses = getmodelclasses(session)' + LF +
    '    color_palette = gencolors(len(modelclasses))' + LF +
    '' + LF +
    '    def checkclass(classvalue, classindex):' + LF +
    '        if (classvalue in filterclasses) or (classindex in filterclasses):' + LF +
    '           return True' + LF +
    '        else:' + LF +
    '           return False' + LF +
    '' + LF +
    '    def markclass(classindex):' + LF +
    '        classes.append(modelclasses[classindex])' + LF +
    '        r,g,b = color_palette[classindex]' + LF +
    '        colors.append((r,g,b))' + LF +
    '' + LF +
    '    classes = []' + LF +
    '    colors = []' + LF +
    '    if len(filterclasses) == 0:' + LF +
    '       out_boxes = boxes' + LF +
    '       out_scores = scores' + LF +
    '       out_indices = indices' + LF +
    '       for i in range(len(indices)):' + LF +
    '           markclass(indices[i])' + LF +
    '    else:' + LF +
    '       out_boxes = []' + LF +
    '       out_scores = []' + LF +
    '       out_indices = []' + LF +
    '       for i in range(len(indices)):' + LF +
    '           if checkclass(modelclasses[indices[i]], indices[i]):' + LF +
    '              out_boxes.append(boxes[i])' + LF +
    '              out_scores.append(scores[i])' + LF +
    '              out_indices.append(indices[i])' + LF +
    '              markclass(indices[i])' + LF +
    '    return out_boxes, out_scores, out_indices, classes, colors';

  /// <summary> Drawing detected boundaries. </summary>
  /// <param name="input_image"> NumPy array of the image in RGB colors. </param>
  /// <param name="boxes"> List of detected class boundaries. </param>
  /// <param name="scores"> List of detected class scores. </param>
  /// <param name="classes"> List of detected classes. </param>
  /// <param name="colors"> List of colors for drawing the boundaries. </param>
  ONNXRT_DRAWDETECTION_DEF =
    'def draw_detection(input_image, boxes, scores, classes, colors):' + LF +
    '    for i in range(len(classes)):' + LF +
    '        # Extract the coordinates of the bounding box' + LF +
    '        x, y, w, h = boxes[i]' + LF +
    '        # Draw the bounding box on the image' + LF +
    '        cv2.rectangle(input_image, (int(x), int(y)), (int(x + w), int(y + h)), colors[i], 2)' + LF +
    '        label = (f"{classes[i]}: {scores[i]:.2f}")' + LF +
    '        # Calculate the dimensions of the label text' + LF +
    '        (label_width, label_height), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)' + LF +
    '        # Calculate the position of the label text' + LF +
    '        label_x = x' + LF +
    '        label_y = y - 10 if y - 10 > label_height else y + 10' + LF +
    '        # Draw a filled rectangle as the background for the label text' + LF +
    '        cv2.rectangle(input_image, (label_x, label_y - label_height), (label_x + label_width, label_y + label_height), colors[i], cv2.FILLED)' + LF +
    '        # Selecting a contrasting color for the font' + LF +
    '        r, g, b = colors[i]' + LF +
    '        luminance = (0.299 * r + 0.587 * g + 0.114 * b)/255' + LF +
    '        fontcolor = (0,0,0) if luminance > 0.5 else (255,255,255)' + LF +
    '        # Draw the label text on the image' + LF +
    '        cv2.putText(input_image, label, (label_x, label_y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, fontcolor, 1, cv2.LINE_AA)' + LF +
    '    return input_image';

  /// <summary> Open image by cv2 function. </summary>
  /// <param name="input_image_File"> Path and file name of image. </param>
  /// <return> NumPy array in RGB colors if the image is loaded successfully. </return>
  ONNXRT_CV2_OPENIMAGE_DEF =
    'def cv2_openimage(input_imagefile):' + LF +
    '    input_image = cv2.cvtColor(cv2.imread(input_imagefile), cv2.COLOR_BGR2RGB)' + LF +
    '    return input_image';

  /// <summary> Save image by cv2 function. </summary>
  /// <param name="out_image"> NumPy array of the image in RGB colors. </param>
  /// <param name="out_image_File"> Path and file name of saving image. </param>
  ONNXRT_CV2_SAVEIMAGE_DEF =
    'def cv2_saveimage(out_image, out_imagefile):' + LF +
    '    cv2.imwrite(out_imagefile, cv2.cvtColor(out_image, cv2.COLOR_RGB2BGR))';

  /// <summary> The main detection function. </summary>
  /// <param name="modelfile"> Path and file name of model. </param>
  /// <param name="providers"> List of execution providers. </param>
  /// <param name="input_image"> NumPy array of the image in RGB colors. </param>
  /// <param name="cf_thres"> Confidence threshold for filtering detections.</param>
  /// <param name="iou_thres"> IoU (Intersection over Union) threshold for non-maximum suppression.</param>
  /// <return>
  ///   boxes - list of detected class boundaries,
  ///   scores - list of detected class scores,
  ///   indices - list of detected class indices.
  ///   classes - list of detected classes.
  ///   colors - list of RGB values for detected classes.
  /// </return>
  ONNXRT_DETECTION_DEF =
    'def onnxrt_detection(modelfile, providers, input_image, filterclasses, cf_thres, iou_thres):' + LF +
    '    session = onnxruntime.InferenceSession(modelfile, providers=providers)' + LF +
    '    # detection - code from external module' + LF +
    '    boxes, scores, indices = detection(session, input_image)' + LF +
    '    boxes, scores, indices = filterout_overlapping(boxes, scores, indices, cf_thres, iou_thres)' + LF +
    '    boxes, scores, indices, classes, colors = markdetected(filterclasses, boxes, scores, indices, session)' + LF +
    '    return boxes, scores, indices, classes, colors';

  /// <summary> Getting information about ONNX model.</summary>
  ONNXRT_MODELINFO = 'model_inputs, model_outputs, model_meta = modelinfo("<modelfile>")';
  /// <summary> Getting information about all providers.</summary>
  ONNXRT_ALL_PROVIDERS = 'providers = onnxruntime.get_all_providers()';
  /// <summary> Getting information about available providers.</summary>
  ONNXRT_AVAILABLE_PROVIDERS = 'providers = onnxruntime.get_available_providers()';
  /// <summary> Open image command. </summary>
  ONNXRT_CV2_OPENIMAGE = 'input_image = cv2_openimage("<input_imagefile>")';
  /// <summary> Save image command. </summary>
  ONNXRT_CV2_SAVEIMAGE = 'cv2_saveimage(out_image, "<out_imagefile>")';
  /// <summary> Drawing of detections on the image. </summary>
  ONNXRT_DRAWDETECTION = 'out_image = draw_detection(input_image, boxes, scores, classes, colors)';
  /// <summary> Build an empty array. </summary>
  ONNXRT_EMPTYIMAGE = 'out_image = []';
  /// <summary> The main detection function. </summary>
  ONNXRT_DETECTION =
    'boxes, scores, indices, classes, colors = onnxrt_detection("<modelfile>", [<providers>], input_image, [<filterclasses>], <cf_threshold>, <iou_threshold>)';
  /// <summary> Select detection function. </summary>
  ONNXRT_MODELDETECTION = 'detection = <modeltype>_detection';

  ONNXRT_DEFINES: array of string = [
    ONNXRT_MODELINFO_DEF,
    ONNXRT_MODELCLASSES_DEF,
    ONNXRT_GENERATECOLORS_DEF,
    ONNXRT_FILTEROUTOVERLAPPING_DEF,
    ONNXRT_MARKDETECTED_DEF,
    ONNXRT_DRAWDETECTION_DEF,
    ONNXRT_CV2_OPENIMAGE_DEF,
    ONNXRT_CV2_SAVEIMAGE_DEF,
    ONNXRT_DETECTION_DEF
    ];

  ONNXRT_VALUES: array of string = [
    S_INPUT_IMAGEFILE, //Path and file name of input image
    S_OUT_IMAGEFILE,  //Path and file name of output image
    S_MODELFILE, //Path and file name of model
    S_PROVIDERS, //Comma separated string of execution providers.
    S_FILTERCLASSES, //Filter for detected classes
    S_CONFIDENCE_THRESHOLD, //Confidence threshold for filtering detections (float)
    S_IOU_THRESHOLD, //IoU (Intersection over Union) threshold for non-maximum suppression (float)
    S_MODELTYPE //Type of model in use
    ];

implementation

end.
