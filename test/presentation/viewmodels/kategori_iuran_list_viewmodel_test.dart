import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/kategori_iuran_list_viewmodel.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class MockIuranRepository implements IuranRepository {
  @override
  Future<List<Map<String, dynamic>>> getKategoriIuran() async {
    return [
      {'id': '1', 'nama_iuran': 'Kebersihan', 'kategori_iuran': 'Wajib'},
      {'id': '2', 'nama_iuran': 'Sosial', 'kategori_iuran': 'Sukarela'}
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('KategoriIuranListViewModel Tests', () {
    late KategoriIuranListViewModel viewModel;
    late MockIuranRepository mockRepository;

    setUp(() {
      mockRepository = MockIuranRepository();
      viewModel = KategoriIuranListViewModel(repository: mockRepository);
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.kategoris, isEmpty);
    });

    test('loadKategoris loads data successfully', () async {
      await viewModel.loadKategoris();

      expect(viewModel.kategoris.length, 2);
      expect(viewModel.kategoris[0]['nama_iuran'], 'Kebersihan');
      expect(viewModel.isLoading, isFalse);
    });
  });
}