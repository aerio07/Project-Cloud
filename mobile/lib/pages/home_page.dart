import 'package:flutter/material.dart';
import 'detail_page.dart';
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
        title: const Text("SPBU Surabaya"),
      ),

      body: FutureBuilder<List<Place>>(
        future: futurePlaces,

        builder: (context, snapshot) {

          print(snapshot.connectionState);

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {

            print(snapshot.error);

            return Center(
              child: Text(
                "ERROR : ${snapshot.error}",
              ),
            );
          }

          // Kosong
          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text("Data kosong"),
            );
          }

          final places = snapshot.data!;
            print(places.length);
          return ListView.builder(
            itemCount: places.length,

            itemBuilder: (context, index) {

              final place = places[index];

             return Card(
  margin: const EdgeInsets.all(10),

  child: ListTile(

    leading: const Icon(
      Icons.local_gas_station,
    ),

    title: Text(place.name),

    subtitle: Text(place.address),

    trailing: const Icon(
      Icons.arrow_forward_ios,
    ),

    onTap: () {

      Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailPage(
        place: place,
      ),
    ),
  );
    },
  ),
);
            },
          );
        },
      ),
    );
  }
}