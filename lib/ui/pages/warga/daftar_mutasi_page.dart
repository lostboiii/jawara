import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../home_page.dart';
import '../../../viewmodels/mutasi_warga_viewmodel.dart';
import 'detail_mutasi_page.dart';

class DaftarMutasiPage extends StatelessWidget {
  const DaftarMutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MutasiWargaViewModel>(
      create: (BuildContext context) => MutasiWargaViewModel()..loadMutasi(),
      child: const _DaftarMutasiContent(),
    );
  }
}

class _DaftarMutasiContent extends StatelessWidget {
  const _DaftarMutasiContent();

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
    final MutasiWargaViewModel viewModel =
        context.watch<MutasiWargaViewModel>();
    final Color primaryColor = scope.primaryColor;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadMutasi,
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
                  'Daftar Mutasi',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _MutasiSummaryBar(primaryColor: primaryColor),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: viewModel.searchController,
                    onChanged: viewModel.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari keluarga, jenis mutasi, atau alasan',
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
                  child: const Icon(Icons.filter_alt_rounded, color: Colors.white),
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
                      'Gagal memuat data mutasi.',
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
                      onPressed: viewModel.loadMutasi,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (viewModel.filteredMutasi.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.swap_horiz_rounded,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada mutasi yang sesuai.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Periksa kata kunci pencarian atau tarik untuk memuat ulang.',
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ...viewModel.filteredMutasi.map(
                (MutasiItem item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _MutasiCard(
                    item: item,
                    primaryColor: primaryColor,
                    onDetail: () => Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => DetailMutasiPage(
                          mutasi: item,
                        ),
                      ),
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

class _MutasiSummaryBar extends StatelessWidget {
  const _MutasiSummaryBar({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final MutasiWargaViewModel viewModel =
        context.watch<MutasiWargaViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: 'Total Mutasi',
                  value: '${viewModel.totalMutasi}',
                  icon: Icons.swap_horiz_rounded,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  label: 'Pindah Rumah',
                  value: '${viewModel.totalDatang}',
                  icon: Icons.login_rounded,
                  color: const Color(0xff22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: 'Keluar Perumahan',
                  value: '${viewModel.totalPergi}',
                  icon: Icons.logout_rounded,
                  color: const Color(0xffEF4444),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
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
              color: color.withOpacity(0.12),
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

class _MutasiCard extends StatelessWidget {
  const _MutasiCard({
    required this.item,
    required this.primaryColor,
    required this.onDetail,
  });

  final MutasiItem item;
  final Color primaryColor;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = item.jenisColor;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.keluarga,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today,
                            size: 14, color: Color(0xffA1A1A1)),
                        const SizedBox(width: 4),
                        Text(
                          item.tanggalLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.jenisLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.alasan,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onDetail,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.visibility, color: primaryColor, size: 18),
                label: Text(
                  'Detail',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
