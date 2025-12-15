import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/tagih_iuran_repository.dart';

class BayarIuranViewModel extends ChangeNotifier {
  BayarIuranViewModel({required TagihIuranRepository repository})
      : _repository = repository;

  final TagihIuranRepository _repository;
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _tagihan;
  List<Map<String, dynamic>> _metodePembayaran = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get tagihan => _tagihan;
  List<Map<String, dynamic>> get metodePembayaran => _metodePembayaran;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTagihan(String tagihanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔍 Loading tagihan: $tagihanId');
      
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
              nama_iuran,
              kategori_iuran
            )
          ''')
          .eq('id', tagihanId)
          .single();

      debugPrint('✅ Tagihan loaded: ${response['id']}');

      // Load nama kepala keluarga separately
      if (response['keluarga'] != null && response['keluarga']['kepala_keluarga_id'] != null) {
        final kepalaKeluargaId = response['keluarga']['kepala_keluarga_id'];
        final kepalaKeluarga = await _supabase
            .from('warga_profiles')
            .select('nama_lengkap')
            .eq('id', kepalaKeluargaId)
            .single();
        
        response['keluarga']['warga_profiles'] = kepalaKeluarga;
        debugPrint('✅ Kepala keluarga: ${kepalaKeluarga['nama_lengkap']}');
      }

      _tagihan = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat tagihan: $e';
      notifyListeners();
      debugPrint('❌ Error load tagihan: $e');
    }
  }

  Future<void> loadMetodePembayaran() async {
    try {
      debugPrint('🔍 Loading metode pembayaran from table...');
      
      final response = await _supabase
          .from('metode_pembayaran')
          .select('*')
          .order('nama_metode');

      debugPrint('✅ Metode pembayaran loaded: ${response.length} items');
      if (response.isNotEmpty) {
        debugPrint('📋 First item: ${response.first}');
      }
      
      _metodePembayaran = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error load metode pembayaran: $e');
      _metodePembayaran = [];
      notifyListeners();
    }
  }

  Future<bool> prosessPembayaran({
    required String tagihanId,
    required String? metodePembayaranId,
    String? catatanPembayaran,
    String? filePath,
    List<int>? fileBytes,
  }) async {
    try {
      String? buktiUrl;

      // Upload bukti jika ada file
      if (filePath != null && fileBytes != null) {
        try {
          buktiUrl = await _repository.uploadBuktiBayar(filePath, fileBytes);
          debugPrint('✅ Bukti berhasil diupload: $buktiUrl');
        } catch (uploadError) {
          debugPrint('⚠️ Upload gagal, gunakan catatan: $uploadError');
          // Jika upload gagal, gunakan catatan sebagai bukti
          buktiUrl = catatanPembayaran;
        }
      } else if (catatanPembayaran != null) {
        // Jika tidak ada file, gunakan catatan sebagai bukti
        buktiUrl = catatanPembayaran;
      }

      // Bayar tagihan
      await _repository.bayarTagihan(
        tagihanId: tagihanId,
        metodePembayaranId: metodePembayaranId,
        buktiBayar: buktiUrl,
      );

      // Tambahkan ke pemasukan_lain jika tagihan sudah dibayar
      if (_tagihan != null) {
        await _tambahPemasukan();
      }

      debugPrint('✅ Pembayaran berhasil diproses');
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memproses pembayaran: $e';
      notifyListeners();
      debugPrint('❌ Error proses pembayaran: $e');
      return false;
    }
  }

  Future<void> _tambahPemasukan() async {
    try {
      final kategoriIuran = _tagihan!['kategori_iuran'];
      final namaKategori = kategoriIuran['nama_iuran'] ?? 'Iuran';
      
      final data = {
        'nama_pemasukan': 'Pembayaran $namaKategori',
        'tanggal_pemasukan': DateTime.now().toIso8601String(),
        'kategori_pemasukan': 'Iuran Bulanan',
        'jumlah': _tagihan!['jumlah'],
        'bukti_pemasukan': _tagihan!['bukti_bayar'],
      };

      await _supabase.from('pemasukan_lain').insert(data);
      debugPrint('✅ Pemasukan berhasil ditambahkan');
    } catch (e) {
      debugPrint('⚠️ Gagal menambah pemasukan: $e');
      // Tidak throw error karena pembayaran sudah sukses
    }
  }
}
