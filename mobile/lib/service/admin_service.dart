import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';
import 'auth_store.dart';

class AdminService {
  static Map<String, String> get _headers => {
        'Authorization': 'Bearer ${AuthStore.token.value}',
        'Accept': 'application/json',
      };

  static Map<String, String> get _jsonHeaders => {
        ..._headers,
        'Content-Type': 'application/json',
      };

  // ==============================
  // DASHBOARD
  // ==============================

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/dashboard"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ==============================
  // PLACES (SPBU)
  // ==============================

  static Future<Map<String, dynamic>> getPlaces() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/places"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPlace({
    required Map<String, dynamic> data,
    File? photo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/admin/places"),
    );

    request.headers.addAll(_headers);

    // Tambahkan field data
    data.forEach((key, value) {
      if (value != null && key != 'facilities' && key != 'fuels') {
        request.fields[key] = value.toString();
      }
    });

    // Tambahkan fasilitas sebagai array
    if (data['facilities'] != null) {
      request.fields['sync_facilities'] = '1';
      final facilities = data['facilities'] as List;
      for (int i = 0; i < facilities.length; i++) {
        request.fields['facilities[$i]'] = facilities[i].toString();
      }
    }

    // Tambahkan BBM sebagai array of objects
    if (data['fuels'] != null) {
      request.fields['sync_fuels'] = '1';
      final fuels = data['fuels'] as List;
      for (int i = 0; i < fuels.length; i++) {
        request.fields['fuels[$i][fuel_id]'] = fuels[i]['fuel_id'].toString();
        if (fuels[i]['price'] != null) {
          request.fields['fuels[$i][price]'] = fuels[i]['price'].toString();
        }
        request.fields['fuels[$i][is_available]'] = (fuels[i]['is_available'] ?? true) ? '1' : '0';
      }
    }

    // Tambahkan foto
    if (photo != null) {
      final ext = photo.path.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePlace({
    required int id,
    required Map<String, dynamic> data,
    File? photo,
  }) async {
    final request = http.MultipartRequest(
      'POST', // POST karena multipart tidak support PUT
      Uri.parse("${ApiConfig.baseUrl}/admin/places/$id"),
    );

    request.headers.addAll(_headers);

    data.forEach((key, value) {
      if (value != null && key != 'facilities' && key != 'fuels') {
        request.fields[key] = value.toString();
      }
    });

    if (data['facilities'] != null) {
      request.fields['sync_facilities'] = '1';
      final facilities = data['facilities'] as List;
      for (int i = 0; i < facilities.length; i++) {
        request.fields['facilities[$i]'] = facilities[i].toString();
      }
    }

    if (data['fuels'] != null) {
      request.fields['sync_fuels'] = '1';
      final fuels = data['fuels'] as List;
      for (int i = 0; i < fuels.length; i++) {
        request.fields['fuels[$i][fuel_id]'] = fuels[i]['fuel_id'].toString();
        if (fuels[i]['price'] != null) {
          request.fields['fuels[$i][price]'] = fuels[i]['price'].toString();
        }
        request.fields['fuels[$i][is_available]'] = (fuels[i]['is_available'] ?? true) ? '1' : '0';
      }
    }

    if (photo != null) {
      final ext = photo.path.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePlace(int id) async {
    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/admin/places/$id"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ==============================
  // FUELS (BBM)
  // ==============================

  static Future<Map<String, dynamic>> getFuels() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/fuels"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createFuel(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/admin/fuels"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFuel(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/admin/fuels/$id"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ==============================
  // CATEGORIES
  // ==============================

  static Future<Map<String, dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/categories"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/admin/categories"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/admin/categories/$id"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ==============================
  // FACILITIES
  // ==============================

  static Future<Map<String, dynamic>> getFacilities() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/facilities"),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createFacility(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/admin/facilities"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFacility(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/admin/facilities/$id"),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
