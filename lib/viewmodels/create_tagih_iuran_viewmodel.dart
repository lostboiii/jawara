import 'package:flutter/foundation.dart';
import 'package:jawara/data/repositories/iuran_repository.dart';

class CreateTagihIuranViewModel extends ChangeNotifier {
  final IuranRepository _repository;

  CreateTagihIuranViewModel({IuranRepository? repository})
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
      debugPrint('🔍 Loading kategori for tagih iuran...');
      
      final response = await _repository.getKategoriIuran();

      debugPrint('✅ Loaded ${response.length} kategori');
      
      _kategoris = response;
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
      
      final keluargaList = await _repository.getAllKeluargaId();
      
      debugPrint('✅ Found ${keluargaList.length} keluarga');

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
      
      if (tagihanList.isNotEmpty) {
        await _repository.insertBatchTagihan(tagihanList);
      }

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