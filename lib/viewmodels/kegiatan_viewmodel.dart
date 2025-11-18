import 'package:flutter/foundation.dart';

import '../data/models/kegiatan_model.dart';
import '../data/repositories/kegiatan_repository.dart';

class KegiatanViewModel extends ChangeNotifier {
  KegiatanViewModel({required KegiatanRepository repository})
      : _repository = repository;

  final KegiatanRepository _repository;

  final List<KegiatanModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KegiatanModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadKegiatan() async {
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

  Future<void> addKegiatan({
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    _setLoading(true);
    try {
      final newItem = await _repository.createKegiatan(
        nama: nama,
        kategori: kategori,
        tanggal: tanggal,
        lokasi: lokasi,
        penanggungJawab: penanggungJawab,
        deskripsi: deskripsi,
      );
      _items.insert(0, newItem);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateKegiatan({
    required String id,
    required String nama,
    required String kategori,
    DateTime? tanggal,
    String? lokasi,
    String? penanggungJawab,
    String? deskripsi,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateKegiatan(
        id: id,
        nama: nama,
        kategori: kategori,
        tanggal: tanggal,
        lokasi: lokasi,
        penanggungJawab: penanggungJawab,
        deskripsi: deskripsi,
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

  Future<void> deleteKegiatan(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteKegiatan(id);
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
