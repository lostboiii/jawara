import 'package:flutter/material.dart';
import '../data/models/tagih_iuran_model.dart';
import '../data/repositories/tagih_iuran_repository.dart';

class TagihIuranViewmodel extends ChangeNotifier {
  TagihIuranViewmodel({required TagihIuranRepository repository})
      : _repository = repository;

  final TagihIuranRepository _repository;

  final List<TagihIuranModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TagihIuranViewmodel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTagihIuran() async {
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

  Future<void> addTagihIuran({
  required DateTime tanggalTagihan,
  required double jumlah,
  required String statusTagihan,
  required DateTime? tanggalBayar,
  required String? buktiBayar,
  required String kategoriId,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createTagihIuran(
        tanggalTagihan: tanggalTagihan,
        jumlah: jumlah,
        statusTagihan: statusTagihan,
        tanggalBayar: tanggalBayar,
        buktiBayar: buktiBayar,
        kategoriId: kategoriId,
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

  Future<void> updateTagihIuran({
  required String id,
  required DateTime tanggalTagihan,
  required double jumlah,
  required String statusTagihan,
  required DateTime? tanggalBayar,
  required String? buktiBayar,
  required String kategoriId
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateTagihIuran(
        id: id,
        tanggalTagihan: tanggalTagihan,
        jumlah: jumlah,
        statusTagihan: statusTagihan,
        tanggalBayar: tanggalBayar,
        buktiBayar: buktiBayar,
        kategoriId: kategoriId,
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

  Future<void> deleteTagihIuran(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteTagihIuran(id);
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

