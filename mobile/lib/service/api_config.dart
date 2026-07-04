import 'package:flutter/foundation.dart';

class ApiConfig {
  // Mengembalikan base URL API berdasarkan platform eksekusi
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    } else {
      // 10.0.2.2 merujuk ke localhost komputer host dari Android Emulator.
      // Jika menggunakan perangkat fisik, ganti dengan IP lokal Wi-Fi Anda (misal: 192.168.1.10).
      return "http://10.0.2.2:8000/api";
    }
  }

  // Mengembalikan domain dasar (tanpa /api) untuk memuat asset/file storage
  static String get baseDomain {
    return baseUrl.replaceAll('/api', '');
  }
}