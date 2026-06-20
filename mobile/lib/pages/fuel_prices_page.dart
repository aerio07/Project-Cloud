import 'package:flutter/material.dart';

class FuelPricesPage extends StatelessWidget {
  const FuelPricesPage({super.key});

  static const _gasoline = [
    _Fuel('Pertalite', 'Subsidi Pemerintah', '90', 'Rp 10.000', Color(0xFF1E8E3E)),
    _Fuel('Pertamax', 'BBM Non-Subsidi', '92', 'Rp 12.950', Color(0xFF1967D2)),
    _Fuel('Pertamax Turbo', 'Performa tinggi', '98', 'Rp 14.400', Color(0xFFBA0015)),
  ];
  static const _diesel = [
    _Fuel('Dexlite', 'CN 51', 'D', 'Rp 14.550', Color(0xFF147D64)),
    _Fuel('Pertamina Dex', 'CN 53 • Ultra Low Sulfur', 'D+', 'Rp 15.100', Color(0xFF455A64)),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(title: const Text('Daftar Harga BBM'), backgroundColor: const Color(0xFFF8F9FC), foregroundColor: const Color(0xFFBA0015), elevation: 0),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
          _hero(),
          const SizedBox(height: 26),
          _section('Gasoline', const Color(0xFFBA0015)),
          ..._gasoline.map(_fuelCard),
          const SizedBox(height: 18),
          _section('Gasoil / Diesel', const Color(0xFF185EB0)),
          ..._diesel.map(_fuelCard),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7BDB8), style: BorderStyle.solid), borderRadius: BorderRadius.circular(16)), child: const Text('*Harga dapat berbeda di setiap wilayah dan SPBU. Konfirmasi harga pada SPBU tujuan sebelum melakukan pengisian.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5F6368), fontStyle: FontStyle.italic, height: 1.4))),
        ]),
      );

  Widget _hero() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: const Color(0xFFE21F26), borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          const Positioned(right: -20, bottom: -30, child: Icon(Icons.local_gas_station_rounded, size: 140, color: Color(0x33FFFFFF))),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STATUS HARGA NASIONAL', style: TextStyle(color: Color(0xFFFFDAD6), fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Informasi harga BBM', style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.info_outline, color: Colors.white, size: 16), SizedBox(width: 6), Text('Periksa pembaruan secara berkala', style: TextStyle(color: Colors.white))]),
          ]),
        ]),
      );

  Widget _section(String title, Color color) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Container(width: 4, height: 25, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))]));

  Widget _fuelCard(_Fuel fuel) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF0DAD7))),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: fuel.color.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Text(fuel.octane, style: TextStyle(color: fuel.color, fontSize: 17, fontWeight: FontWeight.w800))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(fuel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(fuel.detail, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('PER LITER', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(fuel.price, style: const TextStyle(color: Color(0xFFBA0015), fontSize: 18, fontWeight: FontWeight.w800))]),
          ])),
        ),
      );
}

class _Fuel {
  final String name;
  final String detail;
  final String octane;
  final String price;
  final Color color;
  const _Fuel(this.name, this.detail, this.octane, this.price, this.color);
}
