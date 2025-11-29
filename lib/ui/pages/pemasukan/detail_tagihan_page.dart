import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../home_page.dart';
import 'tagihan_page.dart';

class DetailTagihanPage extends StatelessWidget {
  const DetailTagihanPage({super.key, required this.tagihan});

  final TagihanItem tagihan;

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 1,
      sectionBuilders: {
        1: (ctx, scope) => _buildSection(ctx, scope, tagihan),
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    HomePageScope scope,
    TagihanItem tagihan,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IconButton(
                    onPressed: () => context.goNamed('tagihan'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Detail Tagihan',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSummaryCard(tagihan, primaryColor),
            const SizedBox(height: 20),
            _buildInfoCard(tagihan, primaryColor),
            const SizedBox(height: 20),
            _buildPaymentCard(tagihan, primaryColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TagihanItem tagihan, Color primaryColor) {
    final isLunas = tagihan.statusLabel == 'Lunas';
    final statusColor = isLunas ? const Color(0xff34C759) : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5067e9).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagihan.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLunas
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tagihan.statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 32,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tagihan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                tagihan.formattedNominal,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TagihanItem tagihan, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Tagihan',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.account_balance_wallet_rounded,
            'Jenis Iuran',
            tagihan.jenisLabel,
            Icons.calendar_today_rounded,
            'Tanggal Tagihan',
            tagihan.formattedDate,
            primaryColor,
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.text_fields_rounded,
            'ID Tagihan',
            tagihan.id,
            Icons.account_circle_rounded,
            'Nama Keluarga',
            tagihan.displayName,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(TagihanItem tagihan, Color primaryColor) {
    final isLunas = tagihan.statusLabel == 'Lunas';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLunas
                  ? const Color(0xff34C759).withOpacity(0.08)
                  : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isLunas ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: isLunas ? const Color(0xff34C759) : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLunas
                        ? 'Tagihan ini sudah dibayar lunas'
                        : 'Tagihan belum dibayar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLunas ? const Color(0xff34C759) : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon1,
    String label1,
    String value1,
    IconData icon2,
    String label2,
    String value2,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon1, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    label1,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon2, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    label2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value2,
                style: GoogleFonts.inter(
                  fontSize: 14,
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
}