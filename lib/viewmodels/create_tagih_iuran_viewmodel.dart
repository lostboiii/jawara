import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTagihIuranViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _kategoris = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get kategoris => _kategoris;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadKategoris() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Loading kategori for tagih iuran...');
      final response = await _supabase
          .from('kategori_iuran')
          .select('id, nama_iuran, kategori_iuran');

      debugPrint('✅ Loaded ${response.length} kategori');
      _kategoris = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading kategori: $e');
      _isLoading = false;
      _errorMessage = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  Future<void> tagihSemuaKeluarga({
    required String kategoriId,
    required String tanggalTagihan,
    required int jumlah,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Loading keluarga for tagihan...');
      // Load semua keluarga
      final keluargaResponse = await _supabase.from('keluarga').select('id');
      final keluargaList = List<Map<String, dynamic>>.from(keluargaResponse);
      debugPrint('✅ Found ${keluargaList.length} keluarga');

      // Buat tagihan untuk setiap keluarga
      final tagihanList = keluargaList.map((keluarga) {
        return {
          'kategori_id': kategoriId,
          'keluarga_id': keluarga['id'],
          'tanggal_tagihan': tanggalTagihan,
          'jumlah': jumlah,
          'status_tagihan': 'belum_bayar',
        };
      }).toList();

      debugPrint('💾 Inserting ${tagihanList.length} tagihan to tagih_iuran table...');
      // Insert batch
      await _supabase.from('tagih_iuran').insert(tagihanList);

      debugPrint('✅ Successfully created tagihan for all keluarga');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error creating tagihan: $e');
      _isLoading = false;
      _errorMessage = 'Gagal menagih: $e';
      notifyListeners();
      rethrow;
    }
  }
}
