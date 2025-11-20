import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';

class HomeWargaPage extends StatelessWidget {
  const HomeWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: {
        2: _buildWargaSection,
      },
    );
  }

  static Widget _buildWargaSection(
    BuildContext context,
    HomePageScope scope,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => context.goNamed('home'),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Warga',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bagaimana Kabar Keluarga Hari Ini?',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                    'assets/images/dashboard-pic.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_balance_wallet,
                        size: 56,
                        color: primaryColor,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: scope.buildStatCard(
                    title: 'Total Keluarga',
                    value: '20',
                    unit: 'keluarga',
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: scope.buildStatCard(
                    title: 'Total Anggota',
                    value: '64',
                    unit: 'anggota',
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Statistik',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              children: [
                scope.buildMenuIcon(
                  icon: Icons.people_alt_rounded,
                  label: 'Keluarga',
                  onTap: () => context.goNamed('warga-daftar-keluarga'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Tambah Warga',
                  onTap: () => context.goNamed('warga-add'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.list_alt_rounded,
                  label: 'Daftar Warga',
                  onTap: () => context.goNamed('warga-daftar-warga'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.home_work_rounded,
                  label: 'Tambah Rumah',
                  onTap: () {},
                ),
                scope.buildMenuIcon(
                  icon: Icons.home_filled,
                  label: 'Daftar Rumah',
                  onTap: () {},
                ),
                scope.buildMenuIcon(
                  icon: Icons.campaign_rounded,
                  label: 'Aspirasi',
                  onTap: () {},
                ),
                scope.buildMenuIcon(
                  icon: Icons.verified_user_rounded,
                  label: 'Penerimaan Warga',
                  onTap: () {},
                ),
                scope.buildMenuIcon(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Tambah Mutasi',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Aspirasi Warga',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            scope.buildWargaAspirasiItem(
              name: 'Dafa',
              message: 'TOLONK rumah aq kemalingan kemarin malam...',
            ),
          ],
        ),
      ),
    );
  }
}
