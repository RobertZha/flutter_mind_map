import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Base64ImageValidator {
  /// Verify if the Base64 string is a valid image
  static Future<bool> isValidImage(
    String base64String, {
    bool checkHeader = true,
    bool tryDecode = true,
  }) async {
    try {
      // 1. Basic format verification
      if (!_isValidBase64(base64String)) {
        return false;
      }

      // 2. Decoding into bytes
      final Uint8List bytes = _decodeBase64(base64String);

      // 3. Check file header
      if (checkHeader && !_hasValidImageHeader(bytes)) {
        return false;
      }

      // 4. Attempt to decode the image
      if (tryDecode) {
        return await _canDecodeAsImage(bytes);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check Base64 format
  static bool _isValidBase64(String str) {
    if (str.isEmpty) return false;

    // Processing data URI
    if (str.startsWith('data:image/')) {
      final parts = str.split(',');
      if (parts.length != 2) return false;
      str = parts[1];
    }

    // Check Base64 characters
    if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(str)) {
      return false;
    }

    // Check the length
    if (str.length % 4 != 0) {
      return false;
    }

    return true;
  }

  /// Decoding Base64
  static Uint8List _decodeBase64(String base64String) {
    String data = base64String;
    if (base64String.contains(',')) {
      data = base64String.split(',').last;
    }
    return base64.decode(data);
  }

  /// Check the header information of the image
  static bool _hasValidImageHeader(Uint8List bytes) {
    if (bytes.length < 8) return false;

    // Define the magic numbers for common image formats
    final magicNumbers = [
      [0xFF, 0xD8, 0xFF], // JPEG
      [0x89, 0x50, 0x4E, 0x47], // PNG
      [0x47, 0x49, 0x46, 0x38], // GIF
      [0x52, 0x49, 0x46, 0x46], // WebP
      [0x42, 0x4D], // BMP
      [0x49, 0x49, 0x2A, 0x00], // TIFF (little endian)
      [0x4D, 0x4D, 0x00, 0x2A], // TIFF (big endian)
    ];

    for (final magic in magicNumbers) {
      bool matches = true;
      for (int i = 0; i < magic.length; i++) {
        if (bytes.length <= i || bytes[i] != magic[i]) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }

    return false;
  }

  /// Attempt to decode the image
  static Future<bool> _canDecodeAsImage(Uint8List bytes) async {
    try {
      final Completer<bool> completer = Completer();
      final image = MemoryImage(bytes);
      final stream = image.resolve(ImageConfiguration.empty);

      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(true);
          stream.removeListener(listener);
        },
        onError: (Object error, StackTrace? stackTrace) {
          completer.complete(false);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);

      return await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          stream.removeListener(listener);
          return false;
        },
      );
    } catch (e) {
      return false;
    }
  }
}
