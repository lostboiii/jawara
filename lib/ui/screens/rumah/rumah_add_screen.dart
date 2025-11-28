// lib/screens/rumah/rumah_add_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';

class RumahAddScreen extends StatefulWidget {
  const RumahAddScreen({super.key});

  @override
  _RumahAddScreenState createState() => _RumahAddScreenState();
}

class _RumahAddScreenState extends State<RumahAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alamatCtrl = TextEditingController();
  String? _statusRumah;

  @override
  void dispose() {
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('rumah-list'),
        ),
        title: const Text('Tambah Rumah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alamatCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text('Status Rumah', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _statusRumah,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[50]),
                items: const [
                  DropdownMenuItem(value: 'ditempati', child: Text('ditempati')),
                  DropdownMenuItem(value: 'kosong', child: Text('kosong')),
                ],
                onChanged: (v) => setState(() => _statusRumah = v),
                validator: (v) => v == null || v.isEmpty ? 'Status rumah wajib dipilih' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  try {
                    final vm = context.read<RegisterViewModel>();
                    final created = await vm.createRumah(
                      alamat: _alamatCtrl.text.trim(),
                      statusRumah: _statusRumah ?? 'ditempati',
                    );
                    if (mounted) context.goNamed('rumah-list');
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan rumah: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}