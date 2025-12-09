import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/daftar_keluarga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:jawara/data/models/keluarga.dart';

/// Fake implementation untuk testing tanpa mock
class _FakeWargaRepository implements WargaRepository {
  final List<Map<String, dynamic>> keluargaData;
  final List<Map<String, dynamic>> wargaData;
  final bool shouldThrowError;

  _FakeWargaRepository({
    this.keluargaData = const [],
    this.wargaData = const [],
    this.shouldThrowError = false,
  });

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    if (shouldThrowError) {
      throw Exception('Database connection failed');
    }
    return keluargaData;
  }

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
  group('DaftarKeluargaViewModel Tests', () {
    test('initial state should be correct', () {
      final repository = _FakeWargaRepository();
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      expect(viewModel.families, isEmpty);
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.filteredFamilies, isEmpty);

      viewModel.dispose();
    });

    test('loadFamilies should fetch keluargas with warga count successfully',
        () async {
      // Arrange
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Budi Santoso',
          },
          'nama_rumah': 'Rumah A1',
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepala_keluarga_id': 'warga-3',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Siti Aisyah',
          },
          'nama_rumah': 'Rumah B2',
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Budi Santoso',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567890',
        },
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Ani Santoso',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Istri',
          'no_telepon': '081234567891',
        },
        {
          'id': 'warga-3',
          'keluarga_id': 'kel-2',
          'nama_lengkap': 'Siti Aisyah',
          'nik': '3333333333333333',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567892',
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      // Act
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.families, hasLength(2));

      // Verify keluarga 1 data with warga count
      final family1 = viewModel.families.firstWhere(
        (f) => f.keluarga.nomorKk == '1234567890123456',
      );
      expect(family1.kepalaNama, 'Budi Santoso');
      expect(family1.members, hasLength(2)); // Count warga = 2
      expect(family1.isActive, isTrue);
      expect(family1.statusLabel, 'Aktif');
      expect(family1.displayName, 'Keluarga Budi Santoso');
      expect(family1.alamatDisplay, 'Rumah A1');
      // kepalaRole harus cocok dengan kepala keluarga
      expect(family1.kepalaRole, 'Kepala Keluarga');

      // Verify keluarga 2 data with warga count
      final family2 = viewModel.families.firstWhere(
        (f) => f.keluarga.nomorKk == '9876543210987654',
      );
      expect(family2.kepalaNama, 'Siti Aisyah');
      expect(family2.members, hasLength(1)); // Count warga = 1
      expect(family2.isActive, isTrue);
      expect(family2.kepalaRole, 'Kepala Keluarga');

      viewModel.dispose();
    });

    test('loadFamilies should handle empty result', () async {
      final repository = _FakeWargaRepository(
        keluargaData: [],
        wargaData: [],
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.families, isEmpty);

      viewModel.dispose();
    });

    test('loadFamilies should handle error', () async {
      final repository = _FakeWargaRepository(shouldThrowError: true);
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Database connection failed'));
      expect(viewModel.families, isEmpty);

      viewModel.dispose();
    });

    test('loadFamilies should update loading state correctly', () async {
      final repository = _FakeWargaRepository();
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      expect(viewModel.isLoading, isTrue);

      await viewModel.loadFamilies();

      expect(viewModel.isLoading, isFalse);

      viewModel.dispose();
    });

    test('setSearchQuery should filter families correctly', () async {
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepalakeluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Budi Santoso',
          },
          'nama_rumah': 'Rumah A1',
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepalakeluarga_id': 'warga-2',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Siti Aisyah',
          },
          'nama_rumah': 'Rumah B2',
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Budi Santoso',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567890',
        },
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-2',
          'nama_lengkap': 'Siti Aisyah',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567891',
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();

      viewModel.setSearchQuery('Budi');

      expect(viewModel.searchQuery, 'Budi');
      expect(viewModel.filteredFamilies, hasLength(1));
      expect(viewModel.filteredFamilies.first.kepalaNama, 'Budi Santoso');

      viewModel.dispose();
    });

    test('filteredFamilies should filter by nomor KK correctly', () async {
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepalakeluarga_id': 'warga-1',
          'rumah_id': null,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Ahmad Hidayat',
          },
          'nama_rumah': null,
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Ahmad Hidayat',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();
      viewModel.setSearchQuery('123456');

      expect(viewModel.filteredFamilies, hasLength(1));
      expect(viewModel.filteredFamilies.first.keluarga.nomorKk,
          '1234567890123456');

      viewModel.dispose();
    });

    test('filteredFamilies should return all families when query is empty',
        () async {
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepalakeluarga_id': 'warga-1',
          'rumah_id': null,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Ahmad Hidayat',
          },
          'nama_rumah': null,
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepalakeluarga_id': 'warga-2',
          'rumah_id': null,
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Bambang Sutejo',
          },
          'nama_rumah': null,
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Ahmad Hidayat',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-2',
          'nama_lengkap': 'Bambang Sutejo',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();
      viewModel.setSearchQuery('');

      expect(viewModel.filteredFamilies, hasLength(2));

      viewModel.dispose();
    });

    test('families should be sorted by created_at descending', () async {
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1111111111111111',
          'kepalakeluarga_id': 'warga-1',
          'rumah_id': null,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Older Family',
          },
          'nama_rumah': null,
        },
        {
          'id': 'kel-2',
          'nomor_kk': '2222222222222222',
          'kepalakeluarga_id': 'warga-2',
          'rumah_id': null,
          'created_at': '2024-12-01T00:00:00.000Z',
          'updated_at': '2024-12-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Newer Family',
          },
          'nama_rumah': null,
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Older Family',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-2',
          'nama_lengkap': 'Newer Family',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();

      expect(viewModel.families, hasLength(2));
      expect(viewModel.families.first.kepalaNama, 'Newer Family');
      expect(viewModel.families.last.kepalaNama, 'Older Family');

      viewModel.dispose();
    });

    test('KeluargaListItem should correctly compute warga count', () async {
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepalakeluarga_id': 'warga-1',
          'rumah_id': null,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {
            'nama_lengkap': 'Test Family',
          },
          'nama_rumah': null,
        },
      ];

      final wargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Member 1',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Member 2',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Istri',
          'no_telepon': null,
        },
        {
          'id': 'warga-3',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Member 3',
          'nik': '3333333333333333',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Anak',
          'no_telepon': null,
        },
      ];

      final repository = _FakeWargaRepository(
        keluargaData: keluargaData,
        wargaData: wargaData,
      );
      final viewModel = DaftarKeluargaViewModel(repository: repository);

      await viewModel.loadFamilies();

      expect(viewModel.families, hasLength(1));
      final family = viewModel.families.first;
      expect(family.members, hasLength(3)); // Count warga = 3
      expect(family.isActive, isTrue);

      viewModel.dispose();
    });
  });
}
