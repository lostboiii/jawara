// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/rumah_viewmodel.dart';
import 'package:jawara/ui/screens/rumah/rumah_add_screen.dart';

class RumahListScreen extends StatefulWidget {
  const RumahListScreen({super.key});

  @override
  _RumahListScreenState createState() => _RumahListScreenState();
}

class _RumahListScreenState extends State<RumahListScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RumahViewModel>().fetchRumahList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Consumer<RumahViewModel>(
      builder: (context, viewModel, child) {
        final rumahList = viewModel.rumahList;
        return Scaffold(
          backgroundColor: const Color(0xfff8f9fa),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchRumahList();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/home-warga'),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daftar Rumah',
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
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari alamat rumah...',
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
                      GestureDetector(
                        onTap: () => context.goNamed('rumah-add'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (rumahList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.home_outlined,
                              size: 48, color: Color(0xffA1A1A1)),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada rumah terdaftar.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tambahkan rumah baru dengan menekan tombol +',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  else
                    ...rumahList.map(
                      (rumah) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _RumahCard(
                          rumah: rumah,
                          onTapDetail: () => _showDetailDialog(rumah),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(Map<String, dynamic> rumah) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.home, color: Color(0xff5067e9)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detail Rumah',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Alamat', rumah['alamat'] ?? ''),
                _buildDetailRow('RT/RW', 'RT ${rumah['rt'] ?? ''}/RW ${rumah['rw'] ?? ''}'),
                _buildDetailRow('Status', rumah['status_kepemilikan'] ?? ''),
                _buildDetailRow('Penghuni', '${rumah['jumlah_penghuni'] ?? 0} orang'),
                _buildDetailRow('Luas Tanah', '${rumah['luas_tanah'] ?? 0} m²'),
                _buildDetailRow('Luas Bangunan', '${rumah['luas_bangunan'] ?? 0} m²'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RumahCard extends StatelessWidget {
  const _RumahCard({
    required this.rumah,
    required this.onTapDetail,
  });

  final Map<String, dynamic> rumah;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    final statusColor = rumah['status_rumah'] == 'ditempati'
        ? const Color(0xff34C759)
        : const Color(0xffFF9500);

    return Container(
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
                      rumah['alamat'] ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          rumah['status_rumah'] == 'ditempati'
                              ? Icons.home
                              : Icons.home_outlined,
                          size: 14,
                          color: const Color(0xffA1A1A1),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Status: ${rumah['status_rumah'] ?? '-'}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  (rumah['status_rumah'] as String?)?.toUpperCase() ?? '-',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
              onPressed: onTapDetail,
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