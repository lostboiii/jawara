// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/main.dart';

void main() {
  testWidgets('Home shows navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Expect the home screen title and three buttons
    expect(find.textContaining('Akses Halaman'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Mutasi Keluarga'), findsOneWidget);
    expect(find.text('Channel Transfer'), findsOneWidget);
  testWidgets('Home page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Check app bar title
    expect(find.text('Jawara'), findsOneWidget);

    // Check welcome text
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Pilih menu yang ingin Anda akses'), findsOneWidget);

    // Check menu items exist
    expect(find.text('Log Aktivitas'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('Navigate to Activity Log page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap on Log Aktivitas card
    await tester.tap(find.text('Log Aktivitas'));
    await tester.pumpAndSettle();

    // Should be on Activity Log page
    expect(find.text('Log Aktivitas'), findsOneWidget);
    expect(find.text('NO'), findsOneWidget);
    expect(find.text('DESKRIPSI'), findsOneWidget);
  });
}
