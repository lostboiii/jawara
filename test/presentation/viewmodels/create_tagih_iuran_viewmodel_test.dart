import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/create_tagih_iuran_viewmodel.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class FakeIuranRepository implements IuranRepository {
  List<Map<String, dynamic>> capturedData = [];
  bool wasGetAllKeluargaCalled = false;

  @override
  Future<List<Map<String, dynamic>>> getKategoriIuran() async {
    return [
      {'id': '1', 'nama_iuran': 'Kebersihan'},
      {'id': '2', 'nama_iuran': 'Keamanan'}
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluargaId() async {
    wasGetAllKeluargaCalled = true;
    return [
      {'id': 'K001'},
      {'id': 'K002'}
    ];
  }

  @override
  Future<void> insertBatchTagihan(List<Map<String, dynamic>> data) async {
    capturedData = data;
  }

  @override
  Future<List<Map<String, dynamic>>> getTagihan() async => [];
}

void main() {
  group('CreateTagihIuranViewModel Tests', () {
    late CreateTagihIuranViewModel viewModel;
    late FakeIuranRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeIuranRepository();
      viewModel = CreateTagihIuranViewModel(repository: fakeRepository);
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.kategoris, isEmpty);
    });

    test('loadKategoris loads data successfully', () async {
      await viewModel.loadKategoris();

      expect(viewModel.kategoris.length, 2);
      expect(viewModel.kategoris.first['nama_iuran'], 'Kebersihan');
      expect(viewModel.isLoading, isFalse);
    });

    test('tagihSemuaKeluarga processes and inserts data correctly', () async {
      final kategoriId = 'CAT01';
      final tanggal = '2024-03-01';
      final jumlah = 15000;

      await viewModel.tagihSemuaKeluarga(
        kategoriId: kategoriId,
        tanggalTagihan: tanggal,
        jumlah: jumlah,
      );

      expect(fakeRepository.wasGetAllKeluargaCalled, true);
      
      expect(fakeRepository.capturedData.length, 2);
      
      expect(fakeRepository.capturedData[0]['keluarga_id'], 'K001');
      expect(fakeRepository.capturedData[0]['jumlah'], jumlah);
      expect(fakeRepository.capturedData[0]['status_tagihan'], 'belum_bayar');
      
      expect(viewModel.isLoading, isFalse);
    });
  });
}