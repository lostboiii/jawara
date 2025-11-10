import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _penanggungJawabController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedKategori;

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _lokasiController.dispose();
    _penanggungJawabController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
              children: <Widget>[
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
                    DropdownMenuItem(value: 'Sosial', child: Text('Sosial')),
                    DropdownMenuItem(value: 'Kesehatan', child: Text('Kesehatan')),
                    DropdownMenuItem(value: 'Keamanan', child: Text('Keamanan')),
                    DropdownMenuItem(value: 'Kerja Bakti', child: Text('Kerja Bakti')),
                    DropdownMenuItem(value: 'Rapat', child: Text('Rapat')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
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

                _buildFormLabel('Tanggal'),
                TextFormField(
                  controller: _tanggalController,
                  decoration: const InputDecoration(
                    hintText: '--/--/----',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026),
                    );
                    if (date != null) {
                      _tanggalController.text = 
                        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildFormLabel('Lokasi'),
                TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Bala RT 03',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi tidak boleh kosong';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Penanggung jawab tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildFormLabel('Deskripsi'),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan detail event seperti agenda, keperluan, dll.',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kegiatan berhasil dibuat'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.go('/');
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _namaController.clear();
                          _tanggalController.clear();
                          _lokasiController.clear();
                          _penanggungJawabController.clear();
                          _deskripsiController.clear();
                          setState(() {
                            _selectedKategori = null;
                          });
                        },
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

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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