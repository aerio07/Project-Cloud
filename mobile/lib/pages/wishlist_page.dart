import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../service/place_service.dart';
import '../service/wishlist_store.dart';
import 'detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(title: const Text('Wishlist'), foregroundColor: const Color(0xFFBA0015), backgroundColor: const Color(0xFFF8F9FC), elevation: 0),
        body: ValueListenableBuilder<Set<int>>(
          valueListenable: WishlistStore.ids,
          builder: (context, ids, _) => FutureBuilder<List<Place>>(
            future: PlaceService.getPlaces(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final places = snapshot.data!.where((place) => ids.contains(place.id)).toList();
              if (places.isEmpty) return const _EmptyWishlist();
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: places.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Material(color: Colors.white, borderRadius: BorderRadius.circular(16), child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFFFE9E7), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015))),
                    title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(place.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(onPressed: () => WishlistStore.toggle(place.id), icon: const Icon(Icons.favorite, color: Color(0xFFBA0015))),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(place: place))),
                  ));
                },
              );
            },
          ),
        ),
      );
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(36), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFFBA0015)), SizedBox(height: 16), Text('Wishlist masih kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Simpan SPBU favoritmu agar mudah ditemukan lagi.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280)))])));
}
