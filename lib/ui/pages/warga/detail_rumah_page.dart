import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../home_page.dart';
import '../../../viewmodels/daftar_rumah_viewmodel.dart';

class DetailRumahPage extends StatelessWidget {
  const DetailRumahPage({super.key, required this.rumah});

  final RumahListItem rumah;

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: <int, HomeSectionBuilder>{
        2: (BuildContext context, HomePageScope scope) =>
            _buildSection(context, scope),
      },
    );
  }

  Widget _buildSection(BuildContext context, HomePageScope scope) {
    final Color primaryColor = scope.primaryColor;
    final List<PenghuniHistoryItem> history = rumah.riwayatPenghuni;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => context.goNamed('daftar-rumah'),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detail Rumah',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(primaryColor),
          const SizedBox(height: 24),
          Text(
            'Riwayat Penghuni',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            _buildEmptyHistory(primaryColor)
          else
            _buildHistoryCards(history, primaryColor),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color primaryColor) {
    final bool isKosong = rumah.isKosong;
    final Color badgeColor =
        isKosong ? const Color(0xffFCA311) : const Color(0xff34C759);
    final Color badgeTextColor =
        isKosong ? const Color(0xff8C5811) : const Color(0xff1F6F3D);

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Alamat Rumah',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text(
                'Status',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ],
      ),
    );
  }

  Widget _buildHistoryCards(
    List<PenghuniHistoryItem> history,
    Color primaryColor,
  ) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');
    final List<PenghuniHistoryItem> sortedHistory =
        List<PenghuniHistoryItem>.from(history)
          ..sort((PenghuniHistoryItem a, PenghuniHistoryItem b) =>
              b.tanggalMasuk.compareTo(a.tanggalMasuk));

    return Column(
      children: sortedHistory.map((PenghuniHistoryItem item) {
        final bool masihTinggal = item.masihTinggal;
        final String tanggalMasuk = dateFormat.format(item.tanggalMasuk);
        final String tanggalKeluar = masihTinggal
            ? 'Masih Tinggal'
            : dateFormat.format(item.tanggalKeluar!);
        final Color badgeColor =
            masihTinggal ? const Color(0xff34C759) : const Color(0xffA1A1A1);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kepala keluarga: ${item.kepalaKeluarga}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
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
                      masihTinggal ? 'Aktif' : 'Selesai',
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
                  Icon(Icons.login_rounded, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masuk: $tanggalMasuk',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Icon(Icons.logout_rounded,
                      size: 18,
                      color: masihTinggal
                          ? Colors.grey.shade400
                          : const Color(0xffC62828)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keluar: $tanggalKeluar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: masihTinggal ? Colors.black45 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyHistory(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.info_outline, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Belum ada riwayat penghuni.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan penghuni baru ketika rumah mulai ditempati.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
