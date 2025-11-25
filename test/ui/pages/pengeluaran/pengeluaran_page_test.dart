import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/ui/pages/pengeluaran/pengeluaran_page.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';
import 'package:provider/provider.dart';

class _FakePengeluaranRepository implements PengeluaranRepository {
  _FakePengeluaranRepository(this._items);

  final List<PengeluaranModel> _items;

  @override
  Future<List<PengeluaranModel>> fetchAll() async => List<PengeluaranModel>.from(_items);

  @override
  Future<PengeluaranModel> createPengeluaran({
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    final model = PengeluaranModel(
      id: 'new-id',
      namaPengeluaran: nama,
      tanggalPengeluaran: tanggal,
      kategoriPengeluaran: kategori,
      jumlah: jumlah,
      buktiPengeluaran: bukti,
    );
    _items.insert(0, model);
    return model;
  }

  @override
  Future<void> deletePengeluaran(String id) async {
    _items.removeWhere((element) => element.id == id);
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
    final index = _items.indexWhere((element) => element.id == id);
    final updated = PengeluaranModel(
      id: id,
      namaPengeluaran: nama,
      tanggalPengeluaran: tanggal,
      kategoriPengeluaran: kategori,
      jumlah: jumlah,
      buktiPengeluaran: bukti,
    );
    if (index != -1) {
      _items[index] = updated;
    }
    return updated;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('PengeluaranPage renders data and opens form dialog', (tester) async {
    final repository = _FakePengeluaranRepository([
      PengeluaranModel(
        id: '1',
        namaPengeluaran: 'Pembelian Peralatan Kebersihan',
        tanggalPengeluaran: DateTime(2025, 10, 20),
        kategoriPengeluaran: 'Operasional',
        jumlah: 2750000,
        buktiPengeluaran: null,
      ),
    ]);
    final viewModel = PengeluaranViewModel(repository: repository);
    await viewModel.loadPengeluaran();

    await tester.pumpWidget(
      ChangeNotifierProvider<PengeluaranViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: PengeluaranPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pengeluaran'), findsOneWidget);
    expect(find.text('Pembelian Peralatan Kebersihan'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Pengeluaran'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Pengeluaran'), findsNothing);
  });
}
