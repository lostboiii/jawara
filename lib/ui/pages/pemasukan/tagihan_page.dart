import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/tagihan_viewmodel.dart';

import '../home_page.dart';

class TagihanItem {
  TagihanItem({
    required this.id,
    required this.namaKeluarga,
    required this.jenisIuran,
    required this.nominal,
    required this.tanggal,
    required this.status,
  });

  final String id;
  final String namaKeluarga;
  final String jenisIuran;
  final double nominal;
  final DateTime tanggal;
  final String status;

  String get displayName =>
      namaKeluarga.isNotEmpty ? namaKeluarga : 'Nama tidak tersedia';

  String get jenisLabel =>
      jenisIuran.isNotEmpty ? jenisIuran : 'Belum ditetapkan';

  String get statusLabel => status.isNotEmpty ? status : 'Belum Bayar';

  String get formattedNominal => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(nominal);

  String get formattedDate =>
      DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
}

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<TagihanItem> _items = [];
  String _searchQuery = '';
  String? _selectedFilter;

  final List<String> _filterOptions = [
    'Lunas',
    'Belum Bayar',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagihanViewModel>().loadTagihan();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TagihanItem> _getFilteredItems(List<Map<String, dynamic>> tagihan) {
    _items.clear();
    
    for (final item in tagihan) {
      String namaKeluarga = 'N/A';
      
      if (item['keluarga'] != null) {
        final keluarga = item['keluarga'];
        final nomorKk = keluarga['nomor_kk'] ?? 'N/A';
        
        if (keluarga['warga_profiles'] != null) {
          final warga = keluarga['warga_profiles'];
          namaKeluarga = 'KK ${warga['nama_lengkap'] ?? nomorKk}';
        } else {
          namaKeluarga = 'KK $nomorKk';
        }
      }

      String jenisIuran = 'N/A';
      if (item['kategori_iuran'] != null) {
        jenisIuran = item['kategori_iuran']['nama_iuran'] ?? 'N/A';
      }

      String status = 'Belum Bayar';
      if (item['status_tagihan'] == 'lunas') {
        status = 'Lunas';
      }

      _items.add(TagihanItem(
        id: item['id'],
        namaKeluarga: namaKeluarga,
        jenisIuran: jenisIuran,
        nominal: (item['jumlah'] ?? 0).toDouble(),
        tanggal: DateTime.parse(item['tanggal_tagihan']),
        status: status,
      ));
    }

    var filtered = List<TagihanItem>.from(_items);

    if (_selectedFilter != null) {
      filtered = filtered.where((item) {
        final itemStatus = item.statusLabel.trim().toLowerCase();
        final filterStatus = _selectedFilter!.trim().toLowerCase();
        return itemStatus == filterStatus;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((item) {
        final nameMatch = item.displayName.toLowerCase().contains(query);
        final jenisMatch = item.jenisLabel.toLowerCase().contains(query);
        final statusMatch = item.statusLabel.toLowerCase().contains(query);
        return nameMatch || jenisMatch || statusMatch;
      }).toList();
    }

    return filtered;
  }

  Future<void> _onRefresh() async {
    await context.read<TagihanViewModel>().loadTagihan();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSelectedFilter = _selectedFilter;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Tagihan',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (tempSelectedFilter != null)
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                tempSelectedFilter = null;
                              });
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Status Pembayaran',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterOptions.map((filter) {
                        final isSelected = tempSelectedFilter == filter;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                tempSelectedFilter = null;
                              } else {
                                tempSelectedFilter = filter;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xff5067e9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xff5067e9)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
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
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = tempSelectedFilter;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff5067e9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Terapkan',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TagihanViewModel(),
      child: HomePage(
        initialIndex: 1,
        sectionBuilders: {
          1: (ctx, scope) => _buildSection(ctx, scope),
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, HomePageScope scope) {
    final primaryColor = scope.primaryColor;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
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
                  'Tagihan',
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
                      hintText: 'Cari nama keluarga atau status',
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
                    onPressed: () {},
                    icon: const Icon(Icons.print_rounded, color: Colors.white),
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
                    onPressed: () => _showFilterDialog(context),
                    icon: const Icon(Icons.filter_alt_rounded,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_selectedFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Filter: ',
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFilter!,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Consumer<TagihanViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final filteredItems = _getFilteredItems(viewModel.tagihan);
                
                if (filteredItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        const Icon(Icons.filter_list_off_rounded,
                            size: 48, color: Color(0xffA1A1A1)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada tagihan ditemukan.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba reset filter atau gunakan kata kunci lain.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: filteredItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TagihanCard(item: item),
                    ),
                  ).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TagihanCard extends StatelessWidget {
  const _TagihanCard({required this.item});

  final TagihanItem item;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    final isLunas = item.statusLabel == 'Lunas';
    final statusColor = isLunas ? const Color(0xff34C759) : Colors.red;

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
                  item.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.formattedNominal,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
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
              Expanded(
                child: Text(
                  item.jenisLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                item.formattedDate,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                context.goNamed('detail-tagihan', extra: item,);
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
        ],
      ),
    );
  }
}