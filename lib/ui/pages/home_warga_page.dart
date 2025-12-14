import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';

class HomeWargaPage extends StatefulWidget {
  const HomeWargaPage({super.key});

  @override
  State<HomeWargaPage> createState() => _HomeWargaPageState();
}

class _HomeWargaPageState extends State<HomeWargaPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _totalWarga = 0;
  int _totalKeluarga = 0;
  int _totalRumah = 0;
  int _totalAspirasi = 0;
  bool _isLoadingAspirasi = true;
  List<Map<String, dynamic>> _recentAspirasi = [];
  bool _isLoadingBroadcast = true;
  List<Map<String, dynamic>> _recentBroadcast = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRecentAspirasi();
    _loadRecentBroadcast();
  }

  Future<void> _loadRecentAspirasi() async {
    try {
      print('🔍 Loading aspirasi data...');
      
      final response = await _supabase
          .from('aspirasi')
          .select('id, user_id, judul_aspirasi, deskripsi_aspirasi')
          .order('id', ascending: false)
          .limit(4);
      
      // Get user names for each aspirasi
      if (response is List && response.isNotEmpty) {
        for (var aspirasi in response) {
          try {
            final userId = aspirasi['user_id'];
            if (userId != null) {
              final userResponse = await _supabase
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
      
      if (mounted) {
        setState(() {
          _recentAspirasi = response is List ? List<Map<String, dynamic>>.from(response) : [];
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

  Future<void> _loadRecentBroadcast() async {
    try {
      print('🔍 Loading broadcast data...');
      
      final response = await _supabase
          .from('broadcast')
          .select('uuid, judul_broadcast, isi_broadcast')
          .limit(3);
      
      print('✅ Broadcast query completed');
      print('📊 Broadcast data: $response');
      print('📊 Is List: ${response is List}');
      print('📊 Length: ${response is List ? response.length : "Not a list"}');
      
      if (mounted) {
        setState(() {
          _recentBroadcast = response is List ? List<Map<String, dynamic>>.from(response) : [];
          _isLoadingBroadcast = false;
        });
        print('✅ State updated - ${_recentBroadcast.length} broadcast loaded');
        print('📊 _recentBroadcast contents: $_recentBroadcast');
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

  Future<void> _loadData() async {
    try {
      // Load total warga
      final wargaResponse = await _supabase.from('warga_profiles').select('id');

      // Load total keluarga
      final keluargaResponse = await _supabase.from('keluarga').select('id');

      // Load total rumah
      final rumahResponse = await _supabase.from('rumah').select('id');

      // Load total aspirasi
      final aspirasiResponse = await _supabase.from('aspirasi').select('id');

      if (mounted) {
        setState(() {
          _totalWarga = wargaResponse.length;
          _totalKeluarga = keluargaResponse.length;
          _totalRumah = rumahResponse.length;
          _totalAspirasi = aspirasiResponse.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: {
        2: (ctx, scope) => _buildWargaSection(ctx, scope),
      },
    );
  }

  Widget _buildWargaSection(
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
                  'Warga',
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
              'Bagaimana Kabar\nKeluarga Hari Ini?',
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
                      Icons.people_alt_rounded,
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
                          'Total Warga',
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
                              _isLoading ? '...' : '$_totalWarga',
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
                            Icons.people_alt_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalKeluarga',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Keluarga',
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
                            Icons.home_filled,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalRumah',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Rumah',
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
                            Icons.campaign_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalAspirasi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Aspirasi',
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
                            Icons.verified_user_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalWarga',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total',
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
                onPressed: () => context.goNamed('statistik-warga'),
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
                  icon: Icons.people_alt_rounded,
                  label: 'Keluarga',
                  onTap: () => context.goNamed('warga-daftar-keluarga'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Tambah Warga',
                  onTap: () => context.goNamed('warga-add'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.list_alt_rounded,
                  label: 'Daftar Warga',
                  onTap: () => context.goNamed('warga-daftar-warga'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.home_work_rounded,
                  label: 'Tambah Rumah',
                  onTap: () => context.goNamed('tambah-rumah'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.home_filled,
                  label: 'Daftar Rumah',
                  onTap: () => context.goNamed('daftar-rumah'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.campaign_rounded,
                  label: 'Aspirasi',
                  onTap: () => context.goNamed('aspirasi-list'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.verified_user_rounded,
                  label: 'Penerimaan Warga',
                  onTap: () => context.goNamed('warga-add'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Tambah Mutasi',
                  onTap: () => context.goNamed('mutasi-keluarga'),
                ),
              ],
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 32),
            Text(
              'Aspirasi Warga Terbaru',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
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
                final userName = aspirasi['user_name'] ?? 'Warga';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                aspirasi['judul_aspirasi'] ?? aspirasi['deskripsi_aspirasi'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
            Text(
              'Broadcast Terbaru',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingBroadcast)
              const Center(child: CircularProgressIndicator())
            else if (_recentBroadcast.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Belum ada broadcast',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Cek console log untuk debug info',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
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
                            Icons.campaign,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                broadcast['judul_broadcast'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                broadcast['isi_broadcast'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
          ],
        ),
      ),
    );
  }

  static Widget _buildWargaItem({
    required IconData icon,
    required Color iconColor,
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
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
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
                childAspectRatio: 0.75,
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
