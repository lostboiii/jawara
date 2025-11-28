import 'package:flutter/material.dart';
import 'package:jawara/data/models/kategori_iuran_model.dart';
import '../data/repositories/kategori_iuran_repository.dart';

class KategoriIuranViewModel extends ChangeNotifier {
  KategoriIuranViewModel({required KategoriIuranRepository repository})
      : _repository = repository;

  final KategoriIuranRepository _repository;

  final List<KategoriIuranModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KategoriIuranViewModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadKategoriIuran() async {
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

  Future<void> addKategoriIuran({
    required String namaIuran,
    required String kategoriIuran,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createKategoriIuran(
        namaIuran: namaIuran,
        kategoriIuran: kategoriIuran,
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

  Future<void> updateKategoriIuran({
    required String id,
    required String namaIuran,
    required String kategoriIuran,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateKategoriIuran(
        id: id,
        namaIuran: namaIuran,
        kategoriIuran: kategoriIuran,
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

  Future<void> deleteKategoriIuran(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteKategoriIuran(id);
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
