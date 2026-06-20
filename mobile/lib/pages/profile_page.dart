import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(title: const Text('Profil'), foregroundColor: const Color(0xFFBA0015), backgroundColor: const Color(0xFFF8F9FC), elevation: 0),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          _profileHeader(),
          const SizedBox(height: 18),
          _loyaltyCard(),
          const SizedBox(height: 22),
          _menu(Icons.person_outline_rounded, 'Edit Profil'),
          _menu(Icons.directions_car_outlined, 'Kendaraan Saya'),
          _menu(Icons.payments_outlined, 'Metode Pembayaran'),
          _menu(Icons.help_outline_rounded, 'Bantuan'),
          const SizedBox(height: 10),
          _menu(Icons.logout_rounded, 'Keluar', isDanger: true),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF3F3F6), borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Aktivitas Terakhir', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w700)), Text('Belum ada aktivitas pengisian', style: TextStyle(fontWeight: FontWeight.w700))]))])),
        ]),
      );

  Widget _profileHeader() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [CircleAvatar(radius: 34, backgroundColor: Color(0xFFFFE9E7), child: Icon(Icons.person_rounded, size: 38, color: Color(0xFFBA0015))), SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pengguna MySPBU', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), SizedBox(height: 3), Row(children: [Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB300), size: 17), SizedBox(width: 4), Text('Gold Member', style: TextStyle(color: Color(0xFF6B7280)))])]) ]));

  Widget _loyaltyCard() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFE21F26), borderRadius: BorderRadius.circular(18)), child: const Stack(children: [Positioned(right: -14, top: -18, child: Icon(Icons.stars_rounded, color: Colors.white24, size: 110)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('POIN MYPERTAMINA', style: TextStyle(color: Color(0xFFFFDAD6), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)), SizedBox(height: 7), Text('2.450', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)), SizedBox(height: 16), Divider(color: Colors.white24), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tukarkan poin dengan voucher', style: TextStyle(color: Colors.white)), Text('TUKAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])]) ]));

  Widget _menu(IconData icon, String title, {bool isDanger = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Material(color: isDanger ? const Color(0xFFFFF0EF) : Colors.white, borderRadius: BorderRadius.circular(15), child: InkWell(borderRadius: BorderRadius.circular(15), onTap: () {}, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: (isDanger ? const Color(0xFFBA0015) : const Color(0xFF185EB0)).withAlpha(18), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF185EB0))), const SizedBox(width: 14), Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF202124)))), Icon(Icons.chevron_right_rounded, color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF6B7280))])))));
}
