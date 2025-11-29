import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara/ui/pages/kegiatan/detail_broadcast_page.dart';
import 'package:jawara/ui/pages/kegiatan/detail_kegiatan_page.dart';
import 'package:jawara/ui/pages/warga/daftar_warga_page.dart';
import 'package:jawara/viewmodels/daftar_keluarga_viewmodel.dart';
import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';

import '../ui/pages/home_page.dart';
import '../ui/pages/home_keuangan_page.dart';
import '../ui/pages/home_warga_page.dart';
import '../ui/pages/home_kegiatan_page.dart';
import '../ui/pages/activity_log_page.dart';
import '../ui/pages/user_list_page.dart';
import '../ui/pages/pengeluaran/pengeluaran_page.dart';
import '../ui/pages/pengeluaran/pengeluaran_detail_page.dart';
import '../ui/pages/pemasukan/pemasukan_page.dart';
import '../ui/pages/pemasukan/pemasukan_detail_page.dart';
import '../ui/pages/mutasi_keluarga/mutasi_keluarga_page.dart';
import '../ui/pages/mutasi_keluarga/mutasi_keluarga_detail_page.dart';
import '../ui/pages/channel_transfer/channel_transfer_page.dart';
import '../ui/pages/warga/daftar_keluarga_page.dart';
import '../ui/pages/warga/detail_keluarga_page.dart';
import '../ui/pages/warga/detail_warga_page.dart';
import '../ui/pages/warga/edit_warga_page.dart';
import '../ui/pages/warga/aspirasi_warga_page.dart';
import '../ui/pages/warga/daftar_mutasi_page.dart';
import '../ui/pages/warga/tambah_mutasi_page.dart';
import '../ui/pages/channel_transfer/channel_transfer_detail_page.dart';
import '../ui/pages/auth/onboarding_page.dart';
import '../ui/pages/auth/login_page.dart';
import '../ui/pages/auth/register_step1_page.dart';
import '../ui/pages/auth/register_step2_page.dart';
import '../ui/pages/auth/register_step3_page.dart';
import '../ui/pages/dashboard_page.dart';
import '../ui/pages/kegiatan/broadcast_list_page.dart';
import '../ui/pages/kegiatan/create_broadcast_page.dart';
import '../ui/pages/kegiatan/create_kegiatan_page.dart';
import '../ui/pages/kegiatan/kegiatan_list_page.dart';
import '../ui/pages/kegiatan/edit_kegiatan_page.dart';
import '../ui/pages/aspirasi/aspirasi_list_page.dart';
// Types for detail routes come from their list pages
// Screens (feature modules)
import '../ui/pages/warga/daftar_rumah_page.dart';
import '../ui/pages/warga/detail_rumah_page.dart';
import '../ui/pages/warga/tambah_rumah_page.dart';
import '../ui/screens/warga/warga_list_screen.dart';
import '../ui/pages/warga/tambah_warga_page.dart';
import '../ui/screens/warga/keluarga_screen.dart';
import '../ui/screens/warga/keluarga_page.dart';
import '../data/models/pengeluaran_model.dart';
import '../data/models/metode_pembayaran_model.dart';
import '../viewmodels/daftar_rumah_viewmodel.dart';
// (Pengeluaran, MutasiKeluargaItem)

class AppRoutes {
  static const onboarding = '/';
  static const login = '/login';
  static const register = '/register';
  static const registerStep1 = '/register-step1';
  static const registerStep2 = '/register-step2';
  static const registerStep3 = '/register-step3';
  static const home = '/home';
  static const homeKeuangan = '/home-keuangan';
  static const homeWarga = '/home-warga';
  static const homeKegiatan = '/home-kegiatan';
  static const activityLog = '/activity-log';
  static const userList = '/user-list';
  static const pengeluaran = '/pengeluaran';
  static const pengeluaranDetail = '/pengeluaran/detail';
  static const pemasukan = '/pemasukan';
  static const pemasukanDetail = '/pemasukan/detail';
  static const mutasiKeluarga = '/mutasi-keluarga';
  static const mutasiKeluargaDetail = '/mutasi-keluarga/detail';
  static const channelTransfer = '/channel-transfer';
  // Screens module routes
  static const rumahList = '/rumah';
  static const rumahAdd = '/rumah/add';
  static const rumahDetail = '/rumah/detail';
  static const wargaList = '/warga';
  static const wargaAdd = '/warga/add';
  static const keluarga = '/keluarga';
  static const keluargaPage = '/keluarga-page';
  static const wargaDaftarKeluarga = '/warga/keluarga';
  static const wargaDaftarWarga = '/warga/warga';
  static const wargaDetailKeluarga = '/warga/keluarga/detail';
  static const wargaDetail = '/warga/detail';
  static const wargaAspirasi = '/warga/aspirasi';
  static const wargaDaftarMutasi = '/warga/mutasi';
  static const wargaTambahMutasi = '/warga/mutasi/add';
  static const channelTransferDetail = '/channel-transfer/detail';
  static const dashboard = '/dashboard';
  static const ListBroadcast = '/list-broadcast';
  static const createBroadcast = '/create-broadcast';
  static const kegiatan = '/kegiatan';
  static const createKegiatan = '/kegiatan/create';
  static const listKegiatan = '/kegiatan/list';
  static const detailKegiatan = '/kegiatan/detail';
  static String get editKegiatan => '/kegiatan/edit';
  static const aspirasiList = '/aspirasi-list';
}

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterStep1Page(),
    ),
    GoRoute(
      path: AppRoutes.registerStep1,
      name: 'register-step1',
      builder: (context, state) => const RegisterStep1Page(),
    ),
    GoRoute(
      path: AppRoutes.registerStep2,
      name: 'register-step2',
      builder: (context, state) => const RegisterStep2Page(),
    ),
    GoRoute(
      path: AppRoutes.registerStep3,
      name: 'register-step3',
      builder: (context, state) => const RegisterStep3Page(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.homeKeuangan,
      name: 'home-keuangan',
      builder: (context, state) => const HomeKeuanganPage(),
    ),
    GoRoute(
      path: AppRoutes.homeWarga,
      name: 'home-warga',
      builder: (context, state) => const HomeWargaPage(),
    ),
    GoRoute(
      path: AppRoutes.homeKegiatan,
      name: 'home-kegiatan',
      builder: (context, state) => const HomeKegiatanPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaDaftarKeluarga,
      name: 'warga-daftar-keluarga',
      builder: (context, state) => const DaftarKeluargaPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaDaftarWarga,
      name: 'warga-daftar-warga',
      builder: (context, state) => const DaftarWargaPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaDetailKeluarga,
      name: 'warga-keluarga-detail',
      builder: (context, state) {
        final family = state.extra as KeluargaListItem?;
        if (family == null) {
          return const DaftarKeluargaPage();
        }
        return DetailKeluargaPage(family: family);
      },
    ),
    GoRoute(
      path: AppRoutes.wargaDetail,
      name: 'warga-detail',
      builder: (context, state) {
        final warga = state.extra as WargaListItem?;
        if (warga == null) {
          return const DaftarWargaPage();
        }
        return DetailWargaPage(warga: warga);
      },
    ),
    GoRoute(
      path: AppRoutes.wargaAspirasi,
      name: 'aspirasi-warga',
      builder: (context, state) => const AspirasiWargaPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaDaftarMutasi,
      name: 'daftar-mutasi',
      builder: (context, state) => const DaftarMutasiPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaTambahMutasi,
      name: 'tambah-mutasi',
      builder: (context, state) => const TambahMutasiPage(),
    ),
    GoRoute(
      path: '/warga/edit',
      name: 'warga-edit',
      builder: (context, state) {
        final warga = state.extra as WargaListItem?;
        if (warga == null) {
          return const DaftarWargaPage();
        }
        return EditWargaPage(warga: warga);
      },
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
        final item = state.extra as PengeluaranModel;
        return PengeluaranDetailPage(item: item);
      },
    ),
    GoRoute(
      path: AppRoutes.pemasukan,
      name: 'pemasukan',
      builder: (context, state) => const PemasukanPage(),
    ),
    GoRoute(
      path: AppRoutes.pemasukanDetail,
      name: 'pemasukan-detail',
      builder: (context, state) {
        final item = state.extra as Pemasukan;
        return PemasukanDetailPage(item: item);
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
        final item = state.extra as MetodePembayaranModel?;
        return ChannelTransferDetailPage(item: item);
      },
    ),
    // --- Screens module routes ---
    GoRoute(
      path: AppRoutes.rumahList,
      name: 'daftar-rumah',
      builder: (context, state) => const DaftarRumahPage(),
    ),
    GoRoute(
      path: AppRoutes.rumahDetail,
      name: 'detail-rumah',
      builder: (context, state) {
        final rumah = state.extra as RumahListItem?;
        if (rumah == null) {
          return const DaftarRumahPage();
        }
        return DetailRumahPage(rumah: rumah);
      },
    ),
    GoRoute(
      path: AppRoutes.rumahAdd,
      name: 'tambah-rumah',
      builder: (context, state) => const TambahRumahPage(),
    ),
    GoRoute(
      path: AppRoutes.wargaList,
      name: 'warga-list',
      builder: (context, state) => const WargaListScreen(),
    ),
    GoRoute(
      path: AppRoutes.wargaAdd,
      name: 'warga-add',
      builder: (context, state) => const TambahWargaPage(),
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
      path: AppRoutes.ListBroadcast,
      name: 'list-broadcast',
      builder: (context, state) => const BroadcastListPage(),
    ),
    GoRoute(
      path: AppRoutes.createBroadcast,
      name: 'create-broadcast',
      builder: (context, state) => const CreateBroadcastPage(),
    ),
    GoRoute(
      path: '/detail-broadcast',
      name: 'detail-broadcast',
      builder: (context, state) => DetailBroadcastPage(
        broadcast: state.extra as BroadcastListItem,
      ),
    ),
    GoRoute(
      path: AppRoutes.kegiatan,
      name: 'kegiatan',
      builder: (context, state) => const KegiatanListPage(),
    ),
    GoRoute(
      path: AppRoutes.createKegiatan,
      name: 'create-kegiatan',
      builder: (context, state) => const CreateKegiatanPage(),
    ),
    GoRoute(
      path: AppRoutes.listKegiatan,
      name: 'list-kegiatan',
      builder: (context, state) => const KegiatanListPage(),
    ),
    GoRoute(
      path: AppRoutes.detailKegiatan,
      name: 'detail-kegiatan',
      builder: (context, state) {
        final kegiatan = state.extra as KegiatanListItem?;
        if (kegiatan == null) {
          return const KegiatanListPage();
        }
        return DetailKegiatanPage(kegiatan: kegiatan);
      },
    ),
    GoRoute(
      path: AppRoutes.editKegiatan,
      name: 'edit-kegiatan',
      builder: (context, state) {
        final kegiatan = state.extra as KegiatanListItem?;
        if (kegiatan == null) {
          return const KegiatanListPage();
        }
        return EditKegiatanPage(kegiatan: kegiatan);
      },
    ),
    GoRoute(
      path: '/event-list',
      name: 'event-list-legacy',
      builder: (context, state) => const KegiatanListPage(),
    ),
    GoRoute(
      path: '/create-event',
      name: 'create-event-legacy',
      builder: (context, state) => const CreateKegiatanPage(),
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
