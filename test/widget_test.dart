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
  });
}
