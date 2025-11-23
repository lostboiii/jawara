import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:jawara/data/repositories/warga_repositories.dart';

import '../home_page.dart';

class WargaListItem {
  WargaListItem({
    required this.id,
    required this.namaLengkap,
    required this.nik,
    required this.jenisKelamin,
    required this.agama,
    required this.pekerjaan,
    required this.peranKeluarga,
    required this.golonganDarah,
    this.noTelepon,
    this.keluargaId,
    this.namaKeluarga,
    this.tempatLahir,
    this.tanggalLahir,
    this.pendidikan,
  });

  final String id;
  final String namaLengkap;
  final String nik;
  final String jenisKelamin;
  final String agama;
  final String pekerjaan;
  final String peranKeluarga;
  final String golonganDarah;
  final String? noTelepon;
  final String? keluargaId;
  final String? namaKeluarga;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? pendidikan;

  bool get isActive => keluargaId != null && keluargaId!.isNotEmpty;

  String get statusLabel => isActive ? 'Aktif' : 'Tidak Aktif';

  String get keluargaLabel => namaKeluarga ?? 'Tidak Berkeluarga';

  String get displayName =>
      namaLengkap.isNotEmpty ? namaLengkap : 'Nama tidak tersedia';

  String get peranLabel =>
      peranKeluarga.isNotEmpty ? peranKeluarga : 'Belum ditetapkan';

  String get nikDisplay => nik.isNotEmpty ? nik : 'NIK belum tersedia';
}

class DaftarWargaPage extends StatefulWidget {
  const DaftarWargaPage({super.key});

  @override
  State<DaftarWargaPage> createState() => _DaftarWargaPageState();
}

class _DaftarWargaPageState extends State<DaftarWargaPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<WargaListItem> _wargaList = <WargaListItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWarga();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWarga() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<WargaRepository>();
      final wargaRaw = await repository.getAllWarga();

      final List<WargaListItem> fetchedWarga = wargaRaw.map((data) {
        DateTime? parsedTanggalLahir;
        if (data['tanggal_lahir'] != null) {
          try {
            parsedTanggalLahir =
                DateTime.parse(data['tanggal_lahir'] as String);
          } catch (e) {
            parsedTanggalLahir = null;
          }
        }

        // Extract nama keluarga dari data yang di-join
        String? namaKeluarga;
        if (data['keluarga'] != null && data['keluarga'] is Map) {
          final keluargaData = data['keluarga'] as Map<String, dynamic>;
          if (keluargaData['warga_profiles'] != null) {
            final kepalaKeluargaData =
                keluargaData['warga_profiles'] as Map<String, dynamic>;
            namaKeluarga = kepalaKeluargaData['nama_lengkap'] as String?;
          }
        }

        return WargaListItem(
          id: (data['id'] as String?) ?? '',
          namaLengkap: (data['nama_lengkap'] as String?) ?? '',
          nik: (data['nik'] as String?) ?? '',
          jenisKelamin: (data['jenis_kelamin'] as String?) ?? '',
          agama: (data['agama'] as String?) ?? '',
          pekerjaan: (data['pekerjaan'] as String?) ?? '',
          peranKeluarga: (data['peran_keluarga'] as String?) ?? '',
          golonganDarah: (data['golongan_darah'] as String?) ?? '',
          noTelepon: (data['no_telepon'] as String?)?.trim(),
          keluargaId: data['keluarga_id'] as String?,
          namaKeluarga: namaKeluarga,
          tempatLahir: (data['tempat_lahir'] as String?)?.trim(),
          tanggalLahir: parsedTanggalLahir,
          pendidikan: (data['pendidikan'] as String?)?.trim(),
        );
      }).toList();

      fetchedWarga.sort((a, b) => a.namaLengkap.compareTo(b.namaLengkap));

      if (!mounted) return;
      setState(() {
        _wargaList
          ..clear()
          ..addAll(fetchedWarga);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<WargaListItem> get _filteredWarga {
    if (_searchQuery.isEmpty) {
      return List<WargaListItem>.from(_wargaList);
    }

    final query = _searchQuery.toLowerCase();
    return _wargaList.where((warga) {
      final nameMatch = warga.displayName.toLowerCase().contains(query);
      final nikMatch = warga.nikDisplay.toLowerCase().contains(query);
      final peranMatch = warga.peranLabel.toLowerCase().contains(query);
      return nameMatch || nikMatch || peranMatch;
    }).toList();
  }

  Future<void> _onRefresh() => _loadWarga();

  @override
  Widget build(BuildContext context) {
    return HomePage(
      initialIndex: 2,
      sectionBuilders: {
        2: _buildSection,
      },
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
                  onPressed: () => context.goNamed('home-warga'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Warga',
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
                      hintText: 'Cari nama, NIK, atau peran',
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
                  child:
                      const Icon(Icons.filter_alt_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data warga.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _loadWarga,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (_filteredWarga.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada warga yang sesuai.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Periksa kata kunci pencarian atau tarik untuk memuat ulang.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ..._filteredWarga.map(
                (warga) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _WargaCard(warga: warga),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WargaCard extends StatelessWidget {
  const _WargaCard({required this.warga});

  final WargaListItem warga;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    final statusColor =
        warga.isActive ? const Color(0xff34C759) : const Color(0xffF75555);

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
                      warga.displayName,
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
                          warga.isActive
                              ? Icons.people_outline
                              : Icons.person_off_outlined,
                          size: 14,
                          color: const Color(0xffA1A1A1),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            warga.keluargaLabel,
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
                  warga.statusLabel,
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
              onPressed: () => context.goNamed(
                'warga-detail',
                extra: warga,
              ),
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
