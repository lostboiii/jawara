import 'package:flutter/material.dart';
import 'package:jawara/data/models/keluarga.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';

class KeluargaMember {
  KeluargaMember({
    required this.id,
    required this.relation,
    required this.name,
    required this.nik,
    required this.gender,
    this.phone,
  });

  final String id;
  final String relation;
  final String name;
  final String nik;
  final String gender;
  final String? phone;

  String get genderLabel => gender.isNotEmpty ? gender : 'Tidak diketahui';

  String get relationLabel => relation.isNotEmpty ? relation : 'Anggota';
}

class KeluargaListItem {
  KeluargaListItem({
    required this.keluarga,
    required this.kepalaNama,
    required this.kepalaRole,
    required this.alamat,
    required List<KeluargaMember> members,
  }) : members = List<KeluargaMember>.unmodifiable(members);

  final Keluarga keluarga;
  final String kepalaNama;
  final String kepalaRole;
  final String? alamat;
  final List<KeluargaMember> members;

  bool get isActive => members.isNotEmpty;

  String get statusLabel => isActive ? 'Aktif' : 'Tidak Aktif';

  String get displayName {
    if (kepalaNama.isNotEmpty) {
      return 'Keluarga $kepalaNama';
    }
    if (keluarga.nomorKk.isNotEmpty) {
      return 'Keluarga ${keluarga.nomorKk}';
    }
    return 'Keluarga';
  }

  String get hunianLabel =>
      kepalaRole.isNotEmpty ? kepalaRole : 'Belum ditetapkan';

  String get alamatDisplay => (alamat != null && alamat!.isNotEmpty)
      ? alamat!
      : 'Alamat belum tersedia';
}

class DaftarKeluargaViewModel extends ChangeNotifier {
  final WargaRepository _repository;

  DaftarKeluargaViewModel({required WargaRepository repository})
      : _repository = repository;

  final TextEditingController searchController = TextEditingController();
  final List<KeluargaListItem> _families = <KeluargaListItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<KeluargaListItem> get families => _families;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<KeluargaListItem> get filteredFamilies {
    if (_searchQuery.isEmpty) {
      return List<KeluargaListItem>.from(_families);
    }

    final query = _searchQuery.toLowerCase();
    return _families.where((family) {
      final nameMatch = family.displayName.toLowerCase().contains(query);
      final kkMatch = family.keluarga.nomorKk.toLowerCase().contains(query);
      final alamatMatch = family.alamatDisplay.toLowerCase().contains(query);
      return nameMatch || kkMatch || alamatMatch;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadFamilies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final keluargaRaw = await _repository.getAllKeluarga();
      final wargaRaw = await _repository.getAllWarga();

      final Map<String, List<KeluargaMember>> membersByKeluarga = {};

      for (final warga in wargaRaw) {
        final keluargaId = warga['keluarga_id'] as String?;
        if (keluargaId == null) continue;

        final member = KeluargaMember(
          id: (warga['id'] as String?) ?? '',
          relation: (warga['peran_keluarga'] as String?) ?? '',
          name: (warga['nama_lengkap'] as String?) ?? '-',
          nik: (warga['nik'] as String?) ?? '-',
          gender: (warga['jenis_kelamin'] as String?) ?? '',
          phone: (warga['no_telepon'] as String?)?.trim(),
        );

        membersByKeluarga
            .putIfAbsent(keluargaId, () => <KeluargaMember>[])
            .add(member);
      }

      final List<KeluargaListItem> fetchedFamilies = keluargaRaw.map((data) {
        final keluarga = Keluarga.fromJson(data);
        final members =
            membersByKeluarga[keluarga.id ?? ''] ?? <KeluargaMember>[];

        String kepalaRole = '';
        for (final member in members) {
          if (member.id == keluarga.kepalakeluargaId) {
            kepalaRole = member.relationLabel;
            break;
          }
        }

        final kepalaNama = (data['warga_profiles'] is Map<String, dynamic>)
            ? ((data['warga_profiles'] as Map<String, dynamic>)['nama_lengkap']
                    as String? ??
                '')
            : '';

        final namaRumah = data['nama_rumah'] as String?;

        return KeluargaListItem(
          keluarga: keluarga,
          kepalaNama: kepalaNama,
          kepalaRole: kepalaRole,
          alamat: namaRumah,
          members: members,
        );
      }).toList();

      fetchedFamilies.sort((a, b) {
        final createdA =
            a.keluarga.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final createdB =
            b.keluarga.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return createdB.compareTo(createdA);
      });

      _families
        ..clear()
        ..addAll(fetchedFamilies);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
