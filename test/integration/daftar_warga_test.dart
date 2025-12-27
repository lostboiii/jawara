library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

import 'daftar_warga_test.mocks.dart';

@GenerateMocks([WargaRepository])
void main() {
  late MockWargaRepository mockRepository;
  late DaftarWargaViewModel viewModel;

  setUp(() {
    mockRepository = MockWargaRepository();
    viewModel = DaftarWargaViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('loadWarga loads and maps warga correctly', () async {
    // arrange
    when(mockRepository.getAllWarga()).thenAnswer((_) async => [
          {
            'id': 'w1',
            'nama_lengkap': 'Budi',
            'nik': '123',
            'jenis_kelamin': 'Laki-Laki',
            'agama': 'islam',
            'pekerjaan': 'Petani',
            'peran_keluarga': 'kepala keluarga',
            'golongan_darah': 'O',
            'keluarga_id': 'k1',
            'keluarga': {
              'warga_profiles': {
                'nama_lengkap': 'Budi',
              }
            }
          },
          {
            'id': 'w2',
            'nama_lengkap': 'Ani',
            'nik': '456',
            'jenis_kelamin': 'Perempuan',
            'agama': 'islam',
            'pekerjaan': 'Ibu Rumah Tangga',
            'peran_keluarga': 'istri',
            'golongan_darah': 'A',
            'keluarga_id': 'k1',
          },
        ]);

    // act
    await viewModel.loadWarga();

    // assert
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.wargaList.length, 2);
    expect(viewModel.wargaList.first.namaLengkap, 'Ani'); // sorted
    verify(mockRepository.getAllWarga()).called(1);
  });

  test('search filters warga by name and nik', () async {
    when(mockRepository.getAllWarga()).thenAnswer((_) async => [
          {
            'id': 'w1',
            'nama_lengkap': 'Budi',
            'nik': '123',
            'jenis_kelamin': 'Laki-Laki',
            'agama': 'islam',
            'pekerjaan': 'Petani',
            'peran_keluarga': 'kepala keluarga',
            'golongan_darah': 'O',
          },
          {
            'id': 'w2',
            'nama_lengkap': 'Ani',
            'nik': '456',
            'jenis_kelamin': 'Perempuan',
            'agama': 'islam',
            'pekerjaan': 'IRT',
            'peran_keluarga': 'istri',
            'golongan_darah': 'A',
          },
        ]);

    await viewModel.loadWarga();

    // act
    viewModel.setSearchQuery('budi');

    // assert
    expect(viewModel.filteredWarga.length, 1);
    expect(viewModel.filteredWarga.first.namaLengkap, 'Budi');
  });

  test('loadWarga sets errorMessage when repository throws', () async {
    when(mockRepository.getAllWarga())
        .thenThrow(Exception('DB error'));

    await viewModel.loadWarga();

    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, contains('DB error'));
  });
}
