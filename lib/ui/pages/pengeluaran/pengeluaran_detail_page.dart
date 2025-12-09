// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/pengeluaran_model.dart';
import '../home_page.dart';

class PengeluaranDetailPage extends StatelessWidget {
  final PengeluaranModel item;

  const PengeluaranDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 1,
      sectionBuilders: {
        1: (ctx, scope) => _buildSection(ctx, scope, item),
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    HomePageScope scope,
    PengeluaranModel item,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IconButton(
                    onPressed: () => context.goNamed('pengeluaran'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Detail Pengeluaran',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSummaryCard(item, primaryColor),
            const SizedBox(height: 20),
            _buildInfoCard(item, primaryColor),
            if (item.buktiPengeluaran != null &&
                item.buktiPengeluaran!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildBuktiCard(item, primaryColor),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(PengeluaranModel item, Color primaryColor) {
    final kategoriColor = _getKategoriColor(item.kategoriPengeluaran);
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffFF5252).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaPengeluaran,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kategoriColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: kategoriColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _kategoriLabel(item.kategoriPengeluaran),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kategoriColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.trending_down_rounded,
                  size: 32,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pengeluaran',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                currencyFormat.format(item.jumlah),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(PengeluaranModel item, Color primaryColor) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pengeluaran',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.account_balance_wallet_rounded,
            'Kategori',
            _kategoriLabel(item.kategoriPengeluaran),
            Icons.calendar_today_rounded,
            'Tanggal Transaksi',
            dateFormat.format(item.tanggalPengeluaran),
            primaryColor,
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.text_fields_rounded,
            'ID Pengeluaran',
            item.id,
            Icons.source_rounded,
            'Sumber',
            item.namaPengeluaran,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBuktiCard(PengeluaranModel item, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bukti Pengeluaran',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_rounded,
                    color: primaryColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Bukti',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        item.buktiPengeluaran ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon1,
    String label1,
    String value1,
    IconData icon2,
    String label2,
    String value2,
    Color primaryColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon1, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    label1,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon2, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    label2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value2,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const Map<String, String> _kategoriLabels = {
    'Operasional': 'Operasional',
    'Kegiatan Sosial': 'Kegiatan Sosial',
    'Pemeliharaan Fasilitas': 'Pemeliharaan Fasilitas',
    'Pembangunan': 'Pembangunan',
    'Kegiatan Warga': 'Kegiatan Warga',
    'Keamanan dan Kebersihan': 'Keamanan dan Kebersihan',
    'Lain-lain': 'Lain-lain',
  };

  static const Map<String, String> _legacyKategoriMap = {
    'operasional rt/rw': 'Operasional',
    'operasional_rt_rw': 'Operasional',
    'operasional': 'Operasional',
    'kegiatan warga': 'Kegiatan Warga',
    'kegiatan_warga': 'Kegiatan Warga',
    'kegiatan sosial': 'Kegiatan Sosial',
    'pemeliharaan fasilitas': 'Pemeliharaan Fasilitas',
    'pemeliharaan_fasilitas': 'Pemeliharaan Fasilitas',
    'pembangunan': 'Pembangunan',
    'keamanan': 'Keamanan dan Kebersihan',
    'keamanan dan kebersihan': 'Keamanan dan Kebersihan',
    'lainnya': 'Lain-lain',
    'lain lain': 'Lain-lain',
    'lain-lain': 'Lain-lain',
  };

  String _resolveKategoriValue(String value) {
    final trimmed = value.trim();
    if (_kategoriLabels.containsKey(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    final legacyMatch = _legacyKategoriMap[lower];
    if (legacyMatch != null) return legacyMatch;
    return trimmed;
  }

  String _kategoriLabel(String value) {
    final resolved = _resolveKategoriValue(value);
    return _kategoriLabels[resolved] ?? resolved;
  }

  Color _getKategoriColor(String kategori) {
    final resolved = _resolveKategoriValue(kategori).toLowerCase();
    switch (resolved) {
      case 'kegiatan warga':
        return Colors.amber;
      case 'operasional':
        return Colors.blue;
      case 'pembangunan':
        return Colors.green;
      case 'kegiatan sosial':
        return Colors.orange;
      case 'pemeliharaan fasilitas':
        return Colors.pink;
      case 'keamanan dan kebersihan':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
