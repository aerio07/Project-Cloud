
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
  State<NavigationPage> createState() =>
      _NavigationPageState();
}

class _NavigationPageState
    extends State<NavigationPage> {

  GoogleMapController? mapController;

  Position? currentPosition;

  StreamSubscription<Position>? positionStream;

  bool isLoading = true;

  String selectedVehicle = "Mobil";

  final Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  double distanceKm = 0;

  double durationMin = 0;

  String nextInstruction = "";

  @override
  void initState() {
    super.initState();

    initializeNavigation();
  }

  // =========================
  // INIT
  // =========================
  Future<void> initializeNavigation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();
    }

    currentPosition =
        await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    await getRoute();

    startLiveTracking();

    setState(() {
      isLoading = false;
    });
  }

  // =========================
  // LIVE GPS TRACKING
  // =========================
  void startLiveTracking() {

    positionStream =
        Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {

      currentPosition = position;

      await getRoute();

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              position.latitude,
              position.longitude,
            ),
            zoom: 17,
          ),
        ),
      );
    });
  }

  // =========================
  // GET ROUTE
  // =========================
  Future<void> getRoute() async {

    if (currentPosition == null) return;

    String profile = "driving-car";

    if (selectedVehicle == "Jalan Kaki") {
      profile = "foot-walking";
    }

    else if (selectedVehicle == "Motor") {
      profile = "cycling-regular";
    }

    else {
      profile = "driving-car";
    }

    String baseUrl;

    if (kIsWeb) {
      baseUrl = "http://127.0.0.1:8000";
    } else {
      baseUrl = "http://10.0.2.2:8000";
    }

    final url =
        "$baseUrl/api/directions"
        "?start=${currentPosition!.longitude},${currentPosition!.latitude}"
        "&end=${widget.longitude},${widget.latitude}"
        "&profile=$profile";

    try {

      final response =
          await http.get(Uri.parse(url));

      final data =
          jsonDecode(response.body);

      // ======================
      // DISTANCE
      // ======================
      distanceKm =
          data['routes'][0]['summary']
                  ['distance'] /
              1000;

      // ======================
      // DURATION
      // ======================
      durationMin =
          data['routes'][0]['summary']
                  ['duration'] /
              60;

      // ======================
      // NEXT DIRECTION
      // ======================
      nextInstruction =
          data['routes'][0]['segments'][0]
              ['steps'][0]['instruction'];

      // ======================
      // POLYLINE
      // ======================
      String encodedPolyline =
          data['routes'][0]['geometry'];

      PolylinePoints polylinePoints =
          PolylinePoints();

      List<PointLatLng> result =
          polylinePoints.decodePolyline(
        encodedPolyline,
      );

      List<LatLng> routePoints = [];

      for (var point in result) {

        routePoints.add(
          LatLng(
            point.latitude,
            point.longitude,
          ),
        );
      }

      // ======================
      // MARKERS
      // ======================
      markers.clear();

      markers.add(
        Marker(
          markerId:
              const MarkerId("my_location"),

          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),

          infoWindow: const InfoWindow(
            title: "Lokasi Saya",
          ),

          icon:
              BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );

      markers.add(
        Marker(
          markerId:
              const MarkerId("destination"),

          position: LatLng(
            widget.latitude,
            widget.longitude,
          ),

          infoWindow: InfoWindow(
            title: widget.name,
          ),
        ),
      );

      // ======================
      // DRAW ROUTE
      // ======================
      setState(() {

        polylines.clear();

        polylines.add(
          Polyline(
            polylineId:
                const PolylineId("route"),

            points: routePoints,

            width: 6,

            color: Colors.blue,
          ),
        );
      });

    } catch (e) {

      print("ERROR ROUTE");
      print(e);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.name),
      ),

      body: Stack(

        children: [

          // ======================
          // GOOGLE MAP
          // ======================
          GoogleMap(

            initialCameraPosition:
                CameraPosition(

              target: LatLng(
                currentPosition!.latitude,
                currentPosition!.longitude,
              ),

              zoom: 15,
            ),

            myLocationEnabled: true,

            myLocationButtonEnabled:
                true,

            markers: markers,

            polylines: polylines,

            onMapCreated:
                (controller) {

              mapController =
                  controller;
            },
          ),

          // ======================
          // TOP INFO CARD
          // ======================
          Positioned(

            top: 10,
            left: 10,
            right: 10,

            child: Card(

              elevation: 5,

              child: Padding(

                padding:
                    const EdgeInsets.all(15),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      nextInstruction,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Jarak: ${distanceKm.toStringAsFixed(2)} km",
                    ),

                    Text(
                      "Estimasi: ${durationMin.toStringAsFixed(0)} menit",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ======================
          // VEHICLE BUTTONS
          // ======================
          Positioned(

            bottom: 20,
            left: 10,
            right: 10,

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

              children: [

                choiceButton(
                  "Jalan Kaki",
                  Icons.directions_walk,
                ),

                choiceButton(
                  "Motor",
                  Icons.motorcycle,
                ),

                choiceButton(
                  "Mobil",
                  Icons.directions_car,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // VEHICLE BUTTON
  // =========================
  Widget choiceButton(
    String title,
    IconData icon,
  ) {

    final isSelected =
        selectedVehicle == title;

    return GestureDetector(

      onTap: () async {

        setState(() {
          selectedVehicle = title;
        });

        await getRoute();
      },

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: isSelected
              ? Colors.blue
              : Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black26,
            )
          ],
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,

              color: isSelected
                  ? Colors.white
                  : Colors.black,
            ),

            const SizedBox(height: 5),

            Text(
              title,

              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    positionStream?.cancel();

    super.dispose();
  }
}

