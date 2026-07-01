import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../service/admin_service.dart';
import 'admin_location_picker_page.dart';

class AdminPlaceFormPage extends StatefulWidget {
  final Map<String, dynamic>? place;

  const AdminPlaceFormPage({super.key, this.place});

  @override
  State<AdminPlaceFormPage> createState() => _AdminPlaceFormPageState();
}

class _AdminPlaceFormPageState extends State<AdminPlaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openingHoursController = TextEditingController(text: '24 Jam');
  final _latitudeController = TextEditingController(text: '-7.257500');
  final _longitudeController = TextEditingController(text: '112.752100');

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _facilities = [];
  List<Map<String, dynamic>> _fuels = [];
  final Set<int> _selectedFacilities = {};
  final Map<int, TextEditingController> _fuelPriceControllers = {};
  final Set<int> _selectedFuels = {};

  int? _categoryId;
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.place != null;

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _fuelLabel(Map<String, dynamic> fuel) {
    final brand = fuel['brand']?.toString() ?? '';
    final name = fuel['name']?.toString() ?? '-';
    return brand.isEmpty ? name : '$brand - $name';
  }

  @override
  void initState() {
    super.initState();
    _hydratePlace();
    _loadOptions();
  }

  void _hydratePlace() {
    final place = widget.place;
    if (place == null) return;

    _nameController.text = place['name']?.toString() ?? '';
    _addressController.text = place['address']?.toString() ?? '';
    _descriptionController.text = place['description']?.toString() ?? '';
    _openingHoursController.text = place['opening_hours']?.toString() ?? '24 Jam';
    _latitudeController.text = place['latitude']?.toString() ?? '-7.257500';
    _longitudeController.text = place['longitude']?.toString() ?? '112.752100';
    final category = place['category'];
    _categoryId = _intValue(place['category_id']) ??
        (category is Map<String, dynamic> ? _intValue(category['id']) : null);

    final List facilities = place['facilities'] ?? [];
    _selectedFacilities.addAll(
      facilities
          .map<int?>((item) => item is Map<String, dynamic> ? _intValue(item['id']) : null)
          .whereType<int>(),
    );

    final List fuels = place['fuels'] ?? [];
    for (final item in fuels) {
      if (item is! Map<String, dynamic>) continue;
      final id = _intValue(item['id']);
      if (id == null) continue;
      final pivot = item['pivot'] is Map<String, dynamic> ? item['pivot'] as Map<String, dynamic> : null;
      _selectedFuels.add(id);
      _fuelPriceControllers[id] = TextEditingController(
        text: (pivot?['price'] ?? item['national_price'] ?? '').toString(),
      );
    }
  }

  Future<void> _loadOptions() async {
    try {
      final responses = await Future.wait([
        AdminService.getCategories(),
        AdminService.getFacilities(),
        AdminService.getFuels(),
      ]);

      if (!mounted) return;
      setState(() {
        _categories = (responses[0]['data'] as List? ?? []).cast<Map<String, dynamic>>();
        _facilities = (responses[1]['data'] as List? ?? []).cast<Map<String, dynamic>>();
        _fuels = (responses[2]['data'] as List? ?? []).cast<Map<String, dynamic>>();

        _categoryId ??= _categories.isNotEmpty ? _categories.first['id'] as int : null;
        for (final fuel in _fuels) {
          final id = fuel['id'] as int;
          _fuelPriceControllers.putIfAbsent(
            id,
            () => TextEditingController(text: fuel['national_price']?.toString() ?? ''),
          );
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat opsi admin: $e')));
    }
  }

  Future<void> _pickLocation() async {
    final latitude = double.tryParse(_latitudeController.text) ?? -7.2575;
    final longitude = double.tryParse(_longitudeController.text) ?? 112.7521;
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminLocationPickerPage(
          initialLatitude: latitude,
          initialLongitude: longitude,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _latitudeController.text = result.latitude.toStringAsFixed(6);
      _longitudeController.text = result.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;

    setState(() => _saving = true);

    final fuels = _selectedFuels.map((id) {
      final price = double.tryParse(_fuelPriceControllers[id]?.text.trim() ?? '');
      return {
        'fuel_id': id,
        'price': price,
        'is_available': true,
      };
    }).toList();

    final data = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'latitude': double.parse(_latitudeController.text.trim()),
      'longitude': double.parse(_longitudeController.text.trim()),
      'category_id': _categoryId,
      'description': _descriptionController.text.trim(),
      'opening_hours': _openingHoursController.text.trim(),
      'facilities': _selectedFacilities.toList(),
      'fuels': fuels,
    };

    final result = _isEdit
        ? await AdminService.updatePlace(id: widget.place!['id'] as int, data: data)
        : await AdminService.createPlace(data: data);

    if (!mounted) return;
    setState(() => _saving = false);

    if (result['success'] == true) {
      Navigator.pop(context, true);
      return;
    }

    final errors = result['errors'];
    final message = errors is Map && errors.isNotEmpty
        ? (errors.values.first as List).first.toString()
        : result['message']?.toString() ?? 'Gagal menyimpan SPBU.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E2E5)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit SPBU' : 'Tambah SPBU'),
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFFBA0015),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBA0015)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _decoration('Nama SPBU'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama SPBU wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: _decoration('Alamat'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: _decoration('Kategori'),
                    items: _categories
                        .map((category) => DropdownMenuItem<int>(
                              value: category['id'] as int,
                              child: Text(category['name']?.toString() ?? '-'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _openingHoursController,
                    decoration: _decoration('Jam buka'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _decoration('Deskripsi'),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Latitude'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Latitude tidak valid' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Longitude'),
                          validator: (value) => double.tryParse(value ?? '') == null ? 'Longitude tidak valid' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Pilih dari Google Maps'),
                  ),
                  const SizedBox(height: 22),
                  const Text('Fasilitas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _facilities.map((facility) {
                      final id = facility['id'] as int;
                      return FilterChip(
                        selected: _selectedFacilities.contains(id),
                        label: Text(facility['name']?.toString() ?? '-'),
                        onSelected: (selected) {
                          setState(() {
                            selected ? _selectedFacilities.add(id) : _selectedFacilities.remove(id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text('BBM tersedia', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ..._fuels.map((fuel) {
                    final id = fuel['id'] as int;
                    final selected = _selectedFuels.contains(id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (value) {
                              setState(() {
                                value == true ? _selectedFuels.add(id) : _selectedFuels.remove(id);
                              });
                            },
                          ),
                          Expanded(
                            child: Text(_fuelLabel(fuel)),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              enabled: selected,
                              controller: _fuelPriceControllers[id],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Harga'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE21F26),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'Menyimpan...' : 'Simpan SPBU'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _openingHoursController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final controller in _fuelPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
