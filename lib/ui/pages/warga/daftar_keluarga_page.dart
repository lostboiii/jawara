import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/viewmodels/daftar_keluarga_viewmodel.dart';

import '../home_page.dart';

class DaftarKeluargaPage extends StatelessWidget {
  const DaftarKeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DaftarKeluargaViewModel(
        repository: context.read<WargaRepository>(),
      )..loadFamilies(),
      child: const _DaftarKeluargaPageContent(),
    );
  }
}

class _DaftarKeluargaPageContent extends StatelessWidget {
  const _DaftarKeluargaPageContent();

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
    final viewModel = context.watch<DaftarKeluargaViewModel>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadFamilies,
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
                    controller: viewModel.searchController,
                    onChanged: viewModel.setSearchQuery,
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
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (viewModel.errorMessage != null)
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
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: viewModel.loadFamilies,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (viewModel.filteredFamilies.isEmpty)
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
              ...viewModel.filteredFamilies.map(
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
