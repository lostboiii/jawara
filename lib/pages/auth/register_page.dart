import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';

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

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _emailCtrl.dispose();
    _telpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigo[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.menu_book, color: Colors.indigo[700]),
                      ),
                      const SizedBox(width: 12),
                      Text('Jawara Pintar.',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                'Daftar Akun',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Lengkapi formulir untuk membuat akun',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _input('Nama Lengkap', _namaCtrl, hint: 'Masukkan nama lengkap', width: 340),
                                _input('NIK', _nikCtrl, hint: 'Masukkan NIK sesuai KTP', width: 340),
                                _input('Email', _emailCtrl, hint: 'Masukkan email aktif', width: 340),
                                _input('No Telepon', _telpCtrl, hint: '08xxxxxxxx', width: 340),
                                _password('Password', _passCtrl, width: 340),
                                _password('Konfirmasi Password', _confirmCtrl, width: 340,
                                    validator: (v) => v == _passCtrl.text ? null : 'Password tidak cocok'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Akun berhasil dibuat')),
                                    );
                                    context.go(AppRoutes.login);
                                  }
                                },
                                child: const Text('Buat Akun'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('Sudah punya akun?', style: theme.textTheme.bodyMedium),
                                  TextButton(
                                    onPressed: () => context.go(AppRoutes.login),
                                    child: const Text('Masuk'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _input(String label, TextEditingController ctrl, {String? hint, double? width, String? Function(String?)? validator}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _password(String label, TextEditingController ctrl, {double? width, String? Function(String?)? validator}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: validator ?? (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
