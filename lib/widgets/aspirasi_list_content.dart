// lib/widgets/content/aspirasi_list_content.dart (KODE YANG DIBENAHI)
import 'package:flutter/material.dart';
// Ganti import BroadcastListContent dengan ListLayoutHelpers
import 'package:jawara/widgets/list_layout_helpers.dart'; 

class AspirasiListContent extends StatelessWidget {
  const AspirasiListContent({super.key});

  Widget _buildStatusChip(String status) {
    // ... (Logika _buildStatusChip tidak berubah)
    Color color;
    switch (status) {
      case 'Diterima':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> data = [
      {'NO': '1', 'PENGIRIM': 'varcky nakdiba rimra', 'JUDUL': 'titoott', 'STATUS': 'Diterima', 'TANGGAL_DIBUAT': '15 Oktober 2025'},
      {'NO': '2', 'PENGIRIM': 'Habibie Ed Dien', 'JUDUL': 'tes', 'STATUS': 'Pending', 'TANGGAL_DIBUAT': '28 September 2025'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Ganti pemanggilan metode privat dengan Widget ListHeader
        const ListHeader('Informasi Aspirasi'), 
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
                  DataColumn(label: Text('PENGIRIM', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('JUDUL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('TANGGAL DIBUAT', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['NO']!)),
                      DataCell(Text(item['PENGIRIM']!)),
                      DataCell(Text(item['JUDUL']!)),
                      DataCell(_buildStatusChip(item['STATUS']!)),
                      DataCell(Text(item['TANGGAL_DIBUAT']!)),
                      DataCell(IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
        // Ganti pemanggilan metode privat dengan Widget ListPagination
        const ListPagination(), 
      ],
    );
  }
}