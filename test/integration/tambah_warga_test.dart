library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/warga_model.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:jawara/data/models/keluarga.dart';
import 'package:jawara/viewmodels/tambah_warga_viewmodel.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

import 'tambah_warga_test.mocks.dart';

@GenerateMocks([WargaRepository])
void main() {
  late MockWargaRepository mockRepository;
  late TambahWargaViewModel viewModel;

  setUp(() {
    mockRepository = MockWargaRepository();
    viewModel = TambahWargaViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });
  WargaProfile mockWargaProfile({
    String id = 'mock-id',
    String nama = 'Mock Warga',
    String nik = '000',
  }) {
    return WargaProfile(
      id: id,
      namaLengkap: nama,
      nik: nik,
      noHp: '08123456789',
      jenisKelamin: 'Laki-Laki',
      agama: 'islam',
      golonganDarah: 'O',
      pekerjaan: 'Petani',
      createdAt: DateTime.now(),
    );
  }

  final mockKeluarga = Keluarga(
    id: 'keluarga-1',
    kepalakeluargaId: 'warga-1',
    nomorKk: '1234567890123456',
    alamat: 'rumah-1',
  );

  test('saveWarga creates kepala keluarga and updates rumah', () async {
    // arrange
    when(mockRepository.createProfile(
      userId: anyNamed('userId'),
      namaLengkap: anyNamed('namaLengkap'),
      nik: anyNamed('nik'),
      noHp: anyNamed('noHp'),
      jenisKelamin: anyNamed('jenisKelamin'),
      agama: anyNamed('agama'),
      golonganDarah: anyNamed('golonganDarah'),
      pekerjaan: anyNamed('pekerjaan'),
      peranKeluarga: anyNamed('peranKeluarga'),
      tempatLahir: anyNamed('tempatLahir'),
      tanggalLahir: anyNamed('tanggalLahir'),
      pendidikan: anyNamed('pendidikan'),
    )).thenAnswer(
      (_) async => mockWargaProfile(),
    );

    when(mockRepository.createKeluarga(
      kepalakeluargaId: anyNamed('kepalakeluargaId'),
      nomorKk: anyNamed('nomorKk'),
      rumahId: anyNamed('rumahId'),
    )).thenAnswer((_) async => mockKeluarga);

    when(mockRepository.updateRumahStatusToOccupied(any))
        .thenAnswer((_) async {});

    // act
    final result = await viewModel.saveWarga(
      userId: 'u1',
      namaLengkap: 'Budi',
      nik: '123',
      noHp: '08123',
      jenisKelamin: 'Laki-Laki',
      agama: 'islam',
      golonganDarah: 'O',
      pekerjaan: 'Petani',
      peranKeluarga: 'kepala keluarga',
      nomorKk: '321',
      rumahId: 'r1',
    );

    // assert
    expect(result, true);
    verify(mockRepository.createProfile(
      userId: 'u1',
      namaLengkap: 'Budi',
      nik: '123',
      noHp: '08123',
      jenisKelamin: 'Laki-Laki',
      agama: 'islam',
      golonganDarah: 'O',
      pekerjaan: 'Petani',
      peranKeluarga: 'kepala keluarga',
      tempatLahir: null,
      tanggalLahir: null,
      pendidikan: null,
    )).called(1);

    verify(mockRepository.createKeluarga(
      kepalakeluargaId: 'u1',
      nomorKk: '321',
      rumahId: 'r1',
    )).called(1);

    verify(mockRepository.updateRumahStatusToOccupied('r1')).called(1);
  });

  test('saveWarga links anggota keluarga', () async {
    when(mockRepository.createProfile(
      userId: anyNamed('userId'),
      namaLengkap: anyNamed('namaLengkap'),
      nik: anyNamed('nik'),
      noHp: anyNamed('noHp'),
      jenisKelamin: anyNamed('jenisKelamin'),
      agama: anyNamed('agama'),
      golonganDarah: anyNamed('golonganDarah'),
      pekerjaan: anyNamed('pekerjaan'),
      peranKeluarga: anyNamed('peranKeluarga'),
      tempatLahir: anyNamed('tempatLahir'),
      tanggalLahir: anyNamed('tanggalLahir'),
      pendidikan: anyNamed('pendidikan'),
    )).thenAnswer((_) async => mockWargaProfile());

    when(mockRepository.linkWargaToKeluarga(any, any)).thenAnswer((_) async {});

    final result = await viewModel.saveWarga(
      userId: 'u2',
      namaLengkap: 'Ani',
      nik: '456',
      noHp: '08111',
      jenisKelamin: 'Perempuan',
      agama: 'islam',
      golonganDarah: 'A',
      pekerjaan: 'IRT',
      peranKeluarga: 'anak',
      keluargaId: 'k1',
    );

    expect(result, true);
    verify(mockRepository.linkWargaToKeluarga('u2', 'k1')).called(1);
  });

  test('saveWarga returns false when exception occurs', () async {
    when(mockRepository.createProfile(
      userId: anyNamed('userId'),
      namaLengkap: anyNamed('namaLengkap'),
      nik: anyNamed('nik'),
      noHp: anyNamed('noHp'),
      jenisKelamin: anyNamed('jenisKelamin'),
      agama: anyNamed('agama'),
      golonganDarah: anyNamed('golonganDarah'),
      pekerjaan: anyNamed('pekerjaan'),
      peranKeluarga: anyNamed('peranKeluarga'),
      tempatLahir: anyNamed('tempatLahir'),
      tanggalLahir: anyNamed('tanggalLahir'),
      pendidikan: anyNamed('pendidikan'),
    )).thenThrow(Exception('error'));

    final result = await viewModel.saveWarga(
      userId: 'u3',
      namaLengkap: 'Error',
      nik: '000',
      noHp: '08',
      jenisKelamin: 'Laki-Laki',
      agama: 'islam',
      golonganDarah: 'O',
      pekerjaan: 'Test',
      peranKeluarga: 'anak',
    );

    expect(result, false);
    expect(viewModel.error, isNotNull);
  });
}
