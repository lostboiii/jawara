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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MetodePembayaranViewModel>().loadMetodePembayaran();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<MetodePembayaranViewModel>().loadMetodePembayaran();
  }

  List<MetodePembayaranModel> _getFilteredItems(
      List<MetodePembayaranModel> items) {
    var filtered = List<MetodePembayaranModel>.from(items);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((item) {
        final namaMatch = item.namaMetode.toLowerCase().contains(query);
        final nomorMatch =
            (item.nomorRekening ?? '').toLowerCase().contains(query);
        final pemilikMatch =
            (item.namaPemilik ?? '').toLowerCase().contains(query);
        return namaMatch || nomorMatch || pemilikMatch;
      }).toList();
    }

    return filtered;
  }

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
        title: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Hapus Channel?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus metode pembayaran "${item.namaMetode}"? Data yang dihapus tidak dapat dikembalikan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                ),
              ),
            ],
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
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 32),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaMetode,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.namaPemilik ?? 'Pemilik tidak diketahui',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _thumbWidget(item.thumbnail ?? item.fotoBarcode),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                item.nomorRekening ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if ((item.catatan ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.catatan ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
                      'Detail',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                width: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await context.push<bool>(
                      AppRoutes.channelTransferAdd,
                      extra: item,
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Channel diperbarui')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                width: 44,
                child: ElevatedButton(
                  onPressed: () => _confirmDelete(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.red.shade600,
                    size: 20,
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
    final filteredList = _getFilteredItems(items);
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
                    onPressed: () => context.goNamed('home-keuangan'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Channel Transfer',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau nomor rekening',
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
                    child: IconButton(
                      onPressed: () => _openDetail(context),
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Stack(
                  children: [
                    if (!viewModel.isLoading &&
                        viewModel.errorMessage != null &&
                        items.isEmpty)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan coba lagi nanti',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    else if (!viewModel.isLoading && filteredList.isEmpty)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada channel transfer ditemukan.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Coba buat channel transfer baru.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    else
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) =>
                              _channelCard(filteredList[index], index),
                        ),
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
    );
  }
}