import 'package:flutter/foundation.dart';
import '../data/models/kegiatan_model.dart';
import '../data/repositories/kegiatan_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({required KegiatanRepository repository})
      : _repository = repository;

  final KegiatanRepository _repository;

  final List<KegiatanModel> _kegiatanList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Dashboard data
  double _saldoKas = 15750000; // Initial balance
  double _totalPemasukan = 18500000;
  double _totalPengeluaran = 2750000;
  double _pengeluaranTemporary = 0; // Pengeluaran temporary (tidak disimpan ke database)

  List<KegiatanModel> get kegiatanList => List.unmodifiable(_kegiatanList);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get saldoKas => _saldoKas;
  double get totalPemasukan => _totalPemasukan;
  double get totalPengeluaran => _totalPengeluaran + _pengeluaranTemporary;
  double get pengeluaranTemporary => _pengeluaranTemporary;

  Future<void> loadDashboardData() async {
    _setLoading(true);
    try {
      final data = await _repository.fetchAll();
      _kegiatanList
        ..clear()
        ..addAll(data);

      // Recalculate totals based on kegiatan
      _calculateTotals();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _calculateTotals() {
    // Hanya hitung dari kegiatan yang ada di database (anggaran diabaikan)
    // Pengeluaran hanya dari database kegiatan saja
    _totalPengeluaran = 2750000; // Static value atau bisa dihitung dari data lain
    _updateSaldo();
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
