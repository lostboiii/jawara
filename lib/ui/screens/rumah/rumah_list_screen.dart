// lib/screens/rumah/rumah_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RumahListScreen extends StatefulWidget {
  const RumahListScreen({super.key});

  @override
  _RumahListScreenState createState() => _RumahListScreenState();
}

class _RumahListScreenState extends State<RumahListScreen> {
  TextEditingController searchController = TextEditingController();
  
  List<Map<String, dynamic>> rumahList = [
    {
      'nomorRumah': '123',
      'alamat': 'Jl. Raya Surabaya No. 123',
      'rt': '01',
      'rw': '02',
      'statusKepemilikan': 'Milik Sendiri',
      'jumlahPenghuni': 4,
      'luasTanah': 200.0,
      'luasBangunan': 150.0,
    },
    {
      'nomorRumah': '45',
      'alamat': 'Jl. Merdeka No. 45',
      'rt': '03',
      'rw': '01',
      'statusKepemilikan': 'Sewa',
      'jumlahPenghuni': 3,
      'luasTanah': 150.0,
      'luasBangunan': 120.0,
    },
    {
      'nomorRumah': '78',
      'alamat': 'Jl. Pahlawan No. 78',
      'rt': '02',
      'rw': '03',
      'statusKepemilikan': 'Milik Sendiri',
      'jumlahPenghuni': 5,
      'luasTanah': 250.0,
      'luasBangunan': 180.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text('Data Rumah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
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
                    hintText: 'Cari alamat atau nomor rumah...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${rumahList.length} Rumah Terdaftar',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Total Penghuni: ${rumahList.fold(0, (sum, item) => sum + (item['jumlahPenghuni'] as int))}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: rumahList.length,
              itemBuilder: (context, index) {
                final rumah = rumahList[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _showDetailDialog(rumah);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.home, color: Colors.green, size: 32),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Rumah No. ${rumah['nomorRumah']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: rumah['statusKepemilikan'] == 'Milik Sendiri'
                                                  ? Colors.blue[50]
                                                  : Colors.orange[50],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              rumah['statusKepemilikan'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: rumah['statusKepemilikan'] == 'Milik Sendiri'
                                                    ? Colors.blue[700]
                                                    : Colors.orange[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              rumah['alamat'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(height: 1),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.people,
                                  '${rumah['jumlahPenghuni']} Penghuni',
                                  Colors.purple,
                                ),
                                SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.grid_3x3,
                                  'RT ${rumah['rt']}/RW ${rumah['rw']}',
                                  Colors.blue,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.square_foot,
                                  '${rumah['luasTanah']} m²',
                                  Colors.green,
                                ),
                                SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.home_work,
                                  '${rumah['luasBangunan']} m²',
                                  Colors.orange,
                                ),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add rumah
        },
        backgroundColor: Colors.green,
        icon: Icon(Icons.add_home),
        label: Text('Tambah Rumah'),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> rumah) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.home, color: Colors.green),
              SizedBox(width: 8),
              Text('Detail Rumah No. ${rumah['nomorRumah']}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Alamat', rumah['alamat']),
                _buildDetailRow('RT/RW', 'RT ${rumah['rt']}/RW ${rumah['rw']}'),
                _buildDetailRow('Status', rumah['statusKepemilikan']),
                _buildDetailRow('Penghuni', '${rumah['jumlahPenghuni']} orang'),
                _buildDetailRow('Luas Tanah', '${rumah['luasTanah']} m²'),
                _buildDetailRow('Luas Bangunan', '${rumah['luasBangunan']} m²'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to edit
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}