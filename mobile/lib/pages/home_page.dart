import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../service/place_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<Place>> futurePlaces;

  @override
  void initState() {
    super.initState();

    futurePlaces = PlaceService.getPlaces();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Directory"),
      ),

      body: FutureBuilder<List<Place>>(
        future: futurePlaces,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final places = snapshot.data!;

          return ListView.builder(
            itemCount: places.length,

            itemBuilder: (context, index) {

              final place = places[index];

              return Card(
                child: ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                ),
              );
            },
          );
        },
      ),
    );
  }
}