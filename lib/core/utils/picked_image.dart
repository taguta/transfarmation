import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Whether an image picked via image_picker can be displayed.
/// On web the picker returns a blob URL that cannot be probed with dart:io.
bool pickedImageExists(String path) {
  if (path.isEmpty) return false;
  return kIsWeb || File(path).existsSync();
}

/// Displays an image_picker path on every platform: a network/blob URL on web,
/// a local file on mobile and desktop.
class PickedImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PickedImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.broken_image_outlined),
    );
    if (kIsWeb) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
