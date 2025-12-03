import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class ActivityLog {
  final int no;
  final String deskripsi;
  final String aktor;
  final DateTime tanggal;
  final String tipeAktivitas; // 'create', 'update', 'delete'

  ActivityLog({
    required this.no,
    required this.deskripsi,
    required this.aktor,
    required this.tanggal,
    required this.tipeAktivitas,
  });

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
  }
}

List<ActivityLog> getDummyActivityLogs() {
  return [
    ActivityLog(
      no: 1,
      deskripsi: 'Menugaskan tagihan : Mingguan periode Oktober 2025 sebesar Rp. 12',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
      tipeAktivitas: 'create',
    ),
    ActivityLog(
      no: 2,
      deskripsi: 'Menghapus transfer channel: Bank Mega',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
      tipeAktivitas: 'delete',
    ),
    ActivityLog(
      no: 3,
      deskripsi: 'Menambahkan rumah baru dengan alamat: Jl. Merbabu',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
      tipeAktivitas: 'create',
    ),
    ActivityLog(
      no: 4,
      deskripsi: 'Mengubah iuran: Agustusan',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
      tipeAktivitas: 'update',
    ),
    ActivityLog(
      no: 5,
      deskripsi: 'Membuat broadcast baru: DJ BAWS',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
      tipeAktivitas: 'create',
    ),
    ActivityLog(
      no: 6,
      deskripsi: 'Menambahkan pengeluaran : Arka sebesar Rp. 6',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
      tipeAktivitas: 'create',
    ),
    ActivityLog(
      no: 7,
      deskripsi: 'Menambahkan akun : dewqedwddw sebagai neighborhood_head',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
      tipeAktivitas: 'create',
    ),
    ActivityLog(
      no: 8,
      deskripsi: 'Memperbarui data warga: varizkiy naldiba rimra',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
      tipeAktivitas: 'update',
    ),
    ActivityLog(
      no: 9,
      deskripsi: 'Menyetujui registrasi dari : Keluarga Rendha Putra Rahmadya',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 16),
      tipeAktivitas: 'update',
    ),
    ActivityLog(
      no: 10,
      deskripsi: 'Menugaskan tagihan : Mingguan periode Oktober 2025 sebesar Rp. 12',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 16),
      tipeAktivitas: 'create',
    ),
  ];
}

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final List<ActivityLog> _logs = getDummyActivityLogs();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter States
  String? _filterAktor;
  String? _filterAktivitas;
  DateTime? _filterTanggalMulai;
  DateTime? _filterTanggalSelesai;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ActivityLog> get _filteredLogs {
    var filtered = List<ActivityLog>.from(_logs);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((log) {
        return log.deskripsi.toLowerCase().contains(query) ||
            log.aktor.toLowerCase().contains(query);
      }).toList();
    }

    if (_filterAktor != null) {
      filtered = filtered.where((log) => log.aktor == _filterAktor).toList();
    }

    if (_filterAktivitas != null) {
      filtered = filtered
          .where((log) => log.tipeAktivitas == _filterAktivitas)
          .toList();
    }

    if (_filterTanggalMulai != null) {
      filtered = filtered.where((log) {
        return log.tanggal.isAfter(_filterTanggalMulai!) ||
            log.tanggal.isAtSameMomentAs(_filterTanggalMulai!);
      }).toList();
    }

    if (_filterTanggalSelesai != null) {
      final endOfDay = DateTime(
        _filterTanggalSelesai!.year,
        _filterTanggalSelesai!.month,
        _filterTanggalSelesai!.day,
        23,
        59,
        59,
      );
      filtered = filtered.where((log) {
        return log.tanggal.isBefore(endOfDay) ||
            log.tanggal.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    String? tempAktor = _filterAktor;
    String? tempAktivitas = _filterAktivitas;
    DateTime? tempMulai = _filterTanggalMulai;
    DateTime? tempSelesai = _filterTanggalSelesai;

    // Get unique actors
    final actors = _logs.map((e) => e.aktor).toSet().toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Aktivitas',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktor',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: tempAktor,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Pilih Aktor',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xffC7C7CD),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xffE5E5EA)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Semua Aktor'),
                                ),
                                ...actors.map((actor) => DropdownMenuItem(
                                      value: actor,
                                      child: Text(actor),
                                    )),
                              ],
                              onChanged: (val) {
                                setDialogState(() => tempAktor = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Jenis Aktivitas',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: tempAktivitas,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Pilih Aktivitas',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xffC7C7CD),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xffE5E5EA)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: null, child: Text('Semua')),
                                DropdownMenuItem(
                                    value: 'create',
                                    child: Text('Penambahan Data')),
                                DropdownMenuItem(
                                    value: 'update',
                                    child: Text('Pembaruan Data')),
                                DropdownMenuItem(
                                    value: 'delete',
                                    child: Text('Penghapusan Data')),
                              ],
                              onChanged: (val) {
                                setDialogState(() => tempAktivitas = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tanggal Mulai',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempMulai ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setDialogState(() => tempMulai = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffE5E5EA)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tempMulai != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(tempMulai!)
                                          : '-- / -- / ----',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: tempMulai != null
                                            ? Colors.black87
                                            : const Color(0xffC7C7CD),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today,
                                        size: 18, color: Color(0xffC7C7CD)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tanggal Selesai',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempSelesai ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setDialogState(() => tempSelesai = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffE5E5EA)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tempSelesai != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(tempSelesai!)
                                          : '-- / -- / ----',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: tempSelesai != null
                                            ? Colors.black87
                                            : const Color(0xffC7C7CD),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today,
                                        size: 18, color: Color(0xffC7C7CD)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _filterAktor = null;
                                _filterAktivitas = null;
                                _filterTanggalMulai = null;
                                _filterTanggalSelesai = null;
                              });
                              Navigator.pop(dialogContext);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xffE5E5EA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filterAktor = tempAktor;
                                _filterAktivitas = tempAktivitas;
                                _filterTanggalMulai = tempMulai;
                                _filterTanggalSelesai = tempSelesai;
                              });
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff5067e9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Terapkan',
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);
    return HomePage(
      initialIndex: 0,
      sectionBuilders: {
        0: (context, scope) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.goNamed('home'),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Aktivitas',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari aktivitas...',
                              hintStyle: GoogleFonts.inter(fontSize: 14),
                              prefixIcon:
                                  const Icon(Icons.search, size: 18),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: primaryColor, width: 2),
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
                          child: IconButton(
                            onPressed: _showFilterDialog,
                            icon: const Icon(Icons.filter_alt_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _filteredLogs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.history_outlined,
                                      size: 48, color: Color(0xffA1A1A1)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada aktivitas.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredLogs.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final log = _filteredLogs[index];
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.grey.shade100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.deskripsi,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline_rounded,
                                              size: 16,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Text(
                                            log.aktor,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Text(
                                            log.formattedDate,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      },
    );
  }
}