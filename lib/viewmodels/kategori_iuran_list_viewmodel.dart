import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriIuranListViewModel extends ChangeNotifier {
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
      final response = await _supabase
          .from('kategori_iuran')
          .select('id, nama_iuran, kategori_iuran')
          .order('nama_iuran');

      _kategoris = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data: $e';
      notifyListeners();
    }
  }
}
