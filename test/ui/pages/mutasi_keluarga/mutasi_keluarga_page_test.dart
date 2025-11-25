import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/ui/pages/mutasi_keluarga/mutasi_keluarga_detail_page.dart';
import 'package:jawara/ui/pages/mutasi_keluarga/mutasi_keluarga_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('MutasiKeluargaPage shows list, filter, and detail', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MutasiKeluargaPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mutasi Keluarga'), findsOneWidget);
    expect(find.text('Keluarga Ijat'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    expect(find.text('Filter Mutasi Keluarga'), findsOneWidget);

    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Mutasi Keluarga'), findsNothing);

    await tester.tap(find.text('Tambah Data'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Mutasi Keluarga'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Mutasi Keluarga'), findsNothing);

    await tester.tap(find.text('Lihat Detail').first);
    await tester.pumpAndSettle();
    expect(find.text('Detail Mutasi Keluarga'), findsWidgets);

    final detailContext = tester.element(find.byType(MutasiKeluargaDetailPage));
    Navigator.of(detailContext).pop();
    await tester.pumpAndSettle();
    expect(find.byType(MutasiKeluargaDetailPage), findsNothing);
  });
}
