import 'package:flutter/material.dart';

import '../service/admin_service.dart';
import 'admin_categories_page.dart';
import 'admin_fuel_prices_page.dart';
import 'admin_place_form_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<Map<String, dynamic>>> _futurePlaces;

  @override
  void initState() {
    super.initState();
    _futurePlaces = _loadPlaces();
  }

  Future<List<Map<String, dynamic>>> _loadPlaces() async {
    final response = await AdminService.getPlaces();
    final List data = response['data'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  void _reload() {
    setState(() {
      _futurePlaces = _loadPlaces();
    });
  }

  Future<void> _openForm([Map<String, dynamic>? place]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminPlaceFormPage(place: place)),
    );
    if (saved == true) {
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data SPBU tersimpan.')));
      }
    }
  }

  Future<void> _deletePlace(Map<String, dynamic> place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus SPBU'),
        content: Text('Hapus ${place['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFBA0015)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await AdminService.deletePlace(place['id'] as int);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['success'] == true ? 'SPBU dihapus.' : 'Gagal menghapus SPBU.')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Admin MySPBU'),
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFFBA0015),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminCategoriesPage()),
            ),
            tooltip: 'Kategori',
            icon: const Icon(Icons.category_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFuelPricesPage()),
            ),
            tooltip: 'BBM',
            icon: const Icon(Icons.local_gas_station_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFFE21F26),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah SPBU'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePlaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBA0015)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Color(0xFFBA0015), size: 42),
                    const SizedBox(height: 10),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }

          final places = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final place = places[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9E7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)),
                    ),
                    title: Text(
                      place['name']?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${place['latitude']}, ${place['longitude']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openForm(place),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => _deletePlace(place),
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBA0015)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
