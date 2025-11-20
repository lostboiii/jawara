import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:jawara/data/models/keluarga.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

import '../home_page.dart';

class KeluargaListItem {
  KeluargaListItem({
    required this.keluarga,
    required this.kepalaNama,
    required this.kepalaRole,
    required this.alamat,
    required List<KeluargaMember> members,
  }) : members = List<KeluargaMember>.unmodifiable(members);

  final Keluarga keluarga;
  final String kepalaNama;
  final String kepalaRole;
  final String? alamat;
  final List<KeluargaMember> members;

  bool get isActive => members.isNotEmpty;

  String get statusLabel => isActive ? 'Aktif' : 'Tidak Aktif';

  String get displayName {
    if (kepalaNama.isNotEmpty) {
      return 'Keluarga $kepalaNama';
    }
    if (keluarga.nomorKk.isNotEmpty) {
      return 'Keluarga ${keluarga.nomorKk}';
    }
    return 'Keluarga';
  }

  String get hunianLabel =>
      kepalaRole.isNotEmpty ? kepalaRole : 'Belum ditetapkan';

  String get alamatDisplay => (alamat != null && alamat!.isNotEmpty)
      ? alamat!
      : 'Alamat belum tersedia';
}

class KeluargaMember {
  KeluargaMember({
    required this.id,
    required this.relation,
    required this.name,
    required this.nik,
    required this.gender,
    this.phone,
  });

  final String id;
  final String relation;
  final String name;
  final String nik;
  final String gender;
  final String? phone;

  String get genderLabel => gender.isNotEmpty ? gender : 'Tidak diketahui';

  String get relationLabel => relation.isNotEmpty ? relation : 'Anggota';
}

class DaftarKeluargaPage extends StatefulWidget {
  const DaftarKeluargaPage({super.key});

  @override
  State<DaftarKeluargaPage> createState() => _DaftarKeluargaPageState();
}

class _DaftarKeluargaPageState extends State<DaftarKeluargaPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<KeluargaListItem> _families = <KeluargaListItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<WargaRepository>();
      final keluargaRaw = await repository.getAllKeluarga();
      final wargaRaw = await repository.getAllWarga();

      final Map<String, List<KeluargaMember>> membersByKeluarga = {};

      for (final warga in wargaRaw) {
        final keluargaId = warga['keluarga_id'] as String?;
        if (keluargaId == null) continue;

        final member = KeluargaMember(
          id: (warga['id'] as String?) ?? '',
          relation: (warga['peran_keluarga'] as String?) ?? '',
          name: (warga['nama_lengkap'] as String?) ?? '-',
          nik: (warga['nik'] as String?) ?? '-',
          gender: (warga['jenis_kelamin'] as String?) ?? '',
          phone: (warga['no_telepon'] as String?)?.trim(),
        );

        membersByKeluarga
            .putIfAbsent(keluargaId, () => <KeluargaMember>[])
            .add(member);
      }

      final List<KeluargaListItem> fetchedFamilies = keluargaRaw.map((data) {
        final keluarga = Keluarga.fromJson(data);
        final members =
            membersByKeluarga[keluarga.id ?? ''] ?? <KeluargaMember>[];

        String kepalaRole = '';
        for (final member in members) {
          if (member.id == keluarga.kepalakeluargaId) {
            kepalaRole = member.relationLabel;
            break;
          }
        }

        final kepalaNama = (data['warga_profiles'] is Map<String, dynamic>)
            ? ((data['warga_profiles'] as Map<String, dynamic>)['nama_lengkap']
                    as String? ??
                '')
            : '';

        return KeluargaListItem(
          keluarga: keluarga,
          kepalaNama: kepalaNama,
          kepalaRole: kepalaRole,
          alamat: data['alamat'] as String?,
          members: members,
        );
      }).toList();

      fetchedFamilies.sort((a, b) {
        final createdA =
            a.keluarga.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final createdB =
            b.keluarga.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return createdB.compareTo(createdA);
      });

      if (!mounted) return;
      setState(() {
        _families
          ..clear()
          ..addAll(fetchedFamilies);
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

  List<KeluargaListItem> get _filteredFamilies {
    if (_searchQuery.isEmpty) {
      return List<KeluargaListItem>.from(_families);
    }

    final query = _searchQuery.toLowerCase();
    return _families.where((family) {
      final nameMatch = family.displayName.toLowerCase().contains(query);
      final kkMatch = family.keluarga.nomorKk.toLowerCase().contains(query);
      final alamatMatch = family.alamatDisplay.toLowerCase().contains(query);
      return nameMatch || kkMatch || alamatMatch;
    }).toList();
  }

  Future<void> _onRefresh() => _loadFamilies();

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
                  'Daftar Keluarga',
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
                      hintText: 'Cari nama, nomor KK, atau alamat',
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
                      'Gagal memuat data keluarga.',
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
                      onPressed: _loadFamilies,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (_filteredFamilies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.groups_outlined,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada keluarga yang sesuai.',
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
              ..._filteredFamilies.map(
                (family) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FamilyCard(family: family),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.family});

  final KeluargaListItem family;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    final statusColor =
        family.isActive ? const Color(0xff34C759) : const Color(0xffF75555);

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
                child: Text(
                  family.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  family.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.emoji_people_rounded,
                  size: 16, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Text(
                family.hunianLabel,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  family.alamatDisplay,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.badge_outlined,
                  size: 16, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Text(
                family.keluarga.nomorKk.isNotEmpty
                    ? 'No. KK ${family.keluarga.nomorKk}'
                    : 'Nomor KK belum terdata',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.goNamed(
                'warga-keluarga-detail',
                extra: family,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Detail',
                style: GoogleFonts.inter(
                  fontSize: 16,
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
