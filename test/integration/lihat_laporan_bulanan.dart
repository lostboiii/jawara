import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sfb;
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/viewmodels/pemasukan_viewmodel.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/pemasukan_repository.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/data/models/pemasukan_model.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'lihat_laporan_bulanan.mocks.dart';

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

@GenerateMocks([PemasukanRepository, PengeluaranRepository])
void main() {
  group('Lihat Laporan Bulanan Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockPemasukanRepository mockPemasukanRepository;
    late MockPengeluaranRepository mockPengeluaranRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockPemasukanRepository = MockPemasukanRepository();
      mockPengeluaranRepository = MockPengeluaranRepository();
    });

    testWidgets('Full flow: Login → Navigate to Keuangan → Filter by Month → Check Transactions → Logout',
        (WidgetTester tester) async {
      // Setup mock data - transactions for December 2024
      final testPemasukan = [
        PemasukanModel(
          id: 'pemasukan-1',
          nama_pemasukan: 'Gaji Bulanan',
          tanggal_pemasukan: DateTime(2024, 12, 1),
          kategori_pemasukan: 'Gaji',
          jumlah: 5000000.0,
        ),
        PemasukanModel(
          id: 'pemasukan-2',
          nama_pemasukan: 'Bonus',
          tanggal_pemasukan: DateTime(2024, 12, 15),
          kategori_pemasukan: 'Gaji',
          jumlah: 1000000.0,
        ),
      ];

      final testPengeluaran = [
        PengeluaranModel(
          id: 'pengeluaran-1',
          namaPengeluaran: 'Belanja Bulanan',
          tanggalPengeluaran: DateTime(2024, 12, 5),
          kategoriPengeluaran: 'Belanja',
          jumlah: 1500000.0,
          buktiPengeluaran: null,
        ),
        PengeluaranModel(
          id: 'pengeluaran-2',
          namaPengeluaran: 'Bayar Listrik',
          tanggalPengeluaran: DateTime(2024, 12, 10),
          kategoriPengeluaran: 'Tagihan',
          jumlah: 500000.0,
          buktiPengeluaran: null,
        ),
      ];

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

      // Mock fetch pemasukan
      when(mockPemasukanRepository.fetchAll()).thenAnswer((_) async => testPemasukan);

      // Mock fetch pengeluaran
      when(mockPengeluaranRepository.fetchAll()).thenAnswer((_) async => testPengeluaran);

      // Mock logout
      when(mockAuthService.signOut()).thenAnswer((_) async => {});

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LoginViewModel>(
              create: (_) => LoginViewModel(authService: mockAuthService),
            ),
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockPemasukanRepository),
            ),
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockPengeluaranRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
                final pemasukanViewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                final pengeluaranViewModel = Provider.of<PengeluaranViewModel>(context, listen: false);

                return Scaffold(
                  appBar: AppBar(title: const Text('Lihat Laporan Bulanan')),
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
                            key: const Key('login_button'),
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

                          // Navigate to Keuangan Tab Section
                          const Text('Navigate to Keuangan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            key: const Key('navigate_keuangan_button'),
                            onPressed: () async {
                              await pemasukanViewModel.loadPemasukan();
                              await pengeluaranViewModel.loadPengeluaran();
                            },
                            child: const Text('Load Keuangan Data'),
                          ),
                          Consumer2<PemasukanViewModel, PengeluaranViewModel>(
                            builder: (context, pemasukanVm, pengeluaranVm, child) {
                              if (pemasukanVm.isLoading || pengeluaranVm.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              if (pemasukanVm.items.isNotEmpty || pengeluaranVm.items.isNotEmpty) {
                                return const Text('Keuangan Data Loaded');
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),

                          // Filter by Month Section
                          const Text('Filter by Month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Filter: December 2024', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          const Text('Filtered Transactions:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),

                          // Check Transactions Section
                          const Text('Pemasukan Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer<PemasukanViewModel>(
                            builder: (context, vm, child) {
                              if (vm.items.isEmpty) {
                                return const Text('No Pemasukan');
                              }
                              // Filter by December 2024
                              final filteredItems = vm.items.where((item) {
                                return item.tanggal_pemasukan.year == 2024 &&
                                    item.tanggal_pemasukan.month == 12;
                              }).toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Pemasukan: ${filteredItems.length} transactions'),
                                  ...filteredItems.map((item) => Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text('${item.nama_pemasukan}: Rp ${item.jumlah.toStringAsFixed(0)}'),
                                      )),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          const Text('Pengeluaran Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer<PengeluaranViewModel>(
                            builder: (context, vm, child) {
                              if (vm.items.isEmpty) {
                                return const Text('No Pengeluaran');
                              }
                              // Filter by December 2024
                              final filteredItems = vm.items.where((item) {
                                return item.tanggalPengeluaran.year == 2024 &&
                                    item.tanggalPengeluaran.month == 12;
                              }).toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Pengeluaran: ${filteredItems.length} transactions'),
                                  ...filteredItems.map((item) => Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text('${item.namaPengeluaran}: Rp ${item.jumlah.toStringAsFixed(0)}'),
                                      )),
                                ],
                              );
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
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify login success
      expect(find.text('Login Success'), findsOneWidget);
      verify(mockAuthService.signIn(email: 'test@email.com', password: 'password123')).called(1);

      // Step 2: Navigate to Keuangan and load data
      await tester.tap(find.byKey(const Key('navigate_keuangan_button')));
      await tester.pumpAndSettle();

      // Verify data loaded
      expect(find.text('Keuangan Data Loaded'), findsOneWidget);
      verify(mockPemasukanRepository.fetchAll()).called(1);
      verify(mockPengeluaranRepository.fetchAll()).called(1);

      // Step 3: Check filtered transactions for December 2024
      expect(find.text('Total Pemasukan: 2 transactions'), findsOneWidget);
      expect(find.text('Gaji Bulanan: Rp 5000000'), findsOneWidget);
      expect(find.text('Bonus: Rp 1000000'), findsOneWidget);

      expect(find.text('Total Pengeluaran: 2 transactions'), findsOneWidget);
      expect(find.text('Belanja Bulanan: Rp 1500000'), findsOneWidget);
      expect(find.text('Bayar Listrik: Rp 500000'), findsOneWidget);

      // Step 4: Logout
      await tester.ensureVisible(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Verify logout called
      verify(mockAuthService.signOut()).called(1);
    });

    testWidgets('Filter transactions by different month',
        (WidgetTester tester) async {
      // Setup mock data - mix of December and November transactions
      final testPemasukan = [
        PemasukanModel(
          id: 'pemasukan-1',
          nama_pemasukan: 'Gaji December',
          tanggal_pemasukan: DateTime(2024, 12, 1),
          kategori_pemasukan: 'Gaji',
          jumlah: 5000000.0,
        ),
        PemasukanModel(
          id: 'pemasukan-2',
          nama_pemasukan: 'Gaji November',
          tanggal_pemasukan: DateTime(2024, 11, 1),
          kategori_pemasukan: 'Gaji',
          jumlah: 5000000.0,
        ),
      ];

      when(mockPemasukanRepository.fetchAll()).thenAnswer((_) async => testPemasukan);
      when(mockPengeluaranRepository.fetchAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockPemasukanRepository),
            ),
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockPengeluaranRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final pemasukanViewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                final pengeluaranViewModel = Provider.of<PengeluaranViewModel>(context, listen: false);

                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('load_data_button'),
                        onPressed: () async {
                          await pemasukanViewModel.loadPemasukan();
                          await pengeluaranViewModel.loadPengeluaran();
                        },
                        child: const Text('Load Data'),
                      ),
                      Consumer<PemasukanViewModel>(
                        builder: (context, vm, child) {
                          // Filter by November 2024
                          final novemberItems = vm.items.where((item) {
                            return item.tanggal_pemasukan.year == 2024 &&
                                item.tanggal_pemasukan.month == 11;
                          }).toList();

                          // Filter by December 2024
                          final decemberItems = vm.items.where((item) {
                            return item.tanggal_pemasukan.year == 2024 &&
                                item.tanggal_pemasukan.month == 12;
                          }).toList();

                          return Column(
                            children: [
                              Text('November: ${novemberItems.length} transactions'),
                              Text('December: ${decemberItems.length} transactions'),
                            ],
                          );
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

      // Verify filtering works correctly
      expect(find.text('November: 1 transactions'), findsOneWidget);
      expect(find.text('December: 1 transactions'), findsOneWidget);
    });

    testWidgets('Empty state when no transactions found',
        (WidgetTester tester) async {
      // Mock empty data
      when(mockPemasukanRepository.fetchAll()).thenAnswer((_) async => []);
      when(mockPengeluaranRepository.fetchAll()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockPemasukanRepository),
            ),
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockPengeluaranRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final pemasukanViewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                final pengeluaranViewModel = Provider.of<PengeluaranViewModel>(context, listen: false);

                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: const Key('load_data_button'),
                        onPressed: () async {
                          await pemasukanViewModel.loadPemasukan();
                          await pengeluaranViewModel.loadPengeluaran();
                        },
                        child: const Text('Load Data'),
                      ),
                      Consumer2<PemasukanViewModel, PengeluaranViewModel>(
                        builder: (context, pemasukanVm, pengeluaranVm, child) {
                          if (pemasukanVm.items.isEmpty && pengeluaranVm.items.isEmpty) {
                            return const Text('No transactions available');
                          }
                          return const Text('Has transactions');
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

      // Verify empty state
      expect(find.text('No transactions available'), findsOneWidget);
    });
  });
}
