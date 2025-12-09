import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/router/app_router.dart';

void main() {
  group('AppRoutes Tests', () {
    test('all route constants are defined', () {
      expect(AppRoutes.onboarding, isNotEmpty);
      expect(AppRoutes.login, isNotEmpty);
      expect(AppRoutes.register, isNotEmpty);
      expect(AppRoutes.home, isNotEmpty);
      expect(AppRoutes.activityLog, isNotEmpty);
      expect(AppRoutes.userList, isNotEmpty);
    });

    test('route paths are correct format', () {
      expect(AppRoutes.login.startsWith('/'), true);
      expect(AppRoutes.home.startsWith('/'), true);
      expect(AppRoutes.activityLog.startsWith('/'), true);
    });

    test('nested routes have proper format', () {
      expect(AppRoutes.pengeluaranAdd, contains('pengeluaran'));
      expect(AppRoutes.pengeluaranDetail, contains('pengeluaran'));
      expect(AppRoutes.pemasukanDetail, contains('pemasukan'));
    });
  });
}
