import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mutasi_keluarga_detail_page.dart';

class MutasiKeluargaItem {
  final String keluarga;
  final String alamatLama;
  final String alamatBaru;
  final DateTime tanggal;
  final String jenis; 
  final String alasan;

  MutasiKeluargaItem({
    required this.keluarga,
    required this.alamatLama,
    required this.alamatBaru,
    required this.tanggal,
    required this.jenis,
    required this.alasan,
  });
}

class MutasiKeluargaPage extends StatefulWidget {
  const MutasiKeluargaPage({super.key});

  @override
  State<MutasiKeluargaPage> createState() => _MutasiKeluargaPageState();
}

class _MutasiKeluargaPageState extends State<MutasiKeluargaPage> {
  final List<MutasiKeluargaItem> _items = [
    MutasiKeluargaItem(
      keluarga: 'Keluarga Ijat',
      alamatLama: 'Surabaya, Jl. Merpati No. 10',
      alamatBaru: 'Kediri, Jl. Kenari No. 5',
      tanggal: DateTime(2025, 10, 15),
      jenis: 'Keluar Wilayah',
      alasan: 'Karena mau keluar',
    ),
    MutasiKeluargaItem(
      keluarga: 'Keluarga Mara Nunez',
      alamatLama: 'Quis consequatur nob',
      alamatBaru: 'Malang',
      tanggal: DateTime(2025, 9, 30),
      jenis: 'Pindah Rumah',
      alasan: '',
    ),
    MutasiKeluargaItem(
      keluarga: 'Keluarga Opo',
      alamatLama: 'Malang, Jl. Merpati No. 10',
      alamatBaru: 'Kediri, Jl. Kenari No. 5',
      tanggal: DateTime(2025, 10, 15),
      jenis: 'Pindah Rumah',
      alasan: 'terserah gue',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _keluargaCtrl = TextEditingController();
  final _alamatLamaCtrl = TextEditingController();
  final _alamatBaruCtrl = TextEditingController();
  String _jenis = 'Pindah Rumah';
  final _alasanCtrl = TextEditingController();
  DateTime? _pickedDate = DateTime.now();

  // Filter states (dropdowns)
  String? _fNama; // selected keluarga name
  String? _fJenis; // selected jenis mutasi
  List<MutasiKeluargaItem> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = List<MutasiKeluargaItem>.from(_items);
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  void _applyFilter() {
    setState(() {
      _filtered = _items.where((e) {
        final byNama = _fNama == null || e.keluarga == _fNama;
        final byJenis = _fJenis == null || e.jenis == _fJenis;
        return byNama && byJenis;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _fNama = null;
      _fJenis = null;
      _filtered = List<MutasiKeluargaItem>.from(_items);
    });
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter Mutasi Keluarga',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _fNama,
                  decoration: const InputDecoration(labelText: 'Nama Keluarga'),
                  isExpanded: true,
                  items: _items
                      .map((e) => e.keluarga)
                      .toSet()
                      .toList()
                      .map(
                        (n) =>
                            DropdownMenuItem<String>(value: n, child: Text(n)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _fNama = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _fJenis,
                  decoration: const InputDecoration(labelText: 'Jenis Mutasi'),
                  isExpanded: true,
                  items: _items
                      .map((e) => e.jenis)
                      .toSet()
                      .toList()
                      .map(
                        (j) =>
                            DropdownMenuItem<String>(value: j, child: Text(j)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _fJenis = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _resetFilter();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          _applyFilter();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Terapkan'),
                      ),
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

  // Chip warna sederhana berdasarkan jenis
  Color _chipBg(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'masuk wilayah':
        return Colors.green.shade100;
      case 'keluar wilayah':
        return Colors.red.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  Color _chipFg(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'masuk wilayah':
        return Colors.green.shade900;
      case 'keluar wilayah':
        return Colors.red.shade900;
      default:
        return Colors.blue.shade900;
    }
  }

  Widget _kvRow(String label, String value) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: t.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutasiCard(MutasiKeluargaItem m, int index) {
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keluarga',
                        style: t.labelLarge?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.keluarga,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(m.jenis),
                  backgroundColor: _chipBg(m.jenis),
                  labelStyle: t.labelMedium?.copyWith(color: _chipFg(m.jenis)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('Alamat Lama', m.alamatLama),
            const Divider(height: 1),
            _kvRow('Alamat Baru', m.alamatBaru),
            const Divider(height: 1),
            _kvRow('Tanggal', _formatDate(m.tanggal)),
            const Divider(height: 1),
            _kvRow('Alasan', m.alasan),

            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MutasiKeluargaDetailPage(item: m),
                  ),
                );
              },
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() async {
    _keluargaCtrl.clear();
    _alamatLamaCtrl.clear();
    _alamatBaruCtrl.clear();
    _alasanCtrl.clear();
    _jenis = 'Pindah Rumah';
    _pickedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Mutasi Keluarga'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _keluargaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Keluarga'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _alamatLamaCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat Lama'),
                ),
                TextFormField(
                  controller: _alamatBaruCtrl,
                  decoration: const InputDecoration(labelText: 'Alamat Baru'),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Jenis Mutasi'),
                  initialValue: _jenis,
                  items: const [
                    DropdownMenuItem(
                      value: 'Pindah Rumah',
                      child: Text('Pindah Rumah'),
                    ),
                    DropdownMenuItem(
                      value: 'Masuk Wilayah',
                      child: Text('Masuk Wilayah'),
                    ),
                    DropdownMenuItem(
                      value: 'Keluar Wilayah',
                      child: Text('Keluar Wilayah'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _jenis = v ?? 'Pindah Rumah'),
                ),
                TextFormField(
                  controller: _alasanCtrl,
                  decoration: const InputDecoration(labelText: 'Alasan'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('Tanggal: ${_formatDate(_pickedDate!)}'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _pickedDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _pickedDate = d);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pilih'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _items.add(
                    MutasiKeluargaItem(
                      keluarga: _keluargaCtrl.text,
                      alamatLama: _alamatLamaCtrl.text,
                      alamatBaru: _alamatBaruCtrl.text,
                      tanggal: _pickedDate!,
                      jenis: _jenis,
                      alasan: _alasanCtrl.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mutasi Keluarga')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _mutasiCard(_filtered[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
