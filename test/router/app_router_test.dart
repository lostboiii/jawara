import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/router/app_router.dart';

void main() {
  test('AppRoutes constants remain stable', () {
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.home, '/');
    expect(AppRoutes.activityLog, '/activity-log');
    expect(AppRoutes.userList, '/user-list');
    expect(AppRoutes.pengeluaran, '/pengeluaran');
    expect(AppRoutes.kegiatan, '/kegiatan');
    expect(AppRoutes.createKegiatan, '/kegiatan/create');
  });

  test('appRouter exposes delegate and named routes', () {
    expect(appRouter.routerDelegate, isNotNull);
    expect(appRouter.routeInformationParser, isNotNull);

    expect(appRouter.namedLocation('home'), '/');
    expect(appRouter.namedLocation('activity-log'), '/activity-log');
  });
}
