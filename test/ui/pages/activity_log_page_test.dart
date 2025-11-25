import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/ui/pages/activity_log_page.dart';

void main() {
  testWidgets('ActivityLogPage renders header and list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ActivityLogPage(),
      ),
    );

    expect(find.text('Log Aktivitas'), findsWidgets);
    expect(find.text('NO'), findsOneWidget);
    expect(find.text('DESKRIPSI'), findsOneWidget);

    // should show the dummy data entries
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('Menugaskan tagihan'), findsWidgets);
  });

  testWidgets('Filter dialog returns data and shows snackbar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ActivityLogPage(),
      ),
    );

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text('Filter Aktivitas'), findsOneWidget);

    // Fill some filters
    await tester.enterText(find.byType(TextField).first, 'tagihan');
    await tester.tap(find.text('Terapkan Filter'));
    await tester.pumpAndSettle();

    // Dialog closes and snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
