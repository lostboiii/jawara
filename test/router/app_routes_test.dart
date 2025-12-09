import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/router/app_router.dart';

void main() {
  group('AppRoutes Constants', () {
    test('auth routes are correctly defined', () {
      expect(AppRoutes.onboarding, '/');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.registerStep1, '/register-step1');
      expect(AppRoutes.registerStep2, '/register-step2');
      expect(AppRoutes.registerStep3, '/register-step3');
    });

    test('home routes are correctly defined', () {
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.homeKeuangan, '/home-keuangan');
      expect(AppRoutes.homeWarga, '/home-warga');
      expect(AppRoutes.homeKegiatan, '/home-kegiatan');
    });

    test('warga routes are correctly defined', () {
      expect(AppRoutes.wargaList, '/warga');
      expect(AppRoutes.wargaAdd, '/warga/add');
      expect(AppRoutes.wargaDetail, '/warga/detail');
      expect(AppRoutes.wargaDaftarWarga, '/warga/warga');
      expect(AppRoutes.wargaDaftarKeluarga, '/warga/keluarga');
      expect(AppRoutes.wargaDetailKeluarga, '/warga/keluarga/detail');
      expect(AppRoutes.wargaAspirasi, '/warga/aspirasi');
      expect(AppRoutes.wargaDaftarMutasi, '/warga/mutasi');
      expect(AppRoutes.wargaTambahMutasi, '/warga/mutasi/add');
    });

    test('keuangan routes are correctly defined', () {
      expect(AppRoutes.pemasukan, '/pemasukan');
      expect(AppRoutes.pengeluaran, '/pengeluaran');
      expect(AppRoutes.pengeluaranAdd, '/pengeluaran/add');
      expect(AppRoutes.pengeluaranDetail, '/pengeluaran/detail');
      expect(AppRoutes.pemasukanDetail, '/pemasukan/detail');
      expect(AppRoutes.detailTagihan, '/tagihan/detail');
    });

    test('kegiatan routes are correctly defined', () {
      expect(AppRoutes.kegiatan, '/kegiatan');
      expect(AppRoutes.listKegiatan, '/kegiatan/list');
      expect(AppRoutes.createKegiatan, '/kegiatan/create');
      expect(AppRoutes.detailKegiatan, '/kegiatan/detail');
      expect(AppRoutes.editKegiatan, '/kegiatan/edit');
    });

    test('broadcast routes are correctly defined', () {
      expect(AppRoutes.listBroadcast, '/list-broadcast');
      expect(AppRoutes.createBroadcast, '/create-broadcast');
      expect(AppRoutes.editBroadcast, '/edit-broadcast');
    });

    test('other routes are correctly defined', () {
      expect(AppRoutes.mutasiKeluarga, '/mutasi-keluarga');
      expect(AppRoutes.mutasiKeluargaDetail, '/mutasi-keluarga/detail');
      expect(AppRoutes.channelTransfer, '/channel-transfer');
      expect(AppRoutes.channelTransferAdd, '/channel-transfer/add');
      expect(AppRoutes.channelTransferView, '/channel-transfer/view');
      expect(AppRoutes.activityLog, '/activity-log');
      expect(AppRoutes.aspirasiList, '/aspirasi-list');
      expect(AppRoutes.rumahList, '/rumah');
      expect(AppRoutes.rumahAdd, '/rumah/add');
      expect(AppRoutes.rumahDetail, '/rumah/detail');
    });

    test('route paths start with forward slash', () {
      expect(AppRoutes.onboarding.startsWith('/'), true);
      expect(AppRoutes.login.startsWith('/'), true);
      expect(AppRoutes.home.startsWith('/'), true);
      expect(AppRoutes.wargaList.startsWith('/'), true);
      expect(AppRoutes.kegiatan.startsWith('/'), true);
    });

    test('naming patterns for detail and add routes', () {
      expect(AppRoutes.wargaDetail.endsWith('/detail'), true);
      expect(AppRoutes.pengeluaranDetail.endsWith('/detail'), true);
      expect(AppRoutes.wargaAdd.endsWith('/add'), true);
      expect(AppRoutes.pengeluaranAdd.endsWith('/add'), true);
      expect(AppRoutes.channelTransferAdd.endsWith('/add'), true);
      expect(AppRoutes.createKegiatan.contains('/create'), true);
      expect(AppRoutes.createBroadcast.contains('/create'), true);
    });

    test('nested routes contain parent route pattern', () {
      expect(AppRoutes.wargaDaftarWarga.contains('/warga'), true);
      expect(AppRoutes.wargaDaftarKeluarga.contains('/warga'), true);
      expect(AppRoutes.wargaTambahMutasi.contains('/warga'), true);
    });
  });
}
