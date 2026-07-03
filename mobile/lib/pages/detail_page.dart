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

const _kFont = 'Poppins';
const _kPrimary = Color(0xFFE31E24);
const _kPrimaryDark = Color(0xFFA50E13);
const _kBg = Color(0xFFF6F7FB);
const _kSurface = Colors.white;
const _kInk = Color(0xFF0F172A);
const _kInkSoft = Color(0xFF64748B);
const _kBorder = Color(0xFFEEF0F5);
const _kBlue = Color(0xFF1F5FBF);
const _kGreen = Color(0xFF009B3A);
const _kAmber = Color(0xFFF59E0B);

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
            style: const TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _kInk,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
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
            SnackBar(
              content: const Text('Ulasan berhasil dikirim!',
                  style: TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w600)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: _kGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          _reloadDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Gagal mengirim ulasan',
                  style: const TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w600)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: _kInk,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal terhubung ke server: $e',
                style: const TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _kInk,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showLoginPrompt(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Login Diperlukan',
          style: TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w700, color: _kInk),
        ),
        content: Text(
          'Anda perlu masuk terlebih dahulu untuk mengakses fitur $featureName.',
          style: const TextStyle(fontFamily: _kFont, color: _kInkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(
                    fontFamily: _kFont, color: _kInkSoft, fontWeight: FontWeight.w600)),
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
            style: FilledButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Masuk',
                style: TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w700)),
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
      backgroundColor: _kBg,
      body: FutureBuilder<Place>(
        future: _futurePlace,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 3),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.cloud_off_rounded,
                          size: 40, color: _kPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: _kFont,
                        fontWeight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _reloadDetails,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Muat Ulang',
                          style: TextStyle(
                              fontFamily: _kFont, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
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
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.maybePop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_kPrimary, _kPrimaryDark],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -32,
                              top: 20,
                              child: Icon(
                                Icons.local_gas_station_rounded,
                                size: 230,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            Positioned(
                              left: -30,
                              bottom: -30,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 22,
                              right: 22,
                              bottom: 30,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _kGreen,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              place.openingHours,
                                              style: const TextStyle(
                                                fontFamily: _kFont,
                                                color: Colors.white,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (place.category != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.35)),
                                          ),
                                          child: Text(
                                            place.category!.name,
                                            style: const TextStyle(
                                              fontFamily: _kFont,
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontFamily: _kFont,
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.6,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.location_on_rounded,
                                          size: 15,
                                          color:
                                              Colors.white.withValues(alpha: 0.85)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          place.address,
                                          style: TextStyle(
                                            fontFamily: _kFont,
                                            color:
                                                Colors.white.withValues(alpha: 0.9),
                                            fontSize: 12.5,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ValueListenableBuilder<Set<int>>(
                          valueListenable: WishlistStore.ids,
                          builder: (_, ids, __) {
                            final saved = ids.contains(place.id);
                            return Material(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _handleWishlistToggle,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    saved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
                        decoration: const BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating summary card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _kBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7E6),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.star_rounded,
                                        color: _kAmber, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              place.rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontFamily: _kFont,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: _kInk,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const Text(
                                              '/5',
                                              style: TextStyle(
                                                fontFamily: _kFont,
                                                fontSize: 13,
                                                color: _kInkSoft,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${place.reviews.length} ulasan pengguna',
                                          style: const TextStyle(
                                            fontFamily: _kFont,
                                            color: _kInkSoft,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),

                            _sectionTitle('Tentang SPBU'),
                            Text(
                              place.description.isEmpty
                                  ? 'Informasi SPBU ${place.name}. Menyediakan layanan pengisian BBM ramah dan berkualitas.'
                                  : place.description,
                              style: const TextStyle(
                                fontFamily: _kFont,
                                color: _kInkSoft,
                                height: 1.6,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 26),

                            // Daftar BBM yang tersedia
                            _sectionTitle('Bahan Bakar Tersedia'),
                            if (place.fuels.isEmpty)
                              _emptyBox('Informasi BBM belum tersedia.')
                            else
                              Column(
                                children: place.fuels.map((fuel) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _kSurface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: _kBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFFE1DF),
                                                Color(0xFFFFCECB)
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            fuel.octane,
                                            style: const TextStyle(
                                              fontFamily: _kFont,
                                              fontWeight: FontWeight.w800,
                                              color: _kPrimary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fuel.brand.isEmpty
                                                    ? fuel.name
                                                    : '${fuel.brand} - ${fuel.name}',
                                                style: const TextStyle(
                                                  fontFamily: _kFont,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: _kInk,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: fuel.isAvailable
                                                          ? _kGreen
                                                          : _kPrimary,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    fuel.isAvailable
                                                        ? 'Tersedia'
                                                        : 'Kosong',
                                                    style: TextStyle(
                                                      fontFamily: _kFont,
                                                      fontSize: 11.5,
                                                      color: fuel.isAvailable
                                                          ? _kGreen
                                                          : _kPrimary,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Rp ${fuel.price.round()}',
                                          style: const TextStyle(
                                            fontFamily: _kFont,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: _kPrimary,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 26),

                            _sectionTitle('Fasilitas'),
                            if (place.facilities.isEmpty)
                              _emptyBox(
                                  'SPBU ini belum didaftarkan fasilitas penunjang.')
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
                            const SizedBox(height: 28),

                            _sectionTitle('Lokasi'),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _kBorder),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(19),
                                child: SizedBox(
                                  height: 190,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target:
                                          LatLng(place.latitude, place.longitude),
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId(place.id.toString()),
                                        position: LatLng(
                                            place.latitude, place.longitude),
                                        infoWindow: InfoWindow(title: place.name),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                    mapToolbarEnabled: false,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            _sectionTitle('Ulasan & Rating'),
                            // Formulir Tulis Ulasan
                            ValueListenableBuilder<bool>(
                              valueListenable: AuthStore.isLoggedIn,
                              builder: (context, loggedIn, _) {
                                if (!loggedIn) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: _kSurface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _kBorder),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                _kPrimary.withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(Icons.rate_review_rounded,
                                              color: _kPrimary),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Punya pengalaman di SPBU ini?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: _kFont,
                                            fontWeight: FontWeight.w700,
                                            color: _kInk,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Masuk untuk memberikan ulasan Anda.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: _kFont,
                                            color: _kInkSoft,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.icon(
                                            onPressed: () =>
                                                _showLoginPrompt("Menulis Ulasan"),
                                            icon: const Icon(Icons.login_rounded,
                                                size: 18),
                                            label: const Text(
                                              'Masuk untuk Mengulas',
                                              style: TextStyle(
                                                fontFamily: _kFont,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: _kPrimary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: _kSurface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _kBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Berikan Rating & Ulasan Anda',
                                        style: TextStyle(
                                          fontFamily: _kFont,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          color: _kInk,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: List.generate(5, (index) {
                                          final starIndex = index + 1;
                                          final active =
                                              _selectedRating >= starIndex;
                                          return IconButton(
                                            splashRadius: 22,
                                            onPressed: () => setState(
                                                () => _selectedRating = starIndex),
                                            icon: Icon(
                                              active
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              color: active ? _kAmber : _kInkSoft,
                                              size: 32,
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _commentController,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            fontFamily: _kFont, color: _kInk),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Tulis komentar Anda di sini...',
                                          hintStyle: const TextStyle(
                                              fontFamily: _kFont,
                                              color: _kInkSoft,
                                              fontSize: 13),
                                          filled: true,
                                          fillColor: _kBg,
                                          contentPadding: const EdgeInsets.all(14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide:
                                                const BorderSide(color: _kBorder),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: const BorderSide(
                                                color: _kPrimary, width: 1.4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: const LinearGradient(
                                              colors: [_kPrimary, _kPrimaryDark],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: FilledButton(
                                            onPressed: _isSubmittingReview
                                                ? null
                                                : _submitReview,
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: _isSubmittingReview
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.4,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Kirim Ulasan',
                                                    style: TextStyle(
                                                      fontFamily: _kFont,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Daftar Ulasan SPBU
                            if (place.reviews.isEmpty)
                              _emptyBox(
                                  'Belum ada ulasan. Jadilah yang pertama memberikan ulasan!')
                            else
                              Column(
                                children: place.reviews.map((review) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _Review(
                                      name: review.userName,
                                      rating: review.rating
                                          .toDouble()
                                          .toStringAsFixed(1),
                                      text: review.comment,
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom action bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      border: const Border(
                        top: BorderSide(color: _kBorder),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 22,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ValueListenableBuilder<Set<int>>(
                          valueListenable: WishlistStore.ids,
                          builder: (_, ids, __) {
                            final saved = ids.contains(place.id);
                            return Material(
                              color: saved
                                  ? _kPrimary.withValues(alpha: 0.10)
                                  : _kBg,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _handleWishlistToggle,
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: saved
                                          ? _kPrimary.withValues(alpha: 0.30)
                                          : _kBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    saved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: _kPrimary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [_kPrimary, _kPrimaryDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kPrimary.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
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
                                icon: const Icon(Icons.directions_rounded,
                                    color: Colors.white),
                                label: const Text('Mulai Navigasi',
                                    style: TextStyle(
                                      fontFamily: _kFont,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    )),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
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
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimary, _kPrimaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: _kFont,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kInk,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );

  Widget _emptyBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: _kFont,
            color: _kInkSoft,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
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
        width: 76,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kBorder),
              ),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kBlue, size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _kFont,
                fontSize: 11.5,
                color: _kInk,
                fontWeight: FontWeight.w600,
              ),
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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _initial(name),
                      style: const TextStyle(
                        fontFamily: _kFont,
                        color: _kPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: _kAmber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontFamily: _kFont,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A5B00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: _kFont,
                  color: _kInkSoft,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      );

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
