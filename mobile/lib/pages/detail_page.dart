import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import '../service/api_config.dart';
import '../service/auth_store.dart';
import '../service/wishlist_store.dart';
import 'login_page.dart';
import 'navigation_page.dart';

class DetailPage extends StatefulWidget {
  final Place place;
  const DetailPage({super.key, required this.place});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Place> _futurePlace;

  // State untuk form ulasan baru
  int _selectedRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _futurePlace = _loadPlaceDetails();
  }

  Future<Place> _loadPlaceDetails() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/places/${widget.place.id}"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Place.fromJson(data['data']);
    }

    throw Exception("Gagal memuat detail SPBU");
  }

  void _reloadDetails() {
    setState(() {
      _futurePlace = _loadPlaceDetails();
    });
  }

  // Fungsi untuk toggle wishlist dengan verifikasi login
  Future<void> _handleWishlistToggle() async {
    if (!AuthStore.isLoggedIn.value) {
      _showLoginPrompt("Menyimpan SPBU Favorit");
      return;
    }

    final success = await WishlistStore.toggle(widget.place.id);
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            WishlistStore.contains(widget.place.id)
                ? "Ditambahkan ke wishlist"
                : "Dihapus dari wishlist",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Fungsi kirim ulasan ke backend
  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    
    setState(() => _isSubmittingReview = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/reviews"),
        headers: {
          'Authorization': 'Bearer ${AuthStore.token.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'place_id': widget.place.id,
          'rating': _selectedRating,
          'comment': comment,
        }),
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() => _isSubmittingReview = false);
        if (response.statusCode == 201 && data['success'] == true) {
          _commentController.clear();
          setState(() => _selectedRating = 5);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ulasan berhasil dikirim!')),
          );
          _reloadDetails(); // Muat ulang detail untuk menampilkan ulasan baru
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Gagal mengirim ulasan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal terhubung ke server: $e')),
        );
      }
    }
  }

  void _showLoginPrompt(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Diperlukan'),
        content: Text('Anda perlu masuk terlebih dahulu untuk mengakses fitur $featureName.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ).then((success) {
                if (success == true && mounted) {
                  _reloadDetails();
                }
              });
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE21F26)),
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }

  // Pemetaan icon fasilitas berdasarkan nama dari database
  IconData _getFacilityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'toilet':
        return Icons.wc_rounded;
      case 'mushola':
      case 'musholla':
        return Icons.mosque_rounded;
      case 'minimarket':
      case 'bright store':
        return Icons.storefront_rounded;
      case 'atm':
        return Icons.atm_rounded;
      case 'nitrogen':
        return Icons.tire_repair_rounded;
      case 'ev charging':
      case 'charger':
      case 'spklu':
        return Icons.ev_station_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: FutureBuilder<Place>(
        future: _futurePlace,
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
                    const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xFFBA0015)),
                    const SizedBox(height: 12),
                    Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reloadDetails,
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          final place = snapshot.data!;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: const Color(0xFFBA0015),
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE21F26), Color(0xFF7A0010)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              right: -22,
                              top: 12,
                              child: Icon(
                                Icons.local_gas_station_rounded,
                                size: 210,
                                color: Color(0x22FFFFFF),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          place.openingHours,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (place.category != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(99),
                                          ),
                                          child: Text(
                                            place.category!.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    place.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    place.address,
                                    style: const TextStyle(color: Color(0xFFFFEDEA)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      ValueListenableBuilder<Set<int>>(
                        valueListenable: WishlistStore.ids,
                        builder: (_, ids, __) => IconButton(
                          onPressed: _handleWishlistToggle,
                          icon: Icon(
                            ids.contains(place.id) ? Icons.favorite : Icons.favorite_border,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sekilas info Rating & Category
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF0DAD7)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      place.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF202124),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '(${place.reviews.length} Ulasan)',
                                style: const TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _sectionTitle('Tentang SPBU'),
                          Text(
                            place.description.isEmpty
                                ? 'Informasi SPBU ${place.name}. Menyediakan layanan pengisian BBM ramah dan berkualitas.'
                                : place.description,
                            style: const TextStyle(color: Color(0xFF5F6368), height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          // Daftar BBM yang tersedia
                          _sectionTitle('Bahan Bakar Tersedia'),
                          if (place.fuels.isEmpty)
                            const Text('Informasi BBM belum tersedia.')
                          else
                            Column(
                              children: place.fuels.map((fuel) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFF0DAD7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE9E7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          fuel.octane,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFBA0015),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fuel.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              fuel.isAvailable ? 'Tersedia' : 'Kosong',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: fuel.isAvailable ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rp ${fuel.price.round()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: Color(0xFFBA0015),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 24),

                          _sectionTitle('Fasilitas'),
                          if (place.facilities.isEmpty)
                            const Text('SPBU ini belum didaftarkan fasilitas penunjang.')
                          else
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: place.facilities.map((fac) {
                                return _Facility(
                                  _getFacilityIcon(fac.name),
                                  fac.name,
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 25),

                          _sectionTitle('Lokasi'),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 180,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(place.latitude, place.longitude),
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(place.id.toString()),
                                    position: LatLng(place.latitude, place.longitude),
                                    infoWindow: InfoWindow(title: place.name),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          _sectionTitle('Ulasan & Rating'),
                          // Formulir Tulis Ulasan
                          ValueListenableBuilder<bool>(
                            valueListenable: AuthStore.isLoggedIn,
                            builder: (context, loggedIn, _) {
                              if (!loggedIn) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E2E5)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Punya pengalaman di SPBU ini? Tulis ulasanmu!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () => _showLoginPrompt("Menulis Ulasan"),
                                        icon: const Icon(Icons.login),
                                        label: const Text('Masuk untuk Mengulas'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFBA0015),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFF0DAD7)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Berikan Rating & Ulasan Anda',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        final starIndex = index + 1;
                                        return IconButton(
                                          onPressed: () => setState(() => _selectedRating = starIndex),
                                          icon: Icon(
                                            _selectedRating >= starIndex
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _commentController,
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        hintText: 'Tulis komentar Anda di sini...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE2E2E5)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFBA0015)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _isSubmittingReview ? null : _submitReview,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFFBA0015),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: _isSubmittingReview
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text('Kirim Ulasan'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),

                          // Daftar Ulasan SPBU
                          if (place.reviews.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Belum ada ulasan. Jadilah yang pertama memberikan ulasan!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: place.reviews.map((review) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _Review(
                                    name: review.userName,
                                    rating: review.rating.toDouble().toStringAsFixed(1),
                                    text: review.comment,
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        ValueListenableBuilder<Set<int>>(
                          valueListenable: WishlistStore.ids,
                          builder: (_, ids, __) => IconButton.filledTonal(
                            onPressed: _handleWishlistToggle,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE9E7),
                              foregroundColor: const Color(0xFFBA0015),
                            ),
                            icon: Icon(
                              ids.contains(place.id) ? Icons.favorite : Icons.favorite_border,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NavigationPage(
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                  name: place.name,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.directions_rounded),
                            label: const Text('Mulai Navigasi'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE21F26),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _Facility extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Facility(this.icon, this.label);
  
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF185EB0)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}

class _Review extends StatelessWidget {
  final String name;
  final String rating;
  final String text;
  const _Review({required this.name, required this.rating, required this.text});
  
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                Text(' $rating'),
              ],
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(color: Color(0xFF5F6368)),
              ),
            ],
          ],
        ),
      );
}
