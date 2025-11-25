// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/kegiatan_viewmodel.dart';

class CreateKegiatanPage extends StatefulWidget {
  const CreateKegiatanPage({super.key});

  @override
  State<CreateKegiatanPage> createState() => _CreateKegiatanPageState();
}

class _CreateKegiatanPageState extends State<CreateKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _penanggungJawabController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalController = TextEditingController();

  DateTime? _selectedTanggal;
  String? _selectedKategori;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _penanggungJawabController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<KegiatanViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kegiatan'),
        ),
        title: const Text('Buat Kegiatan Baru', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel('Nama Kegiatan'),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Musyawarah Warga',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kegiatan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Kategori Kegiatan'),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('-- Pilih Kategori --'),
                  items: const [
                    DropdownMenuItem(
                      value: 'komunitas & sosial',
                      child: Text('Komunitas & Sosial'),
                    ),
                    DropdownMenuItem(
                      value: 'kebersihan & keamanan',
                      child: Text('Kebersihan & Keamanan'),
                    ),
                    DropdownMenuItem(
                      value: 'keagamaan',
                      child: Text('Keagamaan'),
                    ),
                    DropdownMenuItem(
                      value: 'pendidikan',
                      child: Text('Pendidikan'),
                    ),
                    DropdownMenuItem(
                      value: 'kesehatan & olahraga',
                      child: Text('Kesehatan & Olahraga'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedKategori = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Tanggal Kegiatan'),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal kegiatan',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    contentPadding: const EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  controller: _tanggalController,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedTanggal ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedTanggal = date;
                        _tanggalController.text = DateFormat('dd/MM/yyyy').format(date);
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedTanggal == null) {
                      return 'Tanggal harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Lokasi Kegiatan'),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Balai RT 03',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Penanggung Jawab'),
                TextFormField(
                  controller: _penanggungJawabController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Pak RT atau Bu RW',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Deskripsi'),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan detail kegiatan seperti agenda, keperluan, dll.',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() {
                                  _isSubmitting = true;
                                });
                                try {
                                  await viewModel.addKegiatan(
                                    nama: _namaController.text.trim(),
                                    kategori: _selectedKategori!,
                                    tanggal: _selectedTanggal,
                                    lokasi: _lokasiController.text.trim().isEmpty
                                        ? null
                                        : _lokasiController.text.trim(),
                                    penanggungJawab:
                                        _penanggungJawabController.text.trim().isEmpty
                                            ? null
                                            : _penanggungJawabController.text.trim(),
                                    deskripsi: _deskripsiController.text.trim().isEmpty
                                        ? null
                                        : _deskripsiController.text.trim(),
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kegiatan berhasil dibuat'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  context.go('/kegiatan');
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal membuat kegiatan: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSubmitting = false;
                                    });
                                  }
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _handleReset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Reset', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleReset() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _lokasiController.clear();
    _penanggungJawabController.clear();
    _deskripsiController.clear();
    _tanggalController.clear();
    setState(() {
      _selectedTanggal = null;
      _selectedKategori = null;
    });
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
