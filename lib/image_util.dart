import 'dart:io' show File;
import 'dart:developer' show log;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart' as paint show decodeImageFromList;

Future<(Image, Uint8List)> decodeImageFromPath(String imagePath) async {
  try {
    final imageData = await File(imagePath).readAsBytes();
    final image = await decodeImageFromData(imageData);
    final rawRgbaBytes = await getRawRgbaBytes(image);
    return (image, rawRgbaBytes);
  } catch (e) {
    log(
      'Cannot decode image ',
    );
    throw Exception(
      'InvalidImageFormatException: Error decoding image',
    );
  }
}

/// Decodes [Uint8List] image data to an ui.[Image] object.
Future<Image> decodeImageFromData(Uint8List imageData) async {
  // Decoding using flutter paint. This is the fastest and easiest method.
  final Image image = await paint.decodeImageFromList(imageData);
  return image;
}

Future<Uint8List> getRawRgbaBytes(Image image) async {
  final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
  if (byteData == null) {
    throw Exception('Failed to get byte data from image');
  }
  return byteData.buffer.asUint8List();
}
