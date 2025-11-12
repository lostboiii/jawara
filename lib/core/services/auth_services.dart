import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface untuk Auth Service
abstract class AuthService {
  /// Sign up dengan email dan password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  /// Sign in dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  /// Sign out user
  Future<void> signOut();

  /// Get current user session
  Session? getCurrentSession();

  /// Get current authenticated user
  User? getCurrentUser();

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Reset password dengan email
  Future<void> resetPassword(String email);
}

/// Implementasi Auth Service menggunakan Supabase
class SupabaseAuthService implements AuthService {
  final SupabaseClient client;

  SupabaseAuthService({required this.client});

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw 'Gagal sign up: $e';
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw 'Gagal sign in: $e';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw 'Gagal sign out: $e';
    }
  }

  @override
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  @override
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  @override
  bool isAuthenticated() {
    return client.auth.currentSession != null;
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Gagal reset password: $e';
    }
  }
}
