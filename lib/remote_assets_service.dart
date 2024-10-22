import "dart:async";
import "dart:io";
import "dart:developer" show log;

import "package:flutter/foundation.dart";
import "package:ort_memory/network.dart";
import "package:path_provider/path_provider.dart";

class RemoteAssetsService {
  bool checkRemovedOldAssets = false;

  RemoteAssetsService._privateConstructor();
  final StreamController<(String, int, int)> _progressController =
      StreamController<(String, int, int)>.broadcast();

  Stream<(String, int, int)> get progressStream => _progressController.stream;

  static final RemoteAssetsService instance =
      RemoteAssetsService._privateConstructor();

  Future<File> getAsset(String remotePath, {bool refetch = false}) async {
    final path = await _getLocalPath(remotePath);
    final file = File(path);
    if (file.existsSync() && !refetch) {
      log("Returning cached file for $remotePath");
      return file;
    } else {
      final tempFile = File("$path.temp");
      await _downloadFile(remotePath, tempFile.path);
      tempFile.renameSync(path);
      return File(path);
    }
  }

  Future<String> getAssetPath(String remotePath, {bool refetch = false}) async {
    final file = await getAsset(remotePath, refetch: refetch);
    return file.path;
  }

  Future<String> _getLocalPath(String remotePath) async {
    return "${(await getApplicationSupportDirectory()).path}/assets/${_urlToFileName(remotePath)}";
  }

  String _urlToFileName(String url) {
    // Remove the protocol part (http:// or https://)
    String fileName = url
        .replaceAll(RegExp(r'https?://'), '')
        // Replace all non-alphanumeric characters except for underscores and periods with an underscore
        .replaceAll(RegExp(r'[^\w\.]'), '_');
    // Optionally, you might want to trim the resulting string to a certain length

    // Replace periods with underscores for better readability, if desired
    fileName = fileName.replaceAll('.', '_');

    return fileName;
  }

  Future<void> _downloadFile(String url, String savePath) async {
    log("Downloading $url");
    final existingFile = File(savePath);
    if (existingFile.existsSync()) {
      existingFile.deleteSync();
    }

    await NetworkClient.instance.getDio().download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (received > 0 && total > 0) {
          _progressController.add((url, received, total));
        } else if (kDebugMode) {
          debugPrint("$url Received: $received, Total: $total");
        }
      },
    );

    log("Downloaded $url");
  }
}
