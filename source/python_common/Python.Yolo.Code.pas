(***************************************************************************)
(*  This unit is part of the ONNX Runtime wrapper for Delphi library       *)
(*                                                                         *)
(*  Code Maintainer:  Softacom (https://www.softacom.com)                  *)
(*  Original code:  Ultralytics (https://www.ultralytics.com)             *)
(*                                                                         *)
(*  LICENCE and Copyright: MIT                                             *)
(***************************************************************************)
(*  Functionality:                                                         *)
(*                 These are python code functions                         *)
(*                 for Ultralytics YOLO models.                            *)
(***************************************************************************)

unit Python.Yolo.Code;

interface

uses
  ONNXRT.Constants;

const
  /// <summary>
  ///   Preparing the image for the model.
  ///   Resizing and converting to a numpy array.
  /// </summary>
  /// <param name="input_image"> Loaded image object. </param>
  /// <param name="model_image_size"> Width and height of model image. </param>
  /// <return> image_data - image_data as tensor. </return>
  YOLO_PREPROCESS_DEF =
    'def yolo_preprocess(input_image, model_image_size):' + LF +
    '    # Resize the image to match the input shape' + LF +
    '    image_data = cv2.resize(input_image,  model_image_size)' + LF +
    '    # Normalize the image data' + LF +
    '    image_data = np.array(image_data, dtype="float32") / 255.0' + LF +
    '    # Transpose the image to have the channel dimension as the first dimension' + LF +
    '    image_data = np.transpose(image_data, [2, 0, 1])' + LF +
    '    # Expand the dimensions of the image data to match the expected input shape' + LF +
    '    image_data = np.expand_dims(image_data, 0)' + LF +
    '    return image_data';

  /// <summary> Conversion and filtering of processing results. </summary>
  /// <param name="output"> Outputs of model. </param>
  /// <param name="scale"> input_image.size[0] / model_size[0], input_image.size[1] / model_size[1]. </param>
  /// <return>
  ///   boxes - list of detected class boundaries,
  ///   scores - list of detected class scores,
  ///   indices - list of detected class indices.
  /// </return>
  YOLO_POSTPROCESS_DEF =
    'def yolo_postprocess(output, scale):' + LF +
    '    # Transpose and squeeze the output to match the expected shape' + LF +
    '    outputs = np.transpose(np.squeeze(output[0]))' + LF +
    '    # Get the number of rows in the outputs array' + LF +
    '    rows = outputs.shape[0]' + LF +
    '    # Lists to store the bounding boxes, scores, and class IDs of the detections' + LF +
    '    boxes = []' + LF +
    '    scores = []' + LF +
    '    indices = []' + LF +
    '    # Iterate over each row in the outputs array' + LF +
    '    for i in range(rows):' + LF +
    '        # Extract the class scores from the current row' + LF +
    '        classes_scores = outputs[i][4:]' + LF +
    '        # Find the maximum score among the class scores' + LF +
    '        max_score = np.amax(classes_scores)' + LF +
    '        # If the maximum score is above zero' + LF +
    '        if max_score > 0:' + LF +
    '           # Get the class ID with the highest score' + LF +
    '           class_id = np.argmax(classes_scores)' + LF +
    '           # Extract the bounding box coordinates from the current row' + LF +
    '           x, y, w, h = outputs[i][0], outputs[i][1], outputs[i][2], outputs[i][3]' + LF +
    '           # Calculate the scaled coordinates of the bounding box' + LF +
    '           left = int((x - w / 2) * scale[0])' + LF +
    '           top = int((y - h / 2) * scale[1])' + LF +
    '           width = int(w * scale[0])' + LF +
    '           height = int(h * scale[1])' + LF +
    '           # Add the class ID, score, and box coordinates to the respective lists' + LF +
    '           indices.append(class_id)' + LF +
    '           scores.append(max_score)' + LF +
    '           boxes.append([left, top, width, height])' + LF +
    '    return boxes, scores, indices';

  /// <summary> Detection function.
  ///   It has a name and a set of arguments predefined for functions of this kind.
  ///   It is called in an external module.
  /// </summary>
  /// <param name="session"> Current onnx runtime session.</param>
  /// <param name="input_image"> Loaded image object.</param>
  /// <return>
  ///   boxes - list of detected class boundaries,
  ///   scores - list of detected class scores,
  ///   indices - list of detected class indices.
  /// </return>
  YOLO_DETECT_DEF =
    'def yolo_detection(session, input_image):' + LF +
    '    model_inputs = session.get_inputs()' + LF +
    '    model_size = model_inputs[0].shape[2], model_inputs[0].shape[3]' + LF +
    '    image_data = yolo_preprocess(input_image, model_size)' + LF +
    '    output_data = session.run([], {model_inputs[0].name: image_data})' + LF +
    '    scale = input_image.shape[1] / model_size[0], input_image.shape[0] / model_size[1]' + LF +
    '    boxes, scores, indices = yolo_postprocess(output_data, scale)' + LF +
    '    return boxes, scores, indices';

  YOLO_DEFINES: array of string = [
    YOLO_PREPROCESS_DEF,
    YOLO_POSTPROCESS_DEF,
    YOLO_DETECT_DEF];

implementation

end.

