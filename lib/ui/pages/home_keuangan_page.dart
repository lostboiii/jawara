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

  @override
  void initState() {
    super.initState();
    _loadData();
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
            _buildTransactionItem(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xff5067e9),
              title: 'Iuran Bulanan',
              description: 'Iuran RT Februari 2024',
              amount: '+ Rp 500.000',
              amountColor: const Color(0xff5067e9),
              date: '25 Nov 2025',
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              icon: Icons.trending_down_rounded,
              iconColor: const Color(0xff5067e9),
              title: 'Pembelian Peralatan',
              description: 'Pembelian tanda terima tagihan',
              amount: '- Rp 200.000',
              amountColor: const Color(0xff5067e9),
              date: '24 Nov 2025',
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xff5067e9),
              title: 'Donasi Sosial',
              description: 'Donasi untuk acara sosial RW',
              amount: '+ Rp 1.000.000',
              amountColor: const Color(0xff5067e9),
              date: '23 Nov 2025',
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              icon: Icons.trending_down_rounded,
              iconColor: const Color(0xff5067e9),
              title: 'Pembayaran Listrik',
              description: 'Pembayaran listrik pos ronda',
              amount: '- Rp 150.000',
              amountColor: const Color(0xff5067e9),
              date: '22 Nov 2025',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String amount,
    required Color amountColor,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
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