import 'package:go_router/go_router.dart';
import 'package:jawara/keuangan/pemasukan_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/pemasukan',
  routes: [
    GoRoute(
      path: '/pemasukan',
      name: 'pemasukan',
      builder: (context, state) => const PemasukanPage(),
    ),
  ],
);
