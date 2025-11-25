import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/ui/pages/pemasukan/pemasukan_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('PemasukanPage shows list and dialogs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PemasukanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pemasukan'), findsOneWidget);
    expect(find.text('Iuran Warga'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    expect(find.text('Filter Pemasukan'), findsOneWidget);

    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Filter Pemasukan'), findsNothing);

    await tester.tap(find.text('Tambah Data'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Pemasukan'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Pemasukan'), findsNothing);
  });
}
