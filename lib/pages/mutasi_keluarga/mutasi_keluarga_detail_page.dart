import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mutasi_keluarga_page.dart' show MutasiKeluargaItem;

class MutasiKeluargaDetailPage extends StatelessWidget {
  final MutasiKeluargaItem item;
  const MutasiKeluargaDetailPage({super.key, required this.item});

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

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
      appBar: AppBar(title: const Text('Detail Mutasi Keluarga')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Mutasi Keluarga',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              _kv(context, 'Keluarga', item.keluarga),
              _kv(context, 'Alamat Lama', item.alamatLama),
              _kv(context, 'Alamat Baru', item.alamatBaru),
              _kv(context, 'Tanggal Mutasi', _formatDate(item.tanggal)),
              _kv(context, 'Jenis Mutasi', item.jenis),
              _kv(context, 'Alasan', item.alasan.isEmpty ? '-' : item.alasan),
            ],
          ),
        ),
      ),
    );
  }
}
