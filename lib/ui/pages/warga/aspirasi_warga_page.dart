import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../home_page.dart';
import '../../../viewmodels/aspirasi_warga_viewmodel.dart';
import 'edit_aspirasi_page.dart';

class AspirasiWargaPage extends StatelessWidget {
  const AspirasiWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AspirasiWargaViewModel>(
      create: (BuildContext context) =>
          AspirasiWargaViewModel()..loadAspirasi(),
      child: const _AspirasiWargaContent(),
    );
  }
}

class _AspirasiWargaContent extends StatelessWidget {
  const _AspirasiWargaContent();

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
    final AspirasiWargaViewModel viewModel =
        context.watch<AspirasiWargaViewModel>();
    final Color primaryColor = scope.primaryColor;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadAspirasi,
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
                  'Aspirasi Warga',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _AspirasiSummaryBar(primaryColor: primaryColor),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: viewModel.searchController,
                    onChanged: viewModel.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, pengirim, atau status',
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
                      'Gagal memuat aspirasi.',
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
                      onPressed: viewModel.loadAspirasi,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (viewModel.filteredAspirasi.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.mark_chat_unread_outlined,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada aspirasi yang sesuai.',
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
              ...viewModel.filteredAspirasi.map(
                (AspirasiItem item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AspirasiCard(
                    item: item,
                    primaryColor: primaryColor,
                    onEdit: () async {
                      final String? statusBaru = await Navigator.push<String>(
                        context,
                        MaterialPageRoute<String>(
                          builder: (BuildContext context) => EditAspirasiPage(
                            aspirasi: item,
                          ),
                        ),
                      );

                      if (statusBaru != null && statusBaru.isNotEmpty) {
                        viewModel.updateStatus(item.id, statusBaru);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AspirasiSummaryBar extends StatelessWidget {
  const _AspirasiSummaryBar({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final AspirasiWargaViewModel viewModel =
        context.watch<AspirasiWargaViewModel>();

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
                  label: 'Total Aspirasi',
                  value: '${viewModel.totalAspirasi}',
                  icon: Icons.mark_chat_read_rounded,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  label: 'Pending',
                  value: '${viewModel.totalPending}',
                  icon: Icons.timelapse_rounded,
                  color: const Color(0xffF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: 'Diterima',
                  value: '${viewModel.totalDiterima}',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xff22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  label: 'Ditolak',
                  value: '${viewModel.totalDitolak}',
                  icon: Icons.cancel_rounded,
                  color: const Color(0xffEF4444),
                ),
              ),
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

class _AspirasiCard extends StatelessWidget {
  const _AspirasiCard({
    required this.item,
    required this.primaryColor,
    required this.onEdit,
  });

  final AspirasiItem item;
  final Color primaryColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = item.statusColor;

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
                      item.judul,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.person_outline,
                            size: 14, color: Color(0xffA1A1A1)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.pengirim,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
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
                  item.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Icon(Icons.calendar_today,
                  size: 14, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Text(
                'Dibuat: ${item.tanggalLabel}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.edit, color: primaryColor, size: 18),
                label: Text(
                  'Edit Status',
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
