import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/kegiatan_viewmodel.dart';
import 'package:jawara/data/repositories/kegiatan_repository.dart';
import 'package:jawara/data/models/kegiatan_model.dart';
import 'tambah_kegiatan_test.mocks.dart';

@GenerateMocks([KegiatanRepository])
void main() {
  group('Kegiatan Integration Tests', () {
    late MockKegiatanRepository mockRepository;

    setUp(() {
      mockRepository = MockKegiatanRepository();
    });

    test('Kegiatan ViewModel CRUD operations integration', () {
      late KegiatanViewModel viewModel;

      // Create ViewModel with mock repository
      viewModel = KegiatanViewModel(repository: mockRepository);

      // Test Create operation
      when(mockRepository.createKegiatan(
        nama: 'Gotong Royong',
        kategori: 'Kegiatan Sosial',
        tanggal: DateTime(2024, 1, 15),
        lokasi: 'Balai Desa',
        penanggungJawab: 'Pak RT',
        deskripsi: 'Bersih-bersih lingkungan',
      )).thenAnswer((_) async => KegiatanModel(
        id: 'new-id',
        namaKegiatan: 'Gotong Royong',
        kategoriKegiatan: 'Kegiatan Sosial',
        tanggalKegiatan: DateTime(2024, 1, 15),
        lokasiKegiatan: 'Balai Desa',
        penanggungJawab: 'Pak RT',
        deskripsi: 'Bersih-bersih lingkungan',
      ));

      // Test Read operation
      final mockData = [
        KegiatanModel(
          id: 'read-id-1',
          namaKegiatan: 'Gotong Royong',
          kategoriKegiatan: 'Kegiatan Sosial',
          tanggalKegiatan: DateTime(2024, 1, 15),
          lokasiKegiatan: 'Balai Desa',
          penanggungJawab: 'Pak RT',
          deskripsi: 'Bersih-bersih lingkungan',
        ),
        KegiatanModel(
          id: 'read-id-2',
          namaKegiatan: 'Arisan Warga',
          kategoriKegiatan: 'Kegiatan Warga',
          tanggalKegiatan: DateTime(2024, 1, 20),
          lokasiKegiatan: 'Rumah Pak Lurah',
          penanggungJawab: 'Bu RT',
          deskripsi: 'Arisan bulanan warga',
        ),
      ];

      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Test Update operation
      when(mockRepository.updateKegiatan(
        id: 'read-id-1',
        nama: 'Gotong Royong Updated',
        kategori: 'Kegiatan Sosial',
        tanggal: DateTime(2024, 1, 16),
        lokasi: 'Lapangan Desa',
        penanggungJawab: 'Pak RW',
        deskripsi: 'Bersih-bersih lingkungan dan gotong royong',
      )).thenAnswer((_) async => KegiatanModel(
        id: 'read-id-1',
        namaKegiatan: 'Gotong Royong Updated',
        kategoriKegiatan: 'Kegiatan Sosial',
        tanggalKegiatan: DateTime(2024, 1, 16),
        lokasiKegiatan: 'Lapangan Desa',
        penanggungJawab: 'Pak RW',
        deskripsi: 'Bersih-bersih lingkungan dan gotong royong',
      ));

      // Test Delete operation
      when(mockRepository.deleteKegiatan('read-id-1')).thenAnswer((_) async => {});
    });

    testWidgets('Kegiatan ViewModel with Provider integration', (WidgetTester tester) async {
      // Setup mock data
      final mockData = [
        KegiatanModel(
          id: 'test-id-1',
          namaKegiatan: 'Gotong Royong',
          kategoriKegiatan: 'Kegiatan Sosial',
          tanggalKegiatan: DateTime(2024, 1, 15),
          lokasiKegiatan: 'Balai Desa',
          penanggungJawab: 'Pak RT',
          deskripsi: 'Bersih-bersih lingkungan',
        ),
        KegiatanModel(
          id: 'test-id-2',
          namaKegiatan: 'Arisan Warga',
          kategoriKegiatan: 'Kegiatan Warga',
          tanggalKegiatan: DateTime(2024, 1, 20),
          lokasiKegiatan: 'Rumah Pak Lurah',
          penanggungJawab: 'Bu RT',
          deskripsi: 'Arisan bulanan warga',
        ),
      ];

      // Mock repository methods
      when(mockRepository.fetchAll()).thenAnswer((_) async => mockData);

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KegiatanViewModel>(
              create: (_) => KegiatanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<KegiatanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadKegiatan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<KegiatanViewModel>(
                        builder: (context, vm, child) {
                          if (vm.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (vm.errorMessage != null) {
                            return Text('Error: ${vm.errorMessage}');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaKegiatan)).toList(),
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
      expect(find.text('Gotong Royong'), findsNothing);

      // Tap load button
      await tester.tap(find.text('Load Data'));
      await tester.pumpAndSettle();

      // Should now show the data
      expect(find.text('Gotong Royong'), findsOneWidget);
      expect(find.text('Arisan Warga'), findsOneWidget);
      expect(find.text('Error:'), findsNothing);

      // Verify ViewModel state
      final viewModel = Provider.of<KegiatanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items.length, 2);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockRepository.fetchAll()).called(1);
    });

    testWidgets('Kegiatan error handling integration', (WidgetTester tester) async {
      // Mock repository to throw error
      when(mockRepository.fetchAll()).thenThrow(Exception('Network error'));

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KegiatanViewModel>(
              create: (_) => KegiatanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<KegiatanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadKegiatan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<KegiatanViewModel>(
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
      final viewModel = Provider.of<KegiatanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.errorMessage, 'Exception: Network error');
      expect(viewModel.items, isEmpty);
    });

    testWidgets('Kegiatan empty state integration', (WidgetTester tester) async {
      // Mock empty data
      when(mockRepository.fetchAll()).thenAnswer((_) async => []);

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KegiatanViewModel>(
              create: (_) => KegiatanViewModel(repository: mockRepository),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<KegiatanViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.loadKegiatan(),
                        child: const Text('Load Data'),
                      ),
                      Consumer<KegiatanViewModel>(
                        builder: (context, vm, child) {
                          if (vm.items.isEmpty && !vm.isLoading && vm.errorMessage == null) {
                            return const Text('No data available');
                          }
                          return Column(
                            children: vm.items.map((item) => Text(item.namaKegiatan)).toList(),
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
      final viewModel = Provider.of<KegiatanViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.items, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}
