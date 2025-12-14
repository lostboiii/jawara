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
    Color? iconColor,
    Color? bgColor,
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
    required String time,
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
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
    _NavItem(icon: Icons.people_rounded, label: 'Warga'),
    _NavItem(icon: Icons.event_note_rounded, label: 'Kegiatan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  late int _selectedIndex;
  double _totalPengeluaran = 0;
  double _totalPemasukan = 0;
  double _saldo = 0;
  int _totalWarga = 0;
  int _totalKeluarga = 0;
  bool _isLoadingPengeluaran = true;
  bool _isLoadingStats = true;
  bool _isLoadingTransaksi = true;
  bool _isLoadingAspirasi = true;
  bool _isLoadingKegiatan = true;
  bool _isLoadingBroadcast = true;

  List<Map<String, dynamic>> _recentTransaksi = [];
  List<Map<String, dynamic>> _recentAspirasi = [];
  List<Map<String, dynamic>> _ongoingKegiatan = [];
  List<Map<String, dynamic>> _recentBroadcast = [];

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
          (ctx, scope) => _buildPlaceholderContent(ctx, 'Keuangan'),
      2: widget.sectionBuilders[2] ??
          (ctx, scope) => _buildPlaceholderContent(ctx, 'Warga'),
      3: widget.sectionBuilders[3] ??
          (ctx, scope) => _buildPlaceholderContent(ctx, 'Kegiatan'),
    };
    _loadPengeluaran();
    _loadHomeStats();
    _loadRecentTransaksi();
    _loadRecentAspirasi();
    _loadOngoingKegiatan();
    _loadRecentBroadcast();
  }

  Future<void> _loadRecentTransaksi() async {
    try {
      final supabase = SupabaseService.client;

      print('🔍 Loading transaksi data...');
      print(
          '📍 User auth status: ${supabase.auth.currentUser != null ? "Logged in" : "Not logged in"}');

      // Load 2 pemasukan terbaru
      print('📥 Loading pemasukan...');
      final pemasukanResponse = await supabase
          .from('pemasukan_lain')
          .select(
              'nama_pemasukan, jumlah, tanggal_pemasukan, kategori_pemasukan')
          .order('tanggal_pemasukan', ascending: false)
          .limit(2);
      print(
          '✅ Pemasukan loaded: ${pemasukanResponse is List ? pemasukanResponse.length : 0} records');

      // Load 2 pengeluaran terbaru
      print('📤 Loading pengeluaran...');
      final pengeluaranResponse = await supabase
          .from('pengeluaran')
          .select(
              'nama_pengeluaran, jumlah, tanggal_pengeluaran, kategori_pengeluaran')
          .order('tanggal_pengeluaran', ascending: false)
          .limit(2);
      print(
          '✅ Pengeluaran loaded: ${pengeluaranResponse is List ? pengeluaranResponse.length : 0} records');

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
      print('📊 Transaksi data: $combined');

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

  Future<void> _loadRecentAspirasi() async {
    try {
      final supabase = SupabaseService.client;

      print('🔍 Loading aspirasi data...');
      print(
          '📍 User auth status: ${supabase.auth.currentUser != null ? "Logged in (${supabase.auth.currentUser?.email})" : "Not logged in"}');
      print('📍 User ID: ${supabase.auth.currentUser?.id}');

      final response = await supabase
          .from('aspirasi')
          .select('id, user_id, judul_aspirasi, deskripsi_aspirasi')
          .order('id', ascending: false)
          .limit(3);

      // Get user emails for each aspirasi
      if (response is List && response.isNotEmpty) {
        for (var aspirasi in response) {
          try {
            final userId = aspirasi['user_id'];
            if (userId != null) {
              final userResponse = await supabase
                  .from('warga_profiles')
                  .select('nama_lengkap')
                  .eq('id', userId)
                  .maybeSingle();

              aspirasi['user_name'] = userResponse?['nama_lengkap'] ?? 'Warga';
            } else {
              aspirasi['user_name'] = 'Anonim';
            }
          } catch (e) {
            aspirasi['user_name'] = 'Warga';
          }
        }
      }

      print('✅ Aspirasi query completed');
      print('📊 Response type: ${response.runtimeType}');
      print(
          '📊 Response length: ${response is List ? response.length : "Not a list"}');
      print('📊 Data: $response');

      if (mounted) {
        setState(() {
          _recentAspirasi =
              response is List ? List<Map<String, dynamic>>.from(response) : [];
          _isLoadingAspirasi = false;
        });
        print('✅ State updated - ${_recentAspirasi.length} aspirasi loaded');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading aspirasi: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _recentAspirasi = [];
          _isLoadingAspirasi = false;
        });
      }
    }
  }

  Future<void> _loadOngoingKegiatan() async {
    try {
      final supabase = SupabaseService.client;

      print('🔍 Loading kegiatan data...');

      // Ambil kegiatan terbaru (tidak peduli tanggal)
      final response = await supabase
          .from('kegiatan')
          .select(
              'nama_kegiatan, deskripsi, tanggal_kegiatan, lokasi_kegiatan, kategori_kegiatan, penanggung_jawab')
          .order('tanggal_kegiatan', ascending: false)
          .limit(3);

      print('✅ Kegiatan query completed');
      print(
          '📊 Kegiatan response: ${response is List ? response.length : "Not a list"} records');
      print('📊 Data: $response');

      if (mounted) {
        setState(() {
          _ongoingKegiatan =
              response is List ? List<Map<String, dynamic>>.from(response) : [];
          _isLoadingKegiatan = false;
        });
        print('✅ State updated - ${_ongoingKegiatan.length} kegiatan loaded');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading kegiatan: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _ongoingKegiatan = [];
          _isLoadingKegiatan = false;
        });
      }
    }
  }

  Future<void> _loadRecentBroadcast() async {
    try {
      final supabase = SupabaseService.client;

      print('🔍 Loading broadcast data...');

      // Ambil 3 broadcast terbaru
      final response = await supabase
          .from('broadcast')
          .select('uuid, judul_broadcast, isi_broadcast')
          .limit(3);

      print('✅ Broadcast query completed');
      print(
          '📊 Broadcast response: ${response is List ? response.length : "Not a list"} records');

      if (mounted) {
        setState(() {
          _recentBroadcast =
              response is List ? List<Map<String, dynamic>>.from(response) : [];
          _isLoadingBroadcast = false;
        });
        print('✅ State updated - ${_recentBroadcast.length} broadcast loaded');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading broadcast: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _recentBroadcast = [];
          _isLoadingBroadcast = false;
        });
      }
    }
  }

  Future<void> _loadHomeStats() async {
    try {
      final supabase = SupabaseService.client;

      // Load pemasukan lain
      final pemasukanResponse =
          await supabase.from('pemasukan_lain').select('jumlah');

      double pemasukanLain = 0;
      for (var item in pemasukanResponse) {
        pemasukanLain += (item['jumlah'] as num).toDouble();
      }

      // Load iuran yang sudah dibayar (sudah_bayar)
      final iuranResponse = await supabase
          .from('tagih_iuran')
          .select('jumlah')
          .eq('status_tagihan', 'sudah_bayar');

      double iuranLunas = 0;
      for (var item in iuranResponse) {
        iuranLunas += (item['jumlah'] as num).toDouble();
      }

      // Load pengeluaran for saldo
      final pengeluaranResponse =
          await supabase.from('pengeluaran').select('jumlah');

      double pengeluaran = 0;
      for (var item in pengeluaranResponse) {
        pengeluaran += (item['jumlah'] as num).toDouble();
      }

      // Total pemasukan = pemasukan lain + iuran yang sudah dibayar
      double totalPemasukan = pemasukanLain + iuranLunas;

      // Load warga
      print('🔍 Loading warga data...');
      print(
          '📍 User auth status: ${supabase.auth.currentUser != null ? "Logged in" : "Not logged in"}');
      final wargaResponse = await supabase.from('warga_profiles').select('id');
      print('✅ Warga query completed');
      print(
          '📊 Warga response: ${wargaResponse is List ? wargaResponse.length : "Not a list"} records');
      print('📊 Warga data: $wargaResponse');

      // Load keluarga
      print('🔍 Loading keluarga data...');
      final keluargaResponse = await supabase.from('keluarga').select('id');
      print('✅ Keluarga query completed');
      print(
          '📊 Keluarga response: ${keluargaResponse is List ? keluargaResponse.length : "Not a list"} records');
      print('📊 Keluarga data: $keluargaResponse');

      if (mounted) {
        setState(() {
          _totalPemasukan = totalPemasukan;
          _saldo = totalPemasukan - pengeluaran;
          _totalWarga = wargaResponse is List ? wargaResponse.length : 0;
          _totalKeluarga =
              keluargaResponse is List ? keluargaResponse.length : 0;
          _isLoadingStats = false;
        });
        print(
            '✅ Stats updated - Warga: $_totalWarga, Keluarga: $_totalKeluarga');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading home stats: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
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
      double juta = amount / 1000000;
      double truncated = (juta * 10).truncateToDouble() / 10;
      return truncated.toStringAsFixed(1).replaceAll(RegExp(r'\.?0*$'), '');
    } else if (amount >= 1000) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Admin!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat Datang',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _buildHomeSummaryCard(
                    title: 'Saldo',
                    value: _isLoadingStats
                        ? 'Memuat...'
                        : 'Rp ${formatCurrency(_saldo)}${getCurrencyUnit(_saldo)}',
                    subtitle: 'Update hari ini',
                    icon: Icons.account_balance_wallet_rounded,
                    color: primaryColor,
                    onTap: () => context.goNamed('home-keuangan'),
                  ),
                  const SizedBox(width: 16),
                  _buildHomeSummaryCard(
                    title: 'Warga',
                    value: _isLoadingStats ? 'Memuat...' : '$_totalWarga Jiwa',
                    subtitle: '$_totalKeluarga Keluarga',
                    icon: Icons.groups_rounded,
                    color: primaryColor,
                    onTap: () => context.goNamed('home-warga'),
                  ),
                  const SizedBox(width: 16),
                  _buildHomeSummaryCard(
                    title: 'Agenda',
                    value: 'Lihat Kegiatan',
                    subtitle: 'Cek jadwal terbaru',
                    icon: Icons.event_note_rounded,
                    color: primaryColor,
                    onTap: () => context.goNamed('home-kegiatan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Transaksi Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terbaru',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => context.goNamed('home-keuangan'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                          '${isIncome ? '+' : '-'} Rp ${formatCurrency(amount)}',
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
            // Aspirasi Warga Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aspirasi Warga',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => context.goNamed('aspirasi-list'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingAspirasi)
              const Center(child: CircularProgressIndicator())
            else if (_recentAspirasi.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada aspirasi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else
              ..._recentAspirasi.map((aspirasi) {
                // Use fetched user name
                final userName = aspirasi['user_name'] ?? 'Warga';

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                aspirasi['judul_aspirasi'] ??
                                    aspirasi['deskripsi_aspirasi'] ??
                                    '',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 32),
            // Kegiatan Berlangsung
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kegiatan Berlangsung',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => context.goNamed('home-kegiatan'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingKegiatan)
              const Center(child: CircularProgressIndicator())
            else if (_ongoingKegiatan.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada kegiatan berlangsung',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else
              ..._ongoingKegiatan.map((kegiatan) {
                final tanggal = DateTime.parse(kegiatan['tanggal_kegiatan']);
                final dateFormat =
                    '${tanggal.day}/${tanggal.month}/${tanggal.year}';

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
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kegiatan['nama_kegiatan'],
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kegiatan['deskripsi'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    kegiatan['lokasi_kegiatan'] ?? '-',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateFormat,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
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
                );
              }).toList(),
            const SizedBox(height: 32),
            // Broadcast Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Broadcast Terbaru',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => context.goNamed('list-broadcast'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingBroadcast)
              const Center(child: CircularProgressIndicator())
            else if (_recentBroadcast.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada broadcast',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else
              ..._recentBroadcast.map((broadcast) {
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
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.broadcast_on_personal_rounded,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                broadcast['judul_broadcast'],
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                broadcast['isi_broadcast'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
    Color? iconColor,
    Color? bgColor,
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
              color: bgColor ?? const Color(0xff5067e9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.1,
              ),
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
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
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
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
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

  Widget _buildHomeSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required String title,
    required String date,
    required String type,
    required Color primaryColor,
    bool isUrgent = false,
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
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? Colors.red.withOpacity(0.1)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? Colors.red : primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}
