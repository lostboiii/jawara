import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../home_page.dart';
import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'edit_warga_page.dart';

class DetailWargaPage extends StatelessWidget {
  const DetailWargaPage({super.key, required this.warga});

  final WargaListItem warga;

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: {
        2: (ctx, scope) => _buildSection(ctx, scope, warga),
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    HomePageScope scope,
    WargaListItem warga,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.goNamed('warga-daftar-warga'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detail Warga',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _handleEdit(context, warga),
                  icon: Icon(
                    Icons.edit,
                    color: primaryColor,
                  ),
                  tooltip: 'Edit Warga',
                ),
                IconButton(
                  onPressed: () => _handleDelete(context, warga),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Hapus Warga',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSummaryCard(warga),
            const SizedBox(height: 20),
            _buildInfoCard(warga, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(WargaListItem warga) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                child: Text(
                  warga.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (warga.isActive
                          ? const Color(0xff34C759)
                          : const Color(0xffF75555))
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  warga.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: warga.isActive
                        ? const Color(0xff34C759)
                        : const Color(0xffF75555),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(WargaListItem warga, Color primaryColor) {
    final tanggalLahirStr = warga.tanggalLahir != null
        ? '${warga.tanggalLahir!.day.toString().padLeft(2, '0')}/${warga.tanggalLahir!.month.toString().padLeft(2, '0')}/${warga.tanggalLahir!.year}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGridInfoRow(
            'NIK',
            warga.nik.isNotEmpty ? warga.nik : '—',
            'Status Keaktifan',
            warga.statusLabel,
          ),
          const SizedBox(height: 16),
          _buildGridInfoRow('Keluarga', warga.keluargaLabel, 'Nomor Telepon',
              (warga.noTelepon ?? '').isNotEmpty ? warga.noTelepon! : '—'),
          const SizedBox(height: 16),
          _buildGridInfoRow(
              'Jenis Kelamin',
              warga.jenisKelamin.isNotEmpty ? warga.jenisKelamin : '—',
              'Peran dalam Keluarga',
              warga.peranLabel),
          const SizedBox(height: 16),
          _buildGridInfoRow(
              'Tempat Lahir',
              (warga.tempatLahir ?? '').isNotEmpty ? warga.tempatLahir! : '—',
              'Tanggal Lahir',
              tanggalLahirStr),
          const SizedBox(height: 16),
          _buildGridInfoRow(
              'Golongan Darah',
              warga.golonganDarah.isNotEmpty ? warga.golonganDarah : '—',
              'Agama',
              warga.agama.isNotEmpty ? warga.agama : '—'),
          const SizedBox(height: 16),
          _buildGridInfoRow(
              'Pekerjaan',
              warga.pekerjaan.isNotEmpty ? warga.pekerjaan : '—',
              'Pendidikan Terakhir',
              (warga.pendidikan ?? '').isNotEmpty ? warga.pendidikan! : '—'),
        ],
      ),
    );
  }

  Widget _buildGridInfoRow(
      String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value1,
                style: GoogleFonts.inter(
                  fontSize: 13,
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
              Text(
                label2,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value2,
                style: GoogleFonts.inter(
                  fontSize: 13,
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

  void _handleEdit(BuildContext context, WargaListItem warga) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWargaPage(warga: warga),
      ),
    );

    // If edit was successful, go back to refresh the list
    if (result == true && context.mounted) {
      context.goNamed('warga-daftar-warga');
    }
  }

  void _handleDelete(BuildContext context, WargaListItem warga) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus Warga',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data ${warga.displayName}? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = Provider.of<WargaRepository>(context, listen: false);
        await repository.deleteWarga(warga.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data warga berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to list page
          context.goNamed('warga-daftar-warga');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
