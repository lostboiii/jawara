// lib/widgets/content/broadcast_list_content.dart (PERUBAHAN DIPERLUKAN)
import 'package:flutter/material.dart';
// Import helper baru
import 'package:jawara/widgets/list_layout_helpers.dart'; 

class BroadcastListContent extends StatelessWidget {
  const BroadcastListContent({super.key});

  // Hapus metode _buildHeader dan _buildPagination privat dari sini!

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> data = [
      {'NO': '1', 'PENGIRIM': 'Admin Jawara', 'JUDUL': 'Pengumuman', 'TANGGAL': '21 Oktober 2025'},
      {'NO': '2', 'PENGIRIM': 'Admin Jawara', 'JUDUL': 'DJ BAWS', 'TANGGAL': '17 Oktober 2025'},
      {'NO': '3', 'PENGIRIM': 'Admin Jawara', 'JUDUL': 'gotong royong', 'TANGGAL': '14 Oktober 2025'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Gunakan Widget ListHeader
        ListHeader('Broadcast - Daftar', showAddButton: true, onAddPressed: () {
          // Aksi untuk tombol tambah
        }),
        const Divider(),
        
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                // ... (Detail tabel sama)
                columnSpacing: 30.0,
                dataRowHeight: 50.0,
                headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('NO', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('PENGIRIM', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('JUDUL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('TANGGAL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['NO']!)),
                      DataCell(Text(item['PENGIRIM']!)),
                      DataCell(Text(item['JUDUL']!)),
                      DataCell(Text(item['TANGGAL']!)),
                      DataCell(IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // Gunakan Widget ListPagination
        const ListPagination(),
      ],
    );
  }
}