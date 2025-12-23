import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/kegiatan_model.dart';
import '../data/repositories/kegiatan_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({required KegiatanRepository repository})
      : _repository = repository;

  final KegiatanRepository _repository;

  final List<KegiatanModel> _kegiatanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Dashboard data - akan di-update dari database
  double _saldoKas = 0;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _pemasukanLain = 0;
  double _iuranLunas = 0;
  double _pengeluaranTemporary = 0; // Pengeluaran temporary dari anggaran kegiatan

  List<KegiatanModel> get kegiatanList => List.unmodifiable(_kegiatanList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get saldoKas => _saldoKas;
  double get totalPemasukan => _totalPemasukan;
  double get totalPengeluaran => _totalPengeluaran + _pengeluaranTemporary;
  double get pengeluaranTemporary => _pengeluaranTemporary;
  double get pemasukanLain => _pemasukanLain;
  double get iuranLunas => _iuranLunas;

  Future<void> loadDashboardData() async {
    _setLoading(true);
    try {
      final data = await _repository.fetchAll();
      _kegiatanList
        ..clear()
        ..addAll(data);

      // Load financial data from database
      await loadFinancialData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFinancialData() async {
    try {
      final supabase = Supabase.instance.client;

      // Load pemasukan lain
      final pemasukanResponse = await supabase
          .from('pemasukan_lain')
          .select('jumlah');
      
      double pemasukanLain = 0;
      for (var item in pemasukanResponse) {
        pemasukanLain += (item['jumlah'] as num).toDouble();
      }

      // Load iuran yang sudah dibayar
      final iuranResponse = await supabase
          .from('tagih_iuran')
          .select('jumlah')
          .eq('status_tagihan', 'sudah_bayar');
      
      double iuranLunas = 0;
      for (var item in iuranResponse) {
        iuranLunas += (item['jumlah'] as num).toDouble();
      }

      // Load pengeluaran
      final pengeluaranResponse = await supabase
          .from('pengeluaran')
          .select('jumlah');
      
      double pengeluaran = 0;
      for (var item in pengeluaranResponse) {
        pengeluaran += (item['jumlah'] as num).toDouble();
      }

      // Update values
      _pemasukanLain = pemasukanLain;
      _iuranLunas = iuranLunas;
      _totalPemasukan = pemasukanLain + iuranLunas;
      _totalPengeluaran = pengeluaran;
      _updateSaldo();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading financial data: $e');
    }
  }

  void _updateSaldo() {
    // Saldo = pemasukan - (pengeluaran db + pengeluaran temporary)
    _saldoKas = _totalPemasukan - (_totalPengeluaran + _pengeluaranTemporary);
  }

  void addPemasukan(double jumlah) {
    _totalPemasukan += jumlah;
    _updateSaldo();
    notifyListeners();
  }

  void addPengeluaran(double jumlah) {
    _totalPengeluaran += jumlah;
    _updateSaldo();
    notifyListeners();
  }

  // Method untuk menambah pengeluaran temporary dari anggaran kegiatan
  void addPengeluaranTemporary(double jumlah) {
    _pengeluaranTemporary += jumlah;
    _updateSaldo();
    notifyListeners();
  }

  // Method untuk mengurangi pengeluaran temporary
  void removePengeluaranTemporary(double jumlah) {
    _pengeluaranTemporary -= jumlah;
    if (_pengeluaranTemporary < 0) {
      _pengeluaranTemporary = 0;
    }
    _updateSaldo();
    notifyListeners();
  }

  // Reset pengeluaran temporary
  void resetPengeluaranTemporary() {
    _pengeluaranTemporary = 0;
    _updateSaldo();
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Formatter untuk mata uang
  String formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.')}';
  }

  int getTotalKegiatan() {
    return _kegiatanList.length;
  }

  int getKegiatanBulanIni() {
    final now = DateTime.now();
    return _kegiatanList
        .where((kegiatan) =>
            kegiatan.tanggalKegiatan?.month == now.month &&
            kegiatan.tanggalKegiatan?.year == now.year)
        .length;
  }

  int getKegiatanAkanDatang() {
    final now = DateTime.now();
    return _kegiatanList
        .where((kegiatan) =>
            kegiatan.tanggalKegiatan != null &&
            kegiatan.tanggalKegiatan!.isAfter(now))
        .length;
  }

  int getKegiatanSelesai() {
    final now = DateTime.now();
    return _kegiatanList
        .where((kegiatan) =>
            kegiatan.tanggalKegiatan != null &&
            kegiatan.tanggalKegiatan!.isBefore(now))
        .length;
  }

  List<KegiatanModel> getKegiatanTerbaru({int limit = 4}) {
    return _kegiatanList.take(limit).toList();
  }
}
