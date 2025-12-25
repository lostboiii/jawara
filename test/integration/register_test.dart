import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sfb;
import 'register_test.mocks.dart';

@GenerateMocks([AuthService, WargaRepository])
void main() {
  group('Register Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockWargaRepository mockWargaRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockWargaRepository = MockWargaRepository();
    });

    test('Register ViewModel CRUD operations integration', () {
      late RegisterViewModel viewModel;

      // Create ViewModel with mock services
      viewModel = RegisterViewModel(
        authService: mockAuthService,
        wargaRepository: mockWargaRepository,
      );

      // Test Register operation
      when(mockAuthService.signUp(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => sfb.AuthResponse(
        user: sfb.User(
          id: 'user-id-123',
          email: 'test@example.com',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: null,
      ));

      when(mockWargaRepository.createProfile(
        userId: 'user-id-123',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        golonganDarah: 'A+',
        pekerjaan: 'Programmer',
        peranKeluarga: 'Kepala Keluarga',
        fotoIdentitasUrl: null,
      )).thenAnswer((_) async => WargaProfile(
        id: 'profile-id-123',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        golonganDarah: 'A+',
        pekerjaan: 'Programmer',
        fotoIdentitasUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Test successful registration
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.currentProfile, isNull);
    });

    testWidgets('Register ViewModel with Provider integration', (WidgetTester tester) async {
      // Mock successful registration
      when(mockAuthService.signUp(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => sfb.AuthResponse(
        user: sfb.User(
          id: 'user-id-123',
          email: 'test@example.com',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: null,
      ));

      when(mockWargaRepository.createProfile(
        userId: 'user-id-123',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        golonganDarah: 'A+',
        pekerjaan: 'Programmer',
        peranKeluarga: 'Kepala Keluarga',
        fotoIdentitasUrl: null,
      )).thenAnswer((_) async => WargaProfile(
        id: 'profile-id-123',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        golonganDarah: 'A+',
        pekerjaan: 'Programmer',
        fotoIdentitasUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Create test app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RegisterViewModel>(
              create: (_) => RegisterViewModel(
                authService: mockAuthService,
                wargaRepository: mockWargaRepository,
              ),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async => await viewModel.registerWarga(
                          namaLengkap: 'John Doe',
                          nik: '1234567890123456',
                          email: 'test@example.com',
                          noHp: '081234567890',
                          jenisKelamin: 'Laki-laki',
                          agama: 'Islam',
                          golonganDarah: 'A+',
                          pekerjaan: 'Programmer',
                          password: 'password123',
                          confirmPassword: 'password123',
                          peranKeluarga: 'Kepala Keluarga',
                          fotoIdentitas: null,
                        ),
                        child: const Text('Register'),
                      ),
                      Consumer<RegisterViewModel>(
                        builder: (context, vm, child) {
                          if (vm.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          if (vm.error != null) {
                            return Text('Error: ${vm.error}');
                          }
                          if (vm.currentProfile != null) {
                            return Text('Success: ${vm.currentProfile!.namaLengkap}');
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

      // Initially should be empty
      expect(find.text('Success:'), findsNothing);
      expect(find.text('Error:'), findsNothing);

      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Success: John Doe'), findsOneWidget);
      expect(find.text('Error:'), findsNothing);

      // Verify ViewModel state
      final viewModel = Provider.of<RegisterViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.currentProfile?.namaLengkap, 'John Doe');
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(mockAuthService.signUp(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
      verify(mockWargaRepository.createProfile(
        userId: 'user-id-123',
        namaLengkap: 'John Doe',
        nik: '1234567890123456',
        noHp: '081234567890',
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        golonganDarah: 'A+',
        pekerjaan: 'Programmer',
        peranKeluarga: 'Kepala Keluarga',
        fotoIdentitasUrl: null,
      )).called(1);
    });

    testWidgets('Register error handling integration', (WidgetTester tester) async {
      // Mock registration failure
      when(mockAuthService.signUp(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(Exception('Email already exists'));

      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RegisterViewModel>(
              create: (_) => RegisterViewModel(
                authService: mockAuthService,
                wargaRepository: mockWargaRepository,
              ),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async => await viewModel.registerWarga(
                          namaLengkap: 'John Doe',
                          nik: '1234567890123456',
                          email: 'test@example.com',
                          noHp: '081234567890',
                          jenisKelamin: 'Laki-laki',
                          agama: 'Islam',
                          golonganDarah: 'A+',
                          pekerjaan: 'Programmer',
                          password: 'password123',
                          confirmPassword: 'password123',
                          peranKeluarga: 'Kepala Keluarga',
                          fotoIdentitas: null,
                        ),
                        child: const Text('Register'),
                      ),
                      Consumer<RegisterViewModel>(
                        builder: (context, vm, child) {
                          if (vm.error != null) {
                            return Text('Error: ${vm.error}');
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

      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error:'), findsOneWidget);

      // Verify ViewModel state
      final viewModel = Provider.of<RegisterViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.error, isNotNull);
      expect(viewModel.currentProfile, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    testWidgets('Register validation error integration', (WidgetTester tester) async {
      // Create test widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RegisterViewModel>(
              create: (_) => RegisterViewModel(
                authService: mockAuthService,
                wargaRepository: mockWargaRepository,
              ),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async => await viewModel.registerWarga(
                          namaLengkap: '', // Empty name - should trigger validation error
                          nik: '1234567890123456',
                          email: 'test@example.com',
                          noHp: '081234567890',
                          jenisKelamin: 'Laki-laki',
                          agama: 'Islam',
                          golonganDarah: 'A+',
                          pekerjaan: 'Programmer',
                          password: 'password123',
                          confirmPassword: 'password123',
                          peranKeluarga: 'Kepala Keluarga',
                          fotoIdentitas: null,
                        ),
                        child: const Text('Register'),
                      ),
                      Consumer<RegisterViewModel>(
                        builder: (context, vm, child) {
                          if (vm.error != null) {
                            return Text('Error: ${vm.error}');
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

      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Error: Nama lengkap wajib diisi'), findsOneWidget);

      // Verify ViewModel state
      final viewModel = Provider.of<RegisterViewModel>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      expect(viewModel.error, 'Nama lengkap wajib diisi');
      expect(viewModel.currentProfile, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}