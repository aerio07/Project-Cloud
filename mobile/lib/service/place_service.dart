import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import 'api_config.dart';

class PlaceService {

  static Future<List<Place>> getPlaces() async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/places"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      List placesJson = data['data'];

      return placesJson
          .map((json) => Place.fromJson(json))
          .toList();

    } else {

      throw Exception("Failed to load places");
    }
  }
}