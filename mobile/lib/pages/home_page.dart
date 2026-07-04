import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import '../service/api_config.dart';
import '../service/place_service.dart';
import '../service/auth_store.dart';
import 'detail_page.dart';
import 'fuel_prices_page.dart';
import 'profile_page.dart';
import 'wishlist_page.dart';
import 'login_page.dart';
import 'map_page.dart';

const _kFont = 'Poppins';
const _kPrimary = Color(0xFFE31E24); // Merah Pertamina
const _kPrimaryDark = Color(0xFFA50E13);
const _kBg = Color(0xFFF6F7FB); // Abu muda
const _kSurface = Colors.white;
const _kInk = Color(0xFF0F172A); // slate-900
const _kInkSoft = Color(0xFF64748B); // slate-500
const _kBorder = Color(0xFFEEF0F5);
const _kBlue = Color(0xFF1F5FBF); // Biru Pertamina
const _kGreen = Color(0xFF009B3A); // Hijau Pertamina
const _kAmber = Color(0xFFF59E0B);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Place>> _futurePlaces;
  String _query = '';
  Position? _userPosition;
  String _selectedFilter = 'Terdekat';
  String? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _futurePlaces = PlaceService.getPlaces();
    _loadUserLocation();
    _loadCategories();
  }

  void _reload() => setState(() {
        _futurePlaces = PlaceService.getPlaces();
      });

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'];
        if (mounted) {
          setState(() {
            _categories = list.map((e) => Category.fromJson(e)).toList();
          });
        }
      }
    } catch (_) {
      // Kategori opsional, tidak perlu menampilkan error
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) setState(() => _userPosition = position);
    } catch (_) {
      // Daftar SPBU tetap dapat dipakai walau lokasi perangkat tidak tersedia.
    }
  }

  double? _distanceKm(Place place) {
    final position = _userPosition;
    if (position == null) return null;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          place.latitude,
          place.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FutureBuilder<List<Place>>(
          future: _futurePlaces,
          builder: (context, snapshot) {
            final places = snapshot.data ?? <Place>[];
            final filteredPlaces = places.where((place) {
              final keyword = _query.toLowerCase();
              final matchesSearch = place.name.toLowerCase().contains(keyword) ||
                  place.address.toLowerCase().contains(keyword);
              final matchesCategory = _selectedCategory == null ||
                  (place.category != null && place.category!.name == _selectedCategory);
              return matchesSearch && matchesCategory;
            }).toList();
            if (_selectedFilter == 'Terdekat' && _userPosition != null) {
              filteredPlaces.sort((a, b) => _distanceKm(a)!.compareTo(_distanceKm(b)!));
            } else if (_selectedFilter == 'A–Z') {
              filteredPlaces.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            }

            return RefreshIndicator(
              color: _kPrimary,
              onRefresh: () async => _reload(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(context)),
                  SliverToBoxAdapter(child: _priceInfoCard(context)),
                  SliverToBoxAdapter(child: _searchField()),
                  SliverToBoxAdapter(child: _filterChips()),
                  SliverToBoxAdapter(child: _categoryChips()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _userPosition == null ? 'SPBU di Surabaya' : 'SPBU Terdekat',
                              style: const TextStyle(
                                fontFamily: _kFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _kInk,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (snapshot.hasData)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _kBorder),
                              ),
                              child: Text(
                                '${filteredPlaces.length} lokasi',
                                style: const TextStyle(
                                  fontFamily: _kFont,
                                  color: _kInkSoft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingState(),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadError(onRetry: _reload),
                    )
                  else if (filteredPlaces.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      sliver: SliverList.separated(
                        itemCount: filteredPlaces.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) => _placeCard(filteredPlaces[index]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 12, 10),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kPrimary, _kPrimaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: AuthStore.isLoggedIn,
              builder: (context, loggedIn, _) {
                final name = AuthStore.userName.value ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loggedIn ? 'Halo, $name 👋' : 'MySPBU',
                      style: const TextStyle(
                        fontFamily: _kFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Temukan SPBU pilihanmu',
                      style: TextStyle(
                        fontFamily: _kFont,
                        color: _kInkSoft,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _iconAction(
            icon: Icons.map_outlined,
            tooltip: 'Peta SPBU',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage())),
          ),
          const SizedBox(width: 6),
          _iconAction(
            icon: Icons.favorite_border_rounded,
            tooltip: 'Wishlist',
            onTap: () => _navigateToWishlist(context),
          ),
          const SizedBox(width: 6),
          _iconAction(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profil',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))
                  .then((_) => _reload());
            },
          ),
        ]),
      );

  Widget _iconAction({required IconData icon, required String tooltip, required VoidCallback onTap}) =>
      Tooltip(
        message: tooltip,
        child: Material(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Icon(icon, size: 20, color: _kInk),
            ),
          ),
        ),
      );

  void _navigateToWishlist(BuildContext context) {
    if (AuthStore.isLoggedIn.value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()))
          .then((_) => setState(() {}));
    } else {
      _showLoginPrompt(context, "Wishlist");
    }
  }

  void _showLoginPrompt(BuildContext context, String featureName) {
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
                style: TextStyle(fontFamily: _kFont, color: _kInkSoft, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))
                  .then((success) {
                if (success == true && mounted) _reload();
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

  Widget _priceInfoCard(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kPrimary, _kPrimaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const FuelPricesPage())),
              child: Stack(children: [
                Positioned(
                  right: -30,
                  bottom: -40,
                  child: Icon(
                    Icons.local_gas_station_rounded,
                    size: 170,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  right: 30,
                  top: -20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(children: [
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'INFORMASI HARGA BBM',
                          style: TextStyle(
                            fontFamily: _kFont,
                            color: Color(0xFFFFDAD6),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Cek harga BBM\nterkini',
                          style: TextStyle(
                            fontFamily: _kFont,
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Lihat daftar harga dan jenis BBM',
                          style: TextStyle(
                            fontFamily: _kFont,
                            color: Color(0xFFFFEDEA),
                            fontSize: 12.5,
                          ),
                        ),
                      ]),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );

  Widget _searchField() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            style: const TextStyle(fontFamily: _kFont, fontSize: 14, color: _kInk),
            decoration: InputDecoration(
              hintText: 'Cari SPBU terdekat...',
              hintStyle: const TextStyle(fontFamily: _kFont, color: _kInkSoft, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: _kInkSoft),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _kPrimary, width: 1.4),
              ),
            ),
          ),
        ),
      );

  Widget _filterChips() => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Terdekat', 'Semua', 'A–Z'].map((filter) {
              final selected = _selectedFilter == filter;
              final icon = filter == 'Terdekat'
                  ? Icons.near_me_rounded
                  : filter == 'Semua'
                      ? Icons.tune_rounded
                      : Icons.sort_by_alpha_rounded;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Material(
                  color: selected ? _kPrimary : _kSurface,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? _kPrimary : _kBorder,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _kPrimary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 15, color: selected ? Colors.white : _kInkSoft),
                          const SizedBox(width: 6),
                          Text(
                            filter,
                            style: TextStyle(
                              fontFamily: _kFont,
                              color: selected ? Colors.white : _kInk,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );

  Widget _categoryChips() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: _selectedCategory == null,
                label: const Text('Semua Kategori'),
                avatar: const Icon(Icons.category_rounded, size: 17),
                onSelected: (_) => setState(() => _selectedCategory = null),
                selectedColor: const Color(0xFFFFE9E7),
                checkmarkColor: const Color(0xFFBA0015),
                labelStyle: TextStyle(
                  color: _selectedCategory == null
                      ? const Color(0xFFBA0015)
                      : const Color(0xFF5F6368),
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: _selectedCategory == null
                      ? const Color(0xFFBA0015)
                      : const Color(0xFFE2E2E5),
                ),
              ),
            ),
            ..._categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == cat.name,
                    label: Text(cat.name),
                    onSelected: (_) => setState(() {
                      _selectedCategory =
                          _selectedCategory == cat.name ? null : cat.name;
                    }),
                    selectedColor: const Color(0xFFFFE9E7),
                    checkmarkColor: const Color(0xFFBA0015),
                    labelStyle: TextStyle(
                      color: _selectedCategory == cat.name
                          ? const Color(0xFFBA0015)
                          : const Color(0xFF5F6368),
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: _selectedCategory == cat.name
                          ? const Color(0xFFBA0015)
                          : const Color(0xFFE2E2E5),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _placeCard(Place place) => Material(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        elevation: 0,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            splashColor: _kPrimary.withValues(alpha: 0.06),
            highlightColor: _kPrimary.withValues(alpha: 0.04),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => DetailPage(place: place))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                place.photoUrl.isNotEmpty
                    ? Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kBorder),
                          image: DecorationImage(
                            image: NetworkImage(place.photoUrl.startsWith('http')
                                ? place.photoUrl
                                : '${ApiConfig.baseUrl}${place.photoUrl}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFF1F0), Color(0xFFFFE1DF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.local_gas_station_rounded, color: _kPrimary, size: 26),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontFamily: _kFont,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: _kAmber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                place.rating.toStringAsFixed(1),
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
                    const SizedBox(height: 6),
                    Text(
                      place.address,
                      style: const TextStyle(
                        fontFamily: _kFont,
                        color: _kInkSoft,
                        height: 1.4,
                        fontSize: 12.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 13, color: _kPrimary),
                            const SizedBox(width: 5),
                            Text(
                              _distanceKm(place) == null
                                  ? 'Mengambil lokasi...'
                                  : '${_distanceKm(place)!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontFamily: _kFont,
                                color: _kPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, size: 16, color: _kInk),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 3),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(Icons.travel_explore_rounded, size: 40, color: _kInkSoft),
            ),
            const SizedBox(height: 16),
            const Text(
              'SPBU tidak ditemukan',
              style: TextStyle(
                fontFamily: _kFont,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba kata kunci lain atau ubah filter.',
              style: TextStyle(fontFamily: _kFont, color: _kInkSoft, fontSize: 13),
            ),
          ],
        ),
      );
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
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
              child: const Icon(Icons.cloud_off_rounded, size: 40, color: _kPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daftar SPBU belum dapat dimuat',
              style: TextStyle(
                fontFamily: _kFont,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi',
                  style: TextStyle(fontFamily: _kFont, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
}