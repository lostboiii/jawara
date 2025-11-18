import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/metode_pembayaran_model.dart';
import 'package:jawara/data/repositories/metode_pembayaran_repository.dart';
import 'package:jawara/viewmodels/metode_pembayaran_viewmodel.dart';

class _FakeMetodePembayaranRepository implements MetodePembayaranRepository {
  _FakeMetodePembayaranRepository({List<MetodePembayaranModel>? seed})
      : _seed = List<MetodePembayaranModel>.from(seed ?? const []);

  final List<MetodePembayaranModel> _seed;
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  bool throwOnUpdate = false;
  bool throwOnDelete = false;

  Map<String, dynamic>? lastCreateArgs;
  Map<String, dynamic>? lastUpdateArgs;
  String? lastDeleteId;
  MetodePembayaranModel? nextCreateResult;
  MetodePembayaranModel? nextUpdateResult;

  @override
  Future<List<MetodePembayaranModel>> fetchAll() async {
    if (throwOnFetch) {
      throw Exception('fetch metode pembayaran error');
    }
    return List.unmodifiable(_seed);
  }

  @override
  Future<MetodePembayaranModel> createMetodePembayaran({
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    if (throwOnCreate) {
      throw Exception('create metode pembayaran error');
    }
    lastCreateArgs = {
      'nama_metode': namaMetode,
      'nomor_rekening': nomorRekening,
      'nama_pemilik': namaPemilik,
      'foto_barcode': fotoBarcode,
      'thumbnail': thumbnail,
      'catatan': catatan,
    };
    if (nextCreateResult != null) {
      final result = nextCreateResult!;
      nextCreateResult = null;
      return result;
    }
    return MetodePembayaranModel(
      id: 'metode-${DateTime.now().microsecondsSinceEpoch}',
      namaMetode: namaMetode,
      nomorRekening: nomorRekening,
      namaPemilik: namaPemilik,
      fotoBarcode: fotoBarcode,
      thumbnail: thumbnail,
      catatan: catatan,
    );
  }

  @override
  Future<MetodePembayaranModel> updateMetodePembayaran({
    required String id,
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    if (throwOnUpdate) {
      throw Exception('update metode pembayaran error');
    }
    lastUpdateArgs = {
      'id': id,
      'nama_metode': namaMetode,
      'nomor_rekening': nomorRekening,
      'nama_pemilik': namaPemilik,
      'foto_barcode': fotoBarcode,
      'thumbnail': thumbnail,
      'catatan': catatan,
    };
    if (nextUpdateResult != null) {
      final result = nextUpdateResult!;
      nextUpdateResult = null;
      return result;
    }
    return MetodePembayaranModel(
      id: id,
      namaMetode: namaMetode,
      nomorRekening: nomorRekening,
      namaPemilik: namaPemilik,
      fotoBarcode: fotoBarcode,
      thumbnail: thumbnail,
      catatan: catatan,
    );
  }

  @override
  Future<void> deleteMetodePembayaran(String id) async {
    if (throwOnDelete) {
      throw Exception('delete metode pembayaran error');
    }
    lastDeleteId = id;
  }
}

MetodePembayaranModel _sampleMetode(String id) {
  return MetodePembayaranModel(
    id: id,
    namaMetode: 'Metode $id',
    nomorRekening: '123456$id',
    namaPemilik: 'Pemilik $id',
    fotoBarcode: 'barcode-$id.png',
    thumbnail: 'thumb-$id.png',
    catatan: 'Catatan $id',
  );
}

void main() {
  group('MetodePembayaranViewModel', () {
    late _FakeMetodePembayaranRepository repository;
    late MetodePembayaranViewModel viewModel;

    setUp(() {
      repository = _FakeMetodePembayaranRepository();
      viewModel = MetodePembayaranViewModel(repository: repository);
    });

    test('loadMetodePembayaran success fills items', () async {
      repository = _FakeMetodePembayaranRepository(seed: [
        _sampleMetode('1'),
        _sampleMetode('2'),
      ]);
      viewModel = MetodePembayaranViewModel(repository: repository);

      final future = viewModel.loadMetodePembayaran();
      expect(viewModel.isLoading, true);
      await future;

      expect(viewModel.items, hasLength(2));
      expect(viewModel.items.first.id, '1');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test('loadMetodePembayaran failure sets error message', () async {
      repository.throwOnFetch = true;

      await viewModel.loadMetodePembayaran();

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, contains('fetch metode pembayaran error'));
      expect(viewModel.isLoading, false);
    });

    test('addMetodePembayaran inserts item', () async {
      repository = _FakeMetodePembayaranRepository(seed: [
        _sampleMetode('existing'),
      ]);
      viewModel = MetodePembayaranViewModel(repository: repository);
      await viewModel.loadMetodePembayaran();

      final created = _sampleMetode('baru');
      repository.nextCreateResult = created;

      await viewModel.addMetodePembayaran(
        namaMetode: created.namaMetode,
        nomorRekening: created.nomorRekening,
        namaPemilik: created.namaPemilik,
        fotoBarcode: created.fotoBarcode,
        thumbnail: created.thumbnail,
        catatan: created.catatan,
      );

      expect(viewModel.items.first.id, created.id);
      expect(viewModel.items, hasLength(2));
      expect(viewModel.errorMessage, isNull);
      expect(repository.lastCreateArgs?['nama_metode'], created.namaMetode);
    });

    test('addMetodePembayaran rethrows and stores message', () async {
      repository.throwOnCreate = true;

      try {
        await viewModel.addMetodePembayaran(
          namaMetode: 'Gagal',
          nomorRekening: null,
          namaPemilik: null,
          fotoBarcode: null,
          thumbnail: null,
          catatan: null,
        );
        fail('Expected addMetodePembayaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('create metode pembayaran error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('updateMetodePembayaran replaces existing item', () async {
      final original = _sampleMetode('update');
      repository = _FakeMetodePembayaranRepository(seed: [original]);
      viewModel = MetodePembayaranViewModel(repository: repository);
      await viewModel.loadMetodePembayaran();

      final updated = original.copyWith(namaMetode: 'Metode Baru');
      repository.nextUpdateResult = updated;

      await viewModel.updateMetodePembayaran(
        id: updated.id,
        namaMetode: updated.namaMetode,
        nomorRekening: updated.nomorRekening,
        namaPemilik: updated.namaPemilik,
        fotoBarcode: updated.fotoBarcode,
        thumbnail: updated.thumbnail,
        catatan: updated.catatan,
      );

      expect(viewModel.items.single.namaMetode, 'Metode Baru');
      expect(repository.lastUpdateArgs?['id'], updated.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('updateMetodePembayaran rethrows on failure', () async {
      final original = _sampleMetode('err');
      repository = _FakeMetodePembayaranRepository(seed: [original]);
      viewModel = MetodePembayaranViewModel(repository: repository);
      await viewModel.loadMetodePembayaran();

      repository.throwOnUpdate = true;

      try {
        await viewModel.updateMetodePembayaran(
          id: original.id,
          namaMetode: original.namaMetode,
          nomorRekening: original.nomorRekening,
          namaPemilik: original.namaPemilik,
          fotoBarcode: original.fotoBarcode,
          thumbnail: original.thumbnail,
          catatan: original.catatan,
        );
        fail('Expected updateMetodePembayaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('update metode pembayaran error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('deleteMetodePembayaran removes item', () async {
      final original = _sampleMetode('hapus');
      repository = _FakeMetodePembayaranRepository(seed: [original]);
      viewModel = MetodePembayaranViewModel(repository: repository);
      await viewModel.loadMetodePembayaran();

      await viewModel.deleteMetodePembayaran(original.id);

      expect(viewModel.items, isEmpty);
      expect(repository.lastDeleteId, original.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('deleteMetodePembayaran rethrows on failure', () async {
      final original = _sampleMetode('hapus-error');
      repository = _FakeMetodePembayaranRepository(seed: [original]);
      viewModel = MetodePembayaranViewModel(repository: repository);
      await viewModel.loadMetodePembayaran();

      repository.throwOnDelete = true;

      try {
        await viewModel.deleteMetodePembayaran(original.id);
        fail('Expected deleteMetodePembayaran to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('delete metode pembayaran error'));
        expect(viewModel.isLoading, false);
      }
    });
  });
}
