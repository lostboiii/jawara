// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import '../widgets/filter_pengguna_dialog.dart';

// Model User - diperluas dengan semua field dari form registrasi
class User {
  const User({
    required this.id,
    required this.nama,
    required this.nik,
    required this.email,
    required this.telepon,
    required this.jenisKelamin,
    required this.agama,
    required this.golonganDarah,
    required this.pekerjaan,
    required this.peranKeluarga,
    this.nomorKk,
    this.namaKeluarga,
  });

  final String id;
  final String nama;
  final String nik;
  final String email;
  final String telepon;
  final String jenisKelamin;
  final String agama;
  final String golonganDarah;
  final String pekerjaan;
  final String peranKeluarga;
  final String? nomorKk;
  final String? namaKeluarga;
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final int _itemsPerPage = 10;
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  int _currentPage = 1;
  List<User> _users = [];
  bool _canQueryAuthUsers = true;

  @override
  void initState() {
    super.initState();
    _loadWargaData();
  }

  Future<void> _loadWargaData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('warga_profiles')
          .select('''
            id,
            nama_lengkap,
            nik,
            no_hp,
            jenis_kelamin,
            agama,
            golongan_darah,
            pekerjaan,
            peran_keluarga,
            keluarga_id
          ''')
          .order('created_at', ascending: false);

      final records = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();

      final emailMap = <String, String>{};
      final userIds = <String>[];
      final keluargaIds = <String>{};
      final namaById = <String, String>{};

      for (final warga in records) {
        final id = warga['id'] as String?;
        if (id != null) {
          userIds.add(id);
          final nama = _extractString(warga, const ['nama_lengkap', 'namaLengkap']);
          if (nama != null) {
            namaById[id] = nama;
          }
        }

        final keluargaId = warga['keluarga_id'] as String?;
        if (keluargaId != null && keluargaId.isNotEmpty) {
          keluargaIds.add(keluargaId);
        }
      }

      if (userIds.isNotEmpty && _canQueryAuthUsers) {
        try {
              final authResponse = await _supabase
                .from('auth.users')
              .select('id, email')
              .inFilter('id', userIds);

          final authRecords = (authResponse as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList();
          for (final map in authRecords) {
            final id = map['id'] as String?;
            final email = map['email'] as String?;
            if (id != null && email != null && email.isNotEmpty) {
              emailMap[id] = email;
            }
          }
        } on PostgrestException catch (e) {
          final isSchemaMissing = e.code == 'PGRST106' || e.code == 'PGRST205';
          if (isSchemaMissing) {
            debugPrint('Supabase auth.users query unavailable (${e.code}): email fallback to warga_profiles.');
          } else {
            debugPrint('Supabase auth.users query failed (${e.code}): ${e.message}');
          }
          if (isSchemaMissing) {
            _canQueryAuthUsers = false;
          }
        } catch (e) {
          debugPrint('Unexpected error fetching auth.users: $e');
          _canQueryAuthUsers = false;
        }
      }

      final keluargaInfoMap = <String, Map<String, String?>>{};
      final keluargaIdByKepala = <String, String>{};
      if (keluargaIds.isNotEmpty) {
        try {
          final keluargaResponse = await _supabase
              .from('keluarga')
              .select('id, nomor_kk, kepala_keluarga_id')
              .inFilter('id', keluargaIds.toList());

          final keluargaRecords = (keluargaResponse as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList();

          for (final keluarga in keluargaRecords) {
            final keluargaId = keluarga['id'] as String?;
            if (keluargaId == null) {
              continue;
            }

            final nomorKk = _extractString(keluarga, const ['nomor_kk']);
            final kepalaId = keluarga['kepala_keluarga_id'] as String?;

            keluargaInfoMap[keluargaId] = {
              'nomorKk': nomorKk,
              'kepalaId': kepalaId,
            };

            if (kepalaId != null && kepalaId.isNotEmpty) {
              keluargaIdByKepala[kepalaId] = keluargaId;
            }
          }
        } on PostgrestException catch (e) {
          debugPrint('Supabase keluarga query failed (${e.code}): ${e.message}');
        } catch (e) {
          debugPrint('Unexpected error fetching keluarga: $e');
        }
      }

      final loadedUsers = <User>[];
      for (final warga in records) {
        final wargaId = warga['id'] as String?;
        if (wargaId == null) {
          continue;
        }

        final email = emailMap[wargaId] ?? 'Email tidak tersedia';
        final telepon = _extractString(
              warga,
              const ['no_hp', 'nomor_hp', 'telepon'],
            ) ??
            '';
        String? keluargaId = warga['keluarga_id'] as String?;
        keluargaId ??= keluargaIdByKepala[wargaId];

        final keluargaInfo = keluargaId != null ? keluargaInfoMap[keluargaId] : null;
        final nomorKk = keluargaInfo?['nomorKk'];
        final kepalaId = keluargaInfo?['kepalaId'];
        final kepalaName = kepalaId != null ? namaById[kepalaId] : null;

        String? namaKeluarga;
        final hasNomorKk = nomorKk != null && nomorKk.isNotEmpty;
        if (keluargaInfo != null) {
          if (kepalaId != null && kepalaId == wargaId) {
            if (hasNomorKk) {
              namaKeluarga = 'KK $nomorKk';
            } else if (kepalaName != null && kepalaName.isNotEmpty) {
              namaKeluarga = kepalaName;
            }
          } else {
            final kkLabel = hasNomorKk ? 'KK $nomorKk' : null;
            if (kkLabel != null && kepalaName != null && kepalaName.isNotEmpty) {
              namaKeluarga = '$kkLabel - $kepalaName';
            } else if (kkLabel != null) {
              namaKeluarga = kkLabel;
            } else if (kepalaName != null && kepalaName.isNotEmpty) {
              namaKeluarga = kepalaName;
            }
          }
        }

        loadedUsers.add(User(
          id: wargaId,
          nama: _extractString(warga, const ['nama_lengkap', 'namaLengkap']) ?? 'Nama tidak tersedia',
          nik: _extractString(warga, const ['nik']) ?? 'NIK tidak tersedia',
          email: email,
          telepon: telepon,
          jenisKelamin: _extractString(warga, const ['jenis_kelamin', 'jenisKelamin']) ?? '',
          agama: _extractString(warga, const ['agama']) ?? '',
          golonganDarah: _extractString(warga, const ['golongan_darah', 'golonganDarah']) ?? '',
          pekerjaan: _extractString(warga, const ['pekerjaan']) ?? '',
          peranKeluarga: _extractString(warga, const ['peran_keluarga', 'peranKeluarga']) ?? '',
          nomorKk: nomorKk,
          namaKeluarga: namaKeluarga,
        ));
      }

      final totalPages = loadedUsers.isEmpty
          ? 1
          : (loadedUsers.length / _itemsPerPage).ceil();

      if (!mounted) return;

      setState(() {
        _users = loadedUsers;
        _currentPage = _currentPage.clamp(1, totalPages);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading warga: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _extractString(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value is num) {
        return value.toString();
      }
    }
    return null;
  }

  int get _totalPages {
    if (_users.isEmpty) {
      return 1;
    }
    return (_users.length / _itemsPerPage).ceil();
  }

  List<User> get _currentUsers {
    if (_users.isEmpty) {
      return const <User>[];
    }
    final int currentPage = _currentPage.clamp(1, _totalPages);
    final int startIndex = (currentPage - 1) * _itemsPerPage;
    var endIndex = startIndex + _itemsPerPage;
    if (endIndex > _users.length) {
      endIndex = _users.length;
    }
    return _users.sublist(startIndex, endIndex);
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        nama: user.nama,
        email: user.email,
        nik: user.nik,
        nomorHP: user.telepon,
        role: user.peranKeluarga,
        jenisKelamin: user.jenisKelamin,
        agama: user.agama,
        golonganDarah: user.golonganDarah,
        pekerjaan: user.pekerjaan,
        nomorKk: user.nomorKk,
      ),
    );
  }

  void _showDetailUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => DetailUserDialog(user: user),
    );
  }
  void _showFilterDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const FilterPenggunaDialog(),
    );
    
    if (!mounted) return;
    if (result != null) {
      // Handle filter result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filter diterapkan: ${result['nama'] ?? 'Semua'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Daftar Pengguna',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header dengan tombol tambah
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daftar Akun Pengguna',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'NO',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'NAMA',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'EMAIL',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'TELEPON',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'PERAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'AKSI',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: _currentUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = _currentUsers[index];
                  final rowNumber = (_currentPage - 1) * _itemsPerPage + index + 1;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // No
                        Expanded(
                          flex: 1,
                          child: Text(
                            '$rowNumber',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Nama
                        Expanded(
                          flex: 2,
                          child: Text(
                            user.nama,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Email
                        Expanded(
                          flex: 2,
                          child: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Telepon
                        Expanded(
                          flex: 1,
                          child: Text(
                            user.telepon,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Peran
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.peranKeluarga == 'kepala keluarga' ? 'KK' : 'Anggota',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Aksi
                        SizedBox(
                          width: 80,
                          child: PopupMenuButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[600],
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    Icon(Icons.info, size: 18),
                                    SizedBox(width: 8),
                                    Text('Detail'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'detail') {
                                _showDetailUserDialog(context, user);
                              } else if (value == 'edit') {
                                _showEditUserDialog(context, user);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    color:
                        _currentPage > 1 ? Colors.grey[700] : Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  ..._buildPageNumbers(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    color: _currentPage < _totalPages
                        ? Colors.grey[700]
                        : Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
            ),
      );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    if (_currentPage > 1) {
      pages.add(_buildPageButton(1));
    }

    if (_currentPage > 2) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    pages.add(_buildPageButton(_currentPage, isActive: true));

    if (_currentPage < _totalPages - 1) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    if (_currentPage < _totalPages) {
      pages.add(_buildPageButton(_totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.indigo[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Dialog Detail Pengguna
class DetailUserDialog extends StatelessWidget {
  final User user;

  const DetailUserDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Pengguna',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data Warga Section
              _buildSection('Informasi Warga', [
                _buildDetailRow('Nama', user.nama),
                _buildDetailRow('NIK', user.nik),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Telepon', user.telepon),
                _buildDetailRow('Jenis Kelamin', user.jenisKelamin),
                _buildDetailRow('Agama', _formatAgama(user.agama)),
                _buildDetailRow('Golongan Darah', user.golonganDarah),
                _buildDetailRow('Pekerjaan', user.pekerjaan),
              ]),

              const SizedBox(height: 20),

              // Data Keluarga Section
              if (user.peranKeluarga == 'kepala keluarga')
                _buildSection('Data Keluarga', [
                  _buildDetailRow('Peran', 'Kepala Keluarga'),
                  _buildDetailRow('Nomor KK', user.nomorKk ?? '-'),
                ])
              else
                _buildSection('Data Keluarga', [
                  _buildDetailRow('Peran', user.peranKeluarga),
                  _buildDetailRow('Keluarga', user.namaKeluarga ?? '-'),
                ]),

              const SizedBox(height: 24),

              // Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(':', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAgama(String agama) {
    const agamaMap = {
      'islam': 'Islam',
      'hindu': 'Hindu',
      'budha': 'Budha',
      'kristen': 'Kristen',
      'katolik': 'Katolik',
      'konghucu': 'Konghucu',
    };
    return agamaMap[agama] ?? agama;
  }
}
