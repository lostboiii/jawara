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
