import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PickedImageData {
  final String dataUrl;
  final String? path;

  const PickedImageData({
    required this.dataUrl,
    this.path,
  });
}

class MediaService {
  MediaService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<PickedImageData?> pickImage({
    double maxWidth = 800,
    int imageQuality = 78,
  }) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    final mimeType = _mimeTypeForName(image.name);

    return PickedImageData(
      dataUrl: 'data:$mimeType;base64,${base64Encode(bytes)}',
      path: image.path.isEmpty ? null : image.path,
    );
  }

  static ImageProvider? imageProviderFor(String? value) {
    final source = value?.trim();
    if (source == null || source.isEmpty) return null;

    if (source.startsWith('data:image/')) {
      final comma = source.indexOf(',');
      if (comma == -1) return null;
      try {
        final bytes = base64Decode(source.substring(comma + 1));
        return MemoryImage(Uint8List.fromList(bytes));
      } catch (_) {
        return null;
      }
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return NetworkImage(source);
    }

    return null;
  }

  static String _mimeTypeForName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
