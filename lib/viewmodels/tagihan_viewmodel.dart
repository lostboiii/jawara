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
      final response = await _supabase
          .from('tagih_iuran')
          .select('''
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
          ''')
          .order('tanggal_tagihan', ascending: false);

      _tagihan = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data tagihan: $e';
      notifyListeners();
    }
  }
}
