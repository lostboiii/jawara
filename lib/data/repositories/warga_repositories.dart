import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warga_profile.dart';
import '../models/keluarga.dart';

/// Abstract interface untuk Warga Repository
abstract class WargaRepository {
  /// Create warga profile baru
  Future<WargaProfile> createProfile({
    required String userId,
    required String namaLengkap,
    required String nik,
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

  /// Check if keluarga exists for user
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId);

  /// Create keluarga baru
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  });

  /// Get all keluarga
  Future<List<Map<String, dynamic>>> getAllKeluarga();

  /// Link warga to existing keluarga
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId);

  /// Get all rumah
  Future<List<Map<String, dynamic>>> getRumahList();

  /// Update rumah status to ditempati
  Future<void> updateRumahStatusToOccupied(String rumahId);
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
        'no_hp': noHp,
        'jenis_kelamin': jenisKelamin,
        'agama': agama,
        'golongan_darah': golonganDarah,
        'pekerjaan': pekerjaan,
        'foto_identitas_url': fotoIdentitasUrl,
        'role': 'Warga',
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

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(String kepalakeluargaId) async {
    try {
      final response = await client
          .from('keluarga')
          .select()
          .eq('kepala_keluarga_id', kepalakeluargaId)
          .single();

      return Keluarga.fromJson(response);
    } catch (e) {
      debugPrint('Error getting keluarga: $e');
      return null;
    }
  }

  @override
  @override
  Future<Keluarga> createKeluarga({
    required String kepalakeluargaId,
    required String nomorKk,
    String? rumahId,
  }) async {
    try {
      final response = await client
          .from('keluarga')
          .insert({
            'kepala_keluarga_id': kepalakeluargaId,
            'nomor_kk': nomorKk,
            'alamat': rumahId,
          })
          .select()
          .single();

      return Keluarga.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menyimpan keluarga: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    try {
      final response = await client
          .from('keluarga')
          .select('*, warga_profiles:kepala_keluarga_id(nama_lengkap)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data keluarga: $e');
    }
  }

  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    try {
      // Update warga profile to link to keluarga
      // Note: This requires a keluarga_id column in warga_profiles table
      await client.from('warga_profiles').update({'keluarga_id': keluargaId}).eq('id', wargaId);
    } catch (e) {
      throw Exception('Gagal menautkan warga ke keluarga: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRumahList() async {
    try {
      final response = await client
          .from('rumah')
          .select()
          .eq('status_rumah', 'kosong');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data rumah: $e');
    }
  }

  @override
  Future<void> updateRumahStatusToOccupied(String rumahId) async {
    try {
      await client
          .from('rumah')
          .update({'status_rumah': 'ditempati'})
          .eq('id', rumahId);
    } catch (e) {
      throw Exception('Gagal update status rumah: $e');
    }
  }
}
