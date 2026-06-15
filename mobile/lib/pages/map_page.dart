import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  Set<Marker> markers = {};

  final CameraPosition _initialPosition =
      const CameraPosition(
    target: LatLng(-7.2575, 112.7521),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/places'),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List places = data['data'];

      Set<Marker> loadedMarkers = {};

      for (var place in places) {

        loadedMarkers.add(
          Marker(
            markerId: MarkerId(place['id'].toString()),
            position: LatLng(
              place['latitude'],
              place['longitude'],
            ),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['address'],
            ),
          ),
        );
      }

      setState(() {
        markers = loadedMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("SPBU Surabaya"),
      ),

      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: markers,
      ),
    );
  }
}