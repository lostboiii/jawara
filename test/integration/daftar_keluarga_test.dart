/// Integration test untuk DaftarKeluargaViewModel menggunakan Mockito
/// File: test/integration/daftar_keluarga_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jawara/viewmodels/daftar_keluarga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

// Import generated mocks
import 'daftar_keluarga_test.mocks.dart';

// Annotasi untuk generate mocks
@GenerateMocks([WargaRepository])
void main() {
  late MockWargaRepository mockRepository;
  late DaftarKeluargaViewModel viewModel;

  setUp(() {
    mockRepository = MockWargaRepository();
    viewModel = DaftarKeluargaViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('DaftarKeluargaViewModel Integration Tests', () {
    test('should load and display keluarga list from repository', () async {
      // Arrange
      final mockKeluargaData = [
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
      ];

      final mockWargaData = [
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
          'nama_lengkap': 'Siti Rahayu',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Istri',
          'no_telepon': '081234567891',
        },
      ];

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => mockKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => mockWargaData);

      // Act
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.families, hasLength(1));

      final family = viewModel.families.first;
      expect(family.kepalaNama, 'Budi Santoso');
      expect(family.members, hasLength(2));
      expect(family.isActive, isTrue);

      // Verify repository calls
      verify(mockRepository.getAllKeluarga()).called(1);
      verify(mockRepository.getAllWarga()).called(1);
    });

    test('should add new keluarga and reload list', () async {
      // Arrange - Initial data
      final initialKeluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Budi Santoso'},
          'nama_rumah': 'Rumah A1',
        },
      ];

      final initialWargaData = [
        {
          'id': 'warga-1',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Budi Santoso',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567890',
        },
      ];

      // Setup initial mock
      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => initialKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => initialWargaData);

      await viewModel.loadFamilies();
      expect(viewModel.families, hasLength(1));

      // Arrange - After adding new keluarga
      final updatedKeluargaData = [
        ...initialKeluargaData,
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepala_keluarga_id': 'warga-2',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Ahmad Hidayat'},
          'nama_rumah': 'Rumah B2',
        },
      ];

      final updatedWargaData = [
        ...initialWargaData,
        {
          'id': 'warga-2',
          'keluarga_id': 'kel-2',
          'nama_lengkap': 'Ahmad Hidayat',
          'nik': '3333333333333333',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567892',
        },
      ];

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => updatedKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => updatedWargaData);

      // Act - Reload
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.families, hasLength(2));
      expect(viewModel.families.any((f) => f.kepalaNama == 'Ahmad Hidayat'),
          isTrue);

      verify(mockRepository.getAllKeluarga()).called(2);
      verify(mockRepository.getAllWarga()).called(2);
    });

    test('should search and filter keluarga correctly', () async {
      // Arrange
      final mockKeluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Budi Santoso'},
          'nama_rumah': 'Rumah A1',
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepala_keluarga_id': 'warga-2',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Siti Aisyah'},
          'nama_rumah': 'Rumah B2',
        },
      ];

      final mockWargaData = [
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

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => mockKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => mockWargaData);

      await viewModel.loadFamilies();

      // Act - Search by name
      viewModel.setSearchQuery('Budi');

      // Assert
      expect(viewModel.filteredFamilies, hasLength(1));
      expect(viewModel.filteredFamilies.first.kepalaNama, 'Budi Santoso');

      // Act - Search by KK number
      viewModel.setSearchQuery('9876');

      // Assert
      expect(viewModel.filteredFamilies, hasLength(1));
      expect(viewModel.filteredFamilies.first.keluarga.nomorKk,
          '9876543210987654');

      // Act - Clear search
      viewModel.setSearchQuery('');

      // Assert
      expect(viewModel.filteredFamilies, hasLength(2));
    });

    test('should sort families by created_at descending', () async {
      // Arrange
      final mockKeluargaData = [
        {
          'id': 'kel-old',
          'nomor_kk': '1111111111111111',
          'kepala_keluarga_id': 'warga-old',
          'rumah_id': 'rumah-1',
          'created_at': '2023-01-01T00:00:00.000Z',
          'updated_at': '2023-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Old Family'},
          'nama_rumah': 'Rumah A',
        },
        {
          'id': 'kel-new',
          'nomor_kk': '2222222222222222',
          'kepala_keluarga_id': 'warga-new',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'New Family'},
          'nama_rumah': 'Rumah B',
        },
      ];

      final mockWargaData = [
        {
          'id': 'warga-old',
          'keluarga_id': 'kel-old',
          'nama_lengkap': 'Old Family',
          'nik': '1111111111111111',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
        {
          'id': 'warga-new',
          'keluarga_id': 'kel-new',
          'nama_lengkap': 'New Family',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': null,
        },
      ];

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => mockKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => mockWargaData);

      // Act
      await viewModel.loadFamilies();

      // Assert - Newer should be first
      expect(viewModel.families, hasLength(2));
      expect(viewModel.families.first.kepalaNama, 'New Family');
      expect(viewModel.families.last.kepalaNama, 'Old Family');
    });

    test('should count warga members correctly for each keluarga', () async {
      // Arrange
      final mockKeluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Budi Santoso'},
          'nama_rumah': 'Rumah A1',
        },
      ];

      final mockWargaData = [
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
          'nama_lengkap': 'Siti Rahayu',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Perempuan',
          'peran_keluarga': 'Istri',
          'no_telepon': '081234567891',
        },
        {
          'id': 'warga-3',
          'keluarga_id': 'kel-1',
          'nama_lengkap': 'Andi Santoso',
          'nik': '3333333333333333',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Anak',
          'no_telepon': null,
        },
      ];

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => mockKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => mockWargaData);

      // Act
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.families, hasLength(1));
      final family = viewModel.families.first;
      expect(family.members, hasLength(3)); // Kepala + Istri + Anak
      expect(family.isActive, isTrue);
    });

    test('should handle empty database gracefully', () async {
      // Arrange
      when(mockRepository.getAllKeluarga()).thenAnswer((_) async => []);
      when(mockRepository.getAllWarga()).thenAnswer((_) async => []);

      // Act
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.families, isEmpty);
      expect(viewModel.filteredFamilies, isEmpty);

      verify(mockRepository.getAllKeluarga()).called(1);
      verify(mockRepository.getAllWarga()).called(1);
    });

    test('should handle repository error', () async {
      // Arrange
      when(mockRepository.getAllKeluarga())
          .thenThrow(Exception('Database connection failed'));

      // Act
      await viewModel.loadFamilies();

      // Assert
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Database connection failed'));
      expect(viewModel.families, isEmpty);

      verify(mockRepository.getAllKeluarga()).called(1);
    });

    test('should maintain search query when reloading', () async {
      // Arrange
      final mockKeluargaData = [
        {
          'id': 'kel-1',
          'nomor_kk': '1234567890123456',
          'kepala_keluarga_id': 'warga-1',
          'rumah_id': 'rumah-1',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Budi Santoso'},
          'nama_rumah': 'Rumah A1',
        },
        {
          'id': 'kel-2',
          'nomor_kk': '9876543210987654',
          'kepala_keluarga_id': 'warga-2',
          'rumah_id': 'rumah-2',
          'created_at': '2024-01-02T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'warga_profiles': {'nama_lengkap': 'Test Family'},
          'nama_rumah': 'Rumah B2',
        },
      ];

      final mockWargaData = [
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
          'nama_lengkap': 'Test Family',
          'nik': '2222222222222222',
          'jenis_kelamin': 'Laki-laki',
          'peran_keluarga': 'Kepala Keluarga',
          'no_telepon': '081234567891',
        },
      ];

      when(mockRepository.getAllKeluarga())
          .thenAnswer((_) async => mockKeluargaData);
      when(mockRepository.getAllWarga())
          .thenAnswer((_) async => mockWargaData);

      await viewModel.loadFamilies();

      // Act - Set search query
      viewModel.setSearchQuery('Budi');
      expect(viewModel.filteredFamilies, hasLength(1));

      // Reload
      await viewModel.loadFamilies();

      // Assert - Search query should still be applied
      expect(viewModel.searchQuery, 'Budi');
      expect(viewModel.filteredFamilies, hasLength(1));
      expect(viewModel.filteredFamilies.first.kepalaNama, 'Budi Santoso');

      verify(mockRepository.getAllKeluarga()).called(2);
      verify(mockRepository.getAllWarga()).called(2);
    });
  });
}