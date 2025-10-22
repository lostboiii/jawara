import 'package:flutter/material.dart';

class LaporanKeuanganPage extends StatefulWidget {
  const LaporanKeuanganPage({super.key});

  @override
  State<LaporanKeuanganPage> createState() => _LaporanKeuanganPageState();
}

class _LaporanKeuanganPageState extends State<LaporanKeuanganPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalAkhirController = TextEditingController();

  final List<Map<String, dynamic>> laporanPemasukanList = [
    {
      "no": 1,
      "nama": "aaaaa",
      "jenis": "Dana Bantuan Pemerintah",
      "tanggal": "15 Okt 2025 14:23",
      "nominal": "Rp 11,00"
    },
    {
      "no": 2,
      "nama": "Joki by firman",
      "jenis": "Pendapatan Lainnya",
      "tanggal": "13 Okt 2025 00:55",
      "nominal": "Rp 49.999.997,00"
    },
    {
      "no": 3,
      "nama": "tes",
      "jenis": "Pendapatan Lainnya",
      "tanggal": "12 Agt 2025 13:26",
      "nominal": "Rp 10.000,00"
    },
  ];

  final List<Map<String, dynamic>> laporanPengeluaranList = [
    {
      "no": 1,
      "nama": "Kerja Bakti",
      "jenis": "Pemeliharaan Fasilitas",
      "tanggal": "19 Okt 2025 20:26",
      "nominal": "Rp 50.000,00"
    },
    {
      "no": 2,
      "nama": "Kerja Bakti",
      "jenis": "Kegiatan Warga",
      "tanggal": "19 Okt 2025 20:26",
      "nominal": "Rp 100.000,00"
    },
    {
      "no": 3,
      "nama": "Arka",
      "jenis": "Operasional RT/RW",
      "tanggal": "17 Okt 2025 02:31",
      "nominal": "Rp 6,00"
    },
    {
      "no": 4,
      "nama": "asad",
      "jenis": "Pemeliharaan Fasilitas",
      "tanggal": "10 Okt 2025 01:08",
      "nominal": "Rp 2.112,00"
    },
  ];

  void _showCetakLaporanDialog() {
    final List<String> jenisLaporan = ["Semua", "Pemasukan", "Pengeluaran"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cetak Laporan Keuangan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tanggal Mulai"),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _tanggalMulaiController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                hintText: "-- / -- / ----",
                                border: OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                  setState(() {
                                    _tanggalMulaiController.text =
                                        formattedDate;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tanggal Akhir"),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _tanggalAkhirController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                hintText: "-- / -- / ----",
                                border: OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                  setState(() {
                                    _tanggalAkhirController.text =
                                        formattedDate;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Jenis Laporan"),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: "Semua",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: jenisLaporan
                        .map((laporan) => DropdownMenuItem(
                              value: laporan,
                              child: Text(laporan),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black54,
                        ),
                        child: const Text("Reset"),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Download PDF"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Semua Pemasukan"),
              Tab(text: "Semua Pengeluaran"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPemasukanView(),
            _buildPengeluaranView(),
          ],
        ),
      ),
    );
  }

  Widget _buildPemasukanView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 18),
                label: const Text("Cetak Laporan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showCetakLaporanDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: laporanPemasukanList.length,
              itemBuilder: (context, index) {
                final pemasukan = laporanPemasukanList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(pemasukan["no"].toString()),
                    ),
                    title: Text(pemasukan["nama"]),
                    subtitle: Text(pemasukan["jenis"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pemasukan["nominal"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pemasukan["tanggal"],
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String result) {
                            if (result == 'detail') {
                              print('Detail ${pemasukan["nama"]}');
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'detail',
                              child: Text('Detail'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengeluaranView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 18),
                label: const Text("Cetak Laporan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showCetakLaporanDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: laporanPengeluaranList.length,
              itemBuilder: (context, index) {
                final pengeluaran = laporanPengeluaranList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(pengeluaran["no"].toString()),
                    ),
                    title: Text(pengeluaran["nama"]),
                    subtitle: Text(pengeluaran["jenis"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pengeluaran["nominal"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pengeluaran["tanggal"],
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String result) {
                            if (result == 'detail') {
                              print('Detail ${pengeluaran["nama"]}');
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'detail',
                              child: Text('Detail'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}