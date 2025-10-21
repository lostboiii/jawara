import 'package:go_router/go_router.dart';
import 'package:jawara/keuangan/pemasukan_page.dart';
import 'package:jawara/keuangan/laporan_keuangan.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/laporankeuangan',
  routes: [
    GoRoute(
      path: '/pemasukan',
      name: 'pemasukan',
      builder: (context, state) => const PemasukanPage(),
    ),
    GoRoute(
      path: '/laporankeuangan',
      name: 'laporankeuangan',
      builder: (context, state) => const LaporanKeuanganPage(),
    ),
  ],
);
