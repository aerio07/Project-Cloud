import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import 'api_config.dart';
import 'auth_store.dart';

class WishlistStore {
  WishlistStore._();

  static final ValueNotifier<Set<int>> ids = ValueNotifier(<int>{});

  static bool contains(int id) => ids.value.contains(id);

  // Memuat daftar ID wishlist dari database backend
  static Future<void> loadFromBackend() async {
    final token = AuthStore.token.value;
    if (token == null) {
      ids.value = {};
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/wishlists"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List places = data['data'];
        final set = places.map<int>((e) => e['id'] as int).toSet();
        ids.value = set;
      }
    } catch (_) {
      // Mengabaikan jika terjadi kegagalan koneksi jaringan
    }
  }

  // Mengambil objek Place lengkap yang ada di wishlist dari backend
  static Future<List<Place>> getWishlistPlaces() async {
    final token = AuthStore.token.value;
    if (token == null) return [];

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/wishlists"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List places = data['data'];
      return places.map((e) => Place.fromJson(e)).toList();
    }
    
    throw Exception("Gagal memuat daftar wishlist");
  }

  // Mengubah status wishlist (tambah/hapus) dan mensinkronisasikan ke backend
  static Future<bool> toggle(int id) async {
    final token = AuthStore.token.value;
    if (token == null) {
      return false; // Harus login terlebih dahulu
    }

    final next = Set<int>.from(ids.value);
    final exists = next.contains(id);

    try {
      if (exists) {
        // Hapus dari backend
        final response = await http.delete(
          Uri.parse("${ApiConfig.baseUrl}/wishlists/$id"),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          next.remove(id);
          ids.value = next;
          return true;
        }
      } else {
        // Tambah ke backend
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/wishlists"),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'place_id': id}),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          next.add(id);
          ids.value = next;
          return true;
        }
      }
    } catch (_) {
      // Kegagalan koneksi
    }
    return false;
  }
}
