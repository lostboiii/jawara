import 'package:flutter/foundation.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class TagihanViewModel extends ChangeNotifier {
  final IuranRepository _repository;

  TagihanViewModel({IuranRepository? repository})
      : _repository = repository ?? IuranRepository();

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

      final response = await _repository.getTagihan();

      debugPrint('✅ Tagihan loaded: ${response.length} items');

      for (var item in response) {
        if (item['keluarga'] != null) {
          if (item['keluarga']['warga_profiles'] != null) {
            item['keluarga']['nama_kepala'] = item['keluarga']['warga_profiles']['nama_lengkap'];
          } else {
            item['keluarga']['nama_kepala'] = null;
          }
        }
      }

      if (response.isNotEmpty) {
        debugPrint('📊 Sample data: ${response.first}');
      }

      _tagihan = response;
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