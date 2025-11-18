import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/kegiatan_model.dart';
import 'package:jawara/data/repositories/kegiatan_repository.dart';
import 'package:jawara/viewmodels/kegiatan_viewmodel.dart';

class _FakeKegiatanRepository implements KegiatanRepository {
  _FakeKegiatanRepository({List<KegiatanModel>? seed})
      : _seed = List<KegiatanModel>.from(seed ?? const []);

  final List<KegiatanModel> _seed;
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  bool throwOnUpdate = false;
  bool throwOnDelete = false;

  Map<String, dynamic>? lastCreateArgs;
  Map<String, dynamic>? lastUpdateArgs;
  String? lastDeleteId;
  KegiatanModel? nextCreateResult;
  KegiatanModel? nextUpdateResult;

  @override
  Future<List<KegiatanModel>> fetchAll() async {
    if (throwOnFetch) {
      throw Exception('fetch kegiatan error');
    }
    return List.unmodifiable(_seed);
  }

  @override
  Future<KegiatanModel> createKegiatan({
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    if (throwOnCreate) {
      throw Exception('create kegiatan error');
    }
    lastCreateArgs = {
      'nama': nama,
      'kategori': kategori,
      'tanggal': tanggal,
      'lokasi': lokasi,
      'penanggung_jawab': penanggungJawab,
      'deskripsi': deskripsi,
    };
    if (nextCreateResult != null) {
      final result = nextCreateResult!;
      nextCreateResult = null;
      return result;
    }
    return KegiatanModel(
      id: 'kegiatan-${DateTime.now().microsecondsSinceEpoch}',
      namaKegiatan: nama,
      kategoriKegiatan: kategori,
      tanggalKegiatan: tanggal,
      lokasiKegiatan: lokasi,
      penanggungJawab: penanggungJawab,
      deskripsi: deskripsi,
    );
  }

  @override
  Future<KegiatanModel> updateKegiatan({
    required String id,
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    if (throwOnUpdate) {
      throw Exception('update kegiatan error');
    }
    lastUpdateArgs = {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'tanggal': tanggal,
      'lokasi': lokasi,
      'penanggung_jawab': penanggungJawab,
      'deskripsi': deskripsi,
    };
    if (nextUpdateResult != null) {
      final result = nextUpdateResult!;
      nextUpdateResult = null;
      return result;
    }
    return KegiatanModel(
      id: id,
      namaKegiatan: nama,
      kategoriKegiatan: kategori,
      tanggalKegiatan: tanggal,
      lokasiKegiatan: lokasi,
      penanggungJawab: penanggungJawab,
      deskripsi: deskripsi,
    );
  }

  @override
  Future<void> deleteKegiatan(String id) async {
    if (throwOnDelete) {
      throw Exception('delete kegiatan error');
    }
    lastDeleteId = id;
  }
}

KegiatanModel _sampleKegiatan(String id) {
  return KegiatanModel(
    id: id,
    namaKegiatan: 'Kegiatan $id',
    kategoriKegiatan: 'Kategori $id',
    tanggalKegiatan: DateTime(2024, 3, 10 + int.parse(id.replaceAll(RegExp(r'[^0-9]'), '0')) % 10),
    lokasiKegiatan: 'Lokasi $id',
    penanggungJawab: 'PJ $id',
    deskripsi: 'Deskripsi $id',
  );
}

void main() {
  group('KegiatanViewModel', () {
    late _FakeKegiatanRepository repository;
    late KegiatanViewModel viewModel;

    setUp(() {
      repository = _FakeKegiatanRepository();
      viewModel = KegiatanViewModel(repository: repository);
    });

    test('loadKegiatan success updates items', () async {
      repository = _FakeKegiatanRepository(seed: [
        _sampleKegiatan('1'),
        _sampleKegiatan('2'),
      ]);
      viewModel = KegiatanViewModel(repository: repository);

      final future = viewModel.loadKegiatan();
      expect(viewModel.isLoading, true);
      await future;

      expect(viewModel.items, hasLength(2));
      expect(viewModel.items.first.id, '1');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test('loadKegiatan failure captures error', () async {
      repository.throwOnFetch = true;

      await viewModel.loadKegiatan();

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, contains('fetch kegiatan error'));
      expect(viewModel.isLoading, false);
    });

    test('addKegiatan inserts new item', () async {
      repository = _FakeKegiatanRepository(seed: [
        _sampleKegiatan('existing'),
      ]);
      viewModel = KegiatanViewModel(repository: repository);
      await viewModel.loadKegiatan();

      final created = _sampleKegiatan('baru');
      repository.nextCreateResult = created;

      await viewModel.addKegiatan(
        nama: created.namaKegiatan,
        kategori: created.kategoriKegiatan,
        tanggal: created.tanggalKegiatan,
        lokasi: created.lokasiKegiatan,
        penanggungJawab: created.penanggungJawab,
        deskripsi: created.deskripsi,
      );

      expect(viewModel.items.first.id, created.id);
      expect(viewModel.items, hasLength(2));
      expect(viewModel.errorMessage, isNull);
      expect(repository.lastCreateArgs?['nama'], created.namaKegiatan);
    });

    test('addKegiatan propagates errors', () async {
      repository.throwOnCreate = true;

      try {
        await viewModel.addKegiatan(
          nama: 'Gagal',
          kategori: 'Kategori',
          tanggal: DateTime(2024, 1, 1),
          lokasi: 'Lokasi',
          penanggungJawab: 'PJ',
          deskripsi: 'Deskripsi',
        );
        fail('Expected addKegiatan to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('create kegiatan error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('updateKegiatan replaces item', () async {
      final original = _sampleKegiatan('update');
      repository = _FakeKegiatanRepository(seed: [original]);
      viewModel = KegiatanViewModel(repository: repository);
      await viewModel.loadKegiatan();

      final updated = original.copyWith(namaKegiatan: 'Nama Baru');
      repository.nextUpdateResult = updated;

      await viewModel.updateKegiatan(
        id: updated.id,
        nama: updated.namaKegiatan,
        kategori: updated.kategoriKegiatan,
        tanggal: updated.tanggalKegiatan,
        lokasi: updated.lokasiKegiatan,
        penanggungJawab: updated.penanggungJawab,
        deskripsi: updated.deskripsi,
      );

      expect(viewModel.items.single.namaKegiatan, 'Nama Baru');
      expect(repository.lastUpdateArgs?['id'], updated.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('updateKegiatan propagates errors', () async {
      final original = _sampleKegiatan('err');
      repository = _FakeKegiatanRepository(seed: [original]);
      viewModel = KegiatanViewModel(repository: repository);
      await viewModel.loadKegiatan();

      repository.throwOnUpdate = true;

      try {
        await viewModel.updateKegiatan(
          id: original.id,
          nama: original.namaKegiatan,
          kategori: original.kategoriKegiatan,
          tanggal: original.tanggalKegiatan,
          lokasi: original.lokasiKegiatan,
          penanggungJawab: original.penanggungJawab,
          deskripsi: original.deskripsi,
        );
        fail('Expected updateKegiatan to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('update kegiatan error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('deleteKegiatan removes item', () async {
      final original = _sampleKegiatan('hapus');
      repository = _FakeKegiatanRepository(seed: [original]);
      viewModel = KegiatanViewModel(repository: repository);
      await viewModel.loadKegiatan();

      await viewModel.deleteKegiatan(original.id);

      expect(viewModel.items, isEmpty);
      expect(repository.lastDeleteId, original.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('deleteKegiatan propagates errors', () async {
      final original = _sampleKegiatan('hapus-error');
      repository = _FakeKegiatanRepository(seed: [original]);
      viewModel = KegiatanViewModel(repository: repository);
      await viewModel.loadKegiatan();

      repository.throwOnDelete = true;

      try {
        await viewModel.deleteKegiatan(original.id);
        fail('Expected deleteKegiatan to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('delete kegiatan error'));
        expect(viewModel.isLoading, false);
      }
    });
  });
}
