import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminLocationPickerPage extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const AdminLocationPickerPage({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<AdminLocationPickerPage> createState() => _AdminLocationPickerPageState();
}

class _AdminLocationPickerPageState extends State<AdminLocationPickerPage> {
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    _selected = LatLng(widget.initialLatitude, widget.initialLongitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi SPBU'),
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFFBA0015),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
            onTap: (position) => setState(() => _selected = position),
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selected,
                draggable: true,
                onDragEnd: (position) => setState(() => _selected = position),
              ),
            },
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFFBA0015)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, _selected),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE21F26)),
                      child: const Text('Pakai'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
