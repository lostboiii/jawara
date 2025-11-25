// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/pengeluaran_model.dart';

class PengeluaranDetailPage extends StatelessWidget {
  final PengeluaranModel item;
  const PengeluaranDetailPage({super.key, required this.item});

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  String _formatCurrency(double value) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  ).format(value);

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

  Widget _kv(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelLarge?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(value, style: t.titleMedium?.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detail Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pengeluaran',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              _kv(context, 'Nama Pengeluaran', item.namaPengeluaran),
              _kv(context, 'Kategori', _kategoriLabel(item.kategoriPengeluaran)),
              _kv(context, 'Tanggal Transaksi', _formatDate(item.tanggalPengeluaran)),
              _kv(
                context,
                'Nominal',
                _formatCurrency(item.jumlah),
                valueColor: Colors.red[700],
              ),

              const SizedBox(height: 12),
              if (item.buktiPengeluaran != null && item.buktiPengeluaran!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bukti: ${item.buktiPengeluaran}')),
                    );
                  },
                  icon: const Icon(Icons.insert_drive_file_outlined),
                  label: const Text('Lihat Bukti'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
