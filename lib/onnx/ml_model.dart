import "dart:io" show Directory, File;
import "dart:developer" show log;

import "package:flutter/services.dart";
import "package:onnx_dart/onnx_dart.dart";

abstract class MlModel {
  String get modelPath;

  String get modelName;

  bool isInitialized = false;
  int sessionIndex = -1;

  void storeSessionAddress(int address) {
    sessionIndex = address;
    isInitialized = true;
  }

  void releaseSessionAddress() {
    sessionIndex = -1;
    isInitialized = false;
  }

  // Note: The platform plugin requires a dedicated isolate for loading the model to ensure thread safety and performance isolation.
  // In contrast, the current FFI-based plugin leverages the session memory address for session management, which does not require a dedicated isolate.
  Future<int> loadModel({int session = 0}) async {
    final appModelPath = "${Directory.systemTemp.path}/$modelName.onnx";
    if (!File(appModelPath).existsSync()) {
      final ByteData rawAssetFile = await rootBundle.load(modelPath);
      final File tempFile = File(appModelPath);
      await tempFile.writeAsBytes(rawAssetFile.buffer.asUint8List());
    }
    final OnnxDart plugin = OnnxDart();
    final bool? initResult = await plugin.init(modelName, appModelPath);
    if (initResult == null || !initResult) {
      log("Failed to initialize $modelName with EntePlugin.");
      throw Exception("Failed to initialize $modelName with EntePlugin.");
    }
    storeSessionAddress(0);
    return 0;
  }

  Future<void> releaseModel(String modelName) async {
    final OnnxDart plugin = OnnxDart();
    final bool? initResult = await plugin.release(modelName);
    if (initResult == null || !initResult) {
      throw Exception("Failed to release $modelName with PlatformPlugin.");
    }
    releaseSessionAddress();
  }
}
