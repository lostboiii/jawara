// lib/widgets/content/event_list_content.dart

import 'package:flutter/material.dart';
// Import helper yang berisi ListHeader dan ListPagination
import 'package:jawara/ui/widgets/list_layout_helpers.dart'; 


class EventListContent extends StatelessWidget {
  final String title;
  const EventListContent({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> data = [
      {'NO': '1', 'NAMA_KEGIATAN': 'Musy', 'KATEGORI': 'Komunitas & Sosial', 'PENANGGUNG_JAWAB': 'Pak', 'TANGGAL_PELAKSANAAN': '12 Oktober 2025'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Ganti pemanggilan metode privat dengan Widget ListHeader.
        // Asumsi tombol "Tambah" akan mengarahkan ke rute 'Kegiatan - Tambah'
        ListHeader(
          title, 
          showAddButton: true,
          onAddPressed: () {
            // Logika navigasi untuk tambah kegiatan (misalnya, context.go('/tambah-kegiatan'))
            // Atau memanggil setState pada HomePage untuk mengganti konten
          },
        ), 
        const Divider(),
        
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 30.0,
                dataRowHeight: 50.0,
                headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('NO', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('NAMA KEGIATAN', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('KATEGORI', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('PENANGGUNG JAWAB', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('TANGGAL PELAKSANAAN', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['NO']!)),
                      DataCell(Text(item['NAMA_KEGIATAN']!)),
                      DataCell(Text(item['KATEGORI']!)),
                      DataCell(Text(item['PENANGGUNG_JAWAB']!)),
                      DataCell(Text(item['TANGGAL_PELAKSANAAN']!)),
                      DataCell(IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // Ganti pemanggilan metode privat dengan Widget ListPagination.
        const ListPagination(), 
      ],
    );
  }
}