import 'package:flutter/material.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

class TambahWargaViewModel extends ChangeNotifier {
  final WargaRepository _repository;

  TambahWargaViewModel({required WargaRepository repository})
      : _repository = repository;

  // State
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _keluargaList = [];
  List<Map<String, dynamic>> _rumahList = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get keluargaList => _keluargaList;
  List<Map<String, dynamic>> get rumahList => _rumahList;

  // Options untuk dropdown
  final List<String> jenisKelaminOptions = [
    'Laki-Laki',
    'Perempuan',
  ];

  final List<String> agamaOptions = [
    'islam',
    'kristen',
    'katolik',
    'hindu',
    'buddha',
    'konghucu',
  ];

  final List<String> golonganDarahOptions = [
    'A',
    'B',
    'AB',
    'O',
  ];

  final List<String> peranKeluargaOptions = [
    'kepala keluarga',
    'ibu rumah tangga',
    'anak',
    'lainnya',
  ];

  final List<String> pendidikanOptions = [
    'Tidak/Belum Sekolah',
    'SD',
    'SMP',
    'SMA',
    'D3',
    'S1',
    'S2',
    'S3',
  ];

  /// Load daftar keluarga untuk dropdown
  Future<void> loadKeluargaList() async {
    try {
      _keluargaList = await _repository.getAllKeluarga();
      debugPrint('Total keluarga dari database: ${_keluargaList.length}');
      
      // Debug: print semua keluarga
      for (var keluarga in _keluargaList) {
        debugPrint('Keluarga: ${keluarga['nama_kepala_keluarga']} (ID: ${keluarga['id']})');
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat daftar keluarga: $e';
      notifyListeners();
      debugPrint(_error);
    }
  }

  /// Load daftar rumah yang masih kosong
  Future<void> loadRumahList() async {
    try {
      final allRumah = await _repository.getRumahList();
      debugPrint('Total rumah dari database: ${allRumah.length}');
      
      // Debug: print semua status
      for (var rumah in allRumah) {
        debugPrint('Rumah ${rumah['alamat']}: status = ${rumah['status_rumah']}');
      }
      
      // Filter only rumah with status 'kosong'
      _rumahList = allRumah.where((rumah) {
        final status = rumah['status_rumah'] as String?;
        final isKosong = status?.toLowerCase() == 'kosong';
        debugPrint('Checking rumah ${rumah['alamat']}: status=$status, isKosong=$isKosong');
        return isKosong;
      }).toList();
      
      debugPrint('Rumah kosong yang difilter: ${_rumahList.length}');
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat daftar rumah: $e';
      notifyListeners();
      debugPrint(_error);
    }
  }

  /// Simpan data warga baru
  Future<bool> saveWarga({
    required String userId,
    required String namaLengkap,
    required String nik,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    required String peranKeluarga,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikan,
    String? keluargaId,
    String? nomorKk,
    String? rumahId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create profile (userId is now a generated UUID, not auth user ID)
      await _repository.createProfile(
        userId: userId,
        namaLengkap: namaLengkap,
        nik: nik,
        noHp: noHp,
        jenisKelamin: jenisKelamin,
        agama: agama,
        golonganDarah: golonganDarah,
        pekerjaan: pekerjaan,
        peranKeluarga: peranKeluarga,
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        pendidikan: pendidikan,
      );

      // Handle berdasarkan peran keluarga
      if (peranKeluarga == 'kepala keluarga') {
        // Validasi nomor KK dan rumah harus diisi
        if (nomorKk == null || nomorKk.isEmpty) {
          throw 'Nomor KK harus diisi untuk kepala keluarga';
        }
        if (rumahId == null || rumahId.isEmpty) {
          throw 'Alamat rumah harus dipilih untuk kepala keluarga';
        }

        // Buat keluarga baru dengan userId sebagai kepala keluarga
        await _repository.createKeluarga(
          kepalakeluargaId: userId,
          nomorKk: nomorKk,
          rumahId: rumahId,
        );

        // Update status rumah menjadi ditempati
        await _repository.updateRumahStatusToOccupied(rumahId);
      } else {
        // Untuk anggota keluarga, link ke keluarga yang dipilih
        if (keluargaId != null && keluargaId.isNotEmpty) {
          await _repository.linkWargaToKeluarga(userId, keluargaId);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan data: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_error);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
