import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../viewmodels/broadcast_viewmodel.dart';
import '../../../data/repositories/broadcast_repository.dart';

class CreateBroadcastPage extends StatefulWidget {
  const CreateBroadcastPage({super.key});

  @override
  State<CreateBroadcastPage> createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  
  String? _fotoPath;
  List<int>? _fotoBytes;
  String? _dokumenPath;
  List<int>? _dokumenBytes;
  late BroadcastRepository _repository;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        _fotoPath = file.name;
        _fotoBytes = kIsWeb ? file.bytes?.toList() : null;
      });
    }
  }

  Future<void> _pickDokumen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        _dokumenPath = file.name;
        _dokumenBytes = kIsWeb ? file.bytes?.toList() : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final broadcastViewModel = context.watch<BroadcastViewModel>();
    final isLoading = broadcastViewModel.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/broadcast-warga'),
        ),
        title: const Text('Buat Broadcast Baru', style: TextStyle(fontWeight: FontWeight.w600)),
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
                // Judul Broadcast
                _buildFormLabel('Judul Broadcast'),
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan judul broadcast',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Isi Broadcast
                _buildFormLabel('Isi Broadcast'),
                TextFormField(
                  controller: _isiController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Tulis isi broadcast di sini...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi broadcast tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Foto Upload
                _buildFormLabel('Foto'),
                Text(
                  'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFoto,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, color: Colors.grey[600], size: 32),
                          const SizedBox(height: 4),
                          Text(
                            _fotoPath ?? 'Upload foto png/jpg',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dokumen Upload
                _buildFormLabel('Dokumen'),
                Text(
                  'Maksimal 10 file (.pdf), ukuran maksimal 5MB per file.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDokumen,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, color: Colors.grey[600], size: 32),
                          const SizedBox(height: 4),
                          Text(
                            _dokumenPath ?? 'Upload dokumen pdf',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                try {
                                  String? fotoUrl;
                                  String? dokumenUrl;

                                  // Upload foto jika ada
                                  if (_fotoBytes != null && _fotoPath != null) {
                                    try {
                                      fotoUrl = await _repository.uploadFoto(_fotoPath!, _fotoBytes!);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal upload foto: $e')),
                                      );
                                      return;
                                    }
                                  }

                                  // Upload dokumen jika ada
                                  if (_dokumenBytes != null && _dokumenPath != null) {
                                    try {
                                      dokumenUrl = await _repository.uploadDokumen(_dokumenPath!, _dokumenBytes!);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal upload dokumen: $e')),
                                      );
                                      return;
                                    }
                                  }

                                  await broadcastViewModel.addBroadcast(
                                    judul: _judulController.text.trim(),
                                    isi: _isiController.text.trim(),
                                    foto: fotoUrl,
                                    dokumen: dokumenUrl,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Broadcast berhasil disimpan'),
                                    ),
                                  );
                                  context.go('/broadcast-warga');
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menyimpan broadcast: $e'),
                                    ),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                _judulController.clear();
                                _isiController.clear();
                                setState(() {
                                  _fotoPath = null;
                                  _fotoBytes = null;
                                  _dokumenPath = null;
                                  _dokumenBytes = null;
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