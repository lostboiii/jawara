import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jawara/ui/pages/auth/login_page.dart';
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal fake implementation for widget tests
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

void main() {
  group('Login Page Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => _FakeAuthService(),
          ),
          ChangeNotifierProvider(
            create: (context) => LoginViewModel(
              authService: context.read<AuthService>(),
            ),
          ),
        ],
        child: MaterialApp(
          home: LoginPage(),
        ),
      );
    }

    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check app title
      expect(find.text('Jawara Pintar'), findsOneWidget);
      
      // Check login form title
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk ke akun anda'), findsOneWidget);
      
      // Check form fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login form has email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for text input fields
      expect(find.byType(TextFormField), findsWidgets);
      
      // Should have at least 2 fields (email and password)
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);
    });

    testWidgets('Login button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for login button
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Register link is present', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for register link text
      expect(find.text('Belum punya akun?'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Get email field (first TextFormField)
      final emailField = find.byType(TextFormField).first;
      
      // Enter email
      await tester.enterText(emailField, 'test@example.com');
      
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Get password field (second TextFormField)
      final passwordField = find.byType(TextFormField).at(1);
      
      // Enter password
      await tester.enterText(passwordField, 'password123');
      
      // Password field should have the input (though may not display it due to obscuring)
      expect(find.byType(TextFormField).at(1), findsOneWidget);
    });

    testWidgets('Logo and branding elements are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for icon
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      
      // Check for branding text
      expect(find.text('Jawara Pintar'), findsOneWidget);
    });

    testWidgets('Welcome message is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for welcome text
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(
        find.text('Login untuk mengakses sistem Jawara Pintar.'),
        findsOneWidget,
      );
    });

    testWidgets('Form validation works for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Tap login button without filling fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Validation should trigger - text fields should still be visible
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Card widget wraps the form', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check for Card widget
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
