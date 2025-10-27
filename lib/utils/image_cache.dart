import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ImageSpinCache {
  static final Map<String, ui.Image> _cache = {};

  /// Tải ảnh từ network, có cache trong RAM
  static Future<ui.Image?> loadImage(String url) async {
    if (url.isEmpty) return null;

    // ✅ Kiểm tra cache trước
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // ⚠️ Nếu ảnh quá nhỏ hoặc bytes rỗng -> bỏ qua
        if (bytes.isEmpty) return null;

        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();

        // ✅ Cache lại
        _cache[url] = frame.image;

        return frame.image;
      } else {
        debugPrint('⚠️ Ảnh trả về lỗi ${response.statusCode}: $url');
      }
    } catch (e) {
      debugPrint('❌ Lỗi load ảnh $url: $e');
    }
    return null;
  }

  /// Dọn cache thủ công nếu cần
  static void clearCache() {
    for (final img in _cache.values) {
      img.dispose(); // ✅ Giải phóng bộ nhớ GPU (rất quan trọng)
    }
    _cache.clear();
  }
}
