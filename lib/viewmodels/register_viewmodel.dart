import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jawara/core/services/auth_services.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/data/models/warga_profile.dart';

/// ViewModel untuk halaman register
class RegisterViewModel extends ChangeNotifier {
  final AuthService authService;
  final WargaRepository wargaRepository;

  RegisterViewModel({
    required this.authService,
    required this.wargaRepository,
  });

  /// State management
  bool _isLoading = false;
  String? _error;
  WargaProfile? _currentProfile;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  WargaProfile? get currentProfile => _currentProfile;
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

  /// Validate password
  String? validatePassword(String password, String confirmPassword) {
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (password != confirmPassword) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Register warga baru
  Future<bool> registerWarga({
    required String namaLengkap,
    required String nik,
    required String email,
    required String noHp,
    required String jenisKelamin,
    required String password,
    required String confirmPassword,
    File? fotoIdentitas,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validasi input
      if (namaLengkap.isEmpty) {
        throw 'Nama lengkap wajib diisi';
      }
      if (nik.isEmpty) {
        throw 'NIK wajib diisi';
      }
      if (!validateEmail(email)) {
        throw 'Format email tidak valid. Gunakan format: user@example.com';
      }
      if (noHp.isEmpty) {
        throw 'No telepon wajib diisi';
      }
      if (jenisKelamin.isEmpty) {
        throw 'Jenis kelamin wajib dipilih';
      }

      final passwordError = validatePassword(password, confirmPassword);
      if (passwordError != null) {
        throw passwordError;
      }

      debugPrint('=== REGISTER START ===');
      debugPrint('Email: $email');

      // 1. Auth Sign up
      final authResponse = await authService.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) throw 'Gagal membuat akun auth';

      debugPrint('✓ Auth successful - User ID: ${user.id}');

      // 2. Upload foto ke storage (jika ada)
      String? fotoUrl;
      if (fotoIdentitas != null) {
        try {
          debugPrint('Uploading foto...');
          fotoUrl = await wargaRepository.uploadFoto(
            userId: user.id,
            fotoFile: fotoIdentitas,
          );
          debugPrint('✓ Foto uploaded: $fotoUrl');
        } catch (e) {
          debugPrint('✗ Foto upload error: $e');
          // Continue without foto if upload fails
          fotoUrl = null;
        }
      }

      // 3. Create profile di warga_profiles
      debugPrint('Creating warga profile...');
      _currentProfile = await wargaRepository.createProfile(
        userId: user.id,
        namaLengkap: namaLengkap,
        nik: nik,
        email: email,
        noHp: noHp,
        jenisKelamin: jenisKelamin,
        fotoIdentitasUrl: fotoUrl,
      );

      debugPrint('✓ Profile created successfully');
      debugPrint('=== REGISTER SUCCESS ===');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('✗ Register error: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _error = null;
    _currentProfile = null;
    notifyListeners();
  }
}
