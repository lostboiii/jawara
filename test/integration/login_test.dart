
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sfb;
import 'package:go_router/go_router.dart';
import 'package:jawara/ui/pages/auth/login_page.dart';
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';

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
}

class MockGoRouter extends Mock implements GoRouter {}

class MockSupabaseClient extends Mock implements sfb.SupabaseClient {}

class MockSupabaseAuth extends Mock implements sfb.GoTrueClient {}

void main() {
  late MockAuthService mockAuthService;
  late MockGoRouter mockGoRouter;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseAuth mockSupabaseAuth;

  setUp(() {
    mockAuthService = MockAuthService();
    mockGoRouter = MockGoRouter();
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseAuth = MockSupabaseAuth();
  });

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(authService: mockAuthService),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginPage(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const Scaffold(body: Text('Home')),
            ),
            GoRoute(
              path: '/warga-home',
              builder: (context, state) => const Scaffold(body: Text('Warga Home')),
            ),
          ],
          initialLocation: '/login',
        ),
      ),
    );
  }

  group('LoginPage + LoginViewModel Integration', () {
    testWidgets('Validasi email kosong menampilkan error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Input password saja, biarkan email kosong
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap tombol Masuk
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      // Verifikasi error validation muncul di form field
      // Error dari form validation: "Harap masukkan email"
      expect(find.text('Harap masukkan email'), findsOneWidget);
    });

    testWidgets('Validasi password terlalu pendek menampilkan error dari viewmodel', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Input email valid
      await tester.enterText(find.byType(TextFormField).at(0), 'test@email.com');
      // Input password terlalu pendek
      await tester.enterText(find.byType(TextFormField).at(1), '12345');

      // Panggil viewModel.login untuk trigger validasi viewmodel
      final context = tester.element(find.byType(LoginPage));
      final viewModel = context.read<LoginViewModel>();

      // Trigger login validation
      await viewModel.login(email: 'test@email.com', password: '12345');
      await tester.pump(); // Update UI

      // Verifikasi error validation muncul dari viewmodel
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('Berhasil login menampilkan loading state', (WidgetTester tester) async {
      // Setup mock untuk login berhasil
      when(mockAuthService.signIn(email: 'test@email.com', password: 'password123'))
          .thenAnswer((_) async => sfb.AuthResponse(
                user: sfb.User(id: 'test-user-id', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
                session: null,
              ));

      await tester.pumpWidget(createTestApp());

      // Input email
      await tester.enterText(find.byType(TextFormField).at(0), 'test@email.com');
      // Input password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Dapatkan viewModel dan trigger login langsung (menghindari Supabase calls di _handleLogin)
      final loginElement = tester.element(find.byType(LoginPage));
      final viewModel = Provider.of<LoginViewModel>(loginElement, listen: false);

      // Trigger login langsung melalui viewModel
      await tester.runAsync(() async {
        final future = viewModel.login(email: 'test@email.com', password: 'password123');
        await future;
      });

      // Pump untuk memicu rebuild setelah login selesai
      await tester.pump();

      // Verifikasi tidak ada error message (login berhasil)
      expect(find.text('Gagal login'), findsNothing);
    });

    testWidgets('Gagal login menampilkan pesan error dari viewmodel', (WidgetTester tester) async {
      // Setup mock untuk login gagal
      when(mockAuthService.signIn(email: 'salah@email.com', password: 'salahpassword'))
          .thenAnswer((_) async => sfb.AuthResponse(user: null, session: null));

      await tester.pumpWidget(createTestApp());

      // Input password
      await tester.enterText(find.byType(TextFormField).at(1), 'salahpassword');

      // Dapatkan viewModel dan trigger login langsung
      final loginElement = tester.element(find.byType(LoginPage));
      final viewModel = Provider.of<LoginViewModel>(loginElement, listen: false);

      // Trigger login langsung melalui viewModel
      await tester.runAsync(() async {
        final future = viewModel.login(email: 'salah@email.com', password: 'salahpassword');
        await future;
      });

      // Pump untuk memicu rebuild setelah login gagal
      await tester.pump();

      // Verifikasi error message muncul di UI
      expect(find.text('Gagal login'), findsOneWidget);
    });
  });
}
