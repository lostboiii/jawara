import 'package:flutter/material.dart';

class PenghuniHistoryItem {
  PenghuniHistoryItem({
    required this.keluarga,
    required this.kepalaKeluarga,
    required this.tanggalMasuk,
    this.tanggalKeluar,
  });

  final String keluarga;
  final String kepalaKeluarga;
  final DateTime tanggalMasuk;
  final DateTime? tanggalKeluar;

  bool get masihTinggal => tanggalKeluar == null;
}

class RumahListItem {
  RumahListItem({
    required this.id,
    required this.alamat,
    required this.status,
    required this.riwayatPenghuni,
  });

  final String id;
  final String alamat;
  final String status;
  final List<PenghuniHistoryItem> riwayatPenghuni;

  String get alamatDisplay =>
      alamat.isNotEmpty ? alamat : 'Alamat belum tersedia';

  String get statusLabel {
    final String trimmed = status.trim();
    if (trimmed.isEmpty) {
      return isKosong ? 'Kosong' : 'Ditempati';
    }
    final List<String> words = trimmed.toLowerCase().split(' ');
    return words
        .map((String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  bool get isKosong => status.trim().toLowerCase() == 'kosong';
  bool get isDitempati => !isKosong;

  PenghuniHistoryItem? get penghuniAktif {
    try {
      return riwayatPenghuni
          .firstWhere((PenghuniHistoryItem item) => item.masihTinggal);
    } catch (_) {
      return null;
    }
  }
}

class DaftarRumahViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final List<RumahListItem> _rumahList = <RumahListItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<RumahListItem> get rumahList =>
      List<RumahListItem>.unmodifiable(_rumahList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  int get totalRumah => _rumahList.length;
  int get totalRumahDitempati =>
      _rumahList.where((RumahListItem item) => item.isDitempati).length;
  int get totalRumahKosong =>
      _rumahList.where((RumahListItem item) => item.isKosong).length;

  List<RumahListItem> get filteredRumah {
    if (_searchQuery.isEmpty) {
      return List<RumahListItem>.from(_rumahList);
    }

    final String query = _searchQuery.toLowerCase();
    return _rumahList.where((RumahListItem item) {
      final bool matchesAlamat =
          item.alamatDisplay.toLowerCase().contains(query);
      final bool matchesStatus = item.statusLabel.toLowerCase().contains(query);
      return matchesAlamat || matchesStatus;
    }).toList();
  }

  Future<void> loadRumah() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _rumahList
        ..clear()
        ..addAll(_dummyData);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Gagal memuat data rumah: $error';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

final List<RumahListItem> _dummyData = <RumahListItem>[
  RumahListItem(
    id: 'RMH-001',
    alamat: 'Jl. Mawar No. 12, Kel. Sukamaju',
    status: 'Ditempati',
    riwayatPenghuni: <PenghuniHistoryItem>[
      PenghuniHistoryItem(
        keluarga: 'Keluarga Wiratno',
        kepalaKeluarga: 'Andi Wiratno',
        tanggalMasuk: DateTime(2021, 5, 12),
        tanggalKeluar: null,
      ),
      PenghuniHistoryItem(
        keluarga: 'Keluarga Hasan',
        kepalaKeluarga: 'Budi Hasan',
        tanggalMasuk: DateTime(2019, 1, 10),
        tanggalKeluar: DateTime(2021, 4, 28),
      ),
    ],
  ),
  RumahListItem(
    id: 'RMH-002',
    alamat: 'Jl. Melati Baru No. 7, Kel. Sukamaju',
    status: 'Kosong',
    riwayatPenghuni: <PenghuniHistoryItem>[
      PenghuniHistoryItem(
        keluarga: 'Keluarga Puspito',
        kepalaKeluarga: 'Handoko Puspito',
        tanggalMasuk: DateTime(2018, 9, 3),
        tanggalKeluar: DateTime(2023, 2, 15),
      ),
      PenghuniHistoryItem(
        keluarga: 'Keluarga Alif',
        kepalaKeluarga: 'Alif Kurnia',
        tanggalMasuk: DateTime(2015, 6, 20),
        tanggalKeluar: DateTime(2018, 8, 30),
      ),
    ],
  ),
  RumahListItem(
    id: 'RMH-003',
    alamat: 'Jl. Kenanga Raya Blok B5, Kel. Sukamaju',
    status: 'Ditempati',
    riwayatPenghuni: <PenghuniHistoryItem>[
      PenghuniHistoryItem(
        keluarga: 'Keluarga Rahmawati',
        kepalaKeluarga: 'Siti Rahmawati',
        tanggalMasuk: DateTime(2020, 11, 1),
        tanggalKeluar: null,
      ),
      PenghuniHistoryItem(
        keluarga: 'Keluarga Bhima',
        kepalaKeluarga: 'Bhima Cahya',
        tanggalMasuk: DateTime(2016, 3, 12),
        tanggalKeluar: DateTime(2020, 9, 18),
      ),
    ],
  ),
];
