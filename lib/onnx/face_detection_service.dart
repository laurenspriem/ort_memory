import "dart:typed_data" show Float32List, Int32List, Uint8List;
import "dart:developer" show log;
import "dart:ui" show Image;

import "package:onnx_dart/onnx_dart.dart";
import "package:ort_memory/onnx/ml_model.dart";

class FaceDetectionService extends MlModel {
  @override
  String get modelPath => "assets/yolov5s_face_opset18_rgba_opt_nosplits.onnx";

  static const _modelName = "YOLOv5Face";

  @override
  String get modelName => _modelName;

  // Singleton pattern
  FaceDetectionService._privateConstructor();
  static final instance = FaceDetectionService._privateConstructor();
  factory FaceDetectionService() => instance;

  Future<Float32List?> predict(
    Image image,
    Uint8List rawRgbaBytes,
    int sessionAddress,
  ) async {
    final inputShape = <int>[image.height, image.width, 4]; // [H, W, C]
    try {
      final OnnxDart plugin = OnnxDart();
      final result = await plugin.predictRgba(
        rawRgbaBytes,
        Int32List.fromList(inputShape),
        _modelName,
      );
      return result;
    } catch (e, stackTrace) {
      log("Clip image inference failed $e, $stackTrace");
      rethrow;
    }
  }
}
