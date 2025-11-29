import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';

import '../home_page.dart';
import 'edit_warga_page.dart';

class DaftarWargaPage extends StatelessWidget {
  const DaftarWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DaftarWargaViewModel(
        repository: context.read<WargaRepository>(),
      )..loadWarga(),
      child: const _DaftarWargaPageContent(),
    );
  }
}

class _DaftarWargaPageContent extends StatelessWidget {
  const _DaftarWargaPageContent();

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
    final viewModel = context.watch<DaftarWargaViewModel>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.loadWarga,
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
                    controller: viewModel.searchController,
                    onChanged: viewModel.setSearchQuery,
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
                      'Gagal memuat data warga.',
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
                      onPressed: viewModel.loadWarga,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (viewModel.filteredWarga.isEmpty)
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
              ...viewModel.filteredWarga.map(
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
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
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWargaPage(warga: warga),
                    ),
                  ).then((result) {
                    if (result == true) {
                      // Refresh list if edit was successful
                      final viewModel = context.read<DaftarWargaViewModel>();
                      viewModel.loadWarga();
                    }
                  }),
                  icon: Icon(
                    Icons.edit,
                    color: primaryColor,
                    size: 20,
                  ),
                  tooltip: 'Edit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
