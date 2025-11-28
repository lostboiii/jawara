import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/pengeluaran_model.dart';
import '../../../viewmodels/pengeluaran_viewmodel.dart';
import '../../../router/app_router.dart';

class _ChipColor {
  final Color bg;
  final Color fg;
  const _ChipColor(this.bg, this.fg);
}

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {

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

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  String _formatCurrency(double value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      ).format(value);

  String _resolveKategoriValue(String value) {
    final trimmed = value.trim();
    if (_kategoriLabels.containsKey(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    final legacyMatch = _legacyKategoriMap[lower];
    if (legacyMatch != null) return legacyMatch;
    return trimmed;
  }

  _ChipColor _chipColors(String value) {
    final resolved = _resolveKategoriValue(value).toLowerCase();
    switch (resolved) {
      case 'kegiatan warga':
        return _ChipColor(Colors.amber.shade100, Colors.amber.shade900);
      case 'operasional':
        return _ChipColor(Colors.blue.shade100, Colors.blue.shade900);
      case 'pembangunan':
        return _ChipColor(Colors.green.shade100, Colors.green.shade900);
      case 'kegiatan sosial':
        return _ChipColor(Colors.orange.shade100, Colors.orange.shade900);
      case 'pemeliharaan fasilitas':
        return _ChipColor(Colors.pink.shade100, Colors.pink.shade900);
      case 'keamanan dan kebersihan':
        return _ChipColor(Colors.teal.shade100, Colors.teal.shade900);
      default:
        return _ChipColor(Colors.grey.shade200, Colors.grey.shade800);
    }
  }

  String _kategoriLabel(String value) {
    final resolved = _resolveKategoriValue(value);
    return _kategoriLabels[resolved] ?? resolved;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDelete(PengeluaranModel item) {
    final primaryColor = const Color(0xff5067e9);
    
    showDialog<void>(
      context: context,
      builder: (context) {
        final vm = context.watch<PengeluaranViewModel>();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Pengeluaran',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Hapus data "${item.namaPengeluaran}"?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      try {
                        await vm.deletePengeluaran(item.id);
                        if (mounted) {
                          Navigator.pop(context);
                          _showSnack('Pengeluaran dihapus');
                        }
                      } catch (e) {
                        _showSnack('Gagal menghapus: $e');
                      }
                    },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengeluaranViewModel>();
    final items = vm.items;
    final primaryColor = const Color(0xff5067e9);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Pengeluaran',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (!vm.isLoading && vm.errorMessage != null && items.isEmpty)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              'Terjadi kesalahan saat memuat data.\n${vm.errorMessage}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: Colors.red[700]),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: vm.loadPengeluaran,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Coba lagi', style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    )
                  else if (!vm.isLoading && items.isEmpty)
                    Center(
                      child: Text(
                        'Belum ada data pengeluaran',
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildCard(item, index);
                      },
                    ),
                  if (vm.isLoading)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.isLoading 
            ? null 
            : () async {
                final result = await context.push<bool>(AppRoutes.pengeluaranAdd);
                if (result == true && mounted) {
                  _showSnack('Pengeluaran berhasil ditambahkan');
                }
              },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Data', style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  Widget _buildCard(PengeluaranModel item, int index) {
    final kategoriValue = _resolveKategoriValue(item.kategoriPengeluaran);
    final colors = _chipColors(kategoriValue);
    final kategoriLabel = _kategoriLabel(kategoriValue);
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
                      _formatCurrency(item.jumlah),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.namaPengeluaran,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await context.push<bool>(
                      AppRoutes.pengeluaranAdd,
                      extra: item,
                    );
                    if (result == true && mounted) {
                      _showSnack('Pengeluaran berhasil diperbarui');
                    }
                  } else if (value == 'delete') {
                    _confirmDelete(item);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Ubah', style: GoogleFonts.inter()),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus', style: GoogleFonts.inter()),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  kategoriLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.fg,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _formatDate(item.tanggalPengeluaran),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.pengeluaranDetail, extra: item),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
