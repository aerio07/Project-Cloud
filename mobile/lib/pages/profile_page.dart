import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../service/auth_store.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fungsi logout
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFBA0015)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.logout();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda berhasil keluar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        foregroundColor: const Color(0xFFBA0015),
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AuthStore.isLoggedIn,
        builder: (context, loggedIn, _) {
          final name = AuthStore.userName.value ?? 'Tamu MySPBU';
          final email = AuthStore.userEmail.value ?? 'Silakan masuk untuk akses penuh';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _profileHeader(name, email, loggedIn),
              const SizedBox(height: 18),
              if (loggedIn) ...[
                _loyaltyCard(),
                const SizedBox(height: 22),
                _menu(Icons.person_outline_rounded, 'Edit Profil', onTap: () {}),
                _menu(Icons.directions_car_outlined, 'Kendaraan Saya', onTap: () {}),
                _menu(Icons.payments_outlined, 'Metode Pembayaran', onTap: () {}),
                _menu(Icons.help_outline_rounded, 'Bantuan', onTap: () {}),
                const SizedBox(height: 10),
                _menu(Icons.logout_rounded, 'Keluar dari Akun', isDanger: true, onTap: _handleLogout),
              ] else ...[
                _loginCard(),
                const SizedBox(height: 22),
                _menu(Icons.help_outline_rounded, 'Bantuan', onTap: () {}),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF3F3F6), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.local_gas_station_rounded, color: Color(0xFFBA0015)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktivitas Terakhir',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Belum ada aktivitas pengisian',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(String name, String subtitle, bool loggedIn) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFFFE9E7),
              child: Icon(Icons.person_rounded, size: 38, color: Color(0xFFBA0015)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (loggedIn)
                    const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB300), size: 17),
                        SizedBox(width: 4),
                        Text('Gold Member', style: TextStyle(color: Color(0xFF6B7280))),
                      ],
                    )
                  else
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _loyaltyCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFE21F26), borderRadius: BorderRadius.circular(18)),
        child: const Stack(
          children: [
            Positioned(right: -14, top: -18, child: Icon(Icons.stars_rounded, color: Colors.white24, size: 110)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POIN MYPERTAMINA',
                  style: TextStyle(color: Color(0xFFFFDAD6), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
                ),
                SizedBox(height: 7),
                Text('2.450', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                SizedBox(height: 16),
                Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tukarkan poin dengan voucher', style: TextStyle(color: Colors.white)),
                    Text('TUKAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _loginCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFE21F26), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MASUK KE AKUN',
              style: TextStyle(color: Color(0xFFFFDAD6), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nikmati semua keuntungan dengan mendaftar di MySPBU!',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ).then((success) {
                    if (success == true && mounted) {
                      setState(() {});
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFBA0015),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _menu(IconData icon, String title, {bool isDanger = false, required VoidCallback onTap}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: isDanger ? const Color(0xFFFFF0EF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isDanger ? const Color(0xFFBA0015) : const Color(0xFF185EB0)).withAlpha(18),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF185EB0)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF202124),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDanger ? const Color(0xFFBA0015) : const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
