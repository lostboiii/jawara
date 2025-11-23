// lib/screens/warga/warga_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../pages/warga/tambah_warga_page.dart';

class WargaListScreen extends StatefulWidget {
  const WargaListScreen({super.key});

  @override
  State<WargaListScreen> createState() => _WargaListScreenState();
}

class _WargaListScreenState extends State<WargaListScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> wargaList = [
    {
      'nama': 'Ahmad Sudrajat',
      'nik': '3578012345678901',
      'alamat': 'Jl. Raya Surabaya No. 123, RT 01/RW 02',
      'jenisKelamin': 'Laki-laki',
      'status': 'Kepala Keluarga',
    },
    {
      'nama': 'Siti Aminah',
      'nik': '3578012345678902',
      'alamat': 'Jl. Raya Surabaya No. 123, RT 01/RW 02',
      'jenisKelamin': 'Perempuan',
      'status': 'Istri',
    },
    {
      'nama': 'Budi Santoso',
      'nik': '3578012345678903',
      'alamat': 'Jl. Merdeka No. 45, RT 03/RW 01',
      'jenisKelamin': 'Laki-laki',
      'status': 'Kepala Keluarga',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan pencarian
    final filteredList = wargaList.where((warga) {
      final query = searchController.text.toLowerCase();
      return warga['nama'].toLowerCase().contains(query) ||
          warga['nik'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Data Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // nanti bisa ditambahkan fitur filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Header dengan search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIK...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredList.length} Warga Terdaftar',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Text(
                      'Update: Hari ini',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 List warga
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data warga.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final warga = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // TODO: Navigasi ke detail warga
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 🔹 Icon gender
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color:
                                          warga['jenisKelamin'] == 'Laki-laki'
                                              ? Colors.blue[100]
                                              : Colors.pink[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      warga['jenisKelamin'] == 'Laki-laki'
                                          ? Icons.person
                                          : Icons.person_outline,
                                      color:
                                          warga['jenisKelamin'] == 'Laki-laki'
                                              ? Colors.blue
                                              : Colors.pink,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // 🔹 Detail warga
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          warga['nama'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.credit_card,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              warga['nik'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                warga['alamat'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            warga['status'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 🔹 Tombol tambah warga
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahWargaPage(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Warga'),
      ),
    );
  }
}
