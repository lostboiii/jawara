// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/kegiatan_model.dart';
import '../../../viewmodels/kegiatan_viewmodel.dart';

class KegiatanListPage extends StatelessWidget {
  const KegiatanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KegiatanViewModel>();
    final items = viewModel.items;
    final now = DateTime.now();
    final monthCount = items
        .where(
          (item) => item.tanggalKegiatan != null &&
              item.tanggalKegiatan!.month == now.month &&
              item.tanggalKegiatan!.year == now.year,
        )
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Daftar Kegiatan', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              tooltip: 'Buat Kegiatan Baru',
              onPressed: () => context.go('/kegiatan/create'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Kegiatan',
                      value: '${items.length}',
                      icon: Icons.event,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Bulan Ini',
                      value: '$monthCount',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Material(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: Colors.red[700], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.loadKegiatan,
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Center(
                                child: viewModel.isLoading
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.hourglass_empty,
                                            size: 48,
                                            color: Colors.indigo[200],
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Belum ada kegiatan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tarik ke bawah untuk menyegarkan data.',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 30,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 72,
                              headingRowColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.grey[100],
                              ),
                              columns: const [
                                DataColumn(label: Text('NO', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('NAMA', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('KATEGORI', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('TANGGAL', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('LOKASI', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('PENANGGUNG JAWAB', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: [
                                for (var i = 0; i < items.length; i++)
                                  _buildDataRow(
                                    context: context,
                                    index: i + 1,
                                    item: items[i],
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow({
    required BuildContext context,
    required int index,
    required KegiatanModel item,
  }) {
    final viewModel = context.read<KegiatanViewModel>();
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(item.namaKegiatan, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatKategori(item.kategoriKegiatan),
              style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(Text(_formatTanggal(item.tanggalKegiatan))),
        DataCell(Text(item.lokasiKegiatan ?? '-')),
        DataCell(Text(item.penanggungJawab ?? '-')),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await _confirmDelete(context, item);
                if (confirmed == true) {
                  try {
                    await viewModel.deleteKegiatan(item.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kegiatan dihapus')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus kegiatan: $e')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, KegiatanModel item) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Hapus kegiatan "${item.namaKegiatan}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  String _formatTanggal(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat('d MMM yyyy', 'id_ID').format(value);
  }

  String _formatKategori(String value) {
    switch (value) {
      case 'komunitas & sosial':
        return 'Komunitas & Sosial';
      case 'kebersihan & keamanan':
        return 'Kebersihan & Keamanan';
      case 'keagamaan':
        return 'Keagamaan';
      case 'pendidikan':
        return 'Pendidikan';
      case 'kesehatan & olahraga':
        return 'Kesehatan & Olahraga';
      default:
        return value;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
