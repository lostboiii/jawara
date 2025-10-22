import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'pengeluaran_page.dart' show Pengeluaran; // reuse model

class PengeluaranDetailPage extends StatelessWidget {
  final Pengeluaran item;
  const PengeluaranDetailPage({super.key, required this.item});

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  String _formatDateTime(DateTime dateTime) =>
      DateFormat('d MMM y HH:mm', 'id_ID').format(dateTime);

  String _formatCurrency(double value) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  ).format(value);

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
      appBar: AppBar(title: const Text('Detail Pengeluaran')),
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

              _kv(context, 'Nama Pengeluaran', item.nama),
              _kv(context, 'Kategori', item.jenis),
              _kv(context, 'Tanggal Transaksi', _formatDate(item.tanggal)),
              _kv(
                context,
                'Nominal',
                _formatCurrency(item.nominal),
                valueColor: Colors.red[700],
              ),
              if (item.verifiedAt != null)
                _kv(
                  context,
                  'Tanggal Terverifikasi',
                  _formatDateTime(item.verifiedAt!),
                ),
              if (item.verifier != null)
                _kv(context, 'Verifikator', item.verifier!),

              const SizedBox(height: 12),
              if (item.buktiPath != null)
                OutlinedButton.icon(
                  onPressed: () {
                    // Untuk demo: hanya menampilkan snackbar path
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bukti: ${item.buktiPath}')),
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
