import 'dart:io';
// coverage:ignore-file
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
    required String peranKeluarga,
    String? fotoIdentitasUrl,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikan,
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

  /// Get all warga with details
  Future<List<Map<String, dynamic>>> getAllWarga();

  /// Link warga to existing keluarga
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId);

  /// Get all rumah
  Future<List<Map<String, dynamic>>> getRumahList();

  /// Update rumah status to ditempati
  Future<void> updateRumahStatusToOccupied(String rumahId);

  /// Create mutasi keluarga
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  });

  /// Get all mutasi list
  Future<List<Map<String, dynamic>>> getMutasiList();
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
    required String peranKeluarga,
    String? fotoIdentitasUrl,
    String? tempatLahir,
    String? tanggalLahir,
    String? pendidikan,
  }) async {
    try {
      final wargaData = {
        'id': userId,
        'nama_lengkap': namaLengkap,
        'nik': nik,
        'no_telepon': noHp,
        'jenis_kelamin': jenisKelamin,
        'agama': agama,
        'golongan_darah': golonganDarah,
        'pekerjaan': pekerjaan,
        'peran_keluarga': peranKeluarga,
        'foto_identitas_url': fotoIdentitasUrl,
        'role': 'Warga',
        if (tempatLahir != null) 'tempat_lahir': tempatLahir,
        if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir,
        if (pendidikan != null) 'pendidikan': pendidikan,
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
      await client.from('warga_profiles').delete().eq('id', userId);
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
      await client.storage.from(_fotoBucket).upload(
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
    return client.storage.from(_fotoBucket).getPublicUrl(filePath);
  }

  @override
  Future<Keluarga?> getKeluargaByKepalakeluargaId(
      String kepalakeluargaId) async {
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

      final keluarga = Keluarga.fromJson(response);
      debugPrint(
          'Created keluarga ${keluarga.id} for kepala $kepalakeluargaId');

      try {
        await client
            .from('warga_profiles')
            .update({'keluarga_id': keluarga.id}).eq('id', kepalakeluargaId);
        debugPrint(
            'Linked kepala keluarga $kepalakeluargaId to keluarga ${keluarga.id}');
      } catch (e) {
        debugPrint('Failed to link kepala keluarga $kepalakeluargaId: $e');
      }

      if (rumahId != null && rumahId.isNotEmpty) {
        try {
          await client.from('riwayat_penghuni').insert({
            'alamat_id': rumahId,
            'keluarga_id': keluarga.id,
          });
          debugPrint(
              'Logged riwayat penghuni for keluarga ${keluarga.id} at rumah $rumahId');
        } catch (e) {
          debugPrint(
              'Failed to log riwayat penghuni for keluarga ${keluarga.id}: $e');
        }
      }

      return keluarga;
    } catch (e) {
      throw Exception('Gagal menyimpan keluarga: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllKeluarga() async {
    try {
      final response = await client
          .from('keluarga')
          .select('*, rumah:alamat(alamat)')
          .order('created_at', ascending: false);

      final keluargaList = List<Map<String, dynamic>>.from(response);

      // Fetch nama kepala keluarga untuk setiap keluarga
      for (var keluarga in keluargaList) {
        // Extract nama rumah from rumah object
        if (keluarga['rumah'] != null) {
          final rumahData = keluarga['rumah'];
          keluarga['nama_rumah'] = rumahData['alamat'] ?? '';
        } else {
          keluarga['nama_rumah'] = '';
        }
        
        if (keluarga['kepala_keluarga_id'] != null) {
          try {
            final wargaResponse = await client
                .from('warga_profiles')
                .select('nama_lengkap')
                .eq('id', keluarga['kepala_keluarga_id'])
                .single();
            keluarga['warga_profiles'] = wargaResponse;
            // Add nama_kepala_keluarga for easy access in dropdown
            keluarga['nama_kepala_keluarga'] = wargaResponse['nama_lengkap'];
          } catch (e) {
            debugPrint('Gagal fetch nama kepala keluarga: $e');
            keluarga['warga_profiles'] = {
              'nama_lengkap': 'Nama tidak diketahui'
            };
            keluarga['nama_kepala_keluarga'] = 'Nama tidak diketahui';
          }
        } else {
          keluarga['nama_kepala_keluarga'] = 'Tidak ada kepala keluarga';
        }
      }

      debugPrint('getAllKeluarga result: $keluargaList');
      return keluargaList;
    } catch (e) {
      debugPrint('Gagal mengambil data keluarga: $e');
      throw Exception('Gagal mengambil data keluarga: $e');
    }
  }

  @override
  @override
  Future<void> linkWargaToKeluarga(String wargaId, String keluargaId) async {
    try {
      debugPrint('Linking warga $wargaId to keluarga $keluargaId');

      // Update warga profile to link to keluarga
      final result = await client
          .from('warga_profiles')
          .update({'keluarga_id': keluargaId}).eq('id', wargaId);

      debugPrint('Successfully linked warga to keluarga. Result: $result');
    } catch (e) {
      final errorMsg = e.toString();
      debugPrint('Error linking warga to keluarga: $errorMsg');

      // Check if it's a column not found error
      if (errorMsg.contains('keluarga_id') && errorMsg.contains('column')) {
        throw Exception(
            'Database belum ter-setup. Kolom keluarga_id tidak ditemukan di tabel warga_profiles. Hubungi administrator.');
      }

      throw Exception('Gagal menautkan warga ke keluarga: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRumahList() async {
    try {
      final response =
          await client.from('rumah').select().eq('status_rumah', 'kosong');
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
          .update({'status_rumah': 'ditempati'}).eq('id', rumahId);
    } catch (e) {
      throw Exception('Gagal update status rumah: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWarga() async {
    try {
      // Ambil semua warga
      final response = await client.from('warga_profiles').select('''
            id,
            nama_lengkap,
            nik,
            no_telepon,
            jenis_kelamin,
            agama,
            golongan_darah,
            pekerjaan,
            peran_keluarga,
            keluarga_id
          ''');

      final wargaList = List<Map<String, dynamic>>.from(response);

      // Fetch nama kepala keluarga untuk setiap warga yang punya keluarga
      for (var warga in wargaList) {
        if (warga['keluarga_id'] != null) {
          try {
            // Ambil data keluarga
            final keluargaResponse = await client
                .from('keluarga')
                .select('kepala_keluarga_id')
                .eq('id', warga['keluarga_id'])
                .single();

            if (keluargaResponse['kepala_keluarga_id'] != null) {
              // Ambil nama kepala keluarga
              final kepalaKeluargaResponse = await client
                  .from('warga_profiles')
                  .select('nama_lengkap')
                  .eq('id', keluargaResponse['kepala_keluarga_id'])
                  .single();

              warga['keluarga'] = {
                'warga_profiles': {
                  'nama_lengkap': kepalaKeluargaResponse['nama_lengkap']
                }
              };
            }
          } catch (e) {
            debugPrint(
                'Gagal fetch nama kepala keluarga untuk warga ${warga['id']}: $e');
            // Jika gagal, biarkan keluarga null
          }
        }
      }

      return wargaList;
    } catch (e) {
      throw Exception('Gagal mengambil data warga: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createMutasi({
    required String keluargaId,
    required String rumahId,
    required DateTime tanggalMutasi,
    required String alasanMutasi,
  }) async {
    try {
      final mutasiData = {
        'keluarga_id': keluargaId,
        'rumah_id': rumahId,
        'tanggal_mutasi': tanggalMutasi.toIso8601String(),
        'alasan_mutasi': alasanMutasi,
      };

      final response = await client
          .from('mutasi_keluarga')
          .insert(mutasiData)
          .select()
          .single();

      debugPrint('Created mutasi for keluarga $keluargaId to rumah $rumahId');
      return response;
    } catch (e) {
      debugPrint('Error creating mutasi: $e');
      throw Exception('Gagal membuat mutasi keluarga: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMutasiList() async {
    try {
      final response = await client
          .from('mutasi_keluarga')
          .select('''
            *,
            keluarga:keluarga_id(nomor_kk),
            rumah:rumah_id(alamat)
          ''')
          .order('tanggal_mutasi', ascending: false);

      final mutasiList = List<Map<String, dynamic>>.from(response);

      // Process the joined data
      for (var mutasi in mutasiList) {
        // Extract keluarga data
        if (mutasi['keluarga'] != null) {
          mutasi['keluarga_nomor_kk'] = mutasi['keluarga']['nomor_kk'] ?? '';
        } else {
          mutasi['keluarga_nomor_kk'] = '';
        }

        // Extract rumah data
        if (mutasi['rumah'] != null) {
          mutasi['rumah_alamat'] = mutasi['rumah']['alamat'] ?? '';
        } else {
          mutasi['rumah_alamat'] = '';
        }
      }

      debugPrint('getMutasiList result: $mutasiList');
      return mutasiList;
    } catch (e) {
      debugPrint('Error getting mutasi list: $e');
      throw Exception('Gagal mengambil data mutasi keluarga: $e');
    }
  }
}
