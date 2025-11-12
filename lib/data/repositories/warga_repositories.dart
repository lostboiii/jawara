import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warga_profile.dart';

/// Abstract interface untuk Warga Repository
abstract class WargaRepository {
  /// Create warga profile baru
  Future<WargaProfile> createProfile({
    required String userId,
    required String namaLengkap,
    required String nik,
    required String email,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    String? fotoIdentitasUrl,
  });

  /// Get profile berdasarkan user ID
  Future<WargaProfile?> getProfileById(String userId);

  /// Get profile berdasarkan email
  Future<WargaProfile?> getProfileByEmail(String email);

  /// Update profile
  Future<WargaProfile> updateProfile(WargaProfile profile);

  /// Delete profile
  Future<void> deleteProfile(String userId);

  /// Upload foto ke storage
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  });

  /// Get public URL foto
  String getFotoPublicUrl(String filePath);
}

/// Implementasi Warga Repository menggunakan Supabase
class SupabaseWargaRepository implements WargaRepository {
  final SupabaseClient client;
  static const String _fotoBucket = 'foto_identitas';
  static const String _fotoFolder = 'ktp';

  SupabaseWargaRepository({required this.client});

  @override
  Future<WargaProfile> createProfile({
    required String userId,
    required String namaLengkap,
    required String nik,
    required String email,
    required String noHp,
    required String jenisKelamin,
    required String agama,
    required String golonganDarah,
    required String pekerjaan,
    String? fotoIdentitasUrl,
  }) async {
    try {
      final wargaData = {
        'id': userId,
        'nama_lengkap': namaLengkap,
        'nik': nik,
        'email': email,
        'no_hp': noHp,
        'jenis_kelamin': jenisKelamin,
        'agama': agama,
        'golongan_darah': golonganDarah,
        'pekerjaan': pekerjaan,
        'foto_identitas_url': fotoIdentitasUrl,
        'role': 'warga',
      };

      final insertResponse = await client
          .from('warga_profiles')
          .insert(wargaData)
          .select()
          .single();

      return WargaProfile.fromJson(insertResponse);
    } catch (e) {
      throw 'Gagal membuat profile: $e';
    }
  }

  @override
  Future<WargaProfile?> getProfileById(String userId) async {
    try {
      final response = await client
          .from('warga_profiles')
          .select()
          .eq('id', userId)
          .single();

      return WargaProfile.fromJson(response);
    } catch (e) {
      if (e.toString().contains('no rows')) {
        return null;
      }
      throw 'Gagal mengambil profile: $e';
    }
  }

  @override
  Future<WargaProfile?> getProfileByEmail(String email) async {
    try {
      final response = await client
          .from('warga_profiles')
          .select()
          .eq('email', email)
          .single();

      return WargaProfile.fromJson(response);
    } catch (e) {
      if (e.toString().contains('no rows')) {
        return null;
      }
      throw 'Gagal mengambil profile: $e';
    }
  }

  @override
  Future<WargaProfile> updateProfile(WargaProfile profile) async {
    try {
      final updateResponse = await client
          .from('warga_profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return WargaProfile.fromJson(updateResponse);
    } catch (e) {
      throw 'Gagal update profile: $e';
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await client
          .from('warga_profiles')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw 'Gagal delete profile: $e';
    }
  }

  @override
  Future<String> uploadFoto({
    required String userId,
    required File fotoFile,
  }) async {
    try {
      final filePath = '$_fotoFolder/$userId';

      // Upload file directly
      await client.storage
          .from(_fotoBucket)
          .upload(
            filePath,
            fotoFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Return public URL
      return getFotoPublicUrl(filePath);
    } catch (e) {
      throw 'Gagal upload foto: $e';
    }
  }

  @override
  String getFotoPublicUrl(String filePath) {
    return client.storage
        .from(_fotoBucket)
        .getPublicUrl(filePath);
  }
}
