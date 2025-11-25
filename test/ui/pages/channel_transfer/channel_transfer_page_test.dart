import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/metode_pembayaran_model.dart';
import 'package:jawara/data/repositories/metode_pembayaran_repository.dart';
import 'package:jawara/ui/pages/channel_transfer/channel_transfer_page.dart';
import 'package:jawara/viewmodels/metode_pembayaran_viewmodel.dart';
import 'package:provider/provider.dart';

class _FakeMetodePembayaranRepository implements MetodePembayaranRepository {
  _FakeMetodePembayaranRepository(this._items);

  final List<MetodePembayaranModel> _items;

  @override
  Future<List<MetodePembayaranModel>> fetchAll() async => List<MetodePembayaranModel>.from(_items);

  @override
  Future<MetodePembayaranModel> createMetodePembayaran({
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    final model = MetodePembayaranModel(
      id: 'new-id',
      namaMetode: namaMetode,
      nomorRekening: nomorRekening,
      namaPemilik: namaPemilik,
      fotoBarcode: fotoBarcode,
      thumbnail: thumbnail,
      catatan: catatan,
      insertedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _items.insert(0, model);
    return model;
  }

  @override
  Future<void> deleteMetodePembayaran(String id) async {
    _items.removeWhere((element) => element.id == id);
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
    final index = _items.indexWhere((element) => element.id == id);
    final updated = MetodePembayaranModel(
      id: id,
      namaMetode: namaMetode,
      nomorRekening: nomorRekening,
      namaPemilik: namaPemilik,
      fotoBarcode: fotoBarcode,
      thumbnail: thumbnail,
      catatan: catatan,
      insertedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (index != -1) {
      _items[index] = updated;
    }
    return updated;
  }
}

void main() {
  testWidgets('ChannelTransferPage renders list and delete dialog', (tester) async {
    final repository = _FakeMetodePembayaranRepository([
      MetodePembayaranModel(
        id: '1',
        namaMetode: 'Bank Jawara',
        nomorRekening: '1234567890',
        namaPemilik: 'RT 01',
        fotoBarcode: null,
        thumbnail: null,
        catatan: 'Tersedia 24 jam',
        insertedAt: DateTime(2025, 10, 20),
        updatedAt: DateTime(2025, 10, 21),
      ),
    ]);
    final viewModel = MetodePembayaranViewModel(repository: repository);
    await viewModel.loadMetodePembayaran();

    await tester.pumpWidget(
      ChangeNotifierProvider<MetodePembayaranViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: ChannelTransferPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Channel Transfer'), findsOneWidget);
    expect(find.text('Bank Jawara'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Channel'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Channel'), findsNothing);
  });
}
