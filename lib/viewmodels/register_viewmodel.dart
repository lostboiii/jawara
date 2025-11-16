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
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    required String password,
    required String confirmPassword,
    required String peranKeluarga,
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
      if (agama.isEmpty) {
        throw 'Agama wajib dipilih';
      }
      if (golonganDarah.isEmpty) {
        throw 'Golongan darah wajib dipilih';
      }
      if (pekerjaan.isEmpty) {
        throw 'Pekerjaan wajib diisi';
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
        noHp: noHp,
        jenisKelamin: jenisKelamin,
        agama: agama,
        golonganDarah: golonganDarah,
        pekerjaan: pekerjaan,
        peranKeluarga: peranKeluarga,
        fotoIdentitasUrl: fotoUrl,
      );

      debugPrint('✓ Profile created successfully');
      debugPrint('=== REGISTER SUCCESS ===');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      final errorMessage = e.toString();
      
      // Handle rate limit errors
      if (errorMessage.contains('429') || errorMessage.contains('rate limit') || errorMessage.contains('over_email_send_rate_limit')) {
        _error = 'Terlalu banyak percobaan. Silakan tunggu beberapa menit sebelum mencoba lagi.';
      } else if (errorMessage.contains('email')) {
        _error = 'Email sudah terdaftar atau terjadi kesalahan. Gunakan email lain.';
      } else {
        _error = errorMessage;
      }
      
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

  /// Check if keluarga exists for this user
  Future<bool> checkKeluargaExists(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final keluarga = await wargaRepository.getKeluargaByKepalakeluargaId(userId);

      _isLoading = false;
      notifyListeners();

      return keluarga != null;
    } catch (e) {
      _error = 'Gagal memeriksa data keluarga: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create keluarga data
  Future<bool> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await wargaRepository.createKeluarga(
        kepalakeluargaId: kepalakeluargaId,
        nomorKk: nomorKk,
        rumahId: rumahId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register warga with keluarga (combined single submit)
  Future<bool> registerWargaWithKeluarga({
    required String namaLengkap,
    required String nik,
    required String email,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    required String password,
    required String confirmPassword,
    File? fotoIdentitas,
    required String peranKeluarga,
    required String nomorKk,
    String? rumahId,
    String? keluargaId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // First, register warga normally
      final wargaRegistered = await registerWarga(
        namaLengkap: namaLengkap,
        nik: nik,
        email: email,
        noHp: noHp,
        jenisKelamin: jenisKelamin,
        agama: agama,
        golonganDarah: golonganDarah,
        pekerjaan: pekerjaan,
        password: password,
        confirmPassword: confirmPassword,
        peranKeluarga: peranKeluarga,
        fotoIdentitas: fotoIdentitas,
      );

      if (!wargaRegistered) {
        return false;
      }

      final userId = _currentProfile?.id;
      if (userId == null) throw 'Gagal mendapatkan ID pengguna';

      // Handle keluarga based on peran
      if (peranKeluarga == 'kepala keluarga') {
        // Validate rumahId is selected
        if (rumahId == null || rumahId.isEmpty) {
          throw 'Alamat/Rumah harus dipilih';
        }

        // Create new keluarga with this user as kepala keluarga
        final keluargaCreated = await createKeluarga(
          kepalakeluargaId: userId,
          nomorKk: nomorKk,
          rumahId: rumahId,
        );

        if (!keluargaCreated) {
          throw 'Gagal membuat data keluarga';
        }

        // Update rumah status to ditempati
        await wargaRepository.updateRumahStatusToOccupied(rumahId);
      } else {
        // User is joining existing keluarga
        if (keluargaId == null || keluargaId.isEmpty) {
          throw 'Keluarga harus dipilih untuk peran selain kepala keluarga';
        }

        // Update the warga profile to link to keluarga
        try {
          await wargaRepository.linkWargaToKeluarga(userId, keluargaId);
          debugPrint('✓ Warga successfully linked to keluarga');
        } catch (linkError) {
          debugPrint('⚠ Error linking warga to keluarga: $linkError');
          // If linking fails, still consider registration success since warga is created
          // The linking can be done later through admin panel if needed
          debugPrint('⚠ Warga registered successfully. Link to keluarga will need manual setup.');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('429') || errorMessage.contains('rate limit') || errorMessage.contains('over_email_send_rate_limit')) {
        _error = 'Terlalu banyak percobaan. Silakan tunggu beberapa menit sebelum mencoba lagi.';
      } else if (errorMessage.contains('email')) {
        _error = 'Email sudah terdaftar atau terjadi kesalahan. Gunakan email lain.';
      } else {
        _error = errorMessage;
      }

      _isLoading = false;
      debugPrint('✗ Register with keluarga error: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Get list of all keluarga
  Future<List<Map<String, dynamic>>> getKeluargaList() async {
    try {
      return await wargaRepository.getAllKeluarga();
    } catch (e) {
      debugPrint('Error fetching keluarga list: $e');
      return [];
    }
  }

  /// Get list of all rumah
  Future<List<Map<String, dynamic>>> getRumahList() async {
    try {
      return await wargaRepository.getRumahList();
    } catch (e) {
      debugPrint('Error fetching rumah list: $e');
      return [];
    }
  }
}
