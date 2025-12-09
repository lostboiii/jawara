import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/viewmodels/login_viewmodel.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('LoginViewModel Tests', () {
    group('Email Validation', () {
      // Use a minimal fake service just for validation tests
      late LoginViewModel loginViewModel;
      
      setUp(() {
        // Create a minimal fake that doesn't need full implementation
        loginViewModel = LoginViewModel(
          authService: _MinimalFakeAuthService(),
        );
      });

      test('validateEmail returns true for valid email', () {
        final result = loginViewModel.validateEmail('test@example.com');
        expect(result, true);
      });

      test('validateEmail returns true for valid email with numbers', () {
        final result = loginViewModel.validateEmail('user123@domain.co.id');
        expect(result, true);
      });

      test('validateEmail returns false for email without @', () {
        final result = loginViewModel.validateEmail('testexample.com');
        expect(result, false);
      });

      test('validateEmail returns false for empty email', () {
        final result = loginViewModel.validateEmail('');
        expect(result, false);
      });

      test('validateEmail returns false for email without domain', () {
        final result = loginViewModel.validateEmail('test@');
        expect(result, false);
      });

      test('validateEmail returns false for email without username', () {
        final result = loginViewModel.validateEmail('@example.com');
        expect(result, false);
      });

      test('validateEmail returns false for email with space', () {
        final result = loginViewModel.validateEmail('test @example.com');
        expect(result, false);
      });
    });

    group('ViewModel State Management', () {
      late LoginViewModel loginViewModel;

      setUp(() {
        loginViewModel = LoginViewModel(
          authService: _MinimalFakeAuthService(),
        );
      });

      test('clearError removes error message', () {
        loginViewModel.clearError();
        expect(loginViewModel.error, null);
      });

      test('hasError returns false initially', () {
        expect(loginViewModel.hasError, false);
      });

      test('isLoading is initially false', () {
        expect(loginViewModel.isLoading, false);
      });

      test('reset clears all state', () {
        loginViewModel.reset();
        expect(loginViewModel.isLoading, false);
        expect(loginViewModel.error, null);
        expect(loginViewModel.hasError, false);
      });
    });

    group('Login Functionality', () {
      test('login returns true for valid credentials', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, true);
        expect(vm.error, null);
        expect(vm.isLoading, false);
      });

      test('login returns false for invalid credentials', () async {
        final authService = _FakeAuthService(shouldSucceed: false);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'wrong@example.com',
          password: 'wrongpassword',
        );

        expect(result, false);
        expect(vm.error, isNotNull);
        expect(vm.isLoading, false);
      });

      test('login returns false for empty email', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: '',
          password: 'password123',
        );

        expect(result, false);
        expect(vm.error, contains('Email wajib diisi'));
      });

      test('login returns false for invalid email format', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'invalidemail',
          password: 'password123',
        );

        expect(result, false);
        expect(vm.error, contains('Format email tidak valid'));
      });

      test('login returns false for empty password', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'test@example.com',
          password: '',
        );

        expect(result, false);
        expect(vm.error, contains('Password wajib diisi'));
      });

      test('login returns false for short password', () async {
        final authService = _FakeAuthService(shouldSucceed: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'test@example.com',
          password: '12345',
        );

        expect(result, false);
        expect(vm.error, contains('Password minimal 6 karakter'));
      });

      test('login sets isLoading to true during operation', () async {
        final authService = _FakeAuthService(shouldSucceed: true, delay: Duration(milliseconds: 100));
        final vm = LoginViewModel(authService: authService);

        final loginFuture = vm.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Check isLoading is true immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(vm.isLoading, true);

        await loginFuture;
        expect(vm.isLoading, false);
      });

      test('login handles null user in response', () async {
        final authService = _FakeAuthService(shouldSucceed: true, returnNullUser: true);
        final vm = LoginViewModel(authService: authService);

        final result = await vm.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, false);
        expect(vm.error, contains('Gagal login'));
      });
    });
  });
}

/// Minimal fake implementation for testing
class _MinimalFakeAuthService implements AuthService {
  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

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

/// Full fake implementation for login tests
class _FakeAuthService implements AuthService {
  final bool shouldSucceed;
  final bool returnNullUser;
  final Duration? delay;

  _FakeAuthService({
    required this.shouldSucceed,
    this.returnNullUser = false,
    this.delay,
  });

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (delay != null) {
      await Future.delayed(delay!);
    }

    if (!shouldSucceed) {
      throw Exception('Invalid credentials');
    }

    return AuthResponse(
      session: returnNullUser
          ? null
          : Session(
              accessToken: 'fake_token',
              tokenType: 'bearer',
              user: User(
                id: 'fake_user_id',
                appMetadata: {},
                userMetadata: {},
                aud: 'authenticated',
                createdAt: DateTime.now().toIso8601String(),
              ),
            ),
      user: returnNullUser
          ? null
          : User(
              id: 'fake_user_id',
              appMetadata: {},
              userMetadata: {},
              aud: 'authenticated',
              createdAt: DateTime.now().toIso8601String(),
            ),
    );
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

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
