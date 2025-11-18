import 'package:flutter/foundation.dart';

import '../data/models/metode_pembayaran_model.dart';
import '../data/repositories/metode_pembayaran_repository.dart';

class MetodePembayaranViewModel extends ChangeNotifier {
  MetodePembayaranViewModel({required MetodePembayaranRepository repository})
      : _repository = repository;

  final MetodePembayaranRepository _repository;

  final List<MetodePembayaranModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MetodePembayaranModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMetodePembayaran() async {
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

  Future<void> addMetodePembayaran({
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createMetodePembayaran(
        namaMetode: namaMetode,
        nomorRekening: nomorRekening,
        namaPemilik: namaPemilik,
        fotoBarcode: fotoBarcode,
        thumbnail: thumbnail,
        catatan: catatan,
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

  Future<void> updateMetodePembayaran({
    required String id,
    required String namaMetode,
    String? nomorRekening,
    String? namaPemilik,
    String? fotoBarcode,
    String? thumbnail,
    String? catatan,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateMetodePembayaran(
        id: id,
        namaMetode: namaMetode,
        nomorRekening: nomorRekening,
        namaPemilik: namaPemilik,
        fotoBarcode: fotoBarcode,
        thumbnail: thumbnail,
        catatan: catatan,
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

  Future<void> deleteMetodePembayaran(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteMetodePembayaran(id);
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
