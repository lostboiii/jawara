import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/ui/pages/home_page.dart';

void main() {
  testWidgets('HomePage shows menu cards and logout dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Log Aktivitas'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);

    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Keluar'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Keluar'), findsOneWidget);
  });
}
