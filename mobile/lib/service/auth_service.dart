import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_store.dart';

class AuthService {
  // Fungsi untuk Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'];
        final user = data['user'];
        await AuthStore.saveSession(
          authToken: token,
          name: user['name'],
          email: user['email'],
          id: user['id'],
          role: user['role'] ?? 'user',
        );
        return {'success': true, 'message': data['message'] ?? 'Login berhasil', 'role': user['role'] ?? 'user'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Email atau password salah.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Fungsi untuk Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String dateOfBirth,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/register"),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'date_of_birth': dateOfBirth,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['token'];
        final user = data['user'];
        await AuthStore.saveSession(
          authToken: token,
          name: user['name'],
          email: user['email'],
          id: user['id'],
          role: user['role'] ?? 'user',
        );
        return {'success': true, 'message': data['message'] ?? 'Registrasi berhasil'};
      }

      if (data['errors'] != null) {
        // Ambil pesan error validasi pertama
        final Map<String, dynamic> errors = data['errors'];
        final firstError = errors.values.first.first;
        return {'success': false, 'message': firstError};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal melakukan pendaftaran.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // Fungsi untuk Logout
  static Future<bool> logout() async {
    try {
      final token = AuthStore.token.value;
      if (token == null) {
        await AuthStore.clearSession();
        return true;
      }

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/logout"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await AuthStore.clearSession();
        return true;
      }
    } catch (_) {
      // Jika server down, tetap hapus session lokal agar user bisa keluar
    }
    
    await AuthStore.clearSession();
    return true;
  }
}
