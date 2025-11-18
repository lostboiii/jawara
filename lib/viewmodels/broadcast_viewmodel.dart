import 'package:flutter/foundation.dart';

import '../data/models/broadcast_model.dart';
import '../data/repositories/broadcast_repository.dart';

class BroadcastViewModel extends ChangeNotifier {
  BroadcastViewModel({required BroadcastRepository repository})
      : _repository = repository;

  final BroadcastRepository _repository;

  final List<BroadcastModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BroadcastModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBroadcasts() async {
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

  Future<void> addBroadcast({
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    _setLoading(true);
    try {
      final inserted = await _repository.createBroadcast(
        judul: judul,
        isi: isi,
        foto: foto,
        dokumen: dokumen,
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

  Future<void> updateBroadcast({
    required String id,
    required String judul,
    required String isi,
    String? foto,
    String? dokumen,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repository.updateBroadcast(
        id: id,
        judul: judul,
        isi: isi,
        foto: foto,
        dokumen: dokumen,
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

  Future<void> deleteBroadcast(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteBroadcast(id);
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
