import 'package:flutter/material.dart';

import 'home_page.dart';

const _kFont = 'Poppins';
const _kPrimary = Color(0xFFE31E24);
const _kPrimaryDark = Color(0xFFA50E13);
const _kPrimarySoft = Color(0xFFFFECEC);
const _kBg = Color(0xFFFAF7F7);
const _kInk = Color(0xFF0F172A);
const _kInkSoft = Color(0xFF64748B);
const _kBorder = Color(0xFFF1E9E9);

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const List<_Feature> _features = [
    _Feature(
      icon: Icons.location_on_rounded,
      title: 'Cari SPBU Terdekat',
      subtitle: 'Temukan SPBU di sekitarmu dengan cepat.',
    ),
    _Feature(
      icon: Icons.local_gas_station_rounded,
      title: 'Info Harga BBM',
      subtitle: 'Update harga BBM terbaru setiap saat.',
    ),
    _Feature(
      icon: Icons.favorite_rounded,
      title: 'SPBU Favorit',
      subtitle: 'Simpan SPBU langgananmu sekali klik.',
    ),
    _Feature(
      icon: Icons.rate_review_rounded,
      title: 'Ulasan Pengguna',
      subtitle: 'Bagikan pengalaman & baca review lainnya.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ===== Hero card (bukan full header seperti login) =====
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_kPrimary, _kPrimaryDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _kPrimary.withValues(alpha: 0.28),
                                blurRadius: 26,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Decorative badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.28),
                                  ),
                                ),
                                child: const Text(
                                  'MULAI PERJALANANMU',
                                  style: TextStyle(
                                    fontFamily: _kFont,
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.16),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.32),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_gas_station_rounded,
                                  color: Colors.white,
                                  size: 52,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Selamat Datang di MySPBU',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: _kFont,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Semua kebutuhan SPBU-mu\ndalam satu genggaman.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: _kFont,
                                  color:
                                      Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13.5,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ===== Feature list =====
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 4, top: 8, bottom: 12),
                              child: Text(
                                'Apa yang bisa kamu lakukan?',
                                style: TextStyle(
                                  fontFamily: _kFont,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _kInk,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            for (final f in _features)
                              _FeatureTile(feature: f),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ===== CTA button =====
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [_kPrimary, _kPrimaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      _kPrimary.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Mulai',
                                    style: TextStyle(
                                      fontFamily: _kFont,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 14, top: 4),
                        child: Text(
                          'MySPBU v1.0',
                          style: TextStyle(
                            color: _kInkSoft,
                            fontFamily: _kFont,
                            fontSize: 11.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kPrimarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: _kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kInk,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.subtitle,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontSize: 12,
                    color: _kInkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: _kInkSoft,
            size: 14,
          ),
        ],
      ),
    );
  }
}
