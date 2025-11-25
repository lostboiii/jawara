// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jawara/ui/pages/home_page.dart';
import 'package:jawara/ui/pages/activity_log_page.dart';

void main() {
  Widget createTestApp() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/activity-log',
          builder: (context, state) => const ActivityLogPage(),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(),
    );
  }

  testWidgets('Home page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    // Check app bar title
    expect(find.text('Jawara'), findsOneWidget);

    // Check welcome text
    expect(find.text('Selamat Datang'), findsOneWidget);

    // Check menu items exist
    expect(find.text('Log Aktivitas'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Channel Transfer'), findsOneWidget);
  });

  testWidgets('Navigate to Activity Log page', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    // Tap on Log Aktivitas card
    await tester.tap(find.text('Log Aktivitas'));
    await tester.pumpAndSettle();

    // Should be on Activity Log page
    expect(find.text('Log Aktivitas'), findsWidgets);
    expect(find.text('NO'), findsOneWidget);
    expect(find.text('DESKRIPSI'), findsOneWidget);
  });
}
