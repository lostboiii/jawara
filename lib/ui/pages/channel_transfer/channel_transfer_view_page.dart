import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/metode_pembayaran_model.dart';
import '../../../router/app_router.dart';

class ChannelTransferViewPage extends StatelessWidget {
  final MetodePembayaranModel item;

  const ChannelTransferViewPage({super.key, required this.item});

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      );
    }

    if (kIsWeb) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        file,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value ?? '-',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Detail Channel',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final result = await context.push<bool>(
                          AppRoutes.channelTransferAdd,
                          extra: item,
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      icon: Icon(
                        Icons.edit_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                        Text(
                          item.namaMetode,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.namaPemilik ?? 'Pemilik tidak diketahui',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade100, height: 1),
                        const SizedBox(height: 24),
                        _buildInfoRow('Nomor Rekening', item.nomorRekening),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade100, height: 1),
                        const SizedBox(height: 20),
                        if (item.catatan != null &&
                            item.catatan!.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.catatan!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.fotoBarcode != null &&
                      item.fotoBarcode!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Foto Barcode',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _buildImage(item.fotoBarcode),
                    ),
                  ],
                  if (item.thumbnail != null && item.thumbnail!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Thumbnail',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _buildImage(item.thumbnail),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
