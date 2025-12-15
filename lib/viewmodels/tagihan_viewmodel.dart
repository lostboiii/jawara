import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagihanViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _tagihan = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get tagihan => _tagihan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTagihan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Loading tagihan iuran...');
      final response = await _supabase
          .from('tagih_iuran')
          .select('''
            *,
            keluarga:keluarga_id (
              id,
              nomor_kk,
              kepala_keluarga_id
            ),
            kategori_iuran:kategori_id (
              nama_iuran
            )
          ''')
          .order('tanggal_tagihan', ascending: false);

      debugPrint('✅ Tagihan loaded: ${response.length} items');
      
      // Enrich data dengan nama kepala keluarga
      for (var item in response) {
        if (item['keluarga'] != null && item['keluarga']['kepala_keluarga_id'] != null) {
          try {
            final wargaResponse = await _supabase
                .from('warga_profiles')
                .select('nama_lengkap')
                .eq('id', item['keluarga']['kepala_keluarga_id'])
                .single();
            
            item['keluarga']['nama_kepala'] = wargaResponse['nama_lengkap'];
          } catch (e) {
            debugPrint('⚠️ Gagal fetch nama kepala keluarga: $e');
            item['keluarga']['nama_kepala'] = null;
          }
        }
      }
      
      if (response.isNotEmpty) {
        debugPrint('📊 Sample data: ${response.first}');
      }
      
      _tagihan = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading tagihan: $e');
      _isLoading = false;
      _errorMessage = 'Gagal memuat data tagihan: $e';
      notifyListeners();
    }
  }
}
