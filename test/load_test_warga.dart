import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockListApp extends StatelessWidget {
  final String itemPrefix;
  final int itemCount;

  const MockListApp({
    Key? key,
    required this.itemPrefix,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('$itemPrefix List')),
        body: ListView.builder(
          key: const Key('mockListWarga'),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('$itemPrefix $index'),
              subtitle: Text('Detail $index'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Load test: scroll 1000 warga', (WidgetTester tester) async {
    const itemCount = 1000;

    await tester.pumpWidget(const MockListApp(
      itemPrefix: 'Warga',
      itemCount: itemCount,
    ));

    // Ensure the list is present
    expect(find.byKey(const Key('mockListWarga')), findsOneWidget);

    // Warm up
    await tester.pumpAndSettle();

    final stopwatch = Stopwatch()..start();

    // Perform repeated flings to simulate user scrolling through a long list
    for (int i = 0; i < 25; i++) {
      await tester.fling(find.byKey(const Key('mockListWarga')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
    }

    stopwatch.stop();
    // Print duration to the test logs — useful for a quick performance check
    // (CI will capture test prints)
    print('Scrolled $itemCount items in: ${stopwatch.elapsedMilliseconds} ms');

    // Try repeated flings until the final item appears (best-effort)
    bool found = false;
    for (int i = 0; i < 200 && !found; i++) {
      await tester.fling(find.byKey(const Key('mockListWarga')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
      found = find.text('Warga 999').evaluate().isNotEmpty;
    }
    expect(found, isTrue, reason: 'Warga 999 not found after flinging');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
