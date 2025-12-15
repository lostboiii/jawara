import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateKategoriIuranViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createKategori({
    required String namaIuran,
    required String kategoriIuran,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('💾 Saving kategori iuran: $namaIuran ($kategoriIuran)');
      await _supabase.from('kategori_iuran').insert({
        'nama_iuran': namaIuran,
        'kategori_iuran': kategoriIuran,
      });

      debugPrint('✅ Kategori iuran saved successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error saving kategori: $e');
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan data: $e';
      notifyListeners();
      rethrow;
    }
  }
}
