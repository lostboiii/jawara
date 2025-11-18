import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/broadcast_model.dart';
import 'package:jawara/data/repositories/broadcast_repository.dart';
import 'package:jawara/viewmodels/broadcast_viewmodel.dart';

class _FakeBroadcastRepository implements BroadcastRepository {
  _FakeBroadcastRepository({List<BroadcastModel>? seed})
      : _seed = List<BroadcastModel>.from(seed ?? const []);

  final List<BroadcastModel> _seed;
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  bool throwOnUpdate = false;
  bool throwOnDelete = false;

  Map<String, dynamic>? lastCreateArgs;
  Map<String, dynamic>? lastUpdateArgs;
  String? lastDeleteId;
  BroadcastModel? nextCreateResult;
  BroadcastModel? nextUpdateResult;

  @override
  Future<List<BroadcastModel>> fetchAll() async {
    if (throwOnFetch) {
      throw Exception('fetch broadcast error');
    }
    return List.unmodifiable(_seed);
  }

  @override
  Future<BroadcastModel> createBroadcast({
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    if (throwOnCreate) {
      throw Exception('create broadcast error');
    }
    lastCreateArgs = {
      'judul': judul,
      'isi': isi,
      'foto': foto,
      'dokumen': dokumen,
    };
    if (nextCreateResult != null) {
      final result = nextCreateResult!;
      nextCreateResult = null;
      return result;
    }
    return BroadcastModel(
      id: 'broadcast-${DateTime.now().microsecondsSinceEpoch}',
      judulBroadcast: judul,
      isiBroadcast: isi,
      fotoBroadcast: foto,
      dokumenBroadcast: dokumen,
    );
  }

  @override
  Future<BroadcastModel> updateBroadcast({
    required String id,
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    if (throwOnUpdate) {
      throw Exception('update broadcast error');
    }
    lastUpdateArgs = {
      'id': id,
      'judul': judul,
      'isi': isi,
      'foto': foto,
      'dokumen': dokumen,
    };
    if (nextUpdateResult != null) {
      final result = nextUpdateResult!;
      nextUpdateResult = null;
      return result;
    }
    return BroadcastModel(
      id: id,
      judulBroadcast: judul,
      isiBroadcast: isi,
      fotoBroadcast: foto,
      dokumenBroadcast: dokumen,
    );
  }

  @override
  Future<void> deleteBroadcast(String id) async {
    if (throwOnDelete) {
      throw Exception('delete broadcast error');
    }
    lastDeleteId = id;
  }
}

BroadcastModel _sampleBroadcast(String id) {
  return BroadcastModel(
    id: id,
    judulBroadcast: 'Judul $id',
    isiBroadcast: 'Isi broadcast $id',
    fotoBroadcast: 'foto-$id.png',
    dokumenBroadcast: 'dokumen-$id.pdf',
  );
}

void main() {
  group('BroadcastViewModel', () {
    late _FakeBroadcastRepository repository;
    late BroadcastViewModel viewModel;

    setUp(() {
      repository = _FakeBroadcastRepository();
      viewModel = BroadcastViewModel(repository: repository);
    });

    test('loadBroadcasts success populates items', () async {
      repository = _FakeBroadcastRepository(seed: [
        _sampleBroadcast('1'),
        _sampleBroadcast('2'),
      ]);
      viewModel = BroadcastViewModel(repository: repository);

      final future = viewModel.loadBroadcasts();
      expect(viewModel.isLoading, true);
      await future;

      expect(viewModel.items, hasLength(2));
      expect(viewModel.items.first.id, '1');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, false);
    });

    test('loadBroadcasts failure stores error', () async {
      repository.throwOnFetch = true;

      await viewModel.loadBroadcasts();

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, contains('fetch broadcast error'));
      expect(viewModel.isLoading, false);
    });

    test('addBroadcast inserts item at start', () async {
      repository = _FakeBroadcastRepository(seed: [
        _sampleBroadcast('existing'),
      ]);
      viewModel = BroadcastViewModel(repository: repository);
      await viewModel.loadBroadcasts();

      final created = _sampleBroadcast('new');
      repository.nextCreateResult = created;

      await viewModel.addBroadcast(
        judul: created.judulBroadcast,
        isi: created.isiBroadcast,
        foto: created.fotoBroadcast,
        dokumen: created.dokumenBroadcast,
      );

      expect(viewModel.items.first.id, created.id);
      expect(viewModel.items, hasLength(2));
      expect(viewModel.errorMessage, isNull);
      expect(repository.lastCreateArgs?['judul'], created.judulBroadcast);
    });

    test('addBroadcast propagates failure', () async {
      repository.throwOnCreate = true;

      try {
        await viewModel.addBroadcast(
          judul: 'Gagal',
          isi: 'Isi',
          foto: null,
          dokumen: null,
        );
        fail('Expected addBroadcast to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('create broadcast error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('updateBroadcast replaces item', () async {
      final original = _sampleBroadcast('update');
      repository = _FakeBroadcastRepository(seed: [original]);
      viewModel = BroadcastViewModel(repository: repository);
      await viewModel.loadBroadcasts();

      final updated = original.copyWith(judulBroadcast: 'Judul Baru');
      repository.nextUpdateResult = updated;

      await viewModel.updateBroadcast(
        id: updated.id,
        judul: updated.judulBroadcast,
        isi: updated.isiBroadcast,
        foto: updated.fotoBroadcast,
        dokumen: updated.dokumenBroadcast,
      );

      expect(viewModel.items.single.judulBroadcast, 'Judul Baru');
      expect(repository.lastUpdateArgs?['id'], updated.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('updateBroadcast propagates failure', () async {
      final original = _sampleBroadcast('err');
      repository = _FakeBroadcastRepository(seed: [original]);
      viewModel = BroadcastViewModel(repository: repository);
      await viewModel.loadBroadcasts();

      repository.throwOnUpdate = true;

      try {
        await viewModel.updateBroadcast(
          id: original.id,
          judul: original.judulBroadcast,
          isi: original.isiBroadcast,
          foto: original.fotoBroadcast,
          dokumen: original.dokumenBroadcast,
        );
        fail('Expected updateBroadcast to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('update broadcast error'));
        expect(viewModel.isLoading, false);
      }
    });

    test('deleteBroadcast removes item', () async {
      final original = _sampleBroadcast('hapus');
      repository = _FakeBroadcastRepository(seed: [original]);
      viewModel = BroadcastViewModel(repository: repository);
      await viewModel.loadBroadcasts();

      await viewModel.deleteBroadcast(original.id);

      expect(viewModel.items, isEmpty);
      expect(repository.lastDeleteId, original.id);
      expect(viewModel.errorMessage, isNull);
    });

    test('deleteBroadcast propagates failure', () async {
      final original = _sampleBroadcast('hapus-error');
      repository = _FakeBroadcastRepository(seed: [original]);
      viewModel = BroadcastViewModel(repository: repository);
      await viewModel.loadBroadcasts();

      repository.throwOnDelete = true;

      try {
        await viewModel.deleteBroadcast(original.id);
        fail('Expected deleteBroadcast to throw');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(viewModel.errorMessage, contains('delete broadcast error'));
        expect(viewModel.isLoading, false);
      }
    });
  });
}
