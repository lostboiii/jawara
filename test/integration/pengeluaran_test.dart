import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/pengeluaran_viewmodel.dart';
import 'package:jawara/data/repositories/pengeluaran_repository.dart';
import 'package:jawara/data/models/pengeluaran_model.dart';
import 'pengeluaran_test.mocks.dart';

@GenerateMocks([PengeluaranRepository])
void main() {
  group('Pengeluaran Integration Tests', () {
    late MockPengeluaranRepository mockRepository;

    setUp(() {
      mockRepository = MockPengeluaranRepository();
    });

    test('Pengeluaran ViewModel CRUD operations integration', () {
      late PengeluaranViewModel viewModel;

      // Create ViewModel with mock repository
      viewModel = PengeluaranViewModel(repository: mockRepository);

      // Test Create operation
      when(mockRepository.createPengeluaran(
        nama: 'Beli ATK',
        tanggal: DateTime(2024, 1, 1),
        kategori: 'Operasional',
        jumlah: 50000.0,
        bukti: null,
      )).thenAnswer((_) async => PengeluaranModel(
        id: 'new-id',
        namaPengeluaran: 'Beli ATK',
        tanggalPengeluaran: DateTime(2024, 1, 1),
        kategoriPengeluaran: 'Operasional',
        jumlah: 50000.0,
        buktiPengeluaran: null,
      ));

      // Test Read operation
      final mockData = [
        PengeluaranModel(
          id: 'read-id-1',
          namaPengeluaran: 'Beli ATK',
          tanggalPengeluaran: DateTime(2024, 1, 1),
          kategoriPengeluaran: 'Operasional',
          jumlah: 50000.0,
          buktiPengeluaran: null,
        ),
        PengeluaranModel(
          id: 'read-id-2',
          namaPengeluaran: 'Beli Buku',
          tanggalPengeluaran: DateTime(2024, 1, 2),
          kategoriPengeluaran: 'Operasional',
          jumlah: 75000.0,
          buktiPengeluaran: null,
        ),
      ];

      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Test Update operation
      when(mockRepository.updatePengeluaran(
        id: 'read-id-1',
        nama: 'Beli ATK Updated',
        tanggal: DateTime(2024, 1, 1),
        kategori: 'Operasional',
        jumlah: 60000.0,
        bukti: null,
      )).thenAnswer((_) async => PengeluaranModel(
        id: 'read-id-1',
        namaPengeluaran: 'Beli ATK Updated',
        tanggalPengeluaran: DateTime(2024, 1, 1),
        kategoriPengeluaran: 'Operasional',
        jumlah: 60000.0,
        buktiPengeluaran: null,
      ));

      // Test Delete operation
      when(mockRepository.deletePengeluaran('read-id-1')).thenAnswer((_) async => {});
    });

    testWidgets('Pengeluaran ViewModel with Provider integration', (WidgetTester tester) async {
      // Setup mock data
      final mockData = [
        PengeluaranModel(
          id: 'test-id-1',
          namaPengeluaran: 'Beli ATK',
          tanggalPengeluaran: DateTime(2024, 1, 1),
          kategoriPengeluaran: 'Operasional',
          jumlah: 50000.0,
          buktiPengeluaran: null,
        ),
        PengeluaranModel(
          id: 'test-id-2',
          namaPengeluaran: 'Beli Buku',
          tanggalPengeluaran: DateTime(2024, 1, 2),
          kategoriPengeluaran: 'Operasional',
          jumlah: 75000.0,
          buktiPengeluaran: null,
        ),
      ];

      // Mock repository methods
      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PengeluaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPengeluaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PengeluaranViewModel>(
                        builder: (context, vm, child) {
                          if (vm.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (vm.errorMessage != null) {
                            return Text('Error: ${vm.errorMessage}');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaPengeluaran)).toList(),
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

      // Initially should be empty
      expect(find.text('Beli ATK'), findsNothing);

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should now show the data
      expect(find.text('Beli ATK'), findsOneWidget);
      expect(find.text('Beli Buku'), findsOneWidget);
      expect(find.text('Error:'), findsNothing);

      // Verify ViewModel state
      final viewModel = Provider.of<PengeluaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items.length, 2);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockRepository.fetchAll()).called(1);
    });

    testWidgets('Pengeluaran error handling integration', (WidgetTester tester) async {
      // Mock repository to throw error
      when(mockRepository.fetchAll()).thenThrow(Exception('Network error'));

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PengeluaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPengeluaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PengeluaranViewModel>(
                        builder: (context, vm, child) {
                          if (vm.errorMessage != null) {
                            return Text('Error: ${vm.errorMessage}');
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

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Error: Exception: Network error'), findsOneWidget);

      // Verify ViewModel state
      final viewModel = Provider.of<PengeluaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.errorMessage, 'Exception: Network error');
      expect(viewModel.items, isEmpty);
    });

    testWidgets('Pengeluaran empty state integration', (WidgetTester tester) async {
      // Mock empty data
      when(mockRepository.fetchAll()).thenAnswer((_) async => []);

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PengeluaranViewModel>(
              create: (_) => PengeluaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PengeluaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPengeluaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PengeluaranViewModel>(
                        builder: (context, vm, child) {
                          if (vm.items.isEmpty && !vm.isLoading && vm.errorMessage == null) {
                            return const Text('No data available');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaPengeluaran)).toList(),
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

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No data available'), findsOneWidget);

      // Verify ViewModel state
      final viewModel = Provider.of<PengeluaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}