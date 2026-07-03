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
      backgroundColor: const Color(0xFFF8F9FC),
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
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _userPosition == null ? 'SPBU di Surabaya' : 'SPBU Terdekat',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF202124),
                              ),
                            ),
                          ),
                          if (snapshot.hasData)
                            Text('${filteredPlaces.length} lokasi',
                                style: const TextStyle(color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFBA0015))),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadError(onRetry: _reload),
                    )
                  else if (filteredPlaces.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('SPBU tidak ditemukan.')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList.separated(
                        itemCount: filteredPlaces.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 8),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: AuthStore.isLoggedIn,
              builder: (context, loggedIn, _) {
                final name = AuthStore.userName.value ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loggedIn ? 'Halo, $name' : 'MySPBU',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFBA0015)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('Temukan SPBU pilihanmu', style: TextStyle(color: Color(0xFF6B7280))),
                  ],
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapPage()),
              );
            },
            tooltip: 'Peta SPBU',
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            onPressed: () => _navigateToWishlist(context),
            tooltip: 'Wishlist',
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ).then((_) => setState(() {}));
            },
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ]),
      );

  void _navigateToWishlist(BuildContext context) {
    if (AuthStore.isLoggedIn.value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WishlistPage()),
      ).then((_) => setState(() {}));
    } else {
      _showLoginPrompt(context, "Wishlist");
    }
  }

  void _showLoginPrompt(BuildContext context, String featureName) {
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
                  _reload();
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

  Widget _priceInfoCard(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        child: Material(
          color: const Color(0xFFE21F26),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelPricesPage())),
            child: Stack(children: [
              const Positioned(
                right: -18,
                bottom: -22,
                child: Icon(Icons.local_gas_station_rounded, size: 150, color: Color(0x33FFFFFF)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('INFORMASI HARGA BBM', style: TextStyle(color: Color(0xFFFFDAD6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    SizedBox(height: 7),
                    Text('Cek harga BBM\nterkini', style: TextStyle(color: Colors.white, fontSize: 22, height: 1.15, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10),
                    Text('Lihat daftar harga dan jenis BBM', style: TextStyle(color: Color(0xFFFFEDEA))),
                  ])),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget _searchField() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: TextField(
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Cari SPBU terdekat...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE7BDB8))),
          ),
        ),
      );

  Widget _filterChips() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Terdekat', 'Semua', 'A–Z']
                .map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedFilter == filter,
                        label: Text(filter),
                        avatar: filter == 'Terdekat'
                            ? const Icon(Icons.near_me_rounded, size: 17)
                            : filter == 'Semua'
                                ? const Icon(Icons.filter_list_rounded, size: 17)
                                : null,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                        selectedColor: const Color(0xFFD6E3FF),
                        checkmarkColor: const Color(0xFF185EB0),
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? const Color(0xFF185EB0)
                              : const Color(0xFF5F6368),
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: _selectedFilter == filter
                              ? const Color(0xFF185EB0)
                              : const Color(0xFFE2E2E5),
                        ),
                      ),
                    ))
                .toList(),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(place: place))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFFFE9E7), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(place.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF202124)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(place.address, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.near_me_rounded, size: 17, color: Color(0xFFBA0015)),
                  const SizedBox(width: 5),
                  Text(
                    _distanceKm(place) == null
                        ? 'Mengambil lokasi perangkat...'
                        : '${_distanceKm(place)!.toStringAsFixed(1)} km dari lokasi Anda',
                    style: const TextStyle(color: Color(0xFFBA0015), fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ]),
              ])),
            ]),
          ),
        ),
      );
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFF6B7280)), const SizedBox(height: 12), const Text('Daftar SPBU belum dapat dimuat.'), const SizedBox(height: 12), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Coba lagi'))]));
}
