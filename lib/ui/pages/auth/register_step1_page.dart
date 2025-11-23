import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_router.dart';
import '../../../viewmodels/register_viewmodel.dart';

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _nikCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telpCtrl;

  String? _jenisKelamin;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegisterViewModel>();
    _namaCtrl = TextEditingController(text: vm.cacheNamaLengkap);
    _nikCtrl = TextEditingController(text: vm.cacheNik);
    _emailCtrl = TextEditingController(text: vm.cacheEmail);
    _telpCtrl = TextEditingController(text: vm.cacheNoHp);
    _jenisKelamin = vm.cacheJenisKelamin.isEmpty ? null : vm.cacheJenisKelamin;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _emailCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  void _persistData() {
    final vm = context.read<RegisterViewModel>();
    vm.setNamaLengkap(_namaCtrl.text);
    vm.setNik(_nikCtrl.text);
    vm.setEmail(_emailCtrl.text);
    vm.setNoHp(_telpCtrl.text);
    vm.setJenisKelamin(_jenisKelamin ?? '');
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    _persistData();
    context.go(AppRoutes.registerStep2);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff5067e9);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          // Blur circles
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
                      onPressed: () => context.go(AppRoutes.onboarding),
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
                    _progressDots(step: 1),
                    const SizedBox(height: 28),
                    _label('Nama'),
                    _textField(_namaCtrl, hint: 'Masukkan Nama Lengkap'),
                    _label('NIK'),
                    _textField(_nikCtrl,
                        keyboardType: TextInputType.number,
                        hint: 'Masukkan NIK'),
                    _label('Email'),
                    _textField(_emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'Masukkan Email',
                        validator: _emailValidator),
                    _label('Nomor Telepon'),
                    _textField(_telpCtrl,
                        keyboardType: TextInputType.phone,
                        hint: '+62 Nomor Telepon'),
                    _label('Jenis Kelamin'),
                    _dropdown<String>(
                      value: _jenisKelamin,
                      items: const ['Laki-Laki', 'Perempuan'],
                      hint: 'Pilih Jenis Kelamin',
                      onChanged: (v) => setState(() => _jenisKelamin = v),
                      validator: (v) =>
                          v == null ? 'Pilih jenis kelamin' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        onPressed: _next,
                        child: Text('Selanjutnya',
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5067e9))),
      );

  Widget _textField(TextEditingController c,
      {TextInputType? keyboardType,
      String? hint,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        validator:
            validator ?? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: const Color(0xff949494)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => _persistData(),
      ),
    );
  }

  Widget _dropdown<T>(
      {T? value,
      required List<T> items,
      required ValueChanged<T?> onChanged,
      String? Function(T?)? validator,
      String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: hint != null
            ? Text(hint,
                style: GoogleFonts.inter(color: const Color(0xff949494)))
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff949494)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        items: items
            .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: (v) {
          onChanged(v);
          _persistData();
        },
        validator: validator ?? (v) => v == null ? 'Wajib dipilih' : null,
      ),
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Wajib diisi';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }
}
