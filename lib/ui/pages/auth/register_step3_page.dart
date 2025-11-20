import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_router.dart';
import '../../../viewmodels/register_viewmodel.dart';

class RegisterStep3Page extends StatefulWidget {
  const RegisterStep3Page({super.key});

  @override
  State<RegisterStep3Page> createState() => _RegisterStep3PageState();
}

class _RegisterStep3PageState extends State<RegisterStep3Page> {
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _confirmCtrl;
  bool _obscure1 = true;
  bool _obscure2 = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegisterViewModel>();
    _passwordCtrl = TextEditingController(text: vm.cachePassword);
    _confirmCtrl = TextEditingController(text: vm.cacheConfirmPassword);
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _persist() {
    final vm = context.read<RegisterViewModel>();
    vm.setPassword(_passwordCtrl.text);
    vm.setConfirmPassword(_confirmCtrl.text);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _persist();
    final vm = context.read<RegisterViewModel>();

    final passwordError =
        vm.validatePassword(vm.cachePassword, vm.cacheConfirmPassword);
    if (passwordError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(passwordError)));
      return;
    }

    // Simplified registration without keluarga
    final success = await vm.registerWarga(
      namaLengkap: vm.cacheNamaLengkap,
      nik: vm.cacheNik,
      email: vm.cacheEmail,
      noHp: vm.cacheNoHp,
      jenisKelamin: vm.cacheJenisKelamin,
      agama: vm.cacheAgama.isEmpty ? 'islam' : vm.cacheAgama.toLowerCase(),
      golonganDarah:
          vm.cacheGolonganDarah.isEmpty ? 'O' : vm.cacheGolonganDarah,
      pekerjaan: vm.cacheStatus,
      password: vm.cachePassword,
      confirmPassword: vm.cacheConfirmPassword,
      peranKeluarga: 'warga',
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil. Silakan login.')));
      vm.clearRegistrationCache();
      context.go(AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.error ?? 'Gagal registrasi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff5067e9);
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          Positioned(
            top: -140,
            left: 220,
            child: Container(
              width: 252,
              height: 252,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 100,
                      spreadRadius: 1,
                      color: Color(0xffc5cefd))
                ],
              ),
            ),
          ),
          Positioned(
            top: -140,
            left: 220,
            child: Container(
              width: 252,
              height: 252,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xffc5cefd),
                  const Color(0xffc5cefd).withOpacity(.05),
                  const Color(0xffc5cefd).withOpacity(.01),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: primaryColor,
                      padding: EdgeInsets.zero,
                      onPressed: () => context.go(AppRoutes.registerStep2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Daftarkan\nAkun Anda',
                            style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: primaryColor)),
                        Image.asset(
                          'assets/images/register-pic.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _progressDots(step: 3),
                    const SizedBox(height: 28),
                    _label('Kata Sandi'),
                    _passwordField(_passwordCtrl, _obscure1,
                        () => setState(() => _obscure1 = !_obscure1)),
                    _label('Konfirmasi Kata Sandi'),
                    _passwordField(_confirmCtrl, _obscure2,
                        () => setState(() => _obscure2 = !_obscure2),
                        validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (v != _passwordCtrl.text) return 'Tidak cocok';
                      return null;
                    }),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        onPressed: _submit,
                        child: Text('Daftar',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressDots({required int step}) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: step == 1 ? const Color(0xff5067e9) : Colors.grey[300],
                shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: step == 2 ? const Color(0xff5067e9) : Colors.grey[300],
                shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: step == 3 ? const Color(0xff5067e9) : Colors.grey[300],
                shape: BoxShape.circle)),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5067e9))),
      );

  Widget _passwordField(
      TextEditingController c, bool obscured, VoidCallback toggle,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: c,
        obscureText: obscured,
        validator: validator ??
            (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
        decoration: InputDecoration(
          hintText: 'Masukkan Kata Sandi',
          suffixIcon: IconButton(
            icon: Icon(obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: toggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => _persist(),
      ),
    );
  }
}
