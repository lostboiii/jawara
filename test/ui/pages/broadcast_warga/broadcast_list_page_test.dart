import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/data/models/broadcast_model.dart';
import 'package:jawara/data/repositories/broadcast_repository.dart';
import 'package:jawara/ui/pages/broadcast_warga/broadcast_list_page.dart';
import 'package:jawara/viewmodels/broadcast_viewmodel.dart';
import 'package:provider/provider.dart';

class _FakeBroadcastRepository implements BroadcastRepository {
  _FakeBroadcastRepository(this._items);

  final List<BroadcastModel> _items;

  @override
  Future<List<BroadcastModel>> fetchAll() async => List<BroadcastModel>.from(_items);

  @override
  Future<BroadcastModel> createBroadcast({
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    final model = BroadcastModel(
      id: 'new-id',
      judulBroadcast: judul,
      isiBroadcast: isi,
      fotoBroadcast: foto,
      dokumenBroadcast: dokumen,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _items.insert(0, model);
    return model;
  }

  @override
  Future<void> deleteBroadcast(String id) async {
    _items.removeWhere((element) => element.id == id);
  }

  @override
  Future<BroadcastModel> updateBroadcast({
    required String id,
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    final index = _items.indexWhere((element) => element.id == id);
    final updated = BroadcastModel(
      id: id,
      judulBroadcast: judul,
      isiBroadcast: isi,
      fotoBroadcast: foto,
      dokumenBroadcast: dokumen,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (index != -1) {
      _items[index] = updated;
    }
    return updated;
  }

  @override
  Future<String> uploadFoto(String path, List<int> fileBytes) async {
    return 'https://fake-url.com/foto.jpg';
  }

  @override
  Future<String> uploadDokumen(String path, List<int> fileBytes) async {
    return 'https://fake-url.com/dokumen.pdf';
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('BroadcastListPage renders cards and dialogs', (tester) async {
    final repository = _FakeBroadcastRepository([
      BroadcastModel(
        id: '1',
        judulBroadcast: 'Pengumuman Warga',
        isiBroadcast: 'Kegiatan kerja bakti akhir pekan ini.',
        createdAt: DateTime(2025, 10, 20, 8, 0),
        updatedAt: DateTime(2025, 10, 21, 9, 0),
        fotoBroadcast: 'foto.png',
        dokumenBroadcast: 'dokumen.pdf',
      ),
    ]);
    final viewModel = BroadcastViewModel(repository: repository);
    await viewModel.loadBroadcasts();

    await tester.pumpWidget(
      ChangeNotifierProvider<BroadcastViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: BroadcastListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Broadcast Warga'), findsOneWidget);
    expect(find.text('Pengumuman Warga'), findsOneWidget);

    await tester.tap(find.text('Pengumuman Warga'));
    await tester.pumpAndSettle();
    expect(find.text('Isi Broadcast'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Isi Broadcast'), findsNothing);

    await tester.ensureVisible(find.byIcon(Icons.more_vert).first);
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus broadcast?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus broadcast?'), findsNothing);
  });
}
