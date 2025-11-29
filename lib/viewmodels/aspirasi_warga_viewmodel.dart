import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AspirasiItem {
  AspirasiItem({
    required this.id,
    required this.pengirim,
    required this.judul,
    required this.status,
    required this.tanggalDibuat,
  });

  final String id;
  final String pengirim;
  final String judul;
  final String status;
  final DateTime tanggalDibuat;

  String get statusLabel {
    final String value = status.trim().toLowerCase();
    switch (value) {
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  Color get statusColor {
    final String value = status.trim().toLowerCase();
    switch (value) {
      case 'diterima':
        return const Color(0xff22C55E);
      case 'ditolak':
        return const Color(0xffEF4444);
      default:
        return const Color(0xffF59E0B);
    }
  }

  String get tanggalLabel => DateFormat('dd MMM yyyy').format(tanggalDibuat);

  AspirasiItem copyWith({String? statusBaru}) {
    return AspirasiItem(
      id: id,
      pengirim: pengirim,
      judul: judul,
      status: statusBaru ?? status,
      tanggalDibuat: tanggalDibuat,
    );
  }
}

class AspirasiWargaViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final List<AspirasiItem> _aspirasi = <AspirasiItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<AspirasiItem> get aspirasi => List<AspirasiItem>.unmodifiable(_aspirasi);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalAspirasi => _aspirasi.length;
  int get totalPending => _aspirasi
      .where((AspirasiItem item) => item.statusLabel == 'Pending')
      .length;
  int get totalDiterima => _aspirasi
      .where((AspirasiItem item) => item.statusLabel == 'Diterima')
      .length;
  int get totalDitolak => _aspirasi
      .where((AspirasiItem item) => item.statusLabel == 'Ditolak')
      .length;

  List<AspirasiItem> get filteredAspirasi {
    if (_searchQuery.isEmpty) {
      return List<AspirasiItem>.from(_aspirasi);
    }

    final String query = _searchQuery.toLowerCase();
    return _aspirasi.where((AspirasiItem item) {
      final bool matchJudul = item.judul.toLowerCase().contains(query);
      final bool matchPengirim = item.pengirim.toLowerCase().contains(query);
      final bool matchStatus = item.statusLabel.toLowerCase().contains(query);
      return matchJudul || matchPengirim || matchStatus;
    }).toList();
  }

  Future<void> loadAspirasi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _aspirasi
        ..clear()
        ..addAll(_dummyData);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Gagal memuat aspirasi: $error';
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateStatus(String id, String statusBaru) {
    final int index =
        _aspirasi.indexWhere((AspirasiItem item) => item.id == id);
    if (index == -1) {
      return;
    }
    _aspirasi[index] = _aspirasi[index].copyWith(statusBaru: statusBaru);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

final List<AspirasiItem> _dummyData = <AspirasiItem>[
  AspirasiItem(
    id: 'ASP-001',
    pengirim: 'Siti Rahma',
    judul: 'Perbaikan Lampu Jalan',
    status: 'pending',
    tanggalDibuat: DateTime.now().subtract(const Duration(days: 2)),
  ),
  AspirasiItem(
    id: 'ASP-002',
    pengirim: 'Budi Santoso',
    judul: 'Program Kebersihan Rutin',
    status: 'diterima',
    tanggalDibuat: DateTime.now().subtract(const Duration(days: 7)),
  ),
  AspirasiItem(
    id: 'ASP-003',
    pengirim: 'Intan Permata',
    judul: 'Tambahan Tempat Sampah',
    status: 'pending',
    tanggalDibuat: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AspirasiItem(
    id: 'ASP-004',
    pengirim: 'Andi Wijaya',
    judul: 'Pos Ronda Malam',
    status: 'ditolak',
    tanggalDibuat: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
