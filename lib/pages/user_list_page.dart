import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import '../widgets/filter_pengguna_dialog.dart';

// Model User
class User {
  final int no;
  final String nama;
  final String email;
  final String statusRegistrasi;

  User({
    required this.no,
    required this.nama,
    required this.email,
    required this.statusRegistrasi,
  });
}

// Dummy data
List<User> getDummyUsers() {
  return [
    User(
      no: 1,
      nama: 'dewqedwddw',
      email: 'adminewen1@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 2,
      nama: 'Rendha Putra Rahmadya',
      email: 'rendhazupei@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 3,
      nama: 'bla',
      email: 'y@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 4,
      nama: 'Anti Micin',
      email: 'antimicin3@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 5,
      nama: 'ijat4',
      email: 'ijat4@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 6,
      nama: 'ijat3',
      email: 'ijat3@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 7,
      nama: 'ijat2',
      email: 'ijat2@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 8,
      nama: 'AFIFAH KHOIRUNNISA',
      email: 'afi@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 9,
      nama: 'Raudhil Firdaus Naufal',
      email: 'rauchilifirdausn@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
    User(
      no: 10,
      nama: 'varizkiy naldiba rimra',
      email: 'afsafas@gmail.com',
      statusRegistrasi: 'Diterima',
    ),
  ];
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final List<User> _users = getDummyUsers();
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int get _totalPages => (_users.length / _itemsPerPage).ceil();

  List<User> get _currentUsers {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _users.length);
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
        nomorHP: '081234567890', // Default value, sesuaikan dengan data real
        role: 'user', // Default value, sesuaikan dengan data real
      ),
    );
  }

  void _showFilterDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const FilterPenggunaDialog(),
    );
    
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
        child: Padding(
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
                    flex: 3,
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
                    flex: 3,
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
                    flex: 2,
                    child: Text(
                      'STATUS REGISTRASI',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
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

            // List Items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: _currentUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = _currentUsers[index];
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
                            '${user.no}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Nama
                        Expanded(
                          flex: 3,
                          child: Text(
                            user.nama,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Email
                        Expanded(
                          flex: 3,
                          child: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Status
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.statusRegistrasi,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Aksi
                        SizedBox(
                          width: 50,
                          child: PopupMenuButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[600],
                            ),
                            itemBuilder: (context) => [
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
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditUserDialog(context, user);
                              } else if (value == 'delete') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hapus ${user.nama}'),
                                  ),
                                );
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
