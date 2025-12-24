import 'package:supabase_flutter/supabase_flutter.dart';

class IuranRepository {
  final SupabaseClient _client;

  IuranRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTagihan() async {
    final response = await _client.from('tagih_iuran').select('''
          *,
          keluarga:keluarga_id (
            id,
            nomor_kk,
            kepala_keluarga_id,
            warga_profiles!keluarga_kepala_keluarga_id_fkey (
              nama_lengkap
            )
          ),
          kategori_iuran:kategori_id (
            nama_iuran
          )
        ''').order('tanggal_tagihan', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getKategoriIuran() async {
    final response = await _client
        .from('kategori_iuran')
        .select('id, nama_iuran, kategori_iuran')
        .order('nama_iuran');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllKeluargaId() async {
    final response = await _client.from('keluarga').select('id');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertBatchTagihan(List<Map<String, dynamic>> data) async {
    await _client.from('tagih_iuran').insert(data);
  }
}