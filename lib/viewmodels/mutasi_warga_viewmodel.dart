import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MutasiItem {
  MutasiItem({
    required this.id,
    required this.tanggal,
    required this.keluarga,
    required this.jenis,
    required this.alasan,
  });

  final String id;
  final DateTime tanggal;
  final String keluarga;
  final String jenis;
  final String alasan;

  String get tanggalLabel => DateFormat('dd MMM yyyy').format(tanggal);

  Color get jenisColor {
    switch (jenis.toLowerCase()) {
      case 'pindah rumah':
        return const Color(0xff22C55E);
      case 'keluar perumahan':
        return const Color(0xffEF4444);
      default:
        return const Color(0xff3B82F6);
    }
  }

  String get jenisLabel {
    final String value = jenis.trim();
    if (value.isEmpty) {
      return 'Mutasi';
    }
    return value.split(' ').map((String word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class MutasiWargaViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final List<MutasiItem> _mutasi = <MutasiItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<MutasiItem> get mutasi => List<MutasiItem>.unmodifiable(_mutasi);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalMutasi => _mutasi.length;
  int get totalDatang => _mutasi
      .where((MutasiItem item) => item.jenis.toLowerCase() == 'pindah rumah')
      .length;
  int get totalPergi => _mutasi
      .where(
          (MutasiItem item) => item.jenis.toLowerCase() == 'keluar perumahan')
      .length;

  List<MutasiItem> get filteredMutasi {
    if (_searchQuery.isEmpty) {
      return List<MutasiItem>.from(_mutasi);
    }
    final String query = _searchQuery.toLowerCase();
    return _mutasi.where((MutasiItem item) {
      final bool matchTanggal = item.tanggalLabel.toLowerCase().contains(query);
      final bool matchKeluarga = item.keluarga.toLowerCase().contains(query);
      final bool matchJenis = item.jenis.toLowerCase().contains(query);
      final bool matchAlasan = item.alasan.toLowerCase().contains(query);
      return matchTanggal || matchKeluarga || matchJenis || matchAlasan;
    }).toList();
  }

  Future<void> loadMutasi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _mutasi
        ..clear()
        ..addAll(_dummyData);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Gagal memuat data mutasi: $error';
      _isLoading = false;
      notifyListeners();
    }
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

final List<MutasiItem> _dummyData = <MutasiItem>[
  MutasiItem(
    id: 'MTS-001',
    tanggal: DateTime.now().subtract(const Duration(days: 3)),
    keluarga: 'Keluarga Rahmawati',
    jenis: 'pindah rumah',
    alasan: 'Pindah dari luar kota dan menetap di Blok B5.',
  ),
  MutasiItem(
    id: 'MTS-002',
    tanggal: DateTime.now().subtract(const Duration(days: 10)),
    keluarga: 'Keluarga Wijaya',
    jenis: 'keluar perumahan',
    alasan: 'Pindah ke rumah keluarga di Surabaya.',
  ),
  MutasiItem(
    id: 'MTS-003',
    tanggal: DateTime.now().subtract(const Duration(days: 25)),
    keluarga: 'Keluarga Santoso',
    jenis: 'pindah rumah',
    alasan: 'Pindah karena penugasan kerja di wilayah ini.',
  ),
];
