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
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async => null;

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
  });
}
