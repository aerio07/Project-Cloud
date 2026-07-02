import 'package:flutter/material.dart';

import '../service/admin_service.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  late Future<List<Map<String, dynamic>>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _loadCategories();
  }

  Future<List<Map<String, dynamic>>> _loadCategories() async {
    final response = await AdminService.getCategories();
    final List data = response['data'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  void _reload() {
    setState(() {
      _futureCategories = _loadCategories();
    });
  }

  Future<void> _editCategory([Map<String, dynamic>? category]) async {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?['name']?.toString() ?? '');
    final iconController = TextEditingController(text: category?['icon']?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama kategori')),
              TextField(controller: iconController, decoration: const InputDecoration(labelText: 'Icon')),
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
      'name': nameController.text.trim(),
      'icon': iconController.text.trim(),
    };

    final result = isEdit
        ? await AdminService.updateCategory(category['id'] as int, payload)
        : await AdminService.createCategory(payload);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['success'] == true ? 'Kategori tersimpan.' : 'Gagal menyimpan kategori.')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Master Kategori'),
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFFBA0015),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(),
        backgroundColor: const Color(0xFFE21F26),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBA0015)));
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final categories = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    leading: const Icon(Icons.category_rounded, color: Color(0xFFBA0015)),
                    title: Text(
                      category['name']?.toString() ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(category['icon']?.toString().isNotEmpty == true ? category['icon'].toString() : 'Tanpa icon'),
                    trailing: IconButton(
                      onPressed: () => _editCategory(category),
                      icon: const Icon(Icons.edit_rounded),
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
