import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/metode_pembayaran_viewmodel.dart';
import 'package:jawara/data/repositories/metode_pembayaran_repository.dart';
import 'package:jawara/data/models/metode_pembayaran_model.dart';
import 'pembayaran_test.mocks.dart';

@GenerateMocks([MetodePembayaranRepository])
void main() {
  group('Metode Pembayaran Integration Tests', () {
    late MockMetodePembayaranRepository mockRepository;

    setUp(() {
      mockRepository = MockMetodePembayaranRepository();
    });

    test('Metode Pembayaran ViewModel CRUD operations integration', () {
      late MetodePembayaranViewModel viewModel;

      // Create ViewModel with mock repository
      viewModel = MetodePembayaranViewModel(repository: mockRepository);

      // Test Create operation
      when(mockRepository.createMetodePembayaran(
        namaMetode: 'Transfer Bank',
        nomorRekening: '1234567890',
        namaPemilik: 'John Doe',
        fotoBarcode: null,
        thumbnail: null,
        catatan: 'Bank ABC',
      )).thenAnswer((_) async => MetodePembayaranModel(
        id: 'new-id',
        namaMetode: 'Transfer Bank',
        nomorRekening: '1234567890',
        namaPemilik: 'John Doe',
        fotoBarcode: null,
        thumbnail: null,
        catatan: 'Bank ABC',
      ));

      // Test Read operation
      final mockData = [
        MetodePembayaranModel(
          id: 'read-id-1',
          namaMetode: 'Transfer Bank',
          nomorRekening: '1234567890',
          namaPemilik: 'John Doe',
          fotoBarcode: null,
          thumbnail: null,
          catatan: 'Bank ABC',
        ),
        MetodePembayaranModel(
          id: 'read-id-2',
          namaMetode: 'E-Wallet',
          nomorRekening: '081234567890',
          namaPemilik: 'Jane Smith',
          fotoBarcode: null,
          thumbnail: null,
          catatan: 'GoPay',
        ),
      ];

      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Test Update operation
      when(mockRepository.updateMetodePembayaran(
        id: 'read-id-1',
        namaMetode: 'Transfer Bank Updated',
        nomorRekening: '0987654321',
        namaPemilik: 'John Doe Updated',
        fotoBarcode: null,
        thumbnail: null,
        catatan: 'Bank XYZ',
      )).thenAnswer((_) async => MetodePembayaranModel(
        id: 'read-id-1',
        namaMetode: 'Transfer Bank Updated',
        nomorRekening: '0987654321',
        namaPemilik: 'John Doe Updated',
        fotoBarcode: null,
        thumbnail: null,
        catatan: 'Bank XYZ',
      ));

      // Test Delete operation
      when(mockRepository.deleteMetodePembayaran('read-id-1')).thenAnswer((_) async => {});
    });

    testWidgets('Metode Pembayaran ViewModel with Provider integration', (WidgetTester tester) async {
      // Setup mock data
      final mockData = [
        MetodePembayaranModel(
          id: 'test-id-1',
          namaMetode: 'Transfer Bank',
          nomorRekening: '1234567890',
          namaPemilik: 'John Doe',
          fotoBarcode: null,
          thumbnail: null,
          catatan: 'Bank ABC',
        ),
        MetodePembayaranModel(
          id: 'test-id-2',
          namaMetode: 'E-Wallet',
          nomorRekening: '081234567890',
          namaPemilik: 'Jane Smith',
          fotoBarcode: null,
          thumbnail: null,
          catatan: 'GoPay',
        ),
      ];

      // Mock repository methods
      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MetodePembayaranViewModel>(
              create: (_) => MetodePembayaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<MetodePembayaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadMetodePembayaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<MetodePembayaranViewModel>(
                        builder: (context, vm, child) {
                          if (vm.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (vm.errorMessage != null) {
                            return Text('Error: ${vm.errorMessage}');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaMetode)).toList(),
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
      expect(find.text('Transfer Bank'), findsNothing);

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should now show the data
      expect(find.text('Transfer Bank'), findsOneWidget);
      expect(find.text('E-Wallet'), findsOneWidget);
      expect(find.text('Error:'), findsNothing);

      // Verify ViewModel state
      final viewModel = Provider.of<MetodePembayaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items.length, 2);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockRepository.fetchAll()).called(1);
    });

    testWidgets('Metode Pembayaran error handling integration', (WidgetTester tester) async {
      // Mock repository to throw error
      when(mockRepository.fetchAll()).thenThrow(Exception('Network error'));

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MetodePembayaranViewModel>(
              create: (_) => MetodePembayaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<MetodePembayaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadMetodePembayaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<MetodePembayaranViewModel>(
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
      final viewModel = Provider.of<MetodePembayaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.errorMessage, 'Exception: Network error');
      expect(viewModel.items, isEmpty);
    });

    testWidgets('Metode Pembayaran empty state integration', (WidgetTester tester) async {
      // Mock empty data
      when(mockRepository.fetchAll()).thenAnswer((_) async => []);

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MetodePembayaranViewModel>(
              create: (_) => MetodePembayaranViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<MetodePembayaranViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadMetodePembayaran(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<MetodePembayaranViewModel>(
                        builder: (context, vm, child) {
                          if (vm.items.isEmpty && !vm.isLoading && vm.errorMessage == null) {
                            return const Text('No data available');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaMetode)).toList(),
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
      final viewModel = Provider.of<MetodePembayaranViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}
