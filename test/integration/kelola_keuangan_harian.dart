import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sfb;
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/viewmodels/kegiatan_viewmodel.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/kegiatan_repository.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/data/models/kegiatan_model.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'kelola_keuangan_harian.mocks.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {
  @override
  Future<sfb.AuthResponse> signIn({required String email, required String password}) {
    return super.noSuchMethod(
      Invocation.method(#signIn, [], {#email: email, #password: password}),
      returnValue: Future.value(sfb.AuthResponse(user: null, session: null)),
      returnValueForMissingStub: Future.value(sfb.AuthResponse(user: null, session: null)),
    );
  }

  @override
  Future<void> signOut() {
    return super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

@GenerateMocks([KegiatanRepository, PengeluaranRepository])
void main() {
  group('Kelola Keuangan Harian Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockKegiatanRepository mockKegiatanRepository;
    late MockPengeluaranRepository mockPengeluaranRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockKegiatanRepository = MockKegiatanRepository();
      mockPengeluaranRepository = MockPengeluaranRepository();
    });


    testWidgets('Full flow: Login → Create Kegiatan → Add Pengeluaran → Verify Sisa Anggaran → Logout',
        (WidgetTester tester) async {
      // Setup mock data
      final testKegiatan = KegiatanModel(
        id: 'kegiatan-test-id',
        namaKegiatan: 'Gotong Royong Bulanan',
        kategoriKegiatan: 'Kegiatan Sosial',
        tanggalKegiatan: DateTime(2024, 12, 25),
        lokasiKegiatan: 'Balai Desa',
        penanggungJawab: 'Pak RT',
        deskripsi: 'Bersih-bersih lingkungan',
        anggaran: 1000000.0,
      );

      final testPengeluaran = PengeluaranModel(
        id: 'pengeluaran-test-id',
        namaPengeluaran: 'Beli Peralatan Kebersihan',
        tanggalPengeluaran: DateTime(2024, 12, 25),
        kategoriPengeluaran: 'Operasional',
        jumlah: 350000.0,
        buktiPengeluaran: null,
      );

      // Mock login success
      when(mockAuthService.signIn(email: 'test@email.com', password: 'password123'))
          .thenAnswer((_) async => sfb.AuthResponse(
                user: sfb.User(
                  id: 'test-user-id',
                  appMetadata: {},
                  userMetadata: {},
                  aud: '',
                  createdAt: '',
                ),
                session: null,
              ));

      // Mock create kegiatan
      when(mockKegiatanRepository.createKegiatan(
        nama: 'Gotong Royong Bulanan',
        kategori: 'Kegiatan Sosial',
        tanggal: DateTime(2024, 12, 25),
        lokasi: 'Balai Desa',
        penanggungJawab: 'Pak RT',
        deskripsi: 'Bersih-bersih lingkungan',
      )).thenAnswer((_) async => testKegiatan);

      // Mock fetch kegiatan
      when(mockKegiatanRepository.fetchAll()).thenAnswer((_) async => [testKegiatan]);

      // Mock create pengeluaran
      when(mockPengeluaranRepository.createPengeluaran(
        nama: 'Beli Peralatan Kebersihan',
        tanggal: DateTime(2024, 12, 25),
        kategori: 'Operasional',
        jumlah: 350000.0,
        bukti: null,
      )).thenAnswer((_) async => testPengeluaran);

      // Mock fetch pengeluaran
      when(mockPengeluaranRepository.fetchAll()).thenAnswer((_) async => [testPengeluaran]);

      // Mock logout
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LoginViewModel>(
              create: (_) => LoginViewModel(authService: mockAuthService),
            ),
            ChangeNotifierProvider<KegiatanViewModel>(
              create: (_) => KegiatanViewModel(repository: mockKegiatanRepository),
            ),
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockPengeluaranRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
                final kegiatanViewModel = Provider.of<KegiatanViewModel>(context, listen: false);
                final pengeluaranViewModel = Provider.of<PengeluaranViewModel>(context, listen: false);

                return Scaffold(
                  appBar: AppBar(title: const Text('Kelola Keuangan Harian')),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Login Section
                          const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await loginViewModel.login(
                                email: 'test@email.com',
                                password: 'password123',
                              );
                            },
                            child: const Text('Login'),
                          ),
                          Consumer<LoginViewModel>(
                            builder: (context, vm, child) {
                              if (vm.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              if (vm.hasError) {
                                return Text('Login Error: ${vm.error}');
                              }
                              if (!vm.isLoading && !vm.hasError) {
                                return const Text('Login Success');
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Create Kegiatan Section
                          const Text('Create Kegiatan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await kegiatanViewModel.addKegiatan(
                                nama: 'Gotong Royong Bulanan',
                                kategori: 'Kegiatan Sosial',
                                tanggal: DateTime(2024, 12, 25),
                                lokasi: 'Balai Desa',
                                penanggungJawab: 'Pak RT',
                                deskripsi: 'Bersih-bersih lingkungan',
                              );
                            },
                            child: const Text('Create Kegiatan'),
                          ),
                          Consumer<KegiatanViewModel>(
                            builder: (context, vm, child) {
                              if (vm.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              if (vm.errorMessage != null) {
                                return Text('Kegiatan Error: ${vm.errorMessage}');
                              }
                              if (vm.items.isNotEmpty) {
                                final kegiatan = vm.items.first;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kegiatan Created: ${kegiatan.namaKegiatan}'),
                                    Text('Anggaran: Rp ${kegiatan.anggaran?.toStringAsFixed(0)}'),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Add Pengeluaran Section
                          const Text('Add Pengeluaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await pengeluaranViewModel.addPengeluaran(
                                nama: 'Beli Peralatan Kebersihan',
                                tanggal: DateTime(2024, 12, 25),
                                kategori: 'Operasional',
                                jumlah: 350000.0,
                                bukti: null,
                              );
                            },
                            child: const Text('Add Pengeluaran'),
                          ),
                          Consumer<PengeluaranViewModel>(
                            builder: (context, vm, child) {
                              if (vm.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              if (vm.errorMessage != null) {
                                return Text('Pengeluaran Error: ${vm.errorMessage}');
                              }
                              if (vm.items.isNotEmpty) {
                                final pengeluaran = vm.items.first;
                                return Text('Pengeluaran Added: ${pengeluaran.namaPengeluaran} - Rp ${pengeluaran.jumlah.toStringAsFixed(0)}');
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Verify Sisa Anggaran Section
                          const Text('Sisa Anggaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer2<KegiatanViewModel, PengeluaranViewModel>(
                            builder: (context, kegiatanVm, pengeluaranVm, child) {
                              if (kegiatanVm.items.isNotEmpty && pengeluaranVm.items.isNotEmpty) {
                                final anggaran = kegiatanVm.items.first.anggaran ?? 0.0;
                                final totalPengeluaran = pengeluaranVm.items.fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.jumlah,
                                );
                                final sisaAnggaran = anggaran - totalPengeluaran;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Anggaran: Rp ${anggaran.toStringAsFixed(0)}'),
                                    Text('Total Pengeluaran: Rp ${totalPengeluaran.toStringAsFixed(0)}'),
                                    Text('Sisa Anggaran: Rp ${sisaAnggaran.toStringAsFixed(0)}'),
                                  ],
                                );
                              }
                              return const Text('Calculating...');
                            },
                          ),
                          const SizedBox(height: 24),

                          // Logout Section
                          const Text('Logout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            key: const Key('logout_button'),
                            onPressed: () async {
                              await mockAuthService.signOut();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Step 1: Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify login success
      expect(find.text('Login Success'), findsOneWidget);
      verify(mockAuthService.signIn(email: 'test@email.com', password: 'password123')).called(1);

      // Step 2: Create Kegiatan
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Kegiatan'));
      await tester.pumpAndSettle();

      // Verify kegiatan created
      expect(find.text('Kegiatan Created: Gotong Royong Bulanan'), findsOneWidget);
      expect(find.text('Anggaran: Rp 1000000'), findsOneWidget);
      verify(mockKegiatanRepository.createKegiatan(
        nama: 'Gotong Royong Bulanan',
        kategori: 'Kegiatan Sosial',
        tanggal: DateTime(2024, 12, 25),
        lokasi: 'Balai Desa',
        penanggungJawab: 'Pak RT',
        deskripsi: 'Bersih-bersih lingkungan',
      )).called(1);

      // Step 3: Add Pengeluaran
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Pengeluaran'));
      await tester.pumpAndSettle();

      // Verify pengeluaran added
      expect(find.text('Pengeluaran Added: Beli Peralatan Kebersihan - Rp 350000'), findsOneWidget);
      verify(mockPengeluaranRepository.createPengeluaran(
        nama: 'Beli Peralatan Kebersihan',
        tanggal: DateTime(2024, 12, 25),
        kategori: 'Operasional',
        jumlah: 350000.0,
        bukti: null,
      )).called(1);

      // Step 4: Verify Sisa Anggaran
      expect(find.text('Total Anggaran: Rp 1000000'), findsOneWidget);
      expect(find.text('Total Pengeluaran: Rp 350000'), findsOneWidget);
      expect(find.text('Sisa Anggaran: Rp 650000'), findsOneWidget);

      // Step 5: Logout
      await tester.ensureVisible(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Verify logout called
      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('Error handling: Login failure should prevent further actions',
        (WidgetTester tester) async {
      // Mock login failure
      when(mockAuthService.signIn(email: 'wrong@email.com', password: 'wrongpassword'))
          .thenAnswer((_) async => sfb.AuthResponse(user: null, session: null));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LoginViewModel>(
              create: (_) => LoginViewModel(authService: mockAuthService),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('login_button'),
                        onPressed: () async {
                          await loginViewModel.login(
                            email: 'wrong@email.com',
                            password: 'wrongpassword',
                          );
                        },
                        child: const Text('Login'),
                      ),
                      Consumer<LoginViewModel>(
                        builder: (context, vm, child) {
                          if (vm.hasError) {
                            return Text('Login Error: ${vm.error}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Attempt login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify login error
      expect(find.textContaining('Login Error:'), findsOneWidget);
    });

    testWidgets('Verify budget calculation with multiple pengeluaran',
        (WidgetTester tester) async {
      final testKegiatan = KegiatanModel(
        id: 'kegiatan-test-id',
        namaKegiatan: 'Event Warga',
        kategoriKegiatan: 'Kegiatan Warga',
        tanggalKegiatan: DateTime(2024, 12, 25),
        anggaran: 2000000.0,
      );

      final pengeluaranList = [
        PengeluaranModel(
          id: 'pengeluaran-1',
          namaPengeluaran: 'Konsumsi',
          tanggalPengeluaran: DateTime(2024, 12, 25),
          kategoriPengeluaran: 'Operasional',
          jumlah: 500000.0,
        ),
        PengeluaranModel(
          id: 'pengeluaran-2',
          namaPengeluaran: 'Dekorasi',
          tanggalPengeluaran: DateTime(2024, 12, 25),
          kategoriPengeluaran: 'Operasional',
          jumlah: 300000.0,
        ),
        PengeluaranModel(
          id: 'pengeluaran-3',
          namaPengeluaran: 'Sound System',
          tanggalPengeluaran: DateTime(2024, 12, 25),
          kategoriPengeluaran: 'Operasional',
          jumlah: 400000.0,
        ),
      ];

      when(mockKegiatanRepository.fetchAll()).thenAnswer((_) async => [testKegiatan]);
      when(mockPengeluaranRepository.fetchAll()).thenAnswer((_) async => pengeluaranList);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KegiatanViewModel>(
              create: (_) => KegiatanViewModel(repository: mockKegiatanRepository),
            ),
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockPengeluaranRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final kegiatanViewModel = Provider.of<KegiatanViewModel>(context, listen: false);
                final pengeluaranViewModel = Provider.of<PengeluaranViewModel>(context, listen: false);

                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('load_data_button'),
                        onPressed: () async {
                          await kegiatanViewModel.loadKegiatan();
                          await pengeluaranViewModel.loadPengeluaran();
                        },
                        child: const Text('Load Data'),
                      ),
                      Consumer2<KegiatanViewModel, PengeluaranViewModel>(
                        builder: (context, kegiatanVm, pengeluaranVm, child) {
                          if (kegiatanVm.items.isNotEmpty && pengeluaranVm.items.isNotEmpty) {
                            final anggaran = kegiatanVm.items.first.anggaran ?? 0.0;
                            final totalPengeluaran = pengeluaranVm.items.fold<double>(
                              0.0,
                              (sum, item) => sum + item.jumlah,
                            );
                            final sisaAnggaran = anggaran - totalPengeluaran;
                            return Column(
                              children: [
                                Text('Total Anggaran: Rp ${anggaran.toStringAsFixed(0)}'),
                                Text('Total Pengeluaran: Rp ${totalPengeluaran.toStringAsFixed(0)}'),
                                Text('Sisa Anggaran: Rp ${sisaAnggaran.toStringAsFixed(0)}'),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Load data
      await tester.tap(find.byKey(const Key('load_data_button')));
      await tester.pumpAndSettle();

      // Verify calculations
      expect(find.text('Total Anggaran: Rp 2000000'), findsOneWidget);
      expect(find.text('Total Pengeluaran: Rp 1200000'), findsOneWidget);
      expect(find.text('Sisa Anggaran: Rp 800000'), findsOneWidget);
    });
  });
}