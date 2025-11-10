import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateBroadcastPage extends StatefulWidget {
  const CreateBroadcastPage({super.key});

  @override
  State<CreateBroadcastPage> createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _buildUploadField(
                  'Foto',
                  'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar.',
                  'Upload foto png/jpg',
                  100,
                ),
                const SizedBox(height: 20),

                // Dokumen Upload
                _buildUploadField(
                  'Dokumen',
                  'Maksimal 10 file (.pdf), ukuran maksimal 5MB per file.',
                  'Upload dokumen pdf',
                  70,
                ),
                const SizedBox(height: 30),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Handle submit
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Broadcast berhasil dikirim'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.go('/broadcast-warga');
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
                          _judulController.clear();
                          _isiController.clear();
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

  Widget _buildUploadField(String title, String subtitle, String hint, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(title),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur upload akan segera hadir')),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: height,
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
                    hint,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}