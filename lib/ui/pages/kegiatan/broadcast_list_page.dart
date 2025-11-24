import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/broadcast_model.dart';
import '../../../viewmodels/broadcast_viewmodel.dart';
import '../home_page.dart';

class BroadcastListItem {
  BroadcastListItem({
    required this.id,
    required this.judulBroadcast,
    required this.isiBroadcast,
    this.fotoBroadcast,
    this.dokumenBroadcast,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String judulBroadcast;
  final String isiBroadcast;
  final String? fotoBroadcast;
  final String? dokumenBroadcast;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName =>
      judulBroadcast.isNotEmpty ? judulBroadcast : 'Judul tidak tersedia';

  String get tanggalLabel =>
      createdAt != null ? DateFormat('d MMM yyyy').format(createdAt!) : '-';

  bool get hasAttachment =>
      (fotoBroadcast ?? '').isNotEmpty || (dokumenBroadcast ?? '').isNotEmpty;
}

class BroadcastListPage extends StatefulWidget {
  const BroadcastListPage({super.key});

  @override
  State<BroadcastListPage> createState() => _BroadcastListPageState();
}

class _BroadcastListPageState extends State<BroadcastListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'terbaru'; // 'terbaru', 'terlama'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 3,
      sectionBuilders: {
        3: _buildSection,
      },
    );
  }

  Widget _buildSection(BuildContext context, HomePageScope scope) {
    final primaryColor = scope.primaryColor;
    final viewModel = context.watch<BroadcastViewModel>();
    final items = viewModel.items;
    final now = DateTime.now();
    final monthCount = items
        .where(
          (item) => item.createdAt != null &&
              item.createdAt!.month == now.month &&
              item.createdAt!.year == now.year,
        )
        .length;

    final broadcastItems = items.map((item) {
      return BroadcastListItem(
        id: item.id,
        judulBroadcast: item.judulBroadcast,
        isiBroadcast: item.isiBroadcast,
        fotoBroadcast: item.fotoBroadcast,
        dokumenBroadcast: item.dokumenBroadcast,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
    }).toList();

    // Sort berdasarkan pilihan
    if (_sortBy == 'terbaru') {
      broadcastItems.sort(
          (a, b) => (b.createdAt ?? DateTime(1900)).compareTo(a.createdAt ?? DateTime(1900)));
    } else {
      broadcastItems.sort(
          (a, b) => (a.createdAt ?? DateTime(1900)).compareTo(b.createdAt ?? DateTime(1900)));
    }

    final filteredBroadcast = _searchQuery.isEmpty
        ? broadcastItems
        : broadcastItems.where((broadcast) {
            final query = _searchQuery.toLowerCase();
            return broadcast.displayName.toLowerCase().contains(query) ||
                broadcast.isiBroadcast.toLowerCase().contains(query);
          }).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadBroadcasts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.goNamed('home-kegiatan'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Broadcast',
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
                      hintText: 'Cari broadcast...',
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
                    onPressed: () => _showFilterDialog(context, primaryColor),
                    icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Total Broadcast',
                    value: '${items.length}',
                    icon: Icons.campaign_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Bulan Ini',
                    value: '$monthCount',
                    icon: Icons.calendar_today_rounded,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredBroadcast.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.campaign_outlined,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada broadcast.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tarik ke bawah untuk memuat ulang atau cari broadcast.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ..._filteredBroadcast(filteredBroadcast).map(
                (broadcast) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BroadcastCard(broadcast: broadcast),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<BroadcastListItem> _filteredBroadcast(List<BroadcastListItem> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    final query = _searchQuery.toLowerCase();
    return items.where((broadcast) {
      final judul = broadcast.displayName.toLowerCase().contains(query);
      final isi = broadcast.isiBroadcast.toLowerCase().contains(query);
      return judul || isi;
    }).toList();
  }

  void _showFilterDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Urutkan Broadcast',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(
                  'Terbaru',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                value: 'terbaru',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.of(dialogContext).pop();
                },
                activeColor: primaryColor,
              ),
              RadioListTile<String>(
                title: Text(
                  'Terlama',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                value: 'terlama',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.of(dialogContext).pop();
                },
                activeColor: primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
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

class _BroadcastCard extends StatelessWidget {
  const _BroadcastCard({required this.broadcast});

  final BroadcastListItem broadcast;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    final viewModel = context.read<BroadcastViewModel>();

    return Container(
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
                child: Text(
                  broadcast.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (broadcast.hasAttachment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attachment_rounded,
                        size: 12,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lampiran',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            broadcast.isiBroadcast,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                broadcast.tanggalLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _showDetailPage(context, broadcast),
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
                    final confirmed = await _confirmDelete(context, broadcast);
                    if (confirmed == true) {
                      try {
                        await viewModel.deleteBroadcast(broadcast.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Broadcast dihapus',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
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

  void _showDetailPage(BuildContext context, BroadcastListItem broadcast) {
    context.goNamed('detail-broadcast', extra: broadcast);
  }

  Future<bool?> _confirmDelete(
      BuildContext context, BroadcastListItem broadcast) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                'Hapus Broadcast?',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus broadcast "${broadcast.displayName}"? Data yang dihapus tidak dapat dikembalikan.',
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
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(false),
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
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(true),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}