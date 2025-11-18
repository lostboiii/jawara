import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kegiatan_model.dart';

abstract class KegiatanRepository {
  Future<List<KegiatanModel>> fetchAll();
  Future<KegiatanModel> createKegiatan({
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  });
  Future<KegiatanModel> updateKegiatan({
    required String id,
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  });
  Future<void> deleteKegiatan(String id);
}

class SupabaseKegiatanRepository implements KegiatanRepository {
  SupabaseKegiatanRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<KegiatanModel>> fetchAll() async {
    try {
      final response = await _client
          .from('kegiatan')
          .select()
          .order('tanggal_kegiatan', ascending: true);

      final list = (response as List)
          .whereType<Map<String, dynamic>>()
          .map(KegiatanModel.fromJson)
          .toList();

      return list;
    } catch (e, st) {
      debugPrint('fetchAll kegiatan error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<KegiatanModel> createKegiatan({
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    try {
      final payload = {
        'nama_kegiatan': nama,
        'kategori_kegiatan': kategori,
        'tanggal_kegiatan': _formatDate(tanggal),
        'lokasi_kegiatan': lokasi,
        'penanggung_jawab': penanggungJawab,
        'deskripsi': deskripsi,
      }..removeWhere((key, value) => value == null);

      final response = await _client
          .from('kegiatan')
          .insert(payload)
          .select()
          .single();

      return KegiatanModel.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('createKegiatan error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<KegiatanModel> updateKegiatan({
    required String id,
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    try {
      final payload = {
        'nama_kegiatan': nama,
        'kategori_kegiatan': kategori,
        'tanggal_kegiatan': _formatDate(tanggal),
        'lokasi_kegiatan': lokasi,
        'penanggung_jawab': penanggungJawab,
        'deskripsi': deskripsi,
      }..removeWhere((key, value) => value == null);

      final response = await _client
          .from('kegiatan')
          .update(payload)
          .eq('id', id)
          .select()
          .single();

      return KegiatanModel.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      debugPrint('updateKegiatan error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteKegiatan(String id) async {
    try {
      await _client.from('kegiatan').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('deleteKegiatan error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toIso8601String().split('T').first;
  }
}
