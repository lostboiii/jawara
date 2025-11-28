import 'package:flutter/foundation.dart';
import 'package:jawara/core/services/supabase_service.dart';

class RumahViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _rumahList = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get rumahList => _rumahList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Fetch rumah list from Supabase
  Future<void> fetchRumahList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseService.client
          .from('rumah')
          .select('alamat, status_rumah');
      _rumahList = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data rumah: $e';
      _isLoading = false;
      debugPrint('Error fetching rumah list: $e');
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _rumahList = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
