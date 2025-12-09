import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:jawara/data/models/keluarga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Minimal fake implementations for testing
class _MinimalFakeAuthService implements AuthService {
  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Session? getCurrentSession() => null;

  @override
  User? getCurrentUser() => null;

  @override
  bool isAuthenticated() => false;

  @override
  Future<void> resetPassword(String email) async {}
}

class _MinimalFakeWargaRepository implements WargaRepository {
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
  }) async => WargaProfile(
    id: 'test',
    namaLengkap: namaLengkap,
    nik: nik,
    noHp: noHp,
    jenisKelamin: jenisKelamin,
    agama: agama,
    golonganDarah: golonganDarah,
    pekerjaan: pekerjaan,
    fotoIdentitasUrl: null,
    role: 'Warga',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Future<void> deleteProfile(String userId) async {}

  @override
  String getFotoPublicUrl(String filePath) => '';

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async => null;

  @override
  Future<WargaProfile?> getProfileById(String userId) async => null;

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async => '';

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async => profile;

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async {
    if (kepalakeluargaId == 'warga_1') {
      return Keluarga(
        id: 'keluarga_1',
        kepalakeluargaId: 'warga_1',
        nomorKk: '3210123456789001',
        alamat: 'rumah_1',
      );
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    return [
      {
        'id': 'keluarga_1',
        'kepala_keluarga_id': 'warga_1',
        'nomorKk': '3210123456789001',
        'alamat': 'rumah_1',
        'warga_profiles': {
          'nama_lengkap': 'Budi Santoso',
        },
      },
    ];
  }

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    // Mock implementation
  }

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    return Keluarga(
      id: 'keluarga_123',
      kepalakeluargaId: kepalakeluargaId,
      nomorKk: nomorKk,
      alamat: rumahId ?? 'rumah_default',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async {
    return [
      {
        'id': 'rumah_1',
        'alamat': 'Jl. Merdeka No. 1',
        'status_rumah': 'kosong',
      },
      {
        'id': 'rumah_2',
        'alamat': 'Jl. Sudirman No. 2',
        'status_rumah': 'kosong',
      },
    ];
  }

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {
    // Mock implementation - do nothing
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWarga() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  }) async {
    return {
      'id': 'mutasi_123',
      'keluarga_id': keluargaId,
      'rumah_id': rumahId,
      'tanggal_mutasi': tanggalMutasi.toIso8601String(),
      'alasan_mutasi': alasanMutasi,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getMutasiList() async {
    return [
      {
        'id': 'mutasi_1',
        'keluarga_id': 'keluarga_1',
        'rumah_id': 'rumah_1',
        'tanggal_mutasi': DateTime.now().toIso8601String(),
        'alasan_mutasi': 'Alasan test',
        'keluarga_nomor_kk': '3210123456789001',
        'rumah_alamat': 'Jl. Merdeka No. 1',
      },
    ];
  }

  @override
  Future<void> updateRumahStatus(String rumahId, String status) async {}

  @override
  Future<List<Map<String, dynamic>>> getAllPenghuni() async => [];

  @override
  Future<void> updatePenghuniRumah(String penghuniId, String newRumahId) async {}

  @override
  Future<void> deletePenghuni(String penghuniId) async {}

  @override
  Future<void> createPenghuni({
    required String keluargaId,
    required String rumahId,
  }) async {}

  @override
  Future<void> updateKeluargaAlamat(String keluargaId, String? alamatId) async {}

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
  }) async {}

  @override
  Future<void> deleteWarga(String wargaId) async {}
}

void main() {
  group('RegisterViewModel Tests', () {
    late RegisterViewModel registerViewModel;

    setUp(() {
      registerViewModel = RegisterViewModel(
        authService: _MinimalFakeAuthService(),
        wargaRepository: _MinimalFakeWargaRepository(),
      );
    });

    group('Email Validation', () {
      test('validateEmail returns true for valid email', () {
        final result = registerViewModel.validateEmail('test@example.com');
        expect(result, true);
      });

      test('validateEmail returns true for valid email with numbers', () {
        final result = registerViewModel.validateEmail('test123@example.com');
        expect(result, true);
      });

      test('validateEmail returns false for email without @', () {
        final result = registerViewModel.validateEmail('testexample.com');
        expect(result, false);
      });

      test('validateEmail returns false for empty email', () {
        final result = registerViewModel.validateEmail('');
        expect(result, false);
      });

      test('validateEmail returns false for email without domain', () {
        final result = registerViewModel.validateEmail('test@');
        expect(result, false);
      });

      test('validateEmail returns false for email without username', () {
        final result = registerViewModel.validateEmail('@example.com');
        expect(result, false);
      });

      test('validateEmail returns false for email with space', () {
        final result = registerViewModel.validateEmail('test @example.com');
        expect(result, false);
      });
    });

    group('Password Validation', () {
      test('validatePassword returns null when passwords match and are valid', () {
        final result = registerViewModel.validatePassword('password123', 'password123');
        expect(result, null);
      });

      test('validatePassword returns error when passwords do not match', () {
        final result = registerViewModel.validatePassword('password123', 'password456');
        expect(result, isNotNull);
        expect(result, contains('tidak cocok'));
      });

      test('validatePassword returns error when password < 6 characters', () {
        final result = registerViewModel.validatePassword('pass', 'pass');
        expect(result, isNotNull);
        expect(result, contains('minimal 6 karakter'));
      });

      test('validatePassword returns error for empty passwords', () {
        final result = registerViewModel.validatePassword('', '');
        expect(result, isNotNull);
      });
    });

    group('ViewModel State Management', () {
      test('clearError removes error message', () {
        registerViewModel.clearError();
        expect(registerViewModel.error, null);
      });

      test('hasError returns false initially', () {
        expect(registerViewModel.hasError, false);
      });

      test('isLoading is initially false', () {
        expect(registerViewModel.isLoading, false);
      });

      test('currentProfile is initially null', () {
        expect(registerViewModel.currentProfile, null);
      });
    });

    group('Cache Management', () {
      test('setNamaLengkap updates cache', () {
        registerViewModel.setNamaLengkap('John Doe');
        expect(registerViewModel.cacheNamaLengkap, 'John Doe');
      });

      test('setNik updates cache', () {
        registerViewModel.setNik('1234567890123456');
        expect(registerViewModel.cacheNik, '1234567890123456');
      });

      test('setEmail updates cache', () {
        registerViewModel.setEmail('test@example.com');
        expect(registerViewModel.cacheEmail, 'test@example.com');
      });

      test('setNoHp updates cache', () {
        registerViewModel.setNoHp('081234567890');
        expect(registerViewModel.cacheNoHp, '081234567890');
      });

      test('setJenisKelamin updates cache', () {
        registerViewModel.setJenisKelamin('Laki-laki');
        expect(registerViewModel.cacheJenisKelamin, 'Laki-laki');
      });

      test('setAgama updates cache', () {
        registerViewModel.setAgama('Islam');
        expect(registerViewModel.cacheAgama, 'Islam');
      });

      test('setGolonganDarah updates cache', () {
        registerViewModel.setGolonganDarah('A');
        expect(registerViewModel.cacheGolonganDarah, 'A');
      });

      test('setRumahId updates cache', () {
        registerViewModel.setRumahId('rumah_1');
        expect(registerViewModel.cacheRumahId, 'rumah_1');
      });

      test('setAlamatRumahManual updates cache', () {
        registerViewModel.setAlamatRumahManual('Jl. Merdeka No. 1');
        expect(registerViewModel.cacheAlamatRumahManual, 'Jl. Merdeka No. 1');
      });

      test('setStatus updates cache', () {
        registerViewModel.setStatus('Kepala Keluarga');
        expect(registerViewModel.cacheStatus, 'Kepala Keluarga');
      });

      test('setPassword updates cache', () {
        registerViewModel.setPassword('password123');
        expect(registerViewModel.cachePassword, 'password123');
      });

      test('setConfirmPassword updates cache', () {
        registerViewModel.setConfirmPassword('password123');
        expect(registerViewModel.cacheConfirmPassword, 'password123');
      });

      test('clearRegistrationCache clears all cached values', () {
        registerViewModel.setNamaLengkap('John');
        registerViewModel.setEmail('john@test.com');
        registerViewModel.setPassword('pass123');
        
        registerViewModel.clearRegistrationCache();
        
        expect(registerViewModel.cacheNamaLengkap, '');
        expect(registerViewModel.cacheEmail, '');
        expect(registerViewModel.cachePassword, '');
        expect(registerViewModel.cacheNik, '');
        expect(registerViewModel.cacheNoHp, '');
      });
    });

    group('Registration Flow', () {
      test('registerWarga validates empty nama lengkap', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: '',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('Nama lengkap wajib diisi'));
      });

      test('registerWarga validates empty NIK', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('NIK wajib diisi'));
      });

      test('registerWarga validates email format', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'invalid-email',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        // Auth service may return different error, just check it failed
        expect(registerViewModel.error, isNotNull);
      });

      test('registerWarga validates empty no hp', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('No telepon wajib diisi'));
      });

      test('registerWarga validates empty jenis kelamin', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: '',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('Jenis kelamin wajib dipilih'));
      });

      test('registerWarga validates empty agama', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: '',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('Agama wajib dipilih'));
      });

      test('registerWarga validates empty golongan darah', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: '',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('Golongan darah wajib dipilih'));
      });

      test('registerWarga validates empty pekerjaan', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: '',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('Pekerjaan wajib diisi'));
      });

      test('registerWarga validates password mismatch', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'differentpassword',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('tidak cocok'));
      });

      test('registerWarga validates short password', () async {
        final result = await registerViewModel.registerWarga(
          namaLengkap: 'John Doe',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: '12345',
          confirmPassword: '12345',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(registerViewModel.error, contains('minimal 6 karakter'));
      });
    });

    group('Additional ViewModel Methods', () {
      test('reset clears all state', () {
        registerViewModel.reset();
        expect(registerViewModel.isLoading, false);
        expect(registerViewModel.error, null);
        expect(registerViewModel.currentProfile, null);
      });

      test('getKeluargaList returns list of keluarga', () async {
        final result = await registerViewModel.getKeluargaList();
        expect(result, isNotEmpty);
        expect(result.first['id'], 'keluarga_1');
      });

      test('getRumahList returns list of rumah', () async {
        final result = await registerViewModel.getRumahList();
        expect(result, isNotEmpty);
        expect(result.first['id'], 'rumah_1');
      });

      test('checkKeluargaExists returns true when keluarga exists', () async {
        final result = await registerViewModel.checkKeluargaExists('warga_1');
        expect(result, true);
      });

      test('createKeluarga creates keluarga successfully', () async {
        final result = await registerViewModel.createKeluarga(
          kepalakeluargaId: 'user_123',
          nomorKk: '3210123456789999',
          rumahId: 'rumah_1',
        );
        expect(result, true);
      });

      test('getMutasiList returns list of mutasi', () async {
        final result = await registerViewModel.getMutasiList();
        expect(result, isNotEmpty);
        expect(result.first['id'], 'mutasi_1');
      });

      test('createMutasi creates mutasi successfully', () async {
        final result = await registerViewModel.createMutasi(
          keluarga_id: 'keluarga_1',
          rumah_id: 'rumah_2',
          tanggal_mutasi: DateTime(2024, 1, 1),
          alasan_mutasi: 'Pindah rumah',
        );
        expect(result, isNotEmpty);
        expect(result['id'], 'mutasi_123');
      });

      test('registerWargaWithKeluarga validates empty input', () async {
        // This will fail during registerWarga step which validates inputs
        final result = await registerViewModel.registerWargaWithKeluarga(
          namaLengkap: '',
          nik: '1234567890123456',
          email: 'newuser@test.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'kepala keluarga',
          nomorKk: '3210999999999999',
          rumahId: 'rumah_1',
        );
        
        expect(result, false);
        expect(registerViewModel.error, contains('Nama lengkap'));
      });

      test('createKeluarga handles error', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        final result = await vm.createKeluarga(
          kepalakeluargaId: 'user_123',
          nomorKk: '3210123456789999',
          rumahId: 'rumah_1',
        );

        expect(result, false);
        expect(vm.error, isNotNull);
      });

      test('checkKeluargaExists handles error', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        final result = await vm.checkKeluargaExists('user_123');

        expect(result, false);
        expect(vm.error, isNotNull);
      });

      test('createMutasi handles error', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        expect(
          () => vm.createMutasi(
            keluarga_id: 'k1',
            rumah_id: 'r1',
            tanggal_mutasi: DateTime.now(),
            alasan_mutasi: 'test',
          ),
          throwsException,
        );
      });

      test('getKeluargaList handles error gracefully', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        final result = await vm.getKeluargaList();
        expect(result, isEmpty);
      });

      test('getRumahList handles error gracefully', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        final result = await vm.getRumahList();
        expect(result, isEmpty);
      });

      test('getMutasiList handles error gracefully', () async {
        final fakeRepo = _FakeErrorWargaRepository();
        final vm = RegisterViewModel(
          authService: _MinimalFakeAuthService(),
          wargaRepository: fakeRepo,
        );

        final result = await vm.getMutasiList();
        expect(result, isEmpty);
      });

      test('registerWarga handles auth errors appropriately', () async {
        // Test rate limit error
        var authService = _FakeAuthService(
          shouldSucceed: false,
          errorMessage: 'over_email_send_rate_limit',
        );
        var vm = RegisterViewModel(
          authService: authService,
          wargaRepository: _MinimalFakeWargaRepository(),
        );

        var result = await vm.registerWarga(
          namaLengkap: 'Test User',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(vm.error, contains('Terlalu banyak percobaan'));

        // Test user already exists error
        authService = _FakeAuthService(
          shouldSucceed: false,
          errorMessage: 'user_already_exists',
        );
        vm = RegisterViewModel(
          authService: authService,
          wargaRepository: _MinimalFakeWargaRepository(),
        );

        result = await vm.registerWarga(
          namaLengkap: 'Test User',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(vm.error, contains('Email sudah terdaftar'));
      });

      test('registerWarga successful registration', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = RegisterViewModel(
          authService: authService,
          wargaRepository: _MinimalFakeWargaRepository(),
        );

        final result = await vm.registerWarga(
          namaLengkap: 'Test User',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, true);
        expect(vm.error, null);
        expect(vm.currentProfile, isNotNull);
      });

      test('registerWarga handles null user from auth', () async {
        final authService = _FakeAuthService(
          shouldSucceed: true,
          returnNullUser: true,
        );
        final vm = RegisterViewModel(
          authService: authService,
          wargaRepository: _MinimalFakeWargaRepository(),
        );

        final result = await vm.registerWarga(
          namaLengkap: 'Test User',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
        );

        expect(result, false);
        expect(vm.error, contains('Gagal membuat akun'));
      });

      test('registerWarga continues when foto upload fails', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final fakeRepo = _FakeRepositoryWithUploadError();
        final vm = RegisterViewModel(
          authService: authService,
          wargaRepository: fakeRepo,
        );

        final result = await vm.registerWarga(
          namaLengkap: 'Test User',
          nik: '1234567890123456',
          email: 'test@example.com',
          noHp: '081234567890',
          jenisKelamin: 'Laki-laki',
          agama: 'Islam',
          golonganDarah: 'A',
          pekerjaan: 'Pegawai',
          password: 'password123',
          confirmPassword: 'password123',
          peranKeluarga: 'Kepala Keluarga',
          fotoIdentitas: File('test.jpg'),
        );

        expect(result, true);
        expect(vm.currentProfile, isNotNull);
      });
    });
  });
}

class _FakeRepositoryWithUploadError implements WargaRepository {
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
  }) async => WargaProfile(
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

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async {
    throw Exception('Upload failed');
  }

  @override
  Future<void> deleteProfile(String userId) async {}

  @override
  String getFotoPublicUrl(String filePath) => '';

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async => null;

  @override
  Future<WargaProfile?> getProfileById(String userId) async => null;

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async => profile;

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async => null;

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async => [];

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {}

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async => Keluarga(
    id: 'keluarga_123',
    kepalakeluargaId: kepalakeluargaId,
    nomorKk: nomorKk,
    alamat: rumahId ?? 'rumah_default',
  );

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async => [];

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {}

  @override
  Future<List<Map<String, dynamic>>> getAllWarga() async => [];

  @override
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  }) async => {};

  @override
  Future<List<Map<String, dynamic>>> getMutasiList() async => [];

  @override
  Future<void> updateRumahStatus(String rumahId, String status) async {}

  @override
  Future<List<Map<String, dynamic>>> getAllPenghuni() async => [];

  @override
  Future<void> updatePenghuniRumah(String penghuniId, String newRumahId) async {}

  @override
  Future<void> deletePenghuni(String penghuniId) async {}

  @override
  Future<void> createPenghuni({
    required String keluargaId,
    required String rumahId,
  }) async {}

  @override
  Future<void> updateKeluargaAlamat(String keluargaId, String? alamatId) async {}

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
  }) async {}

  @override
  Future<void> deleteWarga(String wargaId) async {}
}

class _FakeAuthService implements AuthService {
  final bool shouldSucceed;
  final bool returnNullUser;
  final String? errorMessage;

  _FakeAuthService({
    required this.shouldSucceed,
    this.returnNullUser = false,
    this.errorMessage,
  });

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (!shouldSucceed) {
      throw Exception(errorMessage ?? 'Sign up failed');
    }

    return AuthResponse(
      session: returnNullUser
          ? null
          : Session(
              accessToken: 'fake_token',
              tokenType: 'bearer',
              user: User(
                id: 'fake_user_id',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
      user: returnNullUser
          ? null
          : User(
              id: 'fake_user_id',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Session? getCurrentSession() => null;

  @override
  User? getCurrentUser() => null;

  @override
  bool isAuthenticated() => false;

  @override
  Future<void> resetPassword(String email) async {}
}

class _FakeErrorWargaRepository implements WargaRepository {
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
    throw Exception('create profile error');
  }

  @override
  Future<void> deleteProfile(String userId) async {
    throw Exception('delete error');
  }

  @override
  String getFotoPublicUrl(String filePath) => '';

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async {
    throw Exception('get profile error');
  }

  @override
  Future<WargaProfile?> getProfileById(String userId) async {
    throw Exception('get profile error');
  }

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async {
    throw Exception('upload error');
  }

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async {
    throw Exception('update error');
  }

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async {
    throw Exception('get keluarga error');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    throw Exception('get all keluarga error');
  }

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    throw Exception('link error');
  }

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    throw Exception('create keluarga error');
  }

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async {
    throw Exception('get rumah error');
  }

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {
    throw Exception('update rumah error');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWarga() async {
    throw Exception('get all warga error');
  }

  @override
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  }) async {
    throw Exception('create mutasi error');
  }

  @override
  Future<List<Map<String, dynamic>>> getMutasiList() async {
    throw Exception('get mutasi error');
  }

  @override
  Future<void> updateRumahStatus(String rumahId, String status) async {
    throw Exception('update status error');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPenghuni() async {
    throw Exception('get penghuni error');
  }

  @override
  Future<void> updatePenghuniRumah(String penghuniId, String newRumahId) async {
    throw Exception('update penghuni error');
  }

  @override
  Future<void> deletePenghuni(String penghuniId) async {
    throw Exception('delete penghuni error');
  }

  @override
  Future<void> createPenghuni({
    required String keluargaId,
    required String rumahId,
  }) async {
    throw Exception('create penghuni error');
  }

  @override
  Future<void> updateKeluargaAlamat(String keluargaId, String? alamatId) async {
    throw Exception('update alamat error');
  }

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
  }) async {
    throw Exception('update warga error');
  }

  @override
  Future<void> deleteWarga(String wargaId) async {
    throw Exception('delete warga error');
  }
}
