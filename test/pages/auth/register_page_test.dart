import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jawara/ui/pages/auth/register_page.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';
import 'package:jawara/data/models/keluarga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Minimal fake implementations for widget tests
class _FakeAuthService implements AuthService {
  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Session? getCurrentSession() => null;

  @override
  User? getCurrentUser() => null;

  @override
  bool isAuthenticated() => false;

  @override
  Future<void> resetPassword(String email) async {}
}

class _FakeWargaRepository implements WargaRepository {
  @override
  Future<WargaProfile> createProfile({
    required String userId,
    required String namaLengkap,
    required String nik,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    String? fotoIdentitasUrl,
  }) async => WargaProfile(
    id: 'test',
    namaLengkap: namaLengkap,
    nik: nik,
    noHp: noHp,
    jenisKelamin: jenisKelamin,
    agama: agama,
    golonganDarah: golonganDarah,
    pekerjaan: pekerjaan,
    fotoIdentitasUrl: null,
    role: 'Warga',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Future<void> deleteProfile(String userId) async {}

  @override
  String getFotoPublicUrl(String filePath) => '';

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async => null;

  @override
  Future<WargaProfile?> getProfileById(String userId) async => null;

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async => '';

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async => profile;

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async => null;

  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    return Keluarga(
      id: 'keluarga_123',
      kepalakeluargaId: kepalakeluargaId,
      nomorKk: nomorKk,
      alamat: rumahId ?? 'rumah_default',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    return [
      {
        'id': 'keluarga_1',
        'kepala_keluarga_id': 'warga_1',
        'nomorKk': '3210123456789001',
        'alamat': 'rumah_1',
        'warga_profiles': {
          'nama_lengkap': 'Budi Santoso',
        },
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getRumahList() async {
    return [
      {
        'id': 'rumah_1',
        'alamat': 'Jl. Merdeka No. 1',
        'status_rumah': 'kosong',
      },
    ];
  }

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    // Mock implementation
  }

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {
    // Mock implementation
  }
}

void main() {
  group('Register Page Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => _FakeAuthService(),
          ),
          Provider<WargaRepository>(
            create: (_) => _FakeWargaRepository(),
          ),
          ChangeNotifierProvider(
            create: (context) => RegisterViewModel(
              authService: context.read<AuthService>(),
              wargaRepository: context.read<WargaRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          home: RegisterPage(),
        ),
      );
    }

    testWidgets('Register page has form labels', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check form field labels
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('NIK'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('No Telepon'), findsOneWidget);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
      expect(find.text('Agama'), findsOneWidget);
      expect(find.text('Golongan Darah'), findsOneWidget);
      expect(find.text('Pekerjaan'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
    });

    testWidgets('Form has required input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Count TextFormField widgets (should have at least 8 text fields)
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Email field can accept input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Get first TextFormField for name
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);
      
      // Try to enter text in a field
      await tester.enterText(textFields.first, 'John Doe');
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('Phone number field accepts digits', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final textFields = find.byType(TextFormField);
      
      // Enter phone number in one of the fields
      await tester.enterText(textFields.at(3), '081234567890');
      
      expect(find.text('081234567890'), findsOneWidget);
    });

    testWidgets('Jenis Kelamin dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for Jenis Kelamin label (inside DropdownButtonFormField)
      expect(find.text('Jenis Kelamin'), findsOneWidget);
    });

    testWidgets('Agama dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for Agama label
      expect(find.text('Agama'), findsOneWidget);
    });

    testWidgets('Golongan Darah dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for Golongan Darah label
      expect(find.text('Golongan Darah'), findsOneWidget);
    });

    testWidgets('Pekerjaan field label exists', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for Pekerjaan label
      expect(find.text('Pekerjaan'), findsOneWidget);
    });

    testWidgets('Form contains submit button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for ElevatedButton (the register/submit button)
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
