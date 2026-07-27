import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();

  static Future<File> compressImage(File imageFile,
      {int quality = 70, int maxWidth = 720}) async {
    if (kIsWeb) return imageFile;

    final bytes = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) return imageFile;

    img.Image resized;
    if (original.width > maxWidth) {
      final ratio = maxWidth / original.width;
      final newHeight = (original.height * ratio).round();
      resized = img.copyResize(original, width: maxWidth, height: newHeight);
    } else {
      resized = original;
    }

    final compressedBytes = img.encodeJpg(resized, quality: quality);

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(compressedBytes);

    return outputFile;
  }
}
