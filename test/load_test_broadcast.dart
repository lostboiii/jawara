import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockListAppBroadcast extends StatelessWidget {
  final String itemPrefix;
  final int itemCount;

  const MockListAppBroadcast({
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
          key: const Key('mockListBroadcast'),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('$itemPrefix $index'),
              subtitle: Text('Pesan $index'),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Load test: scroll 1000 broadcast', (WidgetTester tester) async {
    const itemCount = 1000;

    await tester.pumpWidget(const MockListAppBroadcast(
      itemPrefix: 'Broadcast',
      itemCount: itemCount,
    ));

    expect(find.byKey(const Key('mockListBroadcast')), findsOneWidget);
    await tester.pumpAndSettle();

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 25; i++) {
      await tester.fling(find.byKey(const Key('mockListBroadcast')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
    }

    stopwatch.stop();
    print('Scrolled $itemCount broadcast items in: ${stopwatch.elapsedMilliseconds} ms');

    bool found = false;
    for (int i = 0; i < 200 && !found; i++) {
      await tester.fling(find.byKey(const Key('mockListBroadcast')), const Offset(0, -600), 2000);
      await tester.pumpAndSettle();
      found = find.text('Broadcast 999').evaluate().isNotEmpty;
    }
    expect(found, isTrue, reason: 'Broadcast 999 not found after flinging');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
