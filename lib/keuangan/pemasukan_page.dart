import 'package:flutter/material.dart';

class PemasukanPage extends StatefulWidget {
  const PemasukanPage({super.key});

  @override
  State<PemasukanPage> createState() => _PemasukanPageState();
}

class _PemasukanPageState extends State<PemasukanPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _dateController = TextEditingController();

  final List<Map<String, dynamic>> iuranList = [
    {"no": 1, "nama": "asad", "jenis": "Iuran Khusus", "nominal": "Rp 3.000,00"},
    {"no": 2, "nama": "yyy", "jenis": "Iuran Bulanan", "nominal": "Rp 5.000,00"},
    {"no": 3, "nama": "Harian", "jenis": "Iuran Khusus", "nominal": "Rp 2,00"},
    {"no": 4, "nama": "Kerja Bakti", "jenis": "Iuran Khusus", "nominal": "Rp 5,00"},
    {
      "no": 5,
      "nama": "Bersih Desa",
      "jenis": "Iuran Khusus",
      "nominal": "Rp 200.000,00"
    },
  ];

  final List<Map<String, dynamic>> tagihanList = [
    {
      "no": 1,
      "nama": "Keluarga Habibie Ed Dien",
      "status": "Aktif",
      "iuran": "Mingguan",
      "kode": "IR175458A501",
      "nominal": "Rp 10,00",
      "periode": "8 Oktober 2025"
    },
    {
      "no": 2,
      "nama": "Keluarga Habibie Ed Dien",
      "status": "Aktif",
      "iuran": "Mingguan",
      "kode": "IR185702KX01",
      "nominal": "Rp 10,00",
      "periode": "15 Oktober 2025"
    },
    {
      "no": 3,
      "nama": "Keluarga Mara Nunez",
      "status": "Aktif",
      "iuran": "Mingguan",
      "kode": "IR223936NM01",
      "nominal": "Rp 10,00",
      "periode": "30 September 2025"
    },
  ];

  final List<Map<String, dynamic>> pemasukanLainList = [
    {
      "no": 1,
      "nama": "aaaaa",
      "jenis": "Dana Bantuan Pemerintah",
      "tanggal": "15 Oktober 2025",
      "nominal": "Rp 11,00"
    },
    {
      "no": 2,
      "nama": "Joki by firman",
      "jenis": "Pendapatan Lainnya",
      "tanggal": "13 Oktober 2025",
      "nominal": "Rp 49.999.997,00"
    },
    {
      "no": 3,
      "nama": "tes",
      "jenis": "Pendapatan Lainnya",
      "tanggal": "12 Agustus 2025",
      "nominal": "Rp 10.000,00"
    },
  ];

  void _showTambahIuranDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Buat Iuran Baru",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Masukkan data iuran baru dengan lengkap."),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Nama Iuran"),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Masukkan nama iuran",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Jumlah"),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Masukkan jumlah",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text("Kategori Iuran"),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        hint: const Text("-- Pilih Kategori --"),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: "bulanan",
                            child: Text("Iuran Bulanan"),
                          ),
                          const DropdownMenuItem(
                            value: "khusus",
                            child: Text("Iuran Khusus"),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Batal"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Simpan"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTagihIuranDialog() {
    final List<String> jenisTagihan = [
      "Agustusan",
      "Mingguan",
      "Bersih Desa",
      "Kerja Bakti",
      "Harian"
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tagih Iuran",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Tagih iuran ke semua keluarga aktif."),
                const SizedBox(height: 20),
                const Text("Jenis Iuran"),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  hint: const Text("-- Pilih Iuran --"),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  items: jenisTagihan
                      .map((jenis) => DropdownMenuItem(
                            value: jenis,
                            child: Text(jenis),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 20),
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
                      child: const Text("Tagih Iuran"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTambahPemasukanDialog() {
    final List<String> kategoriPemasukan = [
      "Donasi",
      "Dana Bantuan Pemerintah",
      "Sumbangan Swadaya",
      "Hasil Usaha Kampung",
      "Pendapatan Lainnya"
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Buat Pemasukan Non Iuran",
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
                  const SizedBox(height: 20),
                  const Text("Nama Pemasukan"),
                  const SizedBox(height: 5),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Masukkan nama pemasukan",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Tanggal Pemasukan"),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _dateController,
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
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        setState(() {
                          _dateController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Kategori pemasukan"),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    hint: const Text("-- Pilih Kategori --"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    items: kategoriPemasukan
                        .map((kategori) => DropdownMenuItem(
                              value: kategori,
                              child: Text(kategori),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  const Text("Nominal"),
                  const SizedBox(height: 5),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Masukkan nama pemasukan",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const Text("Bukti Pemasukan"),
                  const SizedBox(height: 5),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "Upload bukti pemasukan (.png/.jpg)",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        child: const Text("Submit"),
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pemasukan'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Kategori Iuran"),
              Tab(text: "Tagihan"),
              Tab(text: "Pemasukan Lain"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildKategoriIuranView(),
            _buildTagihanView(),
            _buildPemasukanLainView(),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriIuranView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Card(
            color: Colors.blue.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(
                        text: "Info:\n",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "Iuran Bulanan: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "Dibayar setiap bulan sekali secara rutin.\n"),
                    TextSpan(
                        text: "Iuran Khusus: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            "Dibayar sesuai jadwal atau kebutuhan tertentu, misalnya iuran untuk acara khusus, renovasi, atau kegiatan lain yang tidak rutin."),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Tambah Iuran"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showTambahIuranDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: iuranList.length,
              itemBuilder: (context, index) {
                final item = iuranList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(item["no"].toString()),
                    ),
                    title: Text(item["nama"]),
                    subtitle: Text(item["jenis"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item["nominal"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String result) {
                            if (result == 'detail') {
                              print('Detail ${item["nama"]}');
                            } else if (result == 'edit') {
                              print('Edit ${item["nama"]}');
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'detail',
                              child: Text('Detail'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
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

  Widget _buildTagihanView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text("Tagih Iuran"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showTagihIuranDialog,
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.filter_alt, size: 18),
                        SizedBox(width: 8),
                        Text("Filter"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.print, size: 18),
                        SizedBox(width: 8),
                        Text("Cetak PDF"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: tagihanList.length,
              itemBuilder: (context, index) {
                final tagihan = tagihanList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(tagihan["no"].toString()),
                    ),
                    title: Text(tagihan["nama"]),
                    subtitle: Text(
                      "${tagihan['iuran']} - ${tagihan['kode']}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tagihan["nominal"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(tagihan['status']),
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

  Widget _buildPemasukanLainView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Tambah Pemasukan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showTambahPemasukanDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: pemasukanLainList.length,
              itemBuilder: (context, index) {
                final pemasukan = pemasukanLainList[index];
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

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}