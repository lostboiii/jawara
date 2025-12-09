import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/pemasukan_model.dart';
import 'package:jawara/data/repositories/pemasukan_repository.dart';
import 'package:jawara/viewmodels/pemasukan_viewmodel.dart';

class _FakePemasukanRepository implements PemasukanRepository {
  final List<PemasukanModel> _items;
  _FakePemasukanRepository(this._items);

  @override
  Future<List<PemasukanModel>> fetchAll() async => List.from(_items);

  @override
  Future<PemasukanModel?> fetchById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PemasukanModel> createPemasukan({
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    final item = PemasukanModel(
      id: 'new-id',
      nama_pemasukan: nama_pemasukan,
      jumlah: jumlah,
      tanggal_pemasukan: tanggal_pemasukan,
      kategori_pemasukan: kategori_pemasukan,
      bukti_pemasukan: bukti_pemasukan,
    );
    _items.add(item);
    return item;
  }

  @override
  Future<PemasukanModel> updatePemasukan({
    required String id,
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    final index = _items.indexWhere((e) => e.id == id);
    final updated = PemasukanModel(
      id: id,
      nama_pemasukan: nama_pemasukan,
      jumlah: jumlah,
      tanggal_pemasukan: tanggal_pemasukan,
      kategori_pemasukan: kategori_pemasukan,
      bukti_pemasukan: bukti_pemasukan,
    );
    if (index != -1) _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePemasukan(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<PemasukanModel>> filterPemasukan({
    String? nama,
    String? kategori,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _items;
  }

  @override
  Future<List<String>> getCategories() async {
    return ['Iuran', 'Donasi'];
  }

  @override
  Future<String> uploadBukti(String path, List<int> fileBytes) async {
    return 'https://fake-url.com/bukti.jpg';
  }
}

void main() {
  group('PemasukanViewModel Tests', () {
    test('initial state is correct', () {
      final repo = _FakePemasukanRepository([]);
      final vm = PemasukanViewModel(repository: repo);

      expect(vm.isLoading, false);
      expect(vm.items, isEmpty);
      expect(vm.errorMessage, isNull);
    });

    test('loadPemasukan fetches items', () async {
      final items = [
        PemasukanModel(
          id: '1',
          nama_pemasukan: 'Iuran Warga',
          kategori_pemasukan: 'Iuran',
          jumlah: 100000,
          tanggal_pemasukan: DateTime(2024, 1, 1),
        ),
      ];
      final repo = _FakePemasukanRepository(items);
      final vm = PemasukanViewModel(repository: repo);

      await vm.loadPemasukan();

      expect(vm.isLoading, false);
      expect(vm.items.length, 1);
      expect(vm.items.first.kategori_pemasukan, 'Iuran');
    });

    test('addPemasukan adds item', () async {
      final repo = _FakePemasukanRepository([]);
      final vm = PemasukanViewModel(repository: repo);

      await vm.addPemasukan(
        nama_pemasukan: 'Donasi',
        kategori_pemasukan: 'Donasi',
        jumlah: 50000,
        tanggal_pemasukan: DateTime(2024, 1, 1),
      );

      expect(vm.items.length, 1);
      expect(vm.items.first.kategori_pemasukan, 'Donasi');
    });

    test('updatePemasukan updates existing item', () async {
      final items = [
        PemasukanModel(
          id: '1',
          nama_pemasukan: 'Iuran Warga',
          kategori_pemasukan: 'Iuran',
          jumlah: 100000,
          tanggal_pemasukan: DateTime(2024, 1, 1),
        ),
      ];
      final repo = _FakePemasukanRepository(items);
      final vm = PemasukanViewModel(repository: repo);
      await vm.loadPemasukan();

      await vm.updatePemasukan(
        id: '1',
        nama_pemasukan: 'Iuran Updated',
        kategori_pemasukan: 'Iuran',
        jumlah: 150000,
        tanggal_pemasukan: DateTime(2024, 1, 1),
      );

      expect(vm.items.first.nama_pemasukan, 'Iuran Updated');
      expect(vm.items.first.jumlah, 150000);
    });

    test('deletePemasukan removes item', () async {
      final items = [
        PemasukanModel(
          id: '1',
          nama_pemasukan: 'Iuran Warga',
          kategori_pemasukan: 'Iuran',
          jumlah: 100000,
          tanggal_pemasukan: DateTime(2024, 1, 1),
        ),
      ];
      final repo = _FakePemasukanRepository(items);
      final vm = PemasukanViewModel(repository: repo);
      await vm.loadPemasukan();

      await vm.deletePemasukan('1');

      expect(vm.items, isEmpty);
    });

    test('filterPemasukan applies filters', () async {
      final items = [
        PemasukanModel(
          id: '1',
          nama_pemasukan: 'Iuran Warga',
          kategori_pemasukan: 'Iuran',
          jumlah: 100000,
          tanggal_pemasukan: DateTime(2024, 1, 1),
        ),
      ];
      final repo = _FakePemasukanRepository(items);
      final vm = PemasukanViewModel(repository: repo);

      await vm.filterPemasukan(
        nama: 'Iuran',
        kategori: 'Iuran',
        fromDate: DateTime(2024, 1, 1),
        toDate: DateTime(2024, 12, 31),
      );

      expect(vm.items.length, 1);
    });

    test('repository getter exposes repository', () {
      final repo = _FakePemasukanRepository([]);
      final vm = PemasukanViewModel(repository: repo);

      expect(vm.repository, equals(repo));
    });

    test('loadPemasukan handles error', () async {
      final repo = _FakeErrorPemasukanRepository();
      final vm = PemasukanViewModel(repository: repo);

      await vm.loadPemasukan();

      expect(vm.errorMessage, isNotNull);
      expect(vm.errorMessage, contains('fetch error'));
    });

    test('addPemasukan handles error and rethrows', () async {
      final repo = _FakeErrorPemasukanRepository();
      final vm = PemasukanViewModel(repository: repo);

      expect(
        () => vm.addPemasukan(
          nama_pemasukan: 'Test',
          kategori_pemasukan: 'Test',
          jumlah: 100,
          tanggal_pemasukan: DateTime.now(),
        ),
        throwsException,
      );
    });

    test('updatePemasukan handles error and rethrows', () async {
      final repo = _FakeErrorPemasukanRepository();
      final vm = PemasukanViewModel(repository: repo);

      expect(
        () => vm.updatePemasukan(
          id: '1',
          nama_pemasukan: 'Test',
          kategori_pemasukan: 'Test',
          jumlah: 100,
          tanggal_pemasukan: DateTime.now(),
        ),
        throwsException,
      );
    });

    test('deletePemasukan handles error and rethrows', () async {
      final repo = _FakeErrorPemasukanRepository();
      final vm = PemasukanViewModel(repository: repo);

      expect(() => vm.deletePemasukan('1'), throwsException);
    });

    test('filterPemasukan handles error', () async {
      final repo = _FakeErrorPemasukanRepository();
      final vm = PemasukanViewModel(repository: repo);

      await vm.filterPemasukan(nama: 'test');

      expect(vm.errorMessage, isNotNull);
    });
  });
}

class _FakeErrorPemasukanRepository implements PemasukanRepository {
  @override
  Future<List<PemasukanModel>> fetchAll() async {
    throw Exception('fetch error');
  }

  @override
  Future<PemasukanModel?> fetchById(String id) async {
    throw Exception('fetch by id error');
  }

  @override
  Future<PemasukanModel> createPemasukan({
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    throw Exception('create error');
  }

  @override
  Future<PemasukanModel> updatePemasukan({
    required String id,
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    throw Exception('update error');
  }

  @override
  Future<void> deletePemasukan(String id) async {
    throw Exception('delete error');
  }

  @override
  Future<List<PemasukanModel>> filterPemasukan({
    String? nama,
    String? kategori,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    throw Exception('filter error');
  }

  @override
  Future<List<String>> getCategories() async {
    throw Exception('get categories error');
  }

  @override
  Future<String> uploadBukti(String path, List<int> fileBytes) async {
    throw Exception('upload error');
  }
}
