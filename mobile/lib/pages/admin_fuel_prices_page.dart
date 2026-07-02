import 'package:flutter/material.dart';

import '../service/admin_service.dart';

class AdminFuelPricesPage extends StatefulWidget {
  const AdminFuelPricesPage({super.key});

  @override
  State<AdminFuelPricesPage> createState() => _AdminFuelPricesPageState();
}

class _AdminFuelPricesPageState extends State<AdminFuelPricesPage> {
  late Future<List<Map<String, dynamic>>> _futureFuels;

  @override
  void initState() {
    super.initState();
    _futureFuels = _loadFuels();
  }

  Future<List<Map<String, dynamic>>> _loadFuels() async {
    final response = await AdminService.getFuels();
    final List data = response['data'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  void _reload() {
    setState(() {
      _futureFuels = _loadFuels();
    });
  }

  Future<void> _editFuel([Map<String, dynamic>? fuel]) async {
    final isEdit = fuel != null;
    final brandController = TextEditingController(text: fuel?['brand']?.toString() ?? '');
    final nameController = TextEditingController(text: fuel?['name']?.toString() ?? '');
    final octaneController = TextEditingController(text: fuel?['octane']?.toString() ?? '');
    final priceController = TextEditingController(text: fuel?['national_price']?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit BBM' : 'Tambah BBM'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand')),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama BBM')),
              TextField(controller: octaneController, decoration: const InputDecoration(labelText: 'RON/CN')),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga nasional'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (saved != true) return;

    final payload = {
      'brand': brandController.text.trim(),
      'name': nameController.text.trim(),
      'octane': octaneController.text.trim(),
      'national_price': double.tryParse(priceController.text.trim()) ?? 0,
    };

    final result = isEdit
        ? await AdminService.updateFuel(fuel['id'] as int, payload)
        : await AdminService.createFuel(payload);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['success'] == true ? 'Data BBM tersimpan.' : 'Gagal menyimpan BBM.')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Master BBM'),
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFFBA0015),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editFuel(),
        backgroundColor: const Color(0xFFE21F26),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah BBM'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureFuels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBA0015)));
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final fuels = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: fuels.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final fuel = fuels[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    title: Text(
                      fuel['name']?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${fuel['brand'] ?? 'Tanpa brand'} - RON/CN ${fuel['octane'] ?? '-'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rp ${fuel['national_price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: () => _editFuel(fuel),
                          icon: const Icon(Icons.edit_rounded),
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
