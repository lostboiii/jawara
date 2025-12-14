import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';

class HomeKeuanganPage extends StatefulWidget {
  const HomeKeuanganPage({super.key});

  @override
  State<HomeKeuanganPage> createState() => _HomeKeuanganPageState();
}

class _HomeKeuanganPageState extends State<HomeKeuanganPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _saldo = 0;
  double _pemasukanLain = 0;
  double _iuranLunas = 0;
  bool _isLoadingTransaksi = true;
  List<Map<String, dynamic>> _recentTransaksi = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRecentTransaksi();
  }

  Future<void> _loadRecentTransaksi() async {
    try {
      print('🔍 Loading transaksi data...');
      
      // Load 2 pemasukan terbaru
      print('📥 Loading pemasukan...');
      final pemasukanResponse = await _supabase
          .from('pemasukan_lain')
          .select('nama_pemasukan, jumlah, tanggal_pemasukan, kategori_pemasukan')
          .order('tanggal_pemasukan', ascending: false)
          .limit(2);
      print('✅ Pemasukan loaded: ${pemasukanResponse is List ? pemasukanResponse.length : 0} records');
      
      // Load 2 pengeluaran terbaru
      print('📤 Loading pengeluaran...');
      final pengeluaranResponse = await _supabase
          .from('pengeluaran')
          .select('nama_pengeluaran, jumlah, tanggal_pengeluaran, kategori_pengeluaran')
          .order('tanggal_pengeluaran', ascending: false)
          .limit(2);
      print('✅ Pengeluaran loaded: ${pengeluaranResponse is List ? pengeluaranResponse.length : 0} records');
      
      List<Map<String, dynamic>> combined = [];
      
      // Add pemasukan with type
      if (pemasukanResponse is List) {
        for (var item in pemasukanResponse) {
          combined.add({
            'title': item['nama_pemasukan'] ?? 'Pemasukan',
            'subtitle': item['kategori_pemasukan'] ?? 'Tidak ada kategori',
            'amount': item['jumlah'],
            'date': DateTime.parse(item['tanggal_pemasukan']),
            'type': 'pemasukan',
          });
        }
      }
      
      // Add pengeluaran with type
      if (pengeluaranResponse is List) {
        for (var item in pengeluaranResponse) {
          combined.add({
            'title': item['nama_pengeluaran'] ?? 'Pengeluaran',
            'subtitle': item['kategori_pengeluaran'] ?? 'Tidak ada kategori',
            'amount': item['jumlah'],
            'date': DateTime.parse(item['tanggal_pengeluaran']),
            'type': 'pengeluaran',
          });
        }
      }
      
      // Sort by date
      combined.sort((a, b) => b['date'].compareTo(a['date']));
      
      print('✅ Combined transaksi: ${combined.length} records');
      
      if (mounted) {
        setState(() {
          _recentTransaksi = combined.take(4).toList();
          _isLoadingTransaksi = false;
        });
        print('✅ State updated - ${_recentTransaksi.length} transaksi loaded');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading transaksi: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _recentTransaksi = [];
          _isLoadingTransaksi = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    try {
      // Load pemasukan lain
      final pemasukanResponse = await _supabase
          .from('pemasukan_lain')
          .select('jumlah');
      
      double pemasukanLain = 0;
      for (var item in pemasukanResponse) {
        pemasukanLain += (item['jumlah'] as num).toDouble();
      }

      // Load iuran yang sudah dibayar (sudah_bayar)
      final iuranResponse = await _supabase
          .from('tagih_iuran')
          .select('jumlah')
          .eq('status_tagihan', 'sudah_bayar');
      
      double iuranLunas = 0;
      for (var item in iuranResponse) {
        iuranLunas += (item['jumlah'] as num).toDouble();
      }

      // Load pengeluaran
      final pengeluaranResponse = await _supabase
          .from('pengeluaran')
          .select('jumlah');
      
      double pengeluaran = 0;
      for (var item in pengeluaranResponse) {
        pengeluaran += (item['jumlah'] as num).toDouble();
      }

      // Total pemasukan = pemasukan lain + iuran yang sudah dibayar
      double totalPemasukan = pemasukanLain + iuranLunas;

      if (mounted) {
        setState(() {
          _pemasukanLain = pemasukanLain;
          _iuranLunas = iuranLunas;
          _totalPemasukan = totalPemasukan;
          _totalPengeluaran = pengeluaran;
          _saldo = totalPemasukan - pengeluaran;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading keuangan data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatRupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 1,
      sectionBuilders: {
        1: (ctx, scope) => _buildKeuanganSection(ctx, scope),
      },
    );
  }

  Widget _buildKeuanganSection(
    BuildContext context,
    HomePageScope scope,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => context.goNamed('home'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Keuangan',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Cek Laporan Keuangan\nAnda',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    const Color(0xff3a4fcf),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 180,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saldo',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _isLoading ? 'Memuat...' : _formatRupiah(_saldo),
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.attach_money_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : _formatRupiah(_pemasukanLain),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemasukan Lain',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.payment_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : _formatRupiah(_iuranLunas),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Iuran Terbayar',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.trending_down_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : _formatRupiah(_totalPengeluaran),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pengeluaran',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : _formatRupiah(_totalPemasukan),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Pemasukan',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.goNamed('statistik-keuangan'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Statistik Lengkap',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _PagedMenuGrid(
              menus: [
                scope.buildMenuIcon(
                  icon: Icons.category_rounded,
                  label: 'Kategori Iuran',
                  onTap: () => context.goNamed('kategori-iuran'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.request_quote_rounded,
                  label: 'Tagih Iuran',
                  onTap: () => context.goNamed('tagih-iuran'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.receipt_rounded,
                  label: 'Tagihan',
                  onTap: () => context.goNamed('tagihan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.attach_money_rounded,
                  label: 'Pemasukan Lain',
                  onTap: () => context.goNamed('pemasukan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.payments_rounded,
                  label: 'Pengeluaran',
                  onTap: () => context.goNamed('pengeluaran'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.assessment_rounded,
                  label: 'Laporan Keuangan',
                  onTap: () => context.goNamed('laporan-keuangan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.print_rounded,
                  label: 'Cetak Laporan',
                  onTap: () => context.goNamed('cetak-laporan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Channel Transfer',
                  onTap: () => context.goNamed('channel-transfer'),
                ),
              ],
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 32),
            Text(
              'Transaksi Terbaru',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingTransaksi)
              const Center(child: CircularProgressIndicator())
            else if (_recentTransaksi.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada transaksi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else
              ..._recentTransaksi.map((transaksi) {
                final isIncome = transaksi['type'] == 'pemasukan';
                final amount = (transaksi['amount'] as num).toDouble();
                final date = transaksi['date'] as DateTime;
                final now = DateTime.now();
                final diff = now.difference(date);
                String timeAgo;
                if (diff.inDays > 0) {
                  timeAgo = '${diff.inDays} hari lalu';
                } else if (diff.inHours > 0) {
                  timeAgo = '${diff.inHours} jam lalu';
                } else if (diff.inMinutes > 0) {
                  timeAgo = '${diff.inMinutes} menit lalu';
                } else {
                  timeAgo = 'Baru saja';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isIncome
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaksi['title'],
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaksi['subtitle'],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeAgo,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'} ${_formatRupiah(amount)}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PagedMenuGrid extends StatefulWidget {
  final List<Widget> menus;
  final Color primaryColor;

  const _PagedMenuGrid({
    required this.menus,
    required this.primaryColor,
  });

  @override
  State<_PagedMenuGrid> createState() => _PagedMenuGridState();
}

class _PagedMenuGridState extends State<_PagedMenuGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemsPerPage = 8;
    final int pageCount = (widget.menus.length / itemsPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pageCount,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final int startIndex = index * itemsPerPage;
              final int endIndex =
                  (startIndex + itemsPerPage < widget.menus.length)
                      ? startIndex + itemsPerPage
                      : widget.menus.length;
              final List<Widget> pageMenus =
                  widget.menus.sublist(startIndex, endIndex);

              return GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 4,
                childAspectRatio: 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: pageMenus,
              );
            },
          ),
        ),
        if (pageCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? widget.primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}