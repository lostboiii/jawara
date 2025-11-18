import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';

class _FakePengeluaranRepository implements PengeluaranRepository {
  _FakePengeluaranRepository({List<PengeluaranModel>? seed})
      : _seed = List<PengeluaranModel>.from(seed ?? const []);

  final List<PengeluaranModel> _seed;
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  bool throwOnUpdate = false;
  bool throwOnDelete = false;

  int _counter = 0;
  Map<String, dynamic>? lastCreateArgs;
  Map<String, dynamic>? lastUpdateArgs;
  String? lastDeleteId;
  PengeluaranModel? nextCreateResult;
  PengeluaranModel? nextUpdateResult;

  @override
  Future<List<PengeluaranModel>> fetchAll() async {
    if (throwOnFetch) {
      throw Exception('fetch pengeluaran error');
    }
    return List.unmodifiable(_seed);
  }

  @override
  Future<PengeluaranModel> createPengeluaran({
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    if (throwOnCreate) {
      throw Exception('create pengeluaran error');
    }
    lastCreateArgs = {
      'nama': nama,
      'tanggal': tanggal,
      'kategori': kategori,
      'jumlah': jumlah,
      'bukti': bukti,
    };
    if (nextCreateResult != null) {
      final result = nextCreateResult!;
      nextCreateResult = null;
      return result;
    }
    _counter += 1;
    return PengeluaranModel(
      id: 'pengeluaran-${_counter}',
      namaPengeluaran: nama,
      tanggalPengeluaran: tanggal,
      kategoriPengeluaran: kategori,
      jumlah: jumlah,
      buktiPengeluaran: bukti,
    );
  }

  @override
  Future<PengeluaranModel> updatePengeluaran({
    required String id,
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    if (throwOnUpdate) {
      throw Exception('update pengeluaran error');
    }
    lastUpdateArgs = {
      'id': id,
      'nama': nama,
      'tanggal': tanggal,
      'kategori': kategori,
      'jumlah': jumlah,
      'bukti': bukti,
    };
    if (nextUpdateResult != null) {
      final result = nextUpdateResult!;
      nextUpdateResult = null;
      return result;
    }
    return PengeluaranModel(
      id: id,
      namaPengeluaran: nama,
      tanggalPengeluaran: tanggal,
      kategoriPengeluaran: kategori,
      jumlah: jumlah,
      buktiPengeluaran: bukti,
    );
  }

  @override
  Future<void> deletePengeluaran(String id) async {
    if (throwOnDelete) {
      throw Exception('delete pengeluaran error');
    }
    lastDeleteId = id;
  }
}

PengeluaranModel _samplePengeluaran(String id) {
  return PengeluaranModel(
    id: id,
    namaPengeluaran: 'Pengeluaran $id',
    tanggalPengeluaran: DateTime(2024, 1, 1),
    kategoriPengeluaran: 'operasional',
    jumlah: 150000,
    buktiPengeluaran: 'bukti-$id.jpg',
  );
}

void main() {
  group('PengeluaranViewModel', () {
    late _FakePengeluaranRepository repository;
    late PengeluaranViewModel viewModel;

    setUp(() {
      repository = _FakePengeluaranRepository();
      viewModel = PengeluaranViewModel(repository: repository);
    });

    test('loadPengeluaran success updates items and clears error', () async {
      repository = _FakePengeluaranRepository(seed: [
        _samplePengeluaran('1'),
        _samplePengeluaran('2'),
      ]);
      viewModel = PengeluaranViewModel(repository: repository);

      expect(viewModel.isLoading, false);
      final future = viewModel.loadPengeluaran();
      expect(viewModel.isLoading, true);
      await future;

      expect(viewModel.isLoading, false);
      expect(viewModel.items, hasLength(2));
      expect(viewModel.items.first.id, '1');
      expect(viewModel.errorMessage, isNull);
    });

    test('loadPengeluaran failure stores error message', () async {
      repository.throwOnFetch = true;

      await viewModel.loadPengeluaran();

      expect(viewModel.isLoading, false);
      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, contains('fetch pengeluaran error'));
    });

    test('addPengeluaran prepends returned item', () async {
      repository = _FakePengeluaranRepository(seed: [
        _samplePengeluaran('existing'),
      ]);
      viewModel = PengeluaranViewModel(repository: repository);
      await viewModel.loadPengeluaran();

      final created = _samplePengeluaran('new');
      repository.nextCreateResult = created;

      await viewModel.addPengeluaran(
        nama: created.namaPengeluaran,
        tanggal: created.tanggalPengeluaran,
        kategori: created.kategoriPengeluaran,
        jumlah: created.jumlah,
        bukti: created.buktiPengeluaran,
      );

      expect(viewModel.isLoading, false);
      expect(viewModel.items, hasLength(2));
      expect(viewModel.items.first.id, created.id);
      expect(viewModel.errorMessage, isNull);
      expect(repository.lastCreateArgs?['nama'], created.namaPengeluaran);
    });

    test('addPengeluaran rethrows and keeps error message', () async {
      repository.throwOnCreate = true;
      final tanggal = DateTime(2024, 2, 1);

      try {
        await viewModel.addPengeluaran(
          nama: 'Gagal',
          tanggal: tanggal,
          kategori: 'operasional',
          jumlah: 10000,
          bukti: null,
        );
        fail('Expected addPengeluaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('create pengeluaran error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('updatePengeluaran replaces existing item', () async {
      final original = _samplePengeluaran('u1');
      repository = _FakePengeluaranRepository(seed: [original]);
      viewModel = PengeluaranViewModel(repository: repository);
      await viewModel.loadPengeluaran();

      final updated = original.copyWith(
        namaPengeluaran: 'Updated Pengeluaran',
        jumlah: 250000,
      );
      repository.nextUpdateResult = updated;

      await viewModel.updatePengeluaran(
        id: updated.id,
        nama: updated.namaPengeluaran,
        tanggal: updated.tanggalPengeluaran,
        kategori: updated.kategoriPengeluaran,
        jumlah: updated.jumlah,
        bukti: updated.buktiPengeluaran,
      );

      expect(viewModel.items.single.namaPengeluaran, 'Updated Pengeluaran');
      expect(repository.lastUpdateArgs?['id'], updated.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('updatePengeluaran rethrows and preserves error message', () async {
      final original = _samplePengeluaran('err');
      repository = _FakePengeluaranRepository(seed: [original]);
      viewModel = PengeluaranViewModel(repository: repository);
      await viewModel.loadPengeluaran();

      repository.throwOnUpdate = true;

      try {
        await viewModel.updatePengeluaran(
          id: original.id,
          nama: original.namaPengeluaran,
          tanggal: original.tanggalPengeluaran,
          kategori: original.kategoriPengeluaran,
          jumlah: original.jumlah,
          bukti: original.buktiPengeluaran,
        );
        fail('Expected updatePengeluaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('update pengeluaran error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('deletePengeluaran removes item and records id', () async {
      final original = _samplePengeluaran('del');
      repository = _FakePengeluaranRepository(seed: [original]);
      viewModel = PengeluaranViewModel(repository: repository);
      await viewModel.loadPengeluaran();

      await viewModel.deletePengeluaran(original.id);

      expect(viewModel.items, isEmpty);
      expect(repository.lastDeleteId, original.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('deletePengeluaran rethrows on failure', () async {
      final original = _samplePengeluaran('del-err');
      repository = _FakePengeluaranRepository(seed: [original]);
      viewModel = PengeluaranViewModel(repository: repository);
      await viewModel.loadPengeluaran();

      repository.throwOnDelete = true;

      try {
        await viewModel.deletePengeluaran(original.id);
        fail('Expected deletePengeluaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('delete pengeluaran error'));
        expect(viewModel.isLoading, false);
      }
    });
  });
}
