import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../home_page.dart';
import '../../../viewmodels/daftar_rumah_viewmodel.dart';

class DaftarRumahPage extends StatelessWidget {
  const DaftarRumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaftarRumahViewModel>(
      create: (BuildContext context) => DaftarRumahViewModel()..loadRumah(),
      child: const _DaftarRumahContent(),
    );
  }
}

class _DaftarRumahContent extends StatelessWidget {
  const _DaftarRumahContent();

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: <int, HomeSectionBuilder>{
        2: _buildSection,
      },
    );
  }

  Widget _buildSection(BuildContext context, HomePageScope scope) {
    final Color primaryColor = scope.primaryColor;
    final DaftarRumahViewModel viewModel =
        context.watch<DaftarRumahViewModel>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadRumah,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => context.goNamed('home-warga'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Rumah',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _RumahSummaryBar(primaryColor: primaryColor),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: viewModel.searchController,
                    onChanged: viewModel.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari alamat atau status rumah',
                      hintStyle: GoogleFonts.inter(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.filter_alt_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data rumah.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: viewModel.loadRumah,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (viewModel.filteredRumah.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.home_outlined,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada rumah yang sesuai.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Periksa kata kunci pencarian atau tarik untuk memuat ulang.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ...viewModel.filteredRumah.map(
                (RumahListItem rumah) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RumahCard(rumah: rumah, primaryColor: primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RumahSummaryBar extends StatelessWidget {
  const _RumahSummaryBar({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final DaftarRumahViewModel viewModel =
        context.watch<DaftarRumahViewModel>();
    final int totalRumah = viewModel.totalRumah;
    final int totalDitempati = viewModel.totalRumahDitempati;
    final int rumahKosong = viewModel.totalRumahKosong;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryItem(
              label: 'Total Rumah',
              value: '$totalRumah',
              icon: Icons.home_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryItem(
              label: 'Rumah Ditempati',
              value: '$totalDitempati',
              icon: Icons.groups_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryItem(
              label: 'Rumah Kosong',
              value: '$rumahKosong',
              icon: Icons.door_front_door_rounded,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RumahCard extends StatelessWidget {
  const _RumahCard({required this.rumah, required this.primaryColor});

  final RumahListItem rumah;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final bool isKosong = rumah.isKosong;
    final Color badgeColor =
        isKosong ? const Color(0xffFCA311) : const Color(0xff34C759);
    final Color badgeTextColor =
        isKosong ? const Color(0xff8C5811) : const Color(0xff1F6F3D);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.home_rounded, color: primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Alamat Rumah',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rumah.alamatDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    rumah.statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.goNamed('detail-rumah', extra: rumah),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Detail',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
