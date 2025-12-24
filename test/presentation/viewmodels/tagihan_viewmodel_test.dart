import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/tagihan_viewmodel.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class MockIuranRepository implements IuranRepository {
  @override
  Future<List<Map<String, dynamic>>> getTagihan() async {
    return [
      {
        'id': '1',
        'nominal': 50000,
        'status': 'Lunas',
        'keluarga': {'nomor_kk': '12345'}
      }
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TagihanViewModel Tests', () {
    late TagihanViewModel viewModel;
    late MockIuranRepository mockRepository;

    setUp(() {
      mockRepository = MockIuranRepository();
      viewModel = TagihanViewModel(repository: mockRepository);
    });

    test('loadTagihan berhasil memuat data (tanpa error Supabase)', () async {
      expect(viewModel.isLoading, false);
      expect(viewModel.tagihan, isEmpty);

      await viewModel.loadTagihan();

      expect(viewModel.tagihan.length, 1);
      expect(viewModel.tagihan[0]['nominal'], 50000);
      expect(viewModel.isLoading, false);
    });
  });
}