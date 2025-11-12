import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/router/app_router.dart';
import 'package:jawara/viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text('Jawara Pintar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Selamat Datang',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    'Login untuk mengakses sistem Jawara Pintar.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                                'Masuk ke akun anda',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('Email', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(
                                hintText: 'Masukkan email disini',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Wajib diisi';
                                if (!v.contains('@')) return 'Email tidak valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            Text('Password', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Masukkan password disini',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Wajib diisi';
                                if (v.length < 6) return 'Minimal 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 44,
                              child: Consumer<LoginViewModel>(
                                builder: (context, viewModel, _) => 
                                  viewModel.isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _handleLogin(context),
                                        child: const Text('Login'),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('Belum punya akun?', style: theme.textTheme.bodyMedium),
                                  TextButton(
                                    onPressed: () => context.push(AppRoutes.register),
                                    child: const Text('Daftar'),
                                  ),
                                ],
                              ),
                            ),
                            if (context.watch<LoginViewModel>().hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    border: Border.all(color: Colors.red[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    context.read<LoginViewModel>().error ?? '',
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
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

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LoginViewModel>();

    final success = await viewModel.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil')),
        );
        context.go(AppRoutes.home);
      } else {
        // Error message already shown in UI via Consumer
      }
    }
  }
}
