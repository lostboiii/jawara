import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

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
    int retries = 3;
    Duration delay = Duration(seconds: 2);
    
    while (retries > 0) {
      try {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'email_verified': true,
            'skip_email_verification': true,
          },
        );
        return response;
      } catch (e) {
        final errorString = e.toString();
        
        // If rate limit error, retry with backoff
        if (errorString.contains('429') || errorString.contains('rate limit') || errorString.contains('over_email_send_rate_limit')) {
          retries--;
          if (retries > 0) {
            await Future.delayed(delay);
            delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
            continue;
          }
        }
        
        rethrow;
      }
    }
    
    throw 'Gagal sign up setelah beberapa kali percobaan';
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
