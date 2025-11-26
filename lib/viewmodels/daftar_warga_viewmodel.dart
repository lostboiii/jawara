import 'package:flutter/material.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

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

class DaftarWargaViewModel extends ChangeNotifier {
  final WargaRepository _repository;

  DaftarWargaViewModel({required WargaRepository repository})
      : _repository = repository;

  final TextEditingController searchController = TextEditingController();
  final List<WargaListItem> _wargaList = <WargaListItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<WargaListItem> get wargaList => _wargaList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<WargaListItem> get filteredWarga {
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadWarga() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final wargaRaw = await _repository.getAllWarga();

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

      _wargaList
        ..clear()
        ..addAll(fetchedWarga);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
