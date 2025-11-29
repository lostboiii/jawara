import '../models/tagih_iuran_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


abstract class TagihIuranRepository {
  Future<List<TagihIuranModel>> fetchAll();
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
}

  class SupabaseTagihIuranRepository implements TagihIuranRepository {
  SupabaseTagihIuranRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<List<TagihIuranModel>> getAll() async {
    final response = await _client.from('tagih_iuran').select();
    return (response as List).map((e) => TagihIuranModel.fromJson(e)).toList();
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
  Future<TagihIuranModel> createTagihIuran({required double jumlah, required String statusTagihan, required String kategoriId, DateTime? tanggalTagihan, DateTime? tanggalBayar, String? buktiBayar}) {
    // TODO: implement createTagihIuran
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteTagihIuran(String id) {
    // TODO: implement deleteTagihIuran
    throw UnimplementedError();
  }
  
  @override
  Future<List<TagihIuranModel>> fetchAll() {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }
  
  @override
  Future<TagihIuranModel> updateTagihIuran({required String id, required double jumlah, required String statusTagihan, required String kategoriId, DateTime? tanggalTagihan, DateTime? tanggalBayar, String? buktiBayar}) {
    // TODO: implement updateTagihIuran
    throw UnimplementedError();
  }
}
