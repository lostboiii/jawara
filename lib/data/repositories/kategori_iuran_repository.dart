import 'package:jawara/data/models/kategori_iuran_model.dart';

import '../models/kategori_iuran_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


abstract class KategoriIuranRepository {
  Future<List<KategoriIuranModel>> fetchAll();
  Future<KategoriIuranModel> createKategoriIuran({
    required String namaIuran,
    required String kategoriIuran,
  });

  Future<KategoriIuranModel> updateKategoriIuran({
    required String id,
    required String namaIuran,
    required String kategoriIuran,
  });
  Future<void> deleteKategoriIuran(String id);
}

  class SupabaseKategoriIuranRepository implements KategoriIuranRepository {
  SupabaseKategoriIuranRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<List<KategoriIuranModel>> getAll() async {
    final response = await _client.from('kategori_iuran').select();
    return (response as List).map((e) => KategoriIuranModel.fromJson(e)).toList();
  }


  Future<void> create(KategoriIuranModel data) async {
    await _client.from('kategori_iuran').insert(data.toJson());
  }

  Future<void> update(String id, KategoriIuranModel data) async {
    await _client.from('kategori_iuran').update(data.toJson()).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('kategori_iuran').delete().eq('id', id);
  }
  
  @override
  Future<KategoriIuranModel> createKategoriIuran({ required String namaIuran, required String kategoriIuran}) {
    // TODO: implement createKategoriIuran
    throw UnimplementedError();
  }
  
  @override
  Future<void> deleteKategoriIuran(String id) {
    // TODO: implement deleteKategoriIuran
    throw UnimplementedError();
  }
  
  @override
  Future<List<KategoriIuranModel>> fetchAll() {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }
  
  @override
  Future<KategoriIuranModel> updateKategoriIuran({required String id, required String namaIuran, required String kategoriIuran}) {
    // TODO: implement updateKategoriIuran
    throw UnimplementedError();
  }
}
