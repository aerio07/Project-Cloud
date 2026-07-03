import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place_model.dart';
import '../service/place_service.dart';
import 'detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> markers = {};
  bool _isLoading = true;
  Place? _selectedPlace;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-7.2575, 112.7521),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    try {
      final places = await PlaceService.getPlaces();
      Set<Marker> loadedMarkers = {};

      for (Place place in places) {
        loadedMarkers.add(
          Marker(
            markerId: MarkerId(place.id.toString()),
            position: LatLng(
              place.latitude,
              place.longitude,
            ),
            onTap: () {
              setState(() {
                _selectedPlace = place;
              });
            },
          ),
        );
      }

      setState(() {
        markers = loadedMarkers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat peta: $e")),
        );
      }
    }
  }

  Widget _buildPlaceDetailCard(Place place) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202124),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _selectedPlace = null;
                  });
                },
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            place.address,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${place.openingHours})",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(place: place),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBA0015),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "Lihat Detail",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peta SPBU Surabaya"),
        backgroundColor: const Color(0xFFBA0015),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFBA0015),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                  onTap: (_) {
                    setState(() {
                      _selectedPlace = null;
                    });
                  },
                ),
                if (_selectedPlace != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildPlaceDetailCard(_selectedPlace!),
                  ),
              ],
            ),
    );
  }
}