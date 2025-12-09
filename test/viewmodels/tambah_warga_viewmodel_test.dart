import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/tambah_warga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:jawara/data/models/keluarga.dart';

/// Fake implementation untuk testing tanpa mock
class _FakeWargaRepository implements WargaRepository {
  final List<Map<String, dynamic>> keluargaData;
  final List<Map<String, dynamic>> rumahData;
  final bool shouldThrowErrorOnCreate;
  final bool shouldThrowErrorOnGetKeluarga;
  final bool shouldThrowErrorOnGetRumah;

  final List<WargaProfile> createdProfiles = [];
  final List<Keluarga> createdKeluargas = [];
  final Map<String, String> linkedWarga = {}; // wargaId -> keluargaId
  final List<String> occupiedRumah = [];

  _FakeWargaRepository({
    this.keluargaData = const [],
    this.rumahData = const [],
    this.shouldThrowErrorOnCreate = false,
    this.shouldThrowErrorOnGetKeluarga = false,
    this.shouldThrowErrorOnGetRumah = false,
  });

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    if (shouldThrowErrorOnGetKeluarga) {
      throw Exception('Failed to fetch keluarga');
    }
    return keluargaData;
  }

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async {
    if (shouldThrowErrorOnGetRumah) {
      throw Exception('Failed to fetch rumah');
    }
    return rumahData;
  }

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
  }) async {
    if (shouldThrowErrorOnCreate) {
      throw Exception('Failed to create profile');
    }

    final profile = WargaProfile(
      id: userId,
      namaLengkap: namaLengkap,
      nik: nik,
      noHp: noHp,
      jenisKelamin: jenisKelamin,
      agama: agama,
      golonganDarah: golonganDarah,
      pekerjaan: pekerjaan,
      fotoIdentitasUrl: fotoIdentitasUrl,
      role: 'Warga',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    createdProfiles.add(profile);
    return profile;
  }

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    if (shouldThrowErrorOnCreate) {
      throw Exception('Failed to create keluarga');
    }

    final keluarga = Keluarga(
      id: 'new-kel-id',
      kepalakeluargaId: kepalakeluargaId,
      nomorKk: nomorKk,
      alamat: rumahId ?? '',
      createdAt: DateTime.now(),
    );

    createdKeluargas.add(keluarga);
    return keluarga;
  }

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    if (shouldThrowErrorOnCreate) {
      throw Exception('Failed to link warga');
    }
    linkedWarga[wargaId] = keluargaId;
  }

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {
    if (shouldThrowErrorOnCreate) {
      throw Exception('Failed to update rumah');
    }
    occupiedRumah.add(rumahId);
  }

  // Implementasi method lain yang tidak digunakan
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
  Future<List<Map<String, dynamic>>> getAllWarga() async =>
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
  group('TambahWargaViewModel Tests', () {
    test('initial state should be correct', () {
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.keluargaList, isEmpty);
      expect(viewModel.rumahList, isEmpty);
    });

    test('loadKeluargaList should fetch all keluargas successfully', () async {
      // Arrange
      final keluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'nama_kepala_keluarga': 'Budi Santoso',
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepala_keluarga_id': 'warga-2',
          'nama_kepala_keluarga': 'Siti Aisyah',
        },
      ];

      final repository = _FakeWargaRepository(keluargaData: keluargaData);
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      await viewModel.loadKeluargaList();

      // Assert
      expect(viewModel.keluargaList, hasLength(2));
      expect(viewModel.keluargaList[0]['nama_kepala_keluarga'], 'Budi Santoso');
      expect(viewModel.keluargaList[1]['nama_kepala_keluarga'], 'Siti Aisyah');
      expect(viewModel.error, isNull);
    });

    test('loadKeluargaList should handle empty result', () async {
      final repository = _FakeWargaRepository(keluargaData: []);
      final viewModel = TambahWargaViewModel(repository: repository);

      await viewModel.loadKeluargaList();

      expect(viewModel.keluargaList, isEmpty);
      expect(viewModel.error, isNull);
    });

    test('loadKeluargaList should handle error', () async {
      final repository =
          _FakeWargaRepository(shouldThrowErrorOnGetKeluarga: true);
      final viewModel = TambahWargaViewModel(repository: repository);

      await viewModel.loadKeluargaList();

      expect(viewModel.keluargaList, isEmpty);
      expect(viewModel.error, contains('Gagal memuat daftar keluarga'));
    });

    test('loadRumahList should fetch only kosong rumah', () async {
      // Arrange
      final rumahData = [
        {
          'id': 'rumah-1',
          'alamat': 'Jl. Merdeka No. 1',
          'status_rumah': 'kosong',
        },
        {
          'id': 'rumah-2',
          'alamat': 'Jl. Sudirman No. 2',
          'status_rumah': 'ditempati',
        },
        {
          'id': 'rumah-3',
          'alamat': 'Jl. Thamrin No. 3',
          'status_rumah': 'kosong',
        },
      ];

      final repository = _FakeWargaRepository(rumahData: rumahData);
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      await viewModel.loadRumahList();

      // Assert
      expect(viewModel.rumahList, hasLength(2)); // Only kosong
      expect(viewModel.rumahList[0]['status_rumah'], 'kosong');
      expect(viewModel.rumahList[1]['status_rumah'], 'kosong');
      expect(viewModel.error, isNull);
    });

    test('loadRumahList should handle empty result', () async {
      final repository = _FakeWargaRepository(rumahData: []);
      final viewModel = TambahWargaViewModel(repository: repository);

      await viewModel.loadRumahList();

      expect(viewModel.rumahList, isEmpty);
      expect(viewModel.error, isNull);
    });

    test('loadRumahList should handle error', () async {
      final repository = _FakeWargaRepository(shouldThrowErrorOnGetRumah: true);
      final viewModel = TambahWargaViewModel(repository: repository);

      await viewModel.loadRumahList();

      expect(viewModel.rumahList, isEmpty);
      expect(viewModel.error, contains('Gagal memuat daftar rumah'));
    });

    test('saveWarga should create profile for anggota keluarga', () async {
      // Arrange
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      final result = await viewModel.saveWarga(
        userId: 'test-user-id',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'A',
        pekerjaan: 'Pegawai Swasta',
        peranKeluarga: 'anak',
        keluargaId: 'existing-kel-id',
        tempatLahir: 'Jakarta',
        tanggalLahir: '1995-05-15',
        pendidikan: 'S1',
      );

      // Assert
      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(repository.createdProfiles, hasLength(1));
      expect(repository.createdProfiles.first.namaLengkap, 'John Doe');
      expect(repository.linkedWarga['test-user-id'], 'existing-kel-id');
    });

    test('saveWarga should create keluarga for kepala keluarga', () async {
      // Arrange
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      final result = await viewModel.saveWarga(
        userId: 'test-kepala-id',
        namaLengkap: 'Kepala Keluarga',
        nik: '1111111111111111',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'O',
        pekerjaan: 'Wiraswasta',
        peranKeluarga: 'kepala keluarga',
        nomorKk: '1234567890123456',
        rumahId: 'rumah-1',
      );

      // Assert
      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(repository.createdProfiles, hasLength(1));
      expect(repository.createdKeluargas, hasLength(1));
      expect(
          repository.createdKeluargas.first.kepalakeluargaId, 'test-kepala-id');
      expect(repository.createdKeluargas.first.nomorKk, '1234567890123456');
      expect(repository.occupiedRumah, contains('rumah-1'));
    });

    test('saveWarga should fail if kepala keluarga missing nomorKk', () async {
      // Arrange
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      final result = await viewModel.saveWarga(
        userId: 'test-user-id',
        namaLengkap: 'Kepala Test',
        nik: '1111111111111111',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'O',
        pekerjaan: 'Pegawai',
        peranKeluarga: 'kepala keluarga',
        rumahId: 'rumah-1',
        // nomorKk not provided
      );

      // Assert
      expect(result, isFalse);
      expect(viewModel.error, contains('Nomor KK harus diisi'));
      expect(repository.createdProfiles, hasLength(1)); // Profile created
      expect(repository.createdKeluargas, isEmpty); // But no keluarga
    });

    test('saveWarga should fail if kepala keluarga missing rumahId', () async {
      // Arrange
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      final result = await viewModel.saveWarga(
        userId: 'test-user-id',
        namaLengkap: 'Kepala Test',
        nik: '1111111111111111',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'O',
        pekerjaan: 'Pegawai',
        peranKeluarga: 'kepala keluarga',
        nomorKk: '1234567890123456',
        // rumahId not provided
      );

      // Assert
      expect(result, isFalse);
      expect(viewModel.error, contains('Alamat rumah harus dipilih'));
      expect(repository.createdKeluargas, isEmpty);
    });

    test('saveWarga should handle error on profile creation', () async {
      // Arrange
      final repository = _FakeWargaRepository(shouldThrowErrorOnCreate: true);
      final viewModel = TambahWargaViewModel(repository: repository);

      // Act
      final result = await viewModel.saveWarga(
        userId: 'test-user-id',
        namaLengkap: 'Test Error',
        nik: '1111111111111111',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'O',
        pekerjaan: 'Pegawai',
        peranKeluarga: 'anak',
        keluargaId: 'kel-1',
      );

      // Assert
      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, contains('Gagal menyimpan data'));
    });

    test('saveWarga should update loading state correctly', () async {
      // Arrange
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      expect(viewModel.isLoading, isFalse);

      // Act
      final future = viewModel.saveWarga(
        userId: 'test-user-id',
        namaLengkap: 'Test Warga',
        nik: '1111111111111111',
        noHp: '081234567890',
        jenisKelamin: 'Laki-Laki',
        agama: 'islam',
        golonganDarah: 'O',
        pekerjaan: 'Pegawai',
        peranKeluarga: 'anak',
        keluargaId: 'kel-1',
      );

      // Loading should become true
      expect(viewModel.isLoading, isTrue);

      await future;

      // Loading should become false after completion
      expect(viewModel.isLoading, isFalse);
    });

    test('clearError should clear error message', () async {
      // Arrange
      final repository =
          _FakeWargaRepository(shouldThrowErrorOnGetKeluarga: true);
      final viewModel = TambahWargaViewModel(repository: repository);

      await viewModel.loadKeluargaList();
      expect(viewModel.error, isNotNull);

      // Act
      viewModel.clearError();

      // Assert
      expect(viewModel.error, isNull);
    });

    test('options lists should have correct values', () {
      final repository = _FakeWargaRepository();
      final viewModel = TambahWargaViewModel(repository: repository);

      expect(viewModel.jenisKelaminOptions, hasLength(2));
      expect(viewModel.jenisKelaminOptions, contains('Laki-Laki'));
      expect(viewModel.jenisKelaminOptions, contains('Perempuan'));

      expect(viewModel.agamaOptions, hasLength(6));
      expect(viewModel.agamaOptions, contains('islam'));

      expect(viewModel.golonganDarahOptions, hasLength(4));
      expect(viewModel.golonganDarahOptions, contains('A'));

      expect(viewModel.peranKeluargaOptions, hasLength(4));
      expect(viewModel.peranKeluargaOptions, contains('kepala keluarga'));

      expect(viewModel.pendidikanOptions, hasLength(8));
      expect(viewModel.pendidikanOptions, contains('S1'));
    });
  });
}
