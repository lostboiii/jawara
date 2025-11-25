import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/ui/pages/aspirasi/aspirasi_list_page.dart';

void main() {
  testWidgets('AspirasiListPage shows table and dialogs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AspirasiListPage()));

    expect(find.text('Informasi Aspirasi'), findsOneWidget);
    expect(find.text('Total Aspirasi'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.more_vert).first);
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);

    await tester.tap(find.text('Detail'));
    await tester.pumpAndSettle();
    expect(find.text('Perbaikan Jalan RT 03'), findsWidgets);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
