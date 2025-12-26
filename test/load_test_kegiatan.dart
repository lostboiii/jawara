import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockListAppKegiatan extends StatelessWidget {
  final String itemPrefix;
  final int itemCount;

  const MockListAppKegiatan({
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
          key: const Key('mockListKegiatan'),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('$itemPrefix $index'),
              subtitle: Text('Tanggal $index'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Load test: scroll 1000 kegiatan', (WidgetTester tester) async {
    const itemCount = 1000;

    await tester.pumpWidget(const MockListAppKegiatan(
      itemPrefix: 'Kegiatan',
      itemCount: itemCount,
    ));

    expect(find.byKey(const Key('mockListKegiatan')), findsOneWidget);
    await tester.pumpAndSettle();

    final stopwatch = Stopwatch()..start();

    // Warm scrolling to simulate user behaviour
    for (int i = 0; i < 25; i++) {
      await tester.fling(find.byKey(const Key('mockListKegiatan')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
    }

    stopwatch.stop();
    print('Scrolled $itemCount kegiatan items in: ${stopwatch.elapsedMilliseconds} ms');

    // Try repeated flings until the final item appears (best-effort)
    bool found = false;
    for (int i = 0; i < 200 && !found; i++) {
      await tester.fling(find.byKey(const Key('mockListKegiatan')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
      found = find.text('Kegiatan 999').evaluate().isNotEmpty;
    }
    expect(found, isTrue, reason: 'Kegiatan 999 not found after flinging');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
