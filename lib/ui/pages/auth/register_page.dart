import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jawara/router/app_router.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();

  String? _jenisKelamin;
  String? _agama;
  String? _golonganDarah;
  File? _fotoIdentitas;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _fotoIdentitas = File(picked.path));
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<RegisterViewModel>();

    final success = await viewModel.registerWarga(
      namaLengkap: _namaCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      noHp: _telpCtrl.text.trim(),
      jenisKelamin: _jenisKelamin ?? '',
      agama: _agama ?? '',
      golonganDarah: _golonganDarah ?? '',
      pekerjaan: _pekerjaanCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      confirmPassword: _confirmCtrl.text.trim(),
      fotoIdentitas: _fotoIdentitas,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Akun berhasil dibuat. Silakan login.')),
        );
        context.go(AppRoutes.login);
      } else {
        final error = viewModel.error ?? 'Gagal mendaftar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftar: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _emailCtrl.dispose();
    _telpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _pekerjaanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Daftar Akun", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  _input("Nama Lengkap", _namaCtrl),
                  _input("NIK", _nikCtrl),
                  _input("Email", _emailCtrl),
                  _input("No Telepon", _telpCtrl),
                  _input("Pekerjaan", _pekerjaanCtrl),
                  _jenisKelaminDropdown(),
                  _agamaDropdown(),
                  _golonganDarahDropdown(),
                  _password("Password", _passCtrl),
                  _password("Konfirmasi Password", _confirmCtrl,
                      validator: (v) => v == _passCtrl.text ? null : "Password tidak cocok"),

                  const SizedBox(height: 20),

                  // Foto KTP
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          const SizedBox(width: 12),
                          Text(_fotoIdentitas == null ? "Upload Foto Identitas (KTP)" : "Foto terpilih"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) _handleRegister(context);
                      },
                      child: const Text("Buat Akun"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Wajib diisi';
        if (label == 'Email') {
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(v.trim())) {
            return 'Format email tidak valid (contoh: user@example.com)';
          }
        }
        return null;
      },
    ),
  );

  Widget _password(String label, TextEditingController ctrl, {String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          obscureText: true,
          decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
          validator: validator ?? (v) => (v == null || v.length < 6) ? "Minimal 6 karakter" : null,
        ),
      );

  Widget _jenisKelaminDropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: _jenisKelamin,
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
      ],
      onChanged: (value) {
        setState(() => _jenisKelamin = value);
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih jenis kelamin' : null,
    ),
  );

  Widget _agamaDropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: _agama,
      decoration: InputDecoration(
        labelText: 'Agama',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Islam', child: Text('Islam')),
        DropdownMenuItem(value: 'Kristen', child: Text('Kristen')),
        DropdownMenuItem(value: 'Katolik', child: Text('Katolik')),
        DropdownMenuItem(value: 'Hindu', child: Text('Hindu')),
        DropdownMenuItem(value: 'Buddha', child: Text('Buddha')),
        DropdownMenuItem(value: 'Konghucu', child: Text('Konghucu')),
      ],
      onChanged: (value) {
        setState(() => _agama = value);
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih agama' : null,
    ),
  );

  Widget _golonganDarahDropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: _golonganDarah,
      decoration: InputDecoration(
        labelText: 'Golongan Darah',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'O+', child: Text('O+')),
        DropdownMenuItem(value: 'O-', child: Text('O-')),
        DropdownMenuItem(value: 'A+', child: Text('A+')),
        DropdownMenuItem(value: 'A-', child: Text('A-')),
        DropdownMenuItem(value: 'B+', child: Text('B+')),
        DropdownMenuItem(value: 'B-', child: Text('B-')),
        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
      ],
      onChanged: (value) {
        setState(() => _golonganDarah = value);
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih golongan darah' : null,
    ),
  );
}
