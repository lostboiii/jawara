import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/pengeluaran_model.dart';
import '../../../viewmodels/pengeluaran_viewmodel.dart';
import '../../../router/app_router.dart';

class _ChipColor {
  final Color bg;
  final Color fg;
  const _ChipColor(this.bg, this.fg);
}

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  String? _selectedKategori;
  DateTime? _selectedDate;
  String? _buktiPath;
  PengeluaranModel? _editingItem;

  static const Map<String, String> _kategoriLabels = {
    'Operasional': 'Operasional',
    'Kegiatan Sosial': 'Kegiatan Sosial',
    'Pemeliharaan Fasilitas': 'Pemeliharaan Fasilitas',
    'Pembangunan': 'Pembangunan',
    'Kegiatan Warga': 'Kegiatan Warga',
    'Keamanan dan Kebersihan': 'Keamanan dan Kebersihan',
    'Lain-lain': 'Lain-lain',
  };

  static const Map<String, String> _legacyKategoriMap = {
    'operasional rt/rw': 'Operasional',
    'operasional_rt_rw': 'Operasional',
    'operasional': 'Operasional',
    'kegiatan warga': 'Kegiatan Warga',
    'kegiatan_warga': 'Kegiatan Warga',
    'kegiatan sosial': 'Kegiatan Sosial',
    'pemeliharaan fasilitas': 'Pemeliharaan Fasilitas',
    'pemeliharaan_fasilitas': 'Pemeliharaan Fasilitas',
    'pembangunan': 'Pembangunan',
    'keamanan': 'Keamanan dan Kebersihan',
    'keamanan dan kebersihan': 'Keamanan dan Kebersihan',
    'lainnya': 'Lain-lain',
    'lain lain': 'Lain-lain',
    'lain-lain': 'Lain-lain',
  };

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  String _formatCurrency(double value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      ).format(value);

  String _resolveKategoriValue(String value) {
    final trimmed = value.trim();
    if (_kategoriLabels.containsKey(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    final legacyMatch = _legacyKategoriMap[lower];
    if (legacyMatch != null) return legacyMatch;
    return trimmed;
  }

  _ChipColor _chipColors(String value) {
    final resolved = _resolveKategoriValue(value).toLowerCase();
    switch (resolved) {
      case 'kegiatan warga':
        return _ChipColor(Colors.amber.shade100, Colors.amber.shade900);
      case 'operasional':
        return _ChipColor(Colors.blue.shade100, Colors.blue.shade900);
      case 'pembangunan':
        return _ChipColor(Colors.green.shade100, Colors.green.shade900);
      case 'kegiatan sosial':
        return _ChipColor(Colors.orange.shade100, Colors.orange.shade900);
      case 'pemeliharaan fasilitas':
        return _ChipColor(Colors.pink.shade100, Colors.pink.shade900);
      case 'keamanan dan kebersihan':
        return _ChipColor(Colors.teal.shade100, Colors.teal.shade900);
      default:
        return _ChipColor(Colors.grey.shade200, Colors.grey.shade800);
    }
  }

  String _kategoriLabel(String value) {
    final resolved = _resolveKategoriValue(value);
    return _kategoriLabels[resolved] ?? resolved;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaCtrl.clear();
    _nominalCtrl.clear();
    _selectedKategori = null;
    _selectedDate = null;
    _buktiPath = null;
    _editingItem = null;
  }

  Future<void> _pickTanggal() async {
    final initial = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickBukti() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _buktiPath = result.files.single.path);
    }
  }

  void _showForm({PengeluaranModel? item}) {
    if (item != null) {
      _editingItem = item;
      _namaCtrl.text = item.namaPengeluaran;
      _nominalCtrl.text = item.jumlah.toStringAsFixed(2);
      final resolvedKategori = _resolveKategoriValue(item.kategoriPengeluaran);
      _selectedKategori =
          _kategoriLabels.containsKey(resolvedKategori) ? resolvedKategori : null;
      _selectedDate = item.tanggalPengeluaran;
      _buktiPath = item.buktiPengeluaran;
    } else {
      _resetForm();
      _selectedDate = DateTime.now();
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        final vm = context.watch<PengeluaranViewModel>();
        final isEditing = _editingItem != null;
        return AlertDialog(
          title: Text(isEditing ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Pengeluaran'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    decoration: const InputDecoration(labelText: 'Kategori Pengeluaran'),
                    items: _kategoriLabels.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedKategori = value),
                    validator: (value) => value == null || value.isEmpty
                      ? 'Kategori wajib dipilih'
                      : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nominalCtrl,
                    decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah wajib diisi';
                      }
                      final sanitized =
                          value.replaceAll('.', '').replaceAll(',', '.');
                      final parsed = double.tryParse(sanitized);
                      if (parsed == null) {
                        return 'Masukkan angka valid';
                      }
                      if (parsed <= 0) {
                        return 'Jumlah harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Pengeluaran'),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? '-'
                                  : _formatDate(_selectedDate!),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickTanggal,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Pilih'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _buktiPath == null || _buktiPath!.isEmpty
                              ? 'Belum ada bukti'
                              : 'Bukti: ${_buktiPath!.split(RegExp(r"[\\/]+")).last}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickBukti,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      if (!_validateForm()) return;
                      final sanitizedJumlah = _nominalCtrl.text
                          .replaceAll('.', '')
                          .replaceAll(',', '.');
                      final jumlah = double.parse(sanitizedJumlah);
                      final kategori = _selectedKategori!;
                      final tanggal = _selectedDate ?? DateTime.now();

                      try {
                        if (isEditing) {
                          await vm.updatePengeluaran(
                            id: _editingItem!.id,
                            nama: _namaCtrl.text.trim(),
                            kategori: kategori,
                            tanggal: tanggal,
                            jumlah: jumlah,
                            bukti: _buktiPath,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _showSnack('Pengeluaran diperbarui');
                          }
                        } else {
                          await vm.addPengeluaran(
                            nama: _namaCtrl.text.trim(),
                            kategori: kategori,
                            tanggal: tanggal,
                            jumlah: jumlah,
                            bukti: _buktiPath,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            _showSnack('Pengeluaran ditambahkan');
                          }
                        }
                      } catch (e) {
                        _showSnack('Gagal menyimpan data: $e');
                      } finally {
                        _resetForm();
                      }
                    },
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Simpan Perubahan' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  bool _validateForm() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return false;
    if (_selectedKategori == null || _selectedKategori!.isEmpty) {
      _showSnack('Kategori wajib dipilih');
      return false;
    }
    if (_selectedDate == null) {
      _showSnack('Tanggal pengeluaran wajib diisi');
      return false;
    }
    return true;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDelete(PengeluaranModel item) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final vm = context.watch<PengeluaranViewModel>();
        return AlertDialog(
          title: const Text('Hapus Pengeluaran'),
          content: Text('Hapus data "${item.namaPengeluaran}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      try {
                        await vm.deletePengeluaran(item.id);
                        if (mounted) {
                          Navigator.pop(context);
                          _showSnack('Pengeluaran dihapus');
                        }
                      } catch (e) {
                        _showSnack('Gagal menghapus: $e');
                      }
                    },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengeluaranViewModel>();
    final items = vm.items;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Daftar Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.isLoading ? null : () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
      body: Stack(
        children: [
          if (!vm.isLoading && vm.errorMessage != null && items.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Terjadi kesalahan saat memuat data.\n${vm.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  FilledButton(
                    onPressed: vm.loadPengeluaran,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            )
          else if (!vm.isLoading && items.isEmpty)
            Center(
              child: Text(
                'Belum ada data pengeluaran',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCard(item, index);
              },
            ),
          if (vm.isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(PengeluaranModel item, int index) {
    final kategoriValue = _resolveKategoriValue(item.kategoriPengeluaran);
    final colors = _chipColors(kategoriValue);
    final kategoriLabel = _kategoriLabel(kategoriValue);
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrency(item.jumlah),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.namaPengeluaran,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showForm(item: item);
                    } else if (value == 'delete') {
                      _confirmDelete(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Ubah')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(kategoriLabel),
                  backgroundColor: colors.bg,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(color: colors.fg),
                ),
                Chip(
                  label: Text('Tanggal: ${_formatDate(item.tanggalPengeluaran)}'),
                  backgroundColor: Colors.grey.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.pengeluaranDetail, extra: item),
                child: const Text('Lihat Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
