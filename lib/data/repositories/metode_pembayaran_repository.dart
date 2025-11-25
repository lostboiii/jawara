// coverage:ignore-file
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/metode_pembayaran_model.dart';

abstract class MetodePembayaranRepository {
  Future<List<MetodePembayaranModel>> fetchAll();
  Future<MetodePembayaranModel> createMetodePembayaran({
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  });
  Future<MetodePembayaranModel> updateMetodePembayaran({
    required String id,
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  });
  Future<void> deleteMetodePembayaran(String id);
}

class SupabaseMetodePembayaranRepository
    implements MetodePembayaranRepository {
  SupabaseMetodePembayaranRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<MetodePembayaranModel>> fetchAll() async {
    try {
      final response = await _client
          .from('metode_pembayaran')
          .select()
          .order('nama_metode', ascending: true);

      final list = (response as List)
          .whereType<Map<String, dynamic>>()
          .map(MetodePembayaranModel.fromJson)
          .toList();

      return list;
    } catch (e, st) {
      debugPrint('fetchAll metode_pembayaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<MetodePembayaranModel> createMetodePembayaran({
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    try {
      final response = await _client
          .from('metode_pembayaran')
          .insert({
            'nama_metode': namaMetode,
            'nomor_rekening': nomorRekening,
            'nama_pemilik': namaPemilik,
            'foto_barcode': fotoBarcode,
            'thumbnail': thumbnail,
            'catatan': catatan,
          })
          .select()
          .single();

      return MetodePembayaranModel.fromJson(response);
    } catch (e, st) {
      debugPrint('createMetodePembayaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<MetodePembayaranModel> updateMetodePembayaran({
    required String id,
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    try {
      final response = await _client
          .from('metode_pembayaran')
          .update({
            'nama_metode': namaMetode,
            'nomor_rekening': nomorRekening,
            'nama_pemilik': namaPemilik,
            'foto_barcode': fotoBarcode,
            'thumbnail': thumbnail,
            'catatan': catatan,
          })
          .eq('id', id)
          .select()
          .single();

      return MetodePembayaranModel.fromJson(response);
    } catch (e, st) {
      debugPrint('updateMetodePembayaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteMetodePembayaran(String id) async {
    try {
      await _client.from('metode_pembayaran').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('deleteMetodePembayaran error: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
