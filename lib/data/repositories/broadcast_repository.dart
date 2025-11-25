// coverage:ignore-file
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/broadcast_model.dart';

abstract class BroadcastRepository {
  Future<List<BroadcastModel>> fetchAll();
  Future<BroadcastModel> createBroadcast({
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  });
  Future<BroadcastModel> updateBroadcast({
    required String id,
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  });
  Future<void> deleteBroadcast(String id);
}

class SupabaseBroadcastRepository implements BroadcastRepository {
  SupabaseBroadcastRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<BroadcastModel>> fetchAll() async {
    try {
      final response = await _client
          .from('broadcast')
          .select()
          .order('judul_broadcast', ascending: true);

      final list = (response as List)
          .whereType<Map<String, dynamic>>()
          .map(BroadcastModel.fromJson)
          .toList();

      return list;
    } catch (e, st) {
      debugPrint('fetchAll broadcast error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<BroadcastModel> createBroadcast({
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    try {
      final response = await _client
          .from('broadcast')
          .insert({
            'judul_broadcast': judul,
            'isi_broadcast': isi,
            'foto_broadcast': foto,
            'dokumen_broadcast': dokumen,
          })
          .select()
          .single();

      return BroadcastModel.fromJson(response);
    } catch (e, st) {
      debugPrint('createBroadcast error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<BroadcastModel> updateBroadcast({
    required String id,
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    try {
      final response = await _client
          .from('broadcast')
          .update({
            'judul_broadcast': judul,
            'isi_broadcast': isi,
            'foto_broadcast': foto,
            'dokumen_broadcast': dokumen,
          })
          .eq('id', id)
          .select()
          .single();

      return BroadcastModel.fromJson(response);
    } catch (e, st) {
      debugPrint('updateBroadcast error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteBroadcast(String id) async {
    try {
      await _client.from('broadcast').delete().eq('id', id);
    } catch (e, st) {
      debugPrint('deleteBroadcast error: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
