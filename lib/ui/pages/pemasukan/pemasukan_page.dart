import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';
import 'pemasukan_detail_page.dart';

class Pemasukan {
  final String sumber;
  final String kategori;
  final DateTime tanggal;
  final double nominal;
  final String? buktiPath;
  final DateTime? verifiedAt;
  final String? verifier;

  Pemasukan({
    required this.sumber,
    required this.kategori,
    required this.tanggal,
    required this.nominal,
    this.buktiPath,
    this.verifiedAt,
    this.verifier,
  });
}

class _ChipColor {
  final Color bg;
  final Color fg;
  const _ChipColor(this.bg, this.fg);
}

class PemasukanPage extends StatefulWidget {
  const PemasukanPage({super.key});

  @override
  State<PemasukanPage> createState() => _PemasukanPageState();
}

class _PemasukanPageState extends State<PemasukanPage> {
  final List<Pemasukan> _items = [
    Pemasukan(
      sumber: 'Iuran Warga',
      kategori: 'Iuran Bulanan',
      tanggal: DateTime(2025, 10, 19),
      nominal: 250000,
    ),
    Pemasukan(
      sumber: 'Sumbangan RW',
      kategori: 'Donasi',
      tanggal: DateTime(2025, 10, 18),
      nominal: 150000,
    ),
    Pemasukan(
      sumber: 'Kerja Bakti',
      kategori: 'Kegiatan Warga',
      tanggal: DateTime(2025, 10, 17),
      nominal: 60000,
    ),
    Pemasukan(
      sumber: 'Sponsorship',
      kategori: 'Eksternal',
      tanggal: DateTime(2025, 10, 2),
      nominal: 200000,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _sumberCtrl = TextEditingController();
  final _kategoriCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  DateTime? _pickedDate;
  String? _buktiPath;

  final _fSumberCtrl = TextEditingController();
  String? _fKategori;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Pemasukan> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = List<Pemasukan>.from(_items);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM y', 'id_ID').format(date);
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(value);
  }

  bool _withinRange(DateTime d) {
    if (_fromDate == null && _toDate == null) return true;
    final date = DateTime(d.year, d.month, d.day);
    var ok = true;
    if (_fromDate != null) {
      final f = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
      ok &= !date.isBefore(f);
    }
    if (_toDate != null) {
      final t = DateTime(_toDate!.year, _toDate!.month, _toDate!.day)
          .add(const Duration(days: 1));
      ok &= date.isBefore(t);
    }
    return ok;
  }

  void _applyFilter() {
    final qNama = _fSumberCtrl.text.trim().toLowerCase();
    final qKat = (_fKategori ?? '').trim().toLowerCase();
    setState(() {
      _filtered = _items.where((e) {
        final byNama = qNama.isEmpty || e.sumber.toLowerCase().contains(qNama);
        final byKat = qKat.isEmpty || e.kategori.toLowerCase().contains(qKat);
        final byDate = _withinRange(e.tanggal);
        return byNama && byKat && byDate;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _fSumberCtrl.clear();
      _fKategori = null;
      _fromDate = null;
      _toDate = null;
      _filtered = List<Pemasukan>.from(_items);
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
                  'Filter Pemasukan',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fSumberCtrl,
                  decoration: const InputDecoration(labelText: 'Sumber'),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final categories =
                        _items.map((e) => e.kategori).toSet().toList()
                          ..sort((a, b) =>
                              a.toLowerCase().compareTo(b.toLowerCase()));
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      isExpanded: true,
                      value: _fKategori,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Semua'),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _fKategori = v),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dari Tanggal'),
                          const SizedBox(height: 4),
                          Text(
                            _fromDate == null
                                ? '-'
                                : _formatDate(_fromDate!),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _fromDate ?? now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _fromDate = d);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Pilih'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sampai Tanggal'),
                          const SizedBox(height: 4),
                          Text(
                            _toDate == null
                                ? '-'
                                : _formatDate(_toDate!),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _toDate ?? now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _toDate = d);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Pilih'),
                    ),
                  ],
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

  _ChipColor _chipColors(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'iuran bulanan':
        return _ChipColor(Colors.green.shade100, Colors.green.shade900);
      case 'donasi':
        return _ChipColor(Colors.blue.shade100, Colors.blue.shade900);
      case 'kegiatan warga':
        return _ChipColor(Colors.purple.shade100, Colors.purple.shade900);
      case 'eksternal':
        return _ChipColor(Colors.teal.shade100, Colors.teal.shade900);
      default:
        return _ChipColor(Colors.grey.shade200, Colors.grey.shade800);
    }
  }

  Widget _kvRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pemasukanCard(Pemasukan item, int index) {
    final colors = _chipColors(item.kategori);
    final theme = Theme.of(context);
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
                        'Nominal',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.nominal),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(item.kategori),
                  backgroundColor: colors.bg,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: colors.fg,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('Sumber', item.sumber),
            const Divider(height: 1),
            _kvRow('Tanggal', _formatDate(item.tanggal)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push(AppRoutes.pemasukanDetail, extra: item);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() async {
    _pickedDate = DateTime.now();
    _sumberCtrl.clear();
    _kategoriCtrl.clear();
    _nominalCtrl.clear();
    _buktiPath = null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pemasukan'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _sumberCtrl,
                    decoration: const InputDecoration(labelText: 'Sumber'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _kategoriCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kategori Pemasukan',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _nominalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Masukkan angka'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _buktiPath != null
                              ? 'Bukti: '
                                  '${_buktiPath!.split(RegExp(r"[\\\\/]+")).last}'
                              : 'Belum ada bukti',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              _buktiPath = result.files.single.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Bukti'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _pickedDate != null
                              ? 'Tanggal: ${_formatDate(_pickedDate!)}'
                              : 'Pilih tanggal',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _pickedDate ?? now,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setState(() => _pickedDate = d);
                          }
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
                if (_formKey.currentState!.validate() && _pickedDate != null) {
                  setState(() {
                    _items.add(
                      Pemasukan(
                        sumber: _sumberCtrl.text,
                        kategori: _kategoriCtrl.text,
                        tanggal: _pickedDate!,
                        nominal: double.parse(_nominalCtrl.text),
                        buktiPath: _buktiPath,
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
        );
      },
    );
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
        title: const Text('Daftar Pemasukan', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                itemBuilder: (context, i) => _pemasukanCard(_filtered[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
