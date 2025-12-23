import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/pemasukan_viewmodel.dart';
import 'package:jawara/data/repositories/pemasukan_repository.dart';
import 'package:jawara/data/models/pemasukan_model.dart';
import 'pemasukan_test.mocks.dart';

@GenerateMocks([PemasukanRepository])
void main() {
  group('Pemasukan Integration Tests', () {
    late MockPemasukanRepository mockRepository;

    setUp(() {
      mockRepository = MockPemasukanRepository();
    });

    test('Pemasukan ViewModel CRUD operations integration', () {
      late PemasukanViewModel viewModel;

      // Create ViewModel with mock repository
      viewModel = PemasukanViewModel(repository: mockRepository);

      // Test Create operation
      when(mockRepository.createPemasukan(
        nama_pemasukan: 'Test Income',
        tanggal_pemasukan: DateTime(2024, 1, 1),
        kategori_pemasukan: 'Test',
        jumlah: 50000.0,
        bukti_pemasukan: null,
      )).thenAnswer((_) async => PemasukanModel(
        id: 'new-id',
        nama_pemasukan: 'Test Income',
        tanggal_pemasukan: DateTime(2024, 1, 1),
        kategori_pemasukan: 'Test',
        jumlah: 50000.0,
        bukti_pemasukan: null,
      ));

      // Test Read operation
      final mockData = [
        PemasukanModel(
          id: 'read-id-1',
          nama_pemasukan: 'Read Test',
          tanggal_pemasukan: DateTime(2024, 1, 1),
          kategori_pemasukan: 'Test',
          jumlah: 25000.0,
          bukti_pemasukan: null,
        ),
      ];

      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Test Update operation
      when(mockRepository.updatePemasukan(
        id: 'read-id-1',
        nama_pemasukan: 'Updated Test',
        tanggal_pemasukan: DateTime(2024, 1, 1),
        kategori_pemasukan: 'Test',
        jumlah: 30000.0,
        bukti_pemasukan: null,
      )).thenAnswer((_) async => PemasukanModel(
        id: 'read-id-1',
        nama_pemasukan: 'Updated Test',
        tanggal_pemasukan: DateTime(2024, 1, 1),
        kategori_pemasukan: 'Test',
        jumlah: 30000.0,
        bukti_pemasukan: null,
      ));

      // Test Delete operation
      when(mockRepository.deletePemasukan('read-id-1')).thenAnswer((_) async => {});
    });

    testWidgets('Pemasukan ViewModel with Provider integration', (WidgetTester tester) async {
      // Setup mock data
      final mockData = [
        PemasukanModel(
          id: 'test-id-1',
          nama_pemasukan: 'Penjualan Barang',
          tanggal_pemasukan: DateTime(2024, 1, 1),
          kategori_pemasukan: 'Penjualan',
          jumlah: 100000.0,
          bukti_pemasukan: null,
        ),
      ];

      // Mock repository methods
      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Create a simple test widget that uses the ViewModel
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPemasukan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PemasukanViewModel>(
                        builder: (context, vm, child) {
                          if (vm.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (vm.errorMessage != null) {
                            return Text('Error: ${vm.errorMessage}');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.nama_pemasukan)).toList(),
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
      expect(find.text('Penjualan Barang'), findsNothing);

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should now show the data
      expect(find.text('Penjualan Barang'), findsOneWidget);
      expect(find.text('Error:'), findsNothing);

      // Verify ViewModel state
      final viewModel = Provider.of<PemasukanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items.length, 1);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockRepository.fetchAll()).called(1);
    });

    testWidgets('Pemasukan error handling integration', (WidgetTester tester) async {
      // Mock repository to throw error
      when(mockRepository.fetchAll()).thenThrow(Exception('Network error'));

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPemasukan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PemasukanViewModel>(
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
      final viewModel = Provider.of<PemasukanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.errorMessage, 'Exception: Network error');
      expect(viewModel.items, isEmpty);
    });

    testWidgets('Pemasukan empty state integration', (WidgetTester tester) async {
      // Mock empty data
      when(mockRepository.fetchAll()).thenAnswer((_) async => []);

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PemasukanViewModel>(
              create: (_) => PemasukanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<PemasukanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadPemasukan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<PemasukanViewModel>(
                        builder: (context, vm, child) {
                          if (vm.items.isEmpty && !vm.isLoading && vm.errorMessage == null) {
                            return const Text('No data available');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.nama_pemasukan)).toList(),
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
      final viewModel = Provider.of<PemasukanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}
