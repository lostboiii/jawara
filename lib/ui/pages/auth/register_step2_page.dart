import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_router.dart';
import '../../../viewmodels/register_viewmodel.dart';

class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({super.key});

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  late final TextEditingController _pekerjaanCtrl;

  String? _agama;
  String? _golonganDarah;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegisterViewModel>();
    _pekerjaanCtrl = TextEditingController(text: vm.cacheStatus);
    _agama = vm.cacheAgama.isEmpty ? null : vm.cacheAgama;
    _golonganDarah =
        vm.cacheGolonganDarah.isEmpty ? null : vm.cacheGolonganDarah;
  }

  @override
  void dispose() {
    _pekerjaanCtrl.dispose();
    super.dispose();
  }

  void _persistData() {
    final vm = context.read<RegisterViewModel>();
    vm.setStatus(_pekerjaanCtrl.text);
    vm.setAgama(_agama ?? '');
    vm.setGolonganDarah(_golonganDarah ?? '');
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    _persistData();
    context.go('/register-step3'); // Navigate to step 3
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
                      onPressed: () => context.go(AppRoutes.registerStep1),
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
                    _progressDots(step: 2),
                    const SizedBox(height: 28),
                    _label('Agama'),
                    _dropdown<String>(
                      value: _agama,
                      items: const [
                        'Islam',
                        'Kristen',
                        'Katolik',
                        'Hindu',
                        'Buddha',
                        'Konghucu'
                      ],
                      hint: 'Pilih Agama',
                      onChanged: (v) => setState(() => _agama = v),
                      validator: (v) => v == null ? 'Pilih agama' : null,
                    ),
                    _label('Golongan Darah'),
                    _dropdown<String>(
                      value: _golonganDarah,
                      items: const ['A', 'B', 'AB', 'O'],
                      hint: 'Pilih Golongan Darah',
                      onChanged: (v) => setState(() => _golonganDarah = v),
                      validator: (v) =>
                          v == null ? 'Pilih golongan darah' : null,
                    ),
                    _label('Pekerjaan'),
                    _textField(_pekerjaanCtrl, hint: 'Masukkan Pekerjaan'),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5067e9))),
      );

  Widget _textField(TextEditingController c,
      {TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
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
        validator: validator,
      ),
    );
  }
}
