import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import '../models/place_model.dart';

class PlaceService {

  static Future<List<Place>> getPlaces() async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/places"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List places = data['data'];

      return places
          .map((e) => Place.fromJson(e))
          .toList();
    }

    throw Exception("Failed load places");
  }
}