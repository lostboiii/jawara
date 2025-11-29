import 'package:flutter/foundation.dart';
import '../data/models/pemasukan_model.dart';
import '../data/repositories/pemasukan_repository.dart';

class PemasukanViewModel extends ChangeNotifier {
  PemasukanViewModel({required PemasukanRepository repository})
      : _repository = repository;

  final PemasukanRepository _repository;

  // Expose repository for direct access (e.g., file upload)
  PemasukanRepository get repository => _repository;

  final List<PemasukanModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PemasukanModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPemasukan() async {
    _setLoading(true);
    try {
      final data = await _repository.fetchAll();
      _items
        ..clear()
        ..addAll(data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterPemasukan({
    String? nama,
    String? kategori,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _setLoading(true);
    try {
      final data = await _repository.filterPemasukan(
        nama: nama,
        kategori: kategori,
        fromDate: fromDate,
        toDate: toDate,
      );
      _items
        ..clear()
        ..addAll(data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPemasukan({
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createPemasukan(
        nama_pemasukan: nama_pemasukan,
        tanggal_pemasukan: tanggal_pemasukan,
        kategori_pemasukan: kategori_pemasukan,
        jumlah: jumlah,
        bukti_pemasukan: bukti_pemasukan,
      );
      _items.insert(0, inserted);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePemasukan({
    required String id,
    required String nama_pemasukan,
    required DateTime tanggal_pemasukan,
    required String kategori_pemasukan,
    required double jumlah,
    String? bukti_pemasukan,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updatePemasukan(
        id: id,
        nama_pemasukan: nama_pemasukan,
        tanggal_pemasukan: tanggal_pemasukan,
        kategori_pemasukan: kategori_pemasukan,
        jumlah: jumlah,
        bukti_pemasukan: bukti_pemasukan,
      );
      final index = _items.indexWhere((element) => element.id == id);
      if (index != -1) {
        _items[index] = updated;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePemasukan(String id) async {
    _setLoading(true);
    try {
      await _repository.deletePemasukan(id);
      _items.removeWhere((element) => element.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}