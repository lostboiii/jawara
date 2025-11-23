import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/pengeluaran_repository.dart';
import '../../core/services/supabase_service.dart';

typedef HomeSectionBuilder = Widget Function(
  BuildContext context,
  HomePageScope scope,
);

abstract class HomePageScope {
  Color get primaryColor;
  bool get isLoadingPengeluaran;
  double get totalPengeluaran;

  String formatCurrency(double? amount);

  String getCurrencyUnit(double? amount);

  Widget buildStatCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
  });

  Widget buildLoadingCard({
    required String title,
    required Color color,
  });

  Widget buildMenuIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  });

  Widget buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
  });

  Widget buildSummaryCard({
    required String title,
    required String value,
    required String unit,
  });

  Widget buildWargaAspirasiItem({
    required String name,
    required String message,
  });
}

class HomePage extends StatefulWidget {
  final int initialIndex;
  final Map<int, HomeSectionBuilder> sectionBuilders;

  const HomePage({
    super.key,
    this.initialIndex = 0,
    this.sectionBuilders = const {},
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

class _HomePageState extends State<HomePage> implements HomePageScope {
  static const Color _primaryColor = Color(0xff5067e9);
  static const List<_NavItem> _navItems = [
    const _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    const _NavItem(
        icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
    const _NavItem(icon: Icons.people_rounded, label: 'Warga'),
    const _NavItem(icon: Icons.event_note_rounded, label: 'Kegiatan'),
    const _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  late int _selectedIndex;
  double _totalPengeluaran = 0;
  bool _isLoadingPengeluaran = true;

  late final PengeluaranRepository _pengeluaranRepo;
  late final Map<int, HomeSectionBuilder> _builders;

  @override
  Color get primaryColor => _primaryColor;

  @override
  bool get isLoadingPengeluaran => _isLoadingPengeluaran;

  @override
  double get totalPengeluaran => _totalPengeluaran;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pengeluaranRepo = SupabasePengeluaranRepository(
      client: SupabaseService.client,
    );
    _builders = {
      0: widget.sectionBuilders[0] ??
          (ctx, scope) => _buildDefaultHomeContent(ctx),
      1: widget.sectionBuilders[1] ??
          (ctx, scope) => _buildDefaultKeuanganContent(ctx),
      2: widget.sectionBuilders[2] ??
          (ctx, scope) => _buildPlaceholderContent(ctx, 'Warga'),
      3: widget.sectionBuilders[3] ??
          (ctx, scope) => _buildPlaceholderContent(ctx, 'Kegiatan'),
    };
    _loadPengeluaran();
  }

  Future<void> _loadPengeluaran() async {
    try {
      final pengeluaranList = await _pengeluaranRepo.fetchAll();
      double total = 0;
      for (var item in pengeluaranList) {
        total += item.jumlah;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _totalPengeluaran = total;
        _isLoadingPengeluaran = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingPengeluaran = false;
      });
    }
  }

  @override
  String formatCurrency(double? amount) {
    if (amount == null || amount == 0) {
      return '0';
    }

    if (amount >= 1000000) {
      // Format jutaan dengan truncate 1 desimal (tidak dibulatkan)
      double juta = amount / 1000000;
      double truncated = (juta * 10).truncateToDouble() / 10;
      return truncated.toStringAsFixed(1).replaceAll(RegExp(r'\.?0*$'), '');
    } else if (amount >= 1000) {
      // Format ribuan dengan truncate 1 desimal (tidak dibulatkan)
      double ribu = amount / 1000;
      double truncated = (ribu * 10).truncateToDouble() / 10;
      return truncated.toStringAsFixed(1).replaceAll(RegExp(r'\.?0*$'), '');
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  @override
  String getCurrencyUnit(double? amount) {
    if (amount == null || amount == 0) {
      return '';
    }

    if (amount >= 1000000) {
      return 'juta';
    } else if (amount >= 1000) {
      return 'ribu';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = GoogleFonts.inter(
      color: Colors.black87,
    );

    return DefaultTextStyle.merge(
      style: defaultTextStyle,
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: _buildBody(context),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xffF5F6FF),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(
                  context: context,
                  index: index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final builder = _builders[_selectedIndex];
    if (builder != null) {
      return builder(context, this);
    }
    return _buildDefaultHomeContent(context);
  }

  Widget _buildDefaultHomeContent(BuildContext context) {
    const primaryColor = _primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Halo, Sayang!',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                    'assets/images/dashboard-pic.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_balance_wallet,
                        size: 64,
                        color: _primaryColor,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    title: 'Pemasukan',
                    value: '50',
                    unit: 'juta',
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoadingPengeluaran
                      ? buildLoadingCard(
                          title: 'Pengeluaran', color: primaryColor)
                      : buildStatCard(
                          title: 'Pengeluaran',
                          value: formatCurrency(_totalPengeluaran),
                          unit: getCurrencyUnit(_totalPengeluaran),
                          color: primaryColor,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStatCard(
                    title: 'Transaksi',
                    value: '7',
                    unit: 'kali',
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart_outline_rounded,
                        color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat Statistik',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              children: [
                buildMenuIcon(
                  icon: Icons.category,
                  label: 'Kategori\nIuran',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.account_balance_wallet,
                  label: 'Tagih Iuran',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.receipt_long,
                  label: 'Tagihan',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.download,
                  label: 'Pemasukan Lain',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.add_circle,
                  label: 'Tambah\nPemasukan',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.arrow_circle_up,
                  label: 'Daftar\nPengeluaran',
                  onTap: () => context.go('/pengeluaran'),
                ),
                buildMenuIcon(
                  icon: Icons.add_circle,
                  label: 'Tambah\nPengeluaran',
                  onTap: () {},
                ),
                buildMenuIcon(
                  icon: Icons.more_horiz,
                  label: 'Daftar Channel',
                  onTap: () => context.go('/channel-transfer'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Riwayat Transaksi',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            buildTransactionItem(
              title: 'Dafa',
              subtitle: 'Pemeliharaan Fasilitas',
              amount: 'Rp 10.000',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultKeuanganContent(BuildContext context) {
    return _buildPlaceholderContent(context, 'Keuangan');
  }

  Widget _buildPlaceholderContent(BuildContext context, String title) {
    return SafeArea(
      child: Center(
        child: Text(
          '$title page belum dikustomisasi',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildStatCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
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
  Widget buildLoadingCard({
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildMenuIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xff5067e9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff5067e9), width: 1),
            ),
            child: const Icon(
              Icons.add_circle,
              color: Color(0xff5067e9),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 4) {
      _showLogoutDialog(context);
      return;
    }

    if (_selectedIndex == index) {
      return;
    }

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('home-keuangan');
        break;
      case 2:
        context.goNamed('home-warga');
        break;
      case 3:
        context.goNamed('home-kegiatan');
        break;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Keluar',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff5067e9),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5067e9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
  }) {
    final navItem = _navItems[index];
    final bool isSelected = _selectedIndex == index;
    const primaryColor = Color(0xff5067E9);
    const inactiveIconColor = Color(0xff949494);

    return Expanded(
      flex: isSelected ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _onNavTap(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 10 : 0,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: isSelected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(navItem.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      navItem.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    navItem.icon,
                    color: inactiveIconColor,
                    size: 22,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget buildSummaryCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _primaryColor,
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
  Widget buildWargaAspirasiItem({
    required String name,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff5067e9), width: 1),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
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
