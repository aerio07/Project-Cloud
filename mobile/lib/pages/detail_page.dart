import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_model.dart';
import '../service/wishlist_store.dart';
import 'navigation_page.dart';

class DetailPage extends StatefulWidget {
  final Place place;
  const DetailPage({super.key, required this.place});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Place get place => widget.place;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        body: Stack(children: [
          CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: const Color(0xFFBA0015),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE21F26), Color(0xFF7A0010)])),
                  child: Stack(children: [
                    const Positioned(right: -22, top: 12, child: Icon(Icons.local_gas_station_rounded, size: 210, color: Color(0x22FFFFFF))),
                    Positioned(left: 20, right: 20, bottom: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(99)), child: const Text('Buka 24 Jam', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                      const SizedBox(height: 9),
                      Text(place.name, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(place.address, style: const TextStyle(color: Color(0xFFFFEDEA)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                ),
              ),
              actions: [ValueListenableBuilder<Set<int>>(valueListenable: WishlistStore.ids, builder: (_, ids, __) => IconButton(onPressed: () => WishlistStore.toggle(place.id), icon: Icon(ids.contains(place.id) ? Icons.favorite : Icons.favorite_border)))],
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 110), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Tentang SPBU'),
              Text(place.description.isEmpty ? 'Informasi SPBU ${place.name}. Tersedia layanan pengisian bahan bakar untuk perjalanan Anda.' : place.description, style: const TextStyle(color: Color(0xFF5F6368), height: 1.5)),
              const SizedBox(height: 24),
              _sectionTitle('Fasilitas'),
              Wrap(spacing: 12, runSpacing: 12, children: const [_Facility(Icons.wc_rounded, 'Toilet'), _Facility(Icons.mosque_rounded, 'Mushola'), _Facility(Icons.storefront_rounded, 'Minimarket'), _Facility(Icons.atm_rounded, 'ATM'), _Facility(Icons.tire_repair_rounded, 'Nitrogen')]),
              const SizedBox(height: 25),
              _sectionTitle('Lokasi'),
              ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 180, child: GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(place.latitude, place.longitude), zoom: 15), markers: {Marker(markerId: MarkerId(place.id.toString()), position: LatLng(place.latitude, place.longitude), infoWindow: InfoWindow(title: place.name))}, zoomControlsEnabled: false, myLocationButtonEnabled: false, mapToolbarEnabled: false))),
              const SizedBox(height: 25),
              _sectionTitle('Ulasan & Rating'),
              const _Review(name: 'Budi Santoso', rating: '5.0', text: 'Tempatnya bersih dan pelayanannya cepat. Sangat direkomendasikan!'),
              const SizedBox(height: 10),
              const _Review(name: 'Siti Aminah', rating: '4.0', text: 'Fasilitas lengkap, nyaman untuk berhenti sejenak.'),
            ]))),
          ]),
          Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(18, 12, 18, 12), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Row(children: [
            ValueListenableBuilder<Set<int>>(valueListenable: WishlistStore.ids, builder: (_, ids, __) => IconButton.filledTonal(onPressed: () => WishlistStore.toggle(place.id), style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFE9E7), foregroundColor: const Color(0xFFBA0015)), icon: Icon(ids.contains(place.id) ? Icons.favorite : Icons.favorite_border))),
            const SizedBox(width: 12), Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NavigationPage(latitude: place.latitude, longitude: place.longitude, name: place.name))), icon: const Icon(Icons.directions_rounded), label: const Text('Mulai Navigasi'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE21F26), padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontWeight: FontWeight.w800))))
          ])))),
        ]),
      );

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)));
}

class _Facility extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Facility(this.icon, this.label);
  @override
  Widget build(BuildContext context) => SizedBox(width: 70, child: Column(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF185EB0))), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)))]));
}

class _Review extends StatelessWidget {
  final String name;
  final String rating;
  final String text;
  const _Review({required this.name, required this.rating, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.star_rounded, color: Color(0xFFBA0015), size: 18), Text(' $rating')]), const SizedBox(height: 6), Text(text, style: const TextStyle(color: Color(0xFF5F6368)))]));
}
