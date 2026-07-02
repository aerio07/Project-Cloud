import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../service/wishlist_store.dart';
import 'detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          title: const Text('Wishlist Saya'),
          foregroundColor: const Color(0xFFBA0015),
          backgroundColor: const Color(0xFFF8F9FC),
          elevation: 0,
        ),
        body: ValueListenableBuilder<Set<int>>(
          valueListenable: WishlistStore.ids,
          builder: (context, ids, _) => FutureBuilder<List<Place>>(
            future: WishlistStore.getWishlistPlaces(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFBA0015)));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFBA0015)),
                        const SizedBox(height: 12),
                        Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final places = snapshot.data ?? [];
              if (places.isEmpty) return const _EmptyWishlist();

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: places.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)),
                      ),
                      title: Text(
                        place.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        place.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          final success = await WishlistStore.toggle(place.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Dihapus dari wishlist"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.favorite, color: Color(0xFFBA0015)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailPage(place: place)),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  );
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
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFFBA0015)),
              SizedBox(height: 16),
              Text('Wishlist masih kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                'Simpan SPBU favoritmu agar mudah ditemukan kembali.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
}
