import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pemasukan_model.dart';
import 'dart:typed_data';

abstract class PemasukanRepository {
  Future<List<PemasukanModel>> fetchAll();
  Future<PemasukanModel?> fetchById(String id);
  Future<PemasukanModel> createPemasukan({
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  });
  Future<PemasukanModel> updatePemasukan({
    required String id,
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  });
  Future<void> deletePemasukan(String id);
  Future<List<PemasukanModel>> filterPemasukan({
    String? nama,
    String? kategori,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<String>> getCategories();
  Future<String> uploadBukti(String path, List<int> fileBytes);
}

class SupabasePemasukanRepository implements PemasukanRepository {
  SupabasePemasukanRepository({required SupabaseClient client}) : _supabase = client;

  final SupabaseClient _supabase;

  // Fetch all pemasukan
  Future<List<PemasukanModel>> fetchAll() async {
    try {
      final response = await _supabase
          .from('pemasukan_lain')
          .select()
          .order('tanggal_pemasukan', ascending: false);

      return (response as List)
          .map((json) => PemasukanModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat data pemasukan: $e');
    }
  }

  // Fetch pemasukan by ID
  Future<PemasukanModel?> fetchById(String id) async {
    try {
      final response = await _supabase
          .from('pemasukan_lain')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return PemasukanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memuat detail pemasukan: $e');
    }
  }

  // Create new pemasukan
  Future<PemasukanModel> createPemasukan({
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    try {
      final data = {
        'nama_pemasukan': nama_pemasukan,
        'tanggal_pemasukan': tanggal_pemasukan.toIso8601String(),
        'kategori_pemasukan': kategori_pemasukan,
        'jumlah': jumlah,
        'bukti_pemasukan': bukti_pemasukan,
      };

      final response = await _supabase
          .from('pemasukan_lain')
          .insert(data)
          .select()
          .single();

      return PemasukanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan pemasukan: $e');
    }
  }

  // Update existing pemasukan
  Future<PemasukanModel> updatePemasukan({
    required String id,
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    try {
      final data = {
        'nama_pemasukan': nama_pemasukan,
        'tanggal_pemasukan': tanggal_pemasukan.toIso8601String(),
        'kategori_pemasukan': kategori_pemasukan,
        'jumlah': jumlah,
        'bukti_pemasukan': bukti_pemasukan,
      };

      final response = await _supabase
          .from('pemasukan_lain')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return PemasukanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate pemasukan: $e');
    }
  }

  // Delete pemasukan
  Future<void> deletePemasukan(String id) async {
    try {
      await _supabase.from('pemasukan').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus pemasukan: $e');
    }
  }

  // Filter pemasukan
  Future<List<PemasukanModel>> filterPemasukan({
    String? nama,
    String? kategori,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase.from('pemasukan_lain').select();

      if (nama != null && nama.isNotEmpty) {
        query = query.ilike('nama_pemasukan', '%$nama%');
      }

      if (kategori != null && kategori.isNotEmpty) {
        query = query.eq('kategori_pemasukan', kategori);
      }

      if (fromDate != null) {
        query = query.gte('tanggal_pemasukan', fromDate.toIso8601String());
      }

      if (toDate != null) {
        final endDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
        query = query.lte('tanggal_pemasukan', endDate.toIso8601String());
      }

      final response = await query.order('tanggal_pemasukan', ascending: false);

      return (response as List)
          .map((json) => PemasukanModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal memfilter pemasukan: $e');
    }
  }

  // Get unique categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('pemasukan_lain')
          .select('kategori_pemasukan')
          .order('kategori_pemasukan');

      final categories = (response as List)
          .map((e) => e['kategori_pemasukan'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      throw Exception('Gagal memuat kategori: $e');
    }
  }

  // Upload bukti pemasukan
  Future<String> uploadBukti(String path, List<int> fileBytes) async {
    try {
      final fileName = path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'pemasukan/$timestamp-$fileName';

      print('📤 Uploading file: $filePath');
      print('📦 File size: ${fileBytes.length} bytes');

      // ✅ convert List<int> → Uint8List
      final Uint8List bytes = Uint8List.fromList(fileBytes);

      await _supabase.storage.from('bukti').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _supabase.storage.from('bukti').getPublicUrl(filePath);
      
      print('✅ Upload success: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Gagal mengupload bukti: $e');
    }
  }
}
