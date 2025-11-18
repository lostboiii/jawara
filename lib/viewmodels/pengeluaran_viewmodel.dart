import 'package:flutter/foundation.dart';

import '../data/models/pengeluaran_model.dart';
import '../data/repositories/pengeluaran_repository.dart';

class PengeluaranViewModel extends ChangeNotifier {
  PengeluaranViewModel({required PengeluaranRepository repository})
      : _repository = repository;

  final PengeluaranRepository _repository;

  final List<PengeluaranModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PengeluaranModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPengeluaran() async {
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

  Future<void> addPengeluaran({
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createPengeluaran(
        nama: nama,
        tanggal: tanggal,
        kategori: kategori,
        jumlah: jumlah,
        bukti: bukti,
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

  Future<void> updatePengeluaran({
    required String id,
    required String nama,
    required DateTime tanggal,
    required String kategori,
    required double jumlah,
    String? bukti,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updatePengeluaran(
        id: id,
        nama: nama,
        tanggal: tanggal,
        kategori: kategori,
        jumlah: jumlah,
        bukti: bukti,
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

  Future<void> deletePengeluaran(String id) async {
    _setLoading(true);
    try {
      await _repository.deletePengeluaran(id);
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
