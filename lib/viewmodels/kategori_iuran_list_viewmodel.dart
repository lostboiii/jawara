import 'package:flutter/foundation.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class KategoriIuranListViewModel extends ChangeNotifier {
  final IuranRepository _repository;

  KategoriIuranListViewModel({IuranRepository? repository})
      : _repository = repository ?? IuranRepository();

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
      debugPrint('🔍 Loading kategori iuran...');
      
      final response = await _repository.getKategoriIuran();

      debugPrint('✅ Kategori loaded: ${response.length} items');
      debugPrint('📊 Data: $response');
      
      _kategoris = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading kategori: $e');
      _isLoading = false;
      _errorMessage = 'Gagal memuat data: $e';
      notifyListeners();
    }
  }
}