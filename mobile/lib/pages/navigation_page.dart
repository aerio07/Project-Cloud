import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../service/api_config.dart';

class NavigationPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String name;

  const NavigationPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isLoading = true;
  bool _isNavigating = false;
  String? _errorMessage;
  String _selectedVehicle = 'Mobil';
  double _distanceKm = 0;
  double _durationMin = 0;
  double _remainingDistanceKm = 0;
  double _remainingDurationMin = 0;
  double _currentSpeed = 0;
  String _nextInstruction = 'Lurus menuju tujuan';
  Position? _lastNavigationPosition;
  double _travelledRouteMeters = 0;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Aktifkan layanan lokasi terlebih dahulu.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diperlukan untuk memulai navigasi.');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _setBaseMarkers();
      await _getRoute();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _profile {
    switch (_selectedVehicle) {
      case 'Jalan Kaki':
        return 'foot-walking';
      case 'Motor':
        return 'cycling-regular';
      default:
        return 'driving-car';
    }
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null) return;
    _setBaseMarkers();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/directions?start=${_currentPosition!.longitude},${_currentPosition!.latitude}'
      '&end=${widget.longitude},${widget.latitude}&profile=$_profile',
    );

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Rute tidak dapat dimuat (${response.statusCode}).');
      }
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw Exception(data['message'] ?? 'Rute menuju lokasi ini tidak ditemukan.');
      }

      final route = routes.first as Map<String, dynamic>;
      final summary = route['summary'] as Map<String, dynamic>;
      final routePoints = PolylinePoints()
          .decodePolyline(route['geometry'] as String)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      final segments = route['segments'] as List?;
      final steps = segments?.isNotEmpty == true
          ? (segments!.first as Map<String, dynamic>)['steps'] as List?
          : null;

      _distanceKm = (summary['distance'] as num).toDouble() / 1000;
      _durationMin = (summary['duration'] as num).toDouble() / 60;
      _remainingDistanceKm = _distanceKm;
      _remainingDurationMin = _durationMin;
      _nextInstruction = steps?.isNotEmpty == true
          ? ((steps!.first as Map<String, dynamic>)['instruction'] as String? ??
              _nextInstruction)
          : _nextInstruction;

      _polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: const Color(0xFF1A73E8),
          width: 7,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));

      if (mounted) setState(() => _errorMessage = null);
      _fitRoute(routePoints);
    } catch (error) {
      _polylines.clear();
      if (mounted) setState(() => _errorMessage = error.toString().replaceFirst('Exception: ', ''));
      _fitToMarkers();
    }
  }

  void _setBaseMarkers() {
    final position = _currentPosition;
    if (position == null) return;

    _markers
      ..clear()
      ..add(_currentLocationMarker(position))
      ..add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.name),
      ));
  }

  Marker _currentLocationMarker(Position position) => Marker(
        markerId: const MarkerId('my_location'),
        position: LatLng(position.latitude, position.longitude),
        rotation: position.heading.isFinite ? position.heading : 0,
        flat: true,
        anchor: const Offset(.5, .5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

  Future<void> _fitRoute(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty || _isNavigating) return;
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      south = point.latitude < south ? point.latitude : south;
      north = point.latitude > north ? point.latitude : north;
      west = point.longitude < west ? point.longitude : west;
      east = point.longitude > east ? point.longitude : east;
    }
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
        80,
      ),
    );
  }

  Future<void> _fitToMarkers() async {
    final position = _currentPosition;
    if (_mapController == null || position == null || _isNavigating) return;

    final points = [
      LatLng(position.latitude, position.longitude),
      LatLng(widget.latitude, widget.longitude),
    ];
    await _fitRoute(points);
  }

  Future<void> _startNavigation() async {
    if (_currentPosition == null) return;
    // Jangan memakai pembacaan GPS baru sebagai jarak awal. Nilai awal harus
    // sama dengan jarak rute yang sudah ditampilkan di kartu rute.
    _lastNavigationPosition = _currentPosition;
    _travelledRouteMeters = 0;
    setState(() {
      _isNavigating = true;
      _remainingDistanceKm = _distanceKm;
      _remainingDurationMin = _durationMin;
    });
    await _followPosition(_currentPosition!);
    await _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    ).listen((position) async {
      final previousPosition = _lastNavigationPosition;
      _currentPosition = position;
      _currentSpeed = position.speed > 0 ? position.speed * 3.6 : 0;

      // Kurangi jarak rute berdasarkan perjalanan yang benar-benar ditempuh,
      // bukan jarak garis lurus ke tujuan. Ambang 8 m mengabaikan GPS jitter
      // saat pengguna masih diam.
      if (previousPosition != null) {
        final movedMeters = Geolocator.distanceBetween(
          previousPosition.latitude,
          previousPosition.longitude,
          position.latitude,
          position.longitude,
        );
        if (movedMeters >= 8) {
          _travelledRouteMeters += movedMeters;
          _lastNavigationPosition = position;
          _remainingDistanceKm =
              (_distanceKm - (_travelledRouteMeters / 1000))
                  .clamp(0, _distanceKm)
                  .toDouble();
          _remainingDurationMin = _distanceKm == 0
              ? 0
              : _durationMin * (_remainingDistanceKm / _distanceKm);
        }
      }
      _markers.removeWhere((marker) => marker.markerId.value == 'my_location');
      _markers.add(_currentLocationMarker(position));
      if (mounted) setState(() {});
      await _followPosition(position);
    });
  }

  Future<void> _followPosition(Position position) async {
    if (_mapController == null || !_isNavigating) return;
    await _mapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17.5,
        tilt: 50,
        bearing: position.heading.isFinite && position.heading >= 0 ? position.heading : 0,
      ),
    ));
  }

  Future<void> _stopNavigation() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _lastNavigationPosition = null;
    _travelledRouteMeters = 0;
    if (!mounted) return;
    setState(() => _isNavigating = false);
    if (_currentPosition != null) await _getRoute();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigasi')),
        body: _ErrorView(message: _errorMessage ?? 'Lokasi tidak tersedia.', onRetry: _initializeNavigation),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15,
            ),
            mapType: MapType.normal,
            trafficEnabled: true,
            buildingsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_polylines.isNotEmpty) {
                _fitRoute(_polylines.first.points);
              } else {
                _fitToMarkers();
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(Icons.arrow_back, () => Navigator.pop(context)),
                  if (!_isNavigating)
                    _roundButton(
                      Icons.my_location,
                      () => _fitRoute(
                        _polylines.isEmpty
                            ? [
                                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                LatLng(widget.latitude, widget.longitude),
                              ]
                            : _polylines.first.points,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isNavigating) ...[
            Positioned(top: MediaQuery.paddingOf(context).top + 12, left: 70, right: 16, child: _instructionCard()),
            Positioned(left: 16, bottom: 142, child: _speedBadge()),
            Positioned(left: 16, right: 16, bottom: 24, child: _activeNavigationCard()),
          ] else
            Positioned(left: 0, right: 0, bottom: 0, child: _routeSheet()),
          if (_errorMessage != null && _currentPosition != null)
            Positioned(left: 16, right: 16, top: MediaQuery.paddingOf(context).top + 72, child: _errorBanner()),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onPressed) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: IconButton(onPressed: onPressed, icon: Icon(icon, color: const Color(0xFF202124))),
      );

  Widget _routeSheet() => Material(
        elevation: 16,
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFDADCE0), borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.place, color: Color(0xFFEA4335)),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 18),
              Row(children: ['Mobil', 'Motor', 'Jalan Kaki'].map(_vehicleOption).toList()),
              const SizedBox(height: 18),
              Row(children: [
                Text('${_durationMin.round()} mnt', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text('${_distanceKm.toStringAsFixed(1)} km', style: const TextStyle(color: Color(0xFF5F6368))),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: _polylines.isEmpty ? null : _startNavigation,
                icon: const Icon(Icons.navigation),
                label: const Text('Mulai navigasi'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
        ),
      );

  Widget _vehicleOption(String vehicle) {
    final selected = vehicle == _selectedVehicle;
    final icon = vehicle == 'Mobil' ? Icons.directions_car : vehicle == 'Motor' ? Icons.two_wheeler : Icons.directions_walk;
    return Expanded(child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        setState(() => _selectedVehicle = vehicle);
        await _getRoute();
      },
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? const Color(0xFFE8F0FE) : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: selected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368)), const SizedBox(height: 4), Text(vehicle, style: TextStyle(fontSize: 12, color: selected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368), fontWeight: selected ? FontWeight.w700 : FontWeight.w400))])),
    ));
  }

  Widget _instructionCard() => Material(
    color: const Color(0xFF1A73E8), borderRadius: BorderRadius.circular(16), elevation: 5,
    child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [const Icon(Icons.turn_slight_right, color: Colors.white, size: 30), const SizedBox(width: 12), Expanded(child: Text(_nextInstruction, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis))])),
  );

  Widget _speedBadge() => Container(width: 68, height: 68, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF202124), width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]), child: Text('${_currentSpeed.round()}\nkm/j', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)));

  Widget _activeNavigationCard() => Material(
    color: const Color(0xFF202124), borderRadius: BorderRadius.circular(18), elevation: 8,
    child: Padding(padding: const EdgeInsets.fromLTRB(18, 14, 10, 14), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_remainingDurationMin.ceil()} mnt', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), Text('${_remainingDistanceKm.toStringAsFixed(1)} km tersisa • ${widget.name}', style: const TextStyle(color: Color(0xFFBDC1C6)), maxLines: 1, overflow: TextOverflow.ellipsis)])), IconButton(onPressed: _stopNavigation, tooltip: 'Berhenti navigasi', icon: const Icon(Icons.close, color: Colors.white))])),
  );

  Widget _errorBanner() => Material(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.info_outline, color: Color(0xFFB06000)), const SizedBox(width: 8), Expanded(child: Text(_errorMessage!)), IconButton(onPressed: _getRoute, icon: const Icon(Icons.refresh))])));

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_off_outlined, size: 48), const SizedBox(height: 16), Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton(onPressed: onRetry, child: const Text('Coba lagi'))])));
}
