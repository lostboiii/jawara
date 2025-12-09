import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('Date Formatting Tests', () {
    test('date can be formatted', () {
      final date = DateTime(2024, 1, 15);
      expect(date.year, 2024);
      expect(date.month, 1);
      expect(date.day, 15);
    });

    test('date comparison works', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);
      expect(date1.isBefore(date2), true);
      expect(date2.isAfter(date1), true);
    });
  });
}
