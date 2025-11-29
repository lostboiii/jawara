import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      AppRoutes.channelTransferAdd,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hapus Channel',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Hapus metode pembayaran "${item.namaMetode}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
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
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
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
    final primaryColor = const Color(0xff5067e9);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.namaMetode,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await context.push<bool>(
                        AppRoutes.channelTransferView,
                        extra: item,
                      );
                      if (result == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Channel diperbarui')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Lihat Detail',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                width: 44,
                child: IconButton(
                  onPressed: () => _confirmDelete(context, item),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MetodePembayaranViewModel>();
    final items = viewModel.items;
    final primaryColor = const Color(0xff5067e9);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Channel Transfer',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Stack(
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
                                style: GoogleFonts.inter(
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: viewModel.loadMetodePembayaran,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Coba lagi',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!viewModel.isLoading && items.isEmpty)
                      Center(
                        child: Text(
                          'Belum ada channel transfer',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.isLoading ? null : () => _openDetail(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Data',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
