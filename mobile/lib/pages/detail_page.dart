import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_model.dart';
import 'navigation_page.dart';

class DetailPage extends StatelessWidget {

  final Place place;

  const DetailPage({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(place.name),
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // MINI MAP
            SizedBox(
              height: 250,

              child: GoogleMap(

                initialCameraPosition:
                    CameraPosition(

                  target: LatLng(
                    place.latitude,
                    place.longitude,
                  ),

                  zoom: 15,
                ),

                markers: {

                  Marker(
                    markerId:
                        MarkerId(place.id.toString()),

                    position: LatLng(
                      place.latitude,
                      place.longitude,
                    ),

                    infoWindow: InfoWindow(
                      title: place.name,
                    ),
                  ),
                },

                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // NAMA
                  Text(
                    place.name,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ALAMAT
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          place.address,

                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // DESKRIPSI
                  const Text(
                    "Deskripsi",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    place.description,

                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // BUTTON NAVIGASI
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(

                      icon: const Icon(
                        Icons.navigation,
                      ),

                      label: const Text(
                        "Navigasi ke Lokasi",
                      ),

                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),

                      onPressed: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                NavigationPage(

                              latitude:
                                  place.latitude,

                              longitude:
                                  place.longitude,

                              name: place.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}