import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/activity_log_page.dart';
import '../pages/user_list_page.dart';
import '../pages/pengeluaran/pengeluaran_page.dart';
import '../pages/pengeluaran/pengeluaran_detail_page.dart';
import '../pages/mutasi_keluarga/mutasi_keluarga_page.dart';
import '../pages/mutasi_keluarga/mutasi_keluarga_detail_page.dart';
import '../pages/channel_transfer/channel_transfer_page.dart';
import '../pages/channel_transfer/channel_transfer_detail_page.dart';
import '../pages/channel_transfer/channel_item.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/broadcast_warga/broadcast_list_page.dart';
import '../pages/broadcast_warga/create_broadcast_page.dart';
import '../pages/broadcast_warga/create_event_page.dart';
import '../pages/event/event_list_page.dart';
import '../pages/aspirasi/aspirasi_list_page.dart';
// Types for detail routes come from their list pages
// Screens (feature modules)
import '../screens/penerimaan/Penerimaan_warga_screen.dart';
import '../screens/rumah/rumah_list_screen.dart';
import '../screens/rumah/rumah_add_screen.dart';
import '../screens/warga/warga_list_screen.dart';
import '../screens/warga/warga_add_screen.dart';
import '../screens/warga/keluarga_screen.dart';
import '../screens/warga/keluarga_page.dart';
// (Pengeluaran, MutasiKeluargaItem)

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const activityLog = '/activity-log';
  static const userList = '/user-list';
  static const pengeluaran = '/pengeluaran';
  static const pengeluaranDetail = '/pengeluaran/detail';
  static const mutasiKeluarga = '/mutasi-keluarga';
  static const mutasiKeluargaDetail = '/mutasi-keluarga/detail';
  static const channelTransfer = '/channel-transfer';
  // Screens module routes
  static const penerimaan = '/penerimaan';
  static const rumahList = '/rumah';
  static const rumahAdd = '/rumah/add';
  static const wargaList = '/warga';
  static const wargaAdd = '/warga/add';
  static const keluarga = '/keluarga';
  static const keluargaPage = '/keluarga-page';
  static const channelTransferDetail = '/channel-transfer/detail';
  static const dashboard = '/dashboard';
  static const broadcastWarga = '/broadcast-warga';
  static const createBroadcast = '/create-broadcast';
  static const createEvent = '/create-event';
  static const eventList = '/event-list';
  static const aspirasiList = '/aspirasi-list';
}

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.activityLog,
      name: 'activity-log',
      builder: (context, state) => const ActivityLogPage(),
    ),
    GoRoute(
      path: AppRoutes.userList,
      name: 'user-list',
      builder: (context, state) => const UserListPage(),
    ),
    GoRoute(
      path: AppRoutes.pengeluaran,
      name: 'pengeluaran',
      builder: (context, state) => const PengeluaranPage(),
    ),
    GoRoute(
      path: AppRoutes.pengeluaranDetail,
      name: 'pengeluaran-detail',
      builder: (context, state) {
        final item = state.extra as Pengeluaran;
        return PengeluaranDetailPage(item: item);
      },
    ),
    GoRoute(
      path: AppRoutes.mutasiKeluarga,
      name: 'mutasi-keluarga',
      builder: (context, state) => const MutasiKeluargaPage(),
    ),
    GoRoute(
      path: AppRoutes.mutasiKeluargaDetail,
      name: 'mutasi-keluarga-detail',
      builder: (context, state) {
        final item = state.extra as MutasiKeluargaItem;
        return MutasiKeluargaDetailPage(item: item);
      },
    ),
    GoRoute(
      path: AppRoutes.channelTransfer,
      name: 'channel-transfer',
      builder: (context, state) => const ChannelTransferPage(),
    ),
    GoRoute(
      path: AppRoutes.channelTransferDetail,
      name: 'channel-transfer-detail',
      builder: (context, state) {
        final item = state.extra as ChannelItem?; // nullable for create flow
        return ChannelTransferDetailPage(item: item);
      },
    ),
    // --- Screens module routes ---
    GoRoute(
      path: AppRoutes.penerimaan,
      name: 'penerimaan',
      builder: (context, state) => const PenerimaanWargaScreen(),
    ),
    GoRoute(
      path: AppRoutes.rumahList,
      name: 'rumah-list',
      builder: (context, state) => const RumahListScreen(),
    ),
    GoRoute(
      path: AppRoutes.rumahAdd,
      name: 'rumah-add',
      builder: (context, state) => const RumahAddScreen(),
    ),
    GoRoute(
      path: AppRoutes.wargaList,
      name: 'warga-list',
      builder: (context, state) => const WargaListScreen(),
    ),
    GoRoute(
      path: AppRoutes.wargaAdd,
      name: 'warga-add',
      builder: (context, state) => WargaAddScreen(),
    ),
    GoRoute(
      path: AppRoutes.keluarga,
      name: 'keluarga',
      builder: (context, state) => const KeluargaScreen(),
    ),
    GoRoute(
      path: AppRoutes.keluargaPage,
      name: 'keluarga-page',
      builder: (context, state) => const KeluargaPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.broadcastWarga,
      name: 'broadcast-warga',
      builder: (context, state) => const BroadcastListPage(),
    ),
    GoRoute(
      path: AppRoutes.createBroadcast,
      name: 'create-broadcast',
      builder: (context, state) => const CreateBroadcastPage(),
    ),
    GoRoute(
      path: AppRoutes.createEvent,
      name: 'create-event',
      builder: (context, state) => const CreateEventPage(),
    ),
    GoRoute(
      path: AppRoutes.eventList,
      name: 'event-list',
      builder: (context, state) => const EventListPage(),
    ),
    GoRoute(
      path: AppRoutes.aspirasiList,
      name: 'aspirasi-list',
      builder: (context, state) => const AspirasiListPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('404 - Page not found')),
  ),
);
