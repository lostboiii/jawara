import 'package:flutter/foundation.dart';
import 'package:jawara/core/services/auth_services.dart';

/// ViewModel untuk halaman login
class LoginViewModel extends ChangeNotifier {
  final AuthService authService;

  LoginViewModel({required this.authService});

  /// State management
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Validate email format
  bool validateEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validasi input
      if (email.isEmpty) {
        throw 'Email wajib diisi';
      }
      if (!validateEmail(email)) {
        throw 'Format email tidak valid. Gunakan format: user@example.com';
      }
      if (password.isEmpty) {
        throw 'Password wajib diisi';
      }
      if (password.length < 6) {
        throw 'Password minimal 6 karakter';
      }

      debugPrint('=== LOGIN START ===');
      debugPrint('Email: $email');

      // Call auth service
      final authResponse = await authService.signIn(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) throw 'Gagal login';

      debugPrint('✓ Login successful - User ID: ${user.id}');
      debugPrint('=== LOGIN SUCCESS ===');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('✗ Login error: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
