import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:jawara/data/models/keluarga.dart';

/// Fake implementation untuk testing tanpa mock
class _FakeWargaRepository implements WargaRepository {
  final List<Map<String, dynamic>> wargaData;
  final bool shouldThrowError;

  _FakeWargaRepository({
    this.wargaData = const [],
    this.shouldThrowError = false,
  });

  @override
  Future<List<Map<String, dynamic>>> getAllWarga() async {
    if (shouldThrowError) {
      throw Exception('Database connection failed');
    }
    return wargaData;
  }

  // Implementasi method lain yang tidak digunakan dalam test
  @override
  Future<WargaProfile> createProfile({
    required String userId,
    required String namaLengkap,
    required String nik,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    required String peranKeluarga,
    String? fotoIdentitasUrl,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikan,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteProfile(String userId) async => throw UnimplementedError();

  @override
  String getFotoPublicUrl(String filePath) => throw UnimplementedError();

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async =>
      throw UnimplementedError();

  @override
  Future<WargaProfile?> getProfileById(String userId) async =>
      throw UnimplementedError();

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async =>
      throw UnimplementedError();

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async =>
      throw UnimplementedError();

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(
          String kepalakeluargaId) async =>
      throw UnimplementedError();

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async =>
      throw UnimplementedError();

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getMutasiList() async =>
      throw UnimplementedError();

  @override
  Future<void> updateRumahStatus(String rumahId, String status) async =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getAllPenghuni() async =>
      throw UnimplementedError();

  @override
  Future<void> updatePenghuniRumah(
          String penghuniId, String newRumahId) async =>
      throw UnimplementedError();

  @override
  Future<void> deletePenghuni(String penghuniId) async =>
      throw UnimplementedError();

  @override
  Future<void> createPenghuni({
    required String keluargaId,
    required String rumahId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async =>
      throw UnimplementedError();

  @override
  Future<void> updateKeluargaAlamat(
          String keluargaId, String? alamatId) async =>
      throw UnimplementedError();

  @override
  Future<void> updateWarga({
    required String wargaId,
    required String namaLengkap,
    required String nik,
    required String noTelepon,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    required String peranKeluarga,
    String? keluargaId,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikan,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteWarga(String wargaId) async => throw UnimplementedError();
}

void main() {
  group('DaftarWargaViewModel Tests', () {
    test('initial state should be correct', () {
      final repository = _FakeWargaRepository();
      final viewModel = DaftarWargaViewModel(repository: repository);

      expect(viewModel.wargaList, isEmpty);
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.filteredWarga, isEmpty);

      viewModel.dispose();
    });

    test('loadWarga should fetch wargas with keluarga info', () async {
      // Arrange - Warga dengan join keluarga
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Budi Santoso',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai Swasta',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': '081234567890',
          'keluarga_id': 'kel-1',
          'tempat_lahir': 'Jakarta',
          'tanggal_lahir': '1990-01-15',
          'pendidikan': 'S1',
          // Join dengan keluarga
          'keluarga': {
            'id': 'kel-1',
            'nomor_kk': '1234567890123456',
            'warga_profiles': {
              'nama_lengkap': 'Budi Santoso',
            },
          },
        },
        {
          'id': 'warga-2',
          'nama_lengkap': 'Ani Rahayu',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'agama': 'Islam',
          'pekerjaan': 'Ibu Rumah Tangga',
          'peran_keluarga': 'Istri',
          'golongan_darah': 'A',
          'no_telepon': '081234567891',
          'keluarga_id': 'kel-1',
          'tempat_lahir': 'Bandung',
          'tanggal_lahir': '1992-05-20',
          'pendidikan': 'SMA',
          // Join dengan keluarga yang sama
          'keluarga': {
            'id': 'kel-1',
            'nomor_kk': '1234567890123456',
            'warga_profiles': {
              'nama_lengkap': 'Budi Santoso',
            },
          },
        },
        {
          'id': 'warga-3',
          'nama_lengkap': 'Ahmad Rifai',
          'nik': '3333333333333333',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Wiraswasta',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'B',
          'no_telepon': '081234567892',
          'keluarga_id': 'kel-2',
          'tempat_lahir': 'Surabaya',
          'tanggal_lahir': '1985-03-10',
          'pendidikan': 'S1',
          // Join dengan keluarga lain
          'keluarga': {
            'id': 'kel-2',
            'nomor_kk': '9876543210987654',
            'warga_profiles': {
              'nama_lengkap': 'Ahmad Rifai',
            },
          },
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      // Act
      await viewModel.loadWarga();

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.wargaList, hasLength(3));

      // Verify warga 1 dengan join keluarga
      final warga1 = viewModel.wargaList.firstWhere(
        (w) => w.nik == '1111111111111111',
      );
      expect(warga1.namaLengkap, 'Budi Santoso');
      expect(warga1.jenisKelamin, 'Laki-laki');
      expect(warga1.peranKeluarga, 'Kepala Keluarga');
      expect(warga1.keluargaId, 'kel-1');
      expect(warga1.namaKeluarga, 'Budi Santoso'); // Joined dari keluarga
      expect(warga1.isActive, isTrue);
      expect(warga1.statusLabel, 'Aktif');
      expect(warga1.keluargaLabel, 'Budi Santoso');
      expect(warga1.tanggalLahir, isNotNull);
      expect(warga1.tanggalLahir?.year, 1990);

      // Verify warga 2 dengan join keluarga yang sama
      final warga2 = viewModel.wargaList.firstWhere(
        (w) => w.nik == '2222222222222222',
      );
      expect(warga2.namaLengkap, 'Ani Rahayu');
      expect(warga2.peranKeluarga, 'Istri');
      expect(warga2.keluargaId, 'kel-1');
      expect(warga2.namaKeluarga, 'Budi Santoso'); // Same kepala keluarga
      expect(warga2.keluargaLabel, 'Budi Santoso');

      // Verify warga 3 dengan join keluarga berbeda
      final warga3 = viewModel.wargaList.firstWhere(
        (w) => w.nik == '3333333333333333',
      );
      expect(warga3.namaLengkap, 'Ahmad Rifai');
      expect(warga3.keluargaId, 'kel-2');
      expect(warga3.namaKeluarga, 'Ahmad Rifai'); // Different kepala keluarga
      expect(warga3.keluargaLabel, 'Ahmad Rifai');

      viewModel.dispose();
    });

    test('loadWarga should handle warga without keluarga', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Solo Warga',
          'nik': '4444444444444444',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Freelancer',
          'peran_keluarga': 'Belum Berkeluarga',
          'golongan_darah': 'AB',
          'no_telepon': null,
          'keluarga_id': null, // Tidak punya keluarga
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null, // No join
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      expect(viewModel.wargaList, hasLength(1));
      final warga = viewModel.wargaList.first;
      expect(warga.keluargaId, isNull);
      expect(warga.namaKeluarga, isNull);
      expect(warga.isActive, isFalse);
      expect(warga.statusLabel, 'Tidak Aktif');
      expect(warga.keluargaLabel, 'Tidak Berkeluarga');

      viewModel.dispose();
    });

    test('loadWarga should handle empty result', () async {
      final repository = _FakeWargaRepository(wargaData: []);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.wargaList, isEmpty);

      viewModel.dispose();
    });

    test('loadWarga should handle error', () async {
      final repository = _FakeWargaRepository(shouldThrowError: true);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Database connection failed'));
      expect(viewModel.wargaList, isEmpty);

      viewModel.dispose();
    });

    test('loadWarga should update loading state correctly', () async {
      final repository = _FakeWargaRepository();
      final viewModel = DaftarWargaViewModel(repository: repository);

      expect(viewModel.isLoading, isTrue);

      await viewModel.loadWarga();

      expect(viewModel.isLoading, isFalse);

      viewModel.dispose();
    });

    test('setSearchQuery should filter warga correctly', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Budi Santoso',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': '081234567890',
          'keluarga_id': 'kel-1',
          'tempat_lahir': 'Jakarta',
          'tanggal_lahir': '1990-01-15',
          'pendidikan': 'S1',
          'keluarga': {
            'id': 'kel-1',
            'nomor_kk': '1234567890123456',
            'warga_profiles': {'nama_lengkap': 'Budi Santoso'},
          },
        },
        {
          'id': 'warga-2',
          'nama_lengkap': 'Siti Nurhaliza',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'agama': 'Islam',
          'pekerjaan': 'Guru',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'A',
          'no_telepon': '081234567891',
          'keluarga_id': 'kel-2',
          'tempat_lahir': 'Bandung',
          'tanggal_lahir': '1988-07-20',
          'pendidikan': 'S1',
          'keluarga': {
            'id': 'kel-2',
            'nomor_kk': '9876543210987654',
            'warga_profiles': {'nama_lengkap': 'Siti Nurhaliza'},
          },
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      viewModel.setSearchQuery('Budi');

      expect(viewModel.searchQuery, 'Budi');
      expect(viewModel.filteredWarga, hasLength(1));
      expect(viewModel.filteredWarga.first.namaLengkap, 'Budi Santoso');

      viewModel.dispose();
    });

    test('filteredWarga should filter by NIK correctly', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Test Warga',
          'nik': '1234567890123456',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null,
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();
      viewModel.setSearchQuery('123456');

      expect(viewModel.filteredWarga, hasLength(1));
      expect(viewModel.filteredWarga.first.nik, '1234567890123456');

      viewModel.dispose();
    });

    test('filteredWarga should filter by peran keluarga correctly', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Kepala Test',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': null,
          'keluarga_id': 'kel-1',
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': {
            'id': 'kel-1',
            'nomor_kk': '1234567890123456',
            'warga_profiles': {'nama_lengkap': 'Kepala Test'},
          },
        },
        {
          'id': 'warga-2',
          'nama_lengkap': 'Istri Test',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'agama': 'Islam',
          'pekerjaan': 'IRT',
          'peran_keluarga': 'Istri',
          'golongan_darah': 'A',
          'no_telepon': null,
          'keluarga_id': 'kel-1',
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': {
            'id': 'kel-1',
            'nomor_kk': '1234567890123456',
            'warga_profiles': {'nama_lengkap': 'Kepala Test'},
          },
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();
      viewModel.setSearchQuery('Istri');

      expect(viewModel.filteredWarga, hasLength(1));
      expect(viewModel.filteredWarga.first.peranKeluarga, 'Istri');

      viewModel.dispose();
    });

    test('filteredWarga should return all warga when query is empty', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Warga 1',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null,
        },
        {
          'id': 'warga-2',
          'nama_lengkap': 'Warga 2',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'agama': 'Islam',
          'pekerjaan': 'Guru',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'A',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null,
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();
      viewModel.setSearchQuery('');

      expect(viewModel.filteredWarga, hasLength(2));

      viewModel.dispose();
    });

    test('wargaList should be sorted alphabetically by name', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Zaky Rahman',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null,
        },
        {
          'id': 'warga-2',
          'nama_lengkap': 'Andi Wijaya',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Guru',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'A',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': null,
          'pendidikan': null,
          'keluarga': null,
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      expect(viewModel.wargaList, hasLength(2));
      expect(viewModel.wargaList.first.namaLengkap, 'Andi Wijaya');
      expect(viewModel.wargaList.last.namaLengkap, 'Zaky Rahman');

      viewModel.dispose();
    });

    test('loadWarga should handle invalid date format gracefully', () async {
      final wargaData = [
        {
          'id': 'warga-1',
          'nama_lengkap': 'Test Invalid Date',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'agama': 'Islam',
          'pekerjaan': 'Pegawai',
          'peran_keluarga': 'Kepala Keluarga',
          'golongan_darah': 'O',
          'no_telepon': null,
          'keluarga_id': null,
          'tempat_lahir': null,
          'tanggal_lahir': 'invalid-date-format', // Invalid date
          'pendidikan': null,
          'keluarga': null,
        },
      ];

      final repository = _FakeWargaRepository(wargaData: wargaData);
      final viewModel = DaftarWargaViewModel(repository: repository);

      await viewModel.loadWarga();

      expect(viewModel.wargaList, hasLength(1));
      expect(viewModel.wargaList.first.tanggalLahir, isNull); // Should be null

      viewModel.dispose();
    });
  });
}
