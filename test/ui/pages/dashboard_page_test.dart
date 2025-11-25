import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/ui/pages/dashboard_page.dart';

void main() {
  testWidgets('DashboardPage renders tabs and content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Ringkasan Kegiatan'), findsOneWidget);

    await tester.tap(find.text('Keuangan'));
    await tester.pumpAndSettle();
    expect(find.text('Ringkasan Keuangan'), findsOneWidget);

    await tester.tap(find.text('Kependudukan'));
    await tester.pumpAndSettle();
    expect(find.text('Data Kependudukan'), findsOneWidget);
  });
}
