import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_aktivitas_dialog.dart';

class ActivityLog {
  final int no;
  final String deskripsi;
  final String aktor;
  final DateTime tanggal;

  ActivityLog({
    required this.no,
    required this.deskripsi,
    required this.aktor,
    required this.tanggal,
  });

  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }
}

List<ActivityLog> getDummyActivityLogs() {
  return [
    ActivityLog(
      no: 1,
      deskripsi:
          'Menugaskan tagihan : Mingguan periode Oktober 2025 sebesar Rp. 12',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
    ),
    ActivityLog(
      no: 2,
      deskripsi: 'Menghapus transfer channel: Bank Mega',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
    ),
    ActivityLog(
      no: 3,
      deskripsi: 'Menambahkan rumah baru dengan alamat: Jl. Merbabu',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 18),
    ),
    ActivityLog(
      no: 4,
      deskripsi: 'Mengubah iuran: Agustusan',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
    ),
    ActivityLog(
      no: 5,
      deskripsi: 'Membuat broadcast baru: DJ BAWS',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
    ),
    ActivityLog(
      no: 6,
      deskripsi: 'Menambahkan pengeluaran : Arka sebesar Rp. 6',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
    ),
    ActivityLog(
      no: 7,
      deskripsi: 'Menambahkan akun : dewqedwddw sebagai neighborhood_head',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
    ),
    ActivityLog(
      no: 8,
      deskripsi: 'Memperbarui data warga: varizkiy naldiba rimra',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 17),
    ),
    ActivityLog(
      no: 9,
      deskripsi: 'Menyetujui registrasi dari : Keluarga Rendha Putra Rahmadya',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 16),
    ),
    ActivityLog(
      no: 10,
      deskripsi:
          'Menugaskan tagihan : Mingguan periode Oktober 2025 sebesar Rp. 12',
      aktor: 'Admin Jawara',
      tanggal: DateTime(2025, 10, 16),
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
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int get _totalPages => (_logs.length / _itemsPerPage).ceil();

  List<ActivityLog> get _currentLogs {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _logs.length);
    return _logs.sublist(startIndex, endIndex);
  }

  void _showFilterDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const FilterAktivitasDialog(),
    );
    
    if (!mounted) return;
    if (result != null) {
      // Handle filter result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filter diterapkan: ${result['deskripsi'] ?? 'Semua'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Log Aktivitas', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.indigo[600], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
              ),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text('NO', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[700]))),
                    Expanded(flex: 5, child: Text('DESKRIPSI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[700]))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: _currentLogs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = _currentLogs[index];
                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))]),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 30, child: Text('${log.no}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.deskripsi, style: TextStyle(fontSize: 14, color: Colors.grey[900], height: 1.4)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_outline, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(log.aktor, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
                                    Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(log.formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null, color: _currentPage > 1 ? Colors.grey[700] : Colors.grey[300]),
                    const SizedBox(width: 8),
                    ..._buildPageNumbers(),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null, color: _currentPage < _totalPages ? Colors.grey[700] : Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    if (_currentPage > 1) pages.add(_buildPageButton(1));
    if (_currentPage > 2) pages.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey[600]))));
    pages.add(_buildPageButton(_currentPage, isActive: true));
    if (_currentPage < _totalPages - 1) pages.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: Colors.grey[600]))));
    if (_currentPage < _totalPages) pages.add(_buildPageButton(_totalPages));
    return pages;
  }

  Widget _buildPageButton(int page, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isActive ? Colors.indigo[600] : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Text('$page', style: TextStyle(color: isActive ? Colors.white : Colors.grey[700], fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
      ),
    );
  }
}
