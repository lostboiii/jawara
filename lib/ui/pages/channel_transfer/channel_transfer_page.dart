import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/metode_pembayaran_model.dart';
import '../../../router/app_router.dart';
import '../../../viewmodels/metode_pembayaran_viewmodel.dart';

class ChannelTransferPage extends StatefulWidget {
  const ChannelTransferPage({super.key});

  @override
  State<ChannelTransferPage> createState() => _ChannelTransferPageState();
}

class _ChannelTransferPageState extends State<ChannelTransferPage> {
  Future<void> _openDetail(BuildContext context,
      {MetodePembayaranModel? item}) async {
    final result = await context.push<bool>(
      AppRoutes.channelTransferDetail,
      extra: item,
    );
    if (result == true && mounted) {
      final message =
          item == null ? 'Channel ditambahkan' : 'Channel diperbarui';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MetodePembayaranModel item,
  ) async {
    final viewModel = context.read<MetodePembayaranViewModel>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Channel'),
        content: Text('Hapus metode pembayaran "${item.namaMetode}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: viewModel.isLoading
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await viewModel.deleteMetodePembayaran(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel dihapus')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  Widget _kvRow(String label, String value) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbWidget(String? path) {
    if (path == null || path.isEmpty) {
      return const SizedBox.shrink();
    }
    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          path,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32),
        ),
      );
    }
    if (kIsWeb) {
      return const Icon(Icons.image, size: 32);
    }
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.image_not_supported, size: 32);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(file, width: 56, height: 56, fit: BoxFit.cover),
    );
  }

  Widget _channelCard(MetodePembayaranModel item, int index) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Channel',
                        style: t.labelLarge?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.namaMetode,
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _thumbWidget(item.thumbnail ?? item.fotoBarcode),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('Nama Pemilik', item.namaPemilik ?? '-'),
            const Divider(height: 1),
            _kvRow('Nomor', item.nomorRekening ?? '-'),
            if ((item.catatan ?? '').isNotEmpty) ...[
              const Divider(height: 1),
              _kvRow('Catatan', item.catatan!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _openDetail(context, item: item),
                  child: const Text('Lihat Detail'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, item),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MetodePembayaranViewModel>();
    final items = viewModel.items;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Channel Transfer', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.isLoading ? null : () => _openDetail(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
      body: Stack(
        children: [
          if (!viewModel.isLoading && viewModel.errorMessage != null && items.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Terjadi kesalahan saat memuat data.\n${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  FilledButton(
                    onPressed: viewModel.loadMetodePembayaran,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            )
          else if (!viewModel.isLoading && items.isEmpty)
            Center(
              child: Text(
                'Belum ada channel transfer',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (context, index) => _channelCard(items[index], index),
            ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
