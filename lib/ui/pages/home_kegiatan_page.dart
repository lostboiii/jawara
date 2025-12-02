import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';

class HomeKegiatanPage extends StatefulWidget {
  const HomeKegiatanPage({super.key});

  @override
  State<HomeKegiatanPage> createState() => _HomeKegiatanPageState();
}

class _HomeKegiatanPageState extends State<HomeKegiatanPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _totalKegiatan = 0;
  int _totalBroadcast = 0;
  int _kegiatanAkanDatang = 0;
  int _kegiatanSelesai = 0;
  Map<String, dynamic>? _nextKegiatan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      
      // Load total kegiatan
      final kegiatanResponse = await _supabase
          .from('kegiatan')
          .select('id');

      // Load total broadcast
      final broadcastResponse = await _supabase
          .from('broadcast')
          .select('id');

      // Load kegiatan yang akan datang (tanggal >= hari ini)
      final akanDatangResponse = await _supabase
          .from('kegiatan')
          .select('id')
          .gte('tanggal_kegiatan', now.toIso8601String());

      // Load kegiatan selesai (tanggal < hari ini)
      final selesaiResponse = await _supabase
          .from('kegiatan')
          .select('id')
          .lt('tanggal_kegiatan', now.toIso8601String());

      // Load kegiatan terdekat
      final nextKegiatanResponse = await _supabase
          .from('kegiatan')
          .select('nama_kegiatan, tanggal_kegiatan')
          .gte('tanggal_kegiatan', now.toIso8601String())
          .order('tanggal_kegiatan')
          .limit(1);

      if (mounted) {
        setState(() {
          _totalKegiatan = kegiatanResponse.length;
          _totalBroadcast = broadcastResponse.length;
          _kegiatanAkanDatang = akanDatangResponse.length;
          _kegiatanSelesai = selesaiResponse.length;
          _nextKegiatan = nextKegiatanResponse.isNotEmpty 
              ? nextKegiatanResponse.first 
              : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading kegiatan data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 3,
      sectionBuilders: {
        3: (ctx, scope) => _buildKegiatanSection(ctx, scope),
      },
    );
  }

  Widget _buildKegiatanSection(
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
                  'Kegiatan',
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
              'Yuk Cek\nKegiatan Hari Ini!',
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
                      Icons.event_note_rounded,
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
                          'Total Kegiatan',
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
                              _isLoading ? '...' : '$_totalKegiatan',
                              style: GoogleFonts.inter(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 8),
                              child: Text(
                                'Kegiatan',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                            Icons.play_arrow_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalBroadcast',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Broadcast',
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                            Icons.calendar_month_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_kegiatanAkanDatang',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Akan Datang',
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                            Icons.check_circle_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_kegiatanSelesai',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selesai',
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                            Icons.event_note_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLoading ? '...' : '$_totalKegiatan',
                          style: GoogleFonts.inter(
                            fontSize: 24,
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
                onPressed: () => context.goNamed('statistik-kegiatan'),
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
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              children: [
                scope.buildMenuIcon(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Tambah Kegiatan',
                  onTap: () => context.goNamed('create-kegiatan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.event_available_rounded,
                  label: 'Daftar Kegiatan',
                  onTap: () => context.goNamed('list-kegiatan'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.broadcast_on_personal_rounded,
                  label: 'Tambah Broadcast',
                  onTap: () => context.goNamed('create-broadcast'),
                ),
                scope.buildMenuIcon(
                  icon: Icons.list_alt_rounded,
                  label: 'Daftar Broadcast',
                  onTap: () => context.goNamed('list-broadcast'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Kegiatan Berlangsung',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups_2_rounded,
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
                          'Rapat Rutin RW',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Membahas program kerja dan keuangan RW',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Balai Warga RW 05',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
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
          ],
        ),
      ),
    );
  }
}