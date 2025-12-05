// coverage:ignore-file
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pengeluaran_model.dart';

abstract class PengeluaranRepository {
  Future<List<PengeluaranModel>> fetchAll();
  Future<PengeluaranModel> createPengeluaran({
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  });
  Future<PengeluaranModel> updatePengeluaran({
    required String id,
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  });
  Future<void> deletePengeluaran(String id);
  Future<String> uploadBukti(String path, List<int> fileBytes);
}

class SupabasePengeluaranRepository implements PengeluaranRepository {
  SupabasePengeluaranRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<PengeluaranModel>> fetchAll() async {
    try {
      final response = await _client
          .from('pengeluaran')
          .select()
          .order('tanggal_pengeluaran', ascending: false);

      final list = (response as List)
          .whereType<Map<String, dynamic>>()
          .map(PengeluaranModel.fromJson)
          .toList();

      return list;
    } catch (e, st) {
      debugPrint('fetchAll pengeluaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<PengeluaranModel> createPengeluaran({
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    try {
      final response = await _client
          .from('pengeluaran')
          .insert({
            'nama_pengeluaran': nama,
            'tanggal_pengeluaran': tanggal.toIso8601String(),
            'kategori_pengeluaran': kategori,
            'jumlah': jumlah,
            'bukti_pengeluaran': bukti,
          })
          .select()
          .single();

      return PengeluaranModel.fromJson(response);
    } catch (e, st) {
      debugPrint('createPengeluaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<PengeluaranModel> updatePengeluaran({
    required String id,
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    try {
      final response = await _client
          .from('pengeluaran')
          .update({
            'nama_pengeluaran': nama,
            'tanggal_pengeluaran': tanggal.toIso8601String(),
            'kategori_pengeluaran': kategori,
            'jumlah': jumlah,
            'bukti_pengeluaran': bukti,
          })
          .eq('id', id)
          .select()
          .single();

      return PengeluaranModel.fromJson(response);
    } catch (e, st) {
      debugPrint('updatePengeluaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> deletePengeluaran(String id) async {
    try {
      await _client.from('pengeluaran').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('deletePengeluaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<String> uploadBukti(String path, List<int> fileBytes) async {
    try {
      final fileName = path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'pengeluaran/$timestamp-$fileName';

      print('📤 Uploading file: $filePath');
      print('📦 File size: ${fileBytes.length} bytes');

      final bytes = Uint8List.fromList(fileBytes);

      await _client.storage.from('bukti').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from('bukti').getPublicUrl(filePath);
      
      print('✅ Upload success: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Gagal mengupload bukti: $e');
    }
  }
}
