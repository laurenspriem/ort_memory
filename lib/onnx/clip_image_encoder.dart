import "dart:typed_data" show Int32List, Uint8List;
import "dart:developer" show log;
import "dart:ui" show Image;

import "package:onnx_dart/onnx_dart.dart";
import "package:ort_memory/onnx/ml_model.dart";
import "package:ort_memory/remote_assets_service.dart";

class ClipImageEncoder extends MlModel {
  @override
  String get modelPath => "assets/mobileclip_s2_image_opset18_rgba_opt.onnx";

  String get modelRemotePath =>
      "https://models.ente.io/mobileclip_s2_image_opset18_rgba_opt.onnx";

  static const _modelName = "ClipImageEncoder";

  @override
  String get modelName => _modelName;

  // Singleton pattern
  ClipImageEncoder._privateConstructor();
  static final instance = ClipImageEncoder._privateConstructor();
  factory ClipImageEncoder() => instance;

  @override
  // Note: The platform plugin requires a dedicated isolate for loading the model to ensure thread safety and performance isolation.
  // In contrast, the current FFI-based plugin leverages the session memory address for session management, which does not require a dedicated isolate.
  Future<int> loadModel({int session = 0}) async {
    final appModelPath =
        await RemoteAssetsService.instance.getAssetPath(modelRemotePath);
    // final appModelPath = "${Directory.systemTemp.path}/$modelName.onnx";
    // if (!File(appModelPath).existsSync()) {
    //   final ByteData rawAssetFile = await rootBundle.load(modelPath);
    //   final File tempFile = File(appModelPath);
    //   await tempFile.writeAsBytes(rawAssetFile.buffer.asUint8List());
    // }
    final OnnxDart plugin = OnnxDart();
    final bool? initResult = await plugin.init(modelName, appModelPath);
    if (initResult == null || !initResult) {
      log("Failed to initialize $modelName with EntePlugin.");
      throw Exception("Failed to initialize $modelName with EntePlugin.");
    }
    storeSessionAddress(0);
    return 0;
  }

  Future<List<double>> predict(
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
      final List<double> embedding = result!.sublist(0, 512);
      return embedding;
    } catch (e, stackTrace) {
      log("Clip image inference failed $e, $stackTrace");
      rethrow;
    }
  }
}
