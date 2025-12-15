import '../models/tagih_iuran_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';


abstract class TagihIuranRepository {
  Future<List<TagihIuranModel>> fetchAll();
  Future<TagihIuranModel?> fetchById(String id);
  Future<TagihIuranModel> createTagihIuran({
    required double jumlah,
    required String statusTagihan,
    required String kategoriId,
    DateTime? tanggalTagihan,
    DateTime? tanggalBayar,
    String? buktiBayar,
  });

  Future<TagihIuranModel> updateTagihIuran({
     required String id,
    required double jumlah,
    required String statusTagihan,
    required String kategoriId,
    DateTime? tanggalTagihan,
    DateTime? tanggalBayar,
    String? buktiBayar,
  });
  Future<void> deleteTagihIuran(String id);
  
  // Methods untuk pembayaran iuran
  Future<String> uploadBuktiBayar(String path, List<int> fileBytes);
  Future<void> bayarTagihan({
    required String tagihanId,
    required String? metodePembayaranId,
    String? buktiBayar,
  });
}

  class SupabaseTagihIuranRepository implements TagihIuranRepository {
  SupabaseTagihIuranRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<TagihIuranModel>> fetchAll() async {
    try {
      final response = await _client.from('tagih_iuran').select();
      return (response as List).map((e) => TagihIuranModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat tagihan: $e');
    }
  }

  @override
  Future<TagihIuranModel?> fetchById(String id) async {
    try {
      final response = await _client
          .from('tagih_iuran')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TagihIuranModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memuat detail tagihan: $e');
    }
  }

  Future<void> create(TagihIuranModel data) async {
    await _client.from('tagih_iuran').insert(data.toJson());
  }

  Future<void> update(String id, TagihIuranModel data) async {
    await _client.from('tagih_iuran').update(data.toJson()).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('tagih_iuran').delete().eq('id', id);
  }
  
  @override
  Future<TagihIuranModel> createTagihIuran({
    required double jumlah, 
    required String statusTagihan, 
    required String kategoriId, 
    DateTime? tanggalTagihan, 
    DateTime? tanggalBayar, 
    String? buktiBayar
  }) async {
    final data = {
      'jumlah': jumlah,
      'status_tagihan': statusTagihan,
      'kategori_id': kategoriId,
      'tanggal_tagihan': tanggalTagihan?.toIso8601String(),
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'bukti_bayar': buktiBayar,
    };

    final response = await _client
        .from('tagih_iuran')
        .insert(data)
        .select()
        .single();

    return TagihIuranModel.fromJson(response);
  }
  
  @override
  Future<void> deleteTagihIuran(String id) async {
    await _client.from('tagih_iuran').delete().eq('id', id);
  }
  
  @override
  Future<TagihIuranModel> updateTagihIuran({
    required String id, 
    required double jumlah, 
    required String statusTagihan, 
    required String kategoriId, 
    DateTime? tanggalTagihan, 
    DateTime? tanggalBayar, 
    String? buktiBayar
  }) async {
    final data = {
      'jumlah': jumlah,
      'status_tagihan': statusTagihan,
      'kategori_id': kategoriId,
      'tanggal_tagihan': tanggalTagihan?.toIso8601String(),
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'bukti_bayar': buktiBayar,
    };

    final response = await _client
        .from('tagih_iuran')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return TagihIuranModel.fromJson(response);
  }

  @override
  Future<String> uploadBuktiBayar(String path, List<int> fileBytes) async {
    try {
      final fileName = path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'iuran/$timestamp-$fileName';

      debugPrint('📤 Uploading file: $filePath');
      debugPrint('📦 File size: ${fileBytes.length} bytes');

      // ✅ convert List<int> → Uint8List
      final Uint8List bytes = Uint8List.fromList(fileBytes);

      await _client.storage.from('bukti_pembayaran').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from('bukti_pembayaran').getPublicUrl(filePath);
      
      debugPrint('✅ Upload success: $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      throw Exception('Gagal mengupload bukti: $e');
    }
  }

  @override
  Future<void> bayarTagihan({
    required String tagihanId,
    required String? metodePembayaranId,
    String? buktiBayar,
  }) async {
    try {
      final data = {
        'status_tagihan': 'sudah_bayar',
        'tanggal_bayar': DateTime.now().toIso8601String(),
        'metode_pembayaran_id': metodePembayaranId,
        'bukti_bayar': buktiBayar,
      };

      await _client
          .from('tagih_iuran')
          .update(data)
          .eq('id', tagihanId);

      debugPrint('✅ Tagihan $tagihanId berhasil dibayar');
    } catch (e) {
      debugPrint('❌ Error bayar tagihan: $e');
      throw Exception('Gagal memproses pembayaran: $e');
    }
  }
}
