import 'package:flutter/foundation.dart';

class ApiConfig {
  // Menggunakan URL Web Service online dari Render.com
  static const String baseUrl = "https://myspbu.onrender.com/api";

  // Mengembalikan domain dasar (tanpa /api) untuk memuat asset/file storage
  static String get baseDomain {
    return baseUrl.replaceAll('/api', '');
  }
}