import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../router/app_router.dart';
import '../../../data/models/pemasukan_model.dart';
import '../../../viewmodels/pemasukan_viewmodel.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _namaPemasukanCtrl = TextEditingController();
  final _kategoriCtrl = TextEditingController();
  String? _selectedKategori;
  final List<String> _kategoriOptions = [
    'Unnest',
    'Donasi',
    'Dana Bantuan Pemerintah',
    'Sumbangan Swadaya',
    'Hasil Uang Kampung',
    'Lain-lain',
  ];
  final _jumlahCtrl = TextEditingController();
  DateTime? _pickedDate;
  PlatformFile? _selectedFile;

  final _fNamaPemasukanCtrl = TextEditingController();
  String? _fKategori;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();

    // Load data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PemasukanViewModel>().loadPemasukan();
    });
  }

  @override
  void dispose() {
    _namaPemasukanCtrl.dispose();
    _kategoriCtrl.dispose();
    _jumlahCtrl.dispose();
    _fNamaPemasukanCtrl.dispose();
    super.dispose();
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

  Future<void> _applyFilter() async {
    final viewModel = context.read<PemasukanViewModel>();
    await viewModel.filterPemasukan(
      nama: _fNamaPemasukanCtrl.text.trim(),
      kategori: _fKategori?.isEmpty ?? true ? null : _fKategori,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  void _resetFilter() {
    setState(() {
      _fNamaPemasukanCtrl.clear();
      _fKategori = null;
      _fromDate = null;
      _toDate = null;
    });
    context.read<PemasukanViewModel>().loadPemasukan();
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
              children: [
                Text(
                  'Filter Pemasukan',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fNamaPemasukanCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pemasukan'),
                ),
                const SizedBox(height: 8),
                Consumer<PemasukanViewModel>(
                  builder: (context, viewModel, _) {
                    final categories = viewModel.items
                        .map((e) => e.kategori_pemasukan)
                        .toSet()
                        .toList()
                      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      isExpanded: true,
                      value: _fKategori,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
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
                      child: Text(_fromDate == null ? '-' : _formatDate(_fromDate!)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _fromDate = d);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Dari'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(_toDate == null ? '-' : _formatDate(_toDate!)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _toDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _toDate = d);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Sampai'),
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
                        onPressed: () async {
                          await _applyFilter();
                          if (ctx.mounted) Navigator.pop(ctx);
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
                style: textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pemasukanCard(PemasukanModel item, int index) {
    final kategori = item.kategori_pemasukan;
    final colors = _chipColors(kategori);
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nominal',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.jumlah),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(kategori),
                  backgroundColor: colors.bg,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(color: colors.fg),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('Nama', item.nama_pemasukan),
            const Divider(height: 1),
            _kvRow('Tanggal', _formatDate(item.tanggal_pemasukan)),
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
    _namaPemasukanCtrl.clear();
    _kategoriCtrl.clear();
    _jumlahCtrl.clear();
    _selectedFile = null;
    _selectedKategori = null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Pemasukan'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _namaPemasukanCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Pemasukan'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Kategori Pemasukan'),
                        value: _selectedKategori,
                        items: _kategoriOptions
                            .map((category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => _selectedKategori = value);
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: _jumlahCtrl,
                        decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || double.tryParse(v) == null) ? 'Masukkan angka' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedFile != null
                                  ? 'Bukti: ${_selectedFile!.name}'
                                  : 'Belum ada bukti',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles();
                              if (result != null) {
                                setDialogState(() => _selectedFile = result.files.first);
                              }
                            },
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload'),
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
                                  : 'Pilih Tanggal',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _pickedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) {
                                setDialogState(() => _pickedDate = d);
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _pickedDate != null) {
                      try {
                        final viewModel = context.read<PemasukanViewModel>();

                        String? buktiUrl;
                        if (_selectedFile != null && _selectedFile!.bytes != null) {
                          buktiUrl = await viewModel.repository.uploadBukti(
                            _selectedFile!.name,
                            _selectedFile!.bytes!,
                          );
                        }

                        await viewModel.addPemasukan(
                          nama_pemasukan: _namaPemasukanCtrl.text,
                          tanggal_pemasukan: _pickedDate!,
                          kategori_pemasukan: _selectedKategori ?? '',
                          jumlah: double.parse(_jumlahCtrl.text),
                          bukti_pemasukan: buktiUrl,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pemasukan berhasil ditambahkan')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            );
          },
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
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Daftar Pemasukan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Consumer<PemasukanViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadPemasukan(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return Padding(
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
                  child: viewModel.items.isEmpty
                      ? const Center(child: Text('Belum ada data pemasukan'))
                      : RefreshIndicator(
                          onRefresh: () => viewModel.loadPemasukan(),
                          child: ListView.builder(
                            itemCount: viewModel.items.length,
                            itemBuilder: (context, i) =>
                                _pemasukanCard(viewModel.items[i], i),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}