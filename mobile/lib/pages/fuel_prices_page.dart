import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import '../service/api_config.dart';

class FuelPricesPage extends StatefulWidget {
  const FuelPricesPage({super.key});

  @override
  State<FuelPricesPage> createState() => _FuelPricesPageState();
}

class _FuelPricesPageState extends State<FuelPricesPage> {
  late Future<List<Fuel>> _futureFuels;

  @override
  void initState() {
    super.initState();
    _futureFuels = _loadFuelPrices();
  }

  Future<List<Fuel>> _loadFuelPrices() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/fuels"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => Fuel.fromJson(e)).toList();
    }
    
    throw Exception("Gagal memuat harga BBM");
  }

  void _reload() {
    setState(() {
      _futureFuels = _loadFuelPrices();
    });
  }

  // Helper untuk menentukan detail deskripsi BBM berdasarkan nama
  String _getFuelDetail(Fuel fuel) {
    switch (fuel.name.toLowerCase()) {
      case 'pertalite':
        return 'Subsidi Pemerintah';
      case 'pertamax':
        return 'BBM Non-Subsidi';
      case 'pertamax turbo':
        return 'Performa tinggi';
      case 'dexlite':
        return 'CN 51';
      case 'pertamina dex':
        return 'CN 53 • Ultra Low Sulfur';
      default:
        return fuel.brand.isEmpty ? 'BBM' : 'BBM ${fuel.brand}';
    }
  }

  // Helper untuk menentukan warna BBM berdasarkan nama
  Color _getFuelColor(String name) {
    switch (name.toLowerCase()) {
      case 'pertalite':
        return const Color(0xFF1E8E3E);
      case 'pertamax':
        return const Color(0xFF1967D2);
      case 'pertamax turbo':
        return const Color(0xFFBA0015);
      case 'dexlite':
        return const Color(0xFF147D64);
      case 'pertamina dex':
        return const Color(0xFF455A64);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          title: const Text('Daftar Harga BBM'),
          backgroundColor: const Color(0xFFF8F9FC),
          foregroundColor: const Color(0xFFBA0015),
          elevation: 0,
        ),
        body: FutureBuilder<List<Fuel>>(
          future: _futureFuels,
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
                        onPressed: _reload,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final fuels = snapshot.data ?? [];
            final gasoline = fuels.where((f) => f.name.toLowerCase().contains('pertamax') || f.name.toLowerCase() == 'pertalite').toList();
            final diesel = fuels.where((f) => f.name.toLowerCase().contains('dex')).toList();
            final shownFuelIds = {...gasoline.map((f) => f.id), ...diesel.map((f) => f.id)};
            final others = fuels.where((f) => !shownFuelIds.contains(f.id)).toList();

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  _hero(),
                  const SizedBox(height: 26),
                  if (gasoline.isNotEmpty) ...[
                    _section('Gasoline', const Color(0xFFBA0015)),
                    ...gasoline.map((f) => _fuelCard(f)),
                    const SizedBox(height: 18),
                  ],
                  if (diesel.isNotEmpty) ...[
                    _section('Gasoil / Diesel', const Color(0xFF185EB0)),
                    ...diesel.map((f) => _fuelCard(f)),
                    const SizedBox(height: 24),
                  ],
                  if (others.isNotEmpty) ...[
                    _section('Lainnya', const Color(0xFF6B7280)),
                    ...others.map((f) => _fuelCard(f)),
                    const SizedBox(height: 24),
                  ],
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE7BDB8), style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '*Harga di atas merupakan harga acuan master data. Harga dapat berbeda di setiap wilayah dan SPBU.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF5F6368), fontStyle: FontStyle.italic, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _hero() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: const Color(0xFFE21F26), borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            const Positioned(
              right: -20,
              bottom: -30,
              child: Icon(Icons.local_gas_station_rounded, size: 140, color: Color(0x33FFFFFF)),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS HARGA NASIONAL',
                  style: TextStyle(color: Color(0xFFFFDAD6), fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text('Informasi harga BBM', style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Periksa pembaruan secara berkala', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _section(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(width: 4, height: 25, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          ],
        ),
      );

  Widget _fuelCard(Fuel fuel) {
    final color = _getFuelColor(fuel.name);
    final detail = _getFuelDetail(fuel);
    final title = fuel.brand.isEmpty ? fuel.name : '${fuel.brand} - ${fuel.name}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF0DAD7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fuel.octane,
                  style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(detail, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('PER LITER', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                    'Rp ${fuel.nationalPrice.round()}',
                    style: const TextStyle(color: Color(0xFFBA0015), fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
