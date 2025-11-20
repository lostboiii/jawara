import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Keluarga fields
  final _nomorKkCtrl = TextEditingController();

  String? _jenisKelamin;
  String? _agama; 
  String? _golonganDarah;
  String? _peranKeluarga;
  String? _selectedKeluargaId;
  String? _selectedRumahId;
  File? _fotoIdentitas;

  // Lists for dropdowns
  List<Map<String, dynamic>> _keluargaList = [];
  List<Map<String, dynamic>> _rumahList = [];
  bool _loadingKeluarga = false;
  bool _loadingRumah = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _fotoIdentitas = File(picked.path));
    }
  }

  /// Handle "Daftar" button - register warga and keluarga together
  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate peran keluarga selection
    if (_peranKeluarga == null || _peranKeluarga!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih peran keluarga')),
      );
      return;
    }

    // If not kepala keluarga, must select existing keluarga
    if (_peranKeluarga != 'kepala keluarga') {
      if (_selectedKeluargaId == null || _selectedKeluargaId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih keluarga')),
        );
        return;
      }
    }

    final viewModel = context.read<RegisterViewModel>();

    final registerSuccess = await viewModel.registerWargaWithKeluarga(
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
      peranKeluarga: _peranKeluarga ?? '',
      // Keluarga data (only used if kepala keluarga)
      nomorKk: _nomorKkCtrl.text.trim(),
      rumahId: _selectedRumahId,
      // Selected keluarga (only used if not kepala keluarga)
      keluargaId: _selectedKeluargaId,
    );

    if (!mounted) return;

    if (registerSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
      );
      context.go(AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendaftar: ${viewModel.error}')),
      );
    }
  }

  /// Load keluarga list for dropdown
  Future<void> _loadKeluargaList() async {
    setState(() => _loadingKeluarga = true);
    final viewModel = context.read<RegisterViewModel>();
    final keluargaList = await viewModel.getKeluargaList();
    if (mounted) {
      setState(() {
        _keluargaList = keluargaList;
        _loadingKeluarga = false;
      });
    }
  }

  /// Load rumah list for dropdown
  Future<void> _loadRumahList() async {
    setState(() => _loadingRumah = true);
    final viewModel = context.read<RegisterViewModel>();
    final rumahList = await viewModel.getRumahList();
    if (mounted) {
      setState(() {
        _rumahList = rumahList;
        _loadingRumah = false;
      });
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
    _nomorKkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff5067e9);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          // Blur circle 1
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
                    color: Color(0xffc5cefd),
                  ),
                ],
              ),
            ),
          ),
          // Blur circle 2 (gradient)
          Positioned(
            top: -140,
            left: 220,
            child: Container(
              width: 252,
              height: 252,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xffc5cefd),
                    const Color(0xffc5cefd).withOpacity(.05),
                    const Color(0xffc5cefd).withOpacity(.01),
                  ],
                ),
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
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: primaryColor,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.go(AppRoutes.onboarding);
                      },
                    ),
                    Text(
                      'Daftarkan\nAkun Anda',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _progressDots(),
                    const SizedBox(height: 28),

                    // Form fields
                    _label('Nama Lengkap'),
                    _input("Nama Lengkap", _namaCtrl),
                    _label('NIK'),
                    _input("NIK", _nikCtrl),
                    _label('Email'),
                    _input("Email", _emailCtrl),
                    _label('No Telepon'),
                    _input("No Telepon", _telpCtrl),
                    _label('Jenis Kelamin'),
                    _jenisKelaminDropdown(),
                    _label('Agama'),
                    _agamaDropdown(),
                    _label('Golongan Darah'),
                    _golonganDarahDropdown(),
                    _label('Pekerjaan'),
                    _input("Pekerjaan", _pekerjaanCtrl),
                    _label('Peran Keluarga'),
                    _peranKeluargaDropdown(),
                    _label('Password'),
                    _password("Password", _passCtrl),
                    _label('Konfirmasi Password'),
                    _password("Konfirmasi Password", _confirmCtrl,
                        validator: (v) => v == _passCtrl.text
                            ? null
                            : "Password tidak cocok"),

                    const SizedBox(height: 20),

                    // Foto KTP
                    _label('Foto Identitas (KTP)'),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: primaryColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, color: primaryColor),
                            const SizedBox(width: 12),
                            Text(
                              _fotoIdentitas == null
                                  ? "Upload Foto Identitas (KTP)"
                                  : "Foto terpilih",
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Keluarga Fields - Conditionally shown
                    if (_peranKeluarga == 'kepala keluarga') ...[
                      Text(
                        "Data Keluarga Baru",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _label('Nomor KK'),
                      _input("Nomor KK", _nomorKkCtrl),
                      _label('Alamat/Rumah'),
                      // Rumah/Alamat Dropdown
                      _loadingRumah
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: CircularProgressIndicator(),
                            )
                          : _rumahList.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Tidak ada rumah tersedia',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedRumahId,
                                    decoration: InputDecoration(
                                      hintText: 'Pilih Alamat/Rumah',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    items: _rumahList
                                        .map(
                                            (rumah) => DropdownMenuItem<String>(
                                                  value: rumah['id'] as String,
                                                  child: Text(rumah['alamat']
                                                          as String? ??
                                                      'Alamat tidak diketahui'),
                                                ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedRumahId = value);
                                    },
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Wajib pilih rumah/alamat'
                                        : null,
                                  ),
                                ),
                      const SizedBox(height: 20),
                    ] else if (_peranKeluarga != null &&
                        _peranKeluarga!.isNotEmpty) ...[
                      Text(
                        "Pilih Keluarga",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _loadingKeluarga
                          ? const CircularProgressIndicator()
                          : _keluargaList.isEmpty
                              ? Text(
                                  'Tidak ada keluarga tersedia',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.red),
                                )
                              : DropdownButtonFormField<String>(
                                  value: _selectedKeluargaId,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih Keluarga',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: _keluargaList.map((keluarga) {
                                    final wargaProfiles =
                                        keluarga['warga_profiles'];
                                    final namaKepalakeluarga =
                                        (wargaProfiles is Map)
                                            ? wargaProfiles['nama_lengkap'] ??
                                                'Nama tidak diketahui'
                                            : 'Nama tidak diketahui';
                                    final nomorKk =
                                        keluarga['nomorKk'] as String? ?? '';
                                    return DropdownMenuItem<String>(
                                      value: keluarga['id'] as String,
                                      child: Text(
                                          'KK $nomorKk - $namaKepalakeluarga'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedKeluargaId = value);
                                  },
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Wajib pilih keluarga'
                                      : null,
                                ),
                      const SizedBox(height: 20),
                    ],

                    // "Daftar" Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _handleRegister(context),
                        child: Text(
                          "Daftar",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressDots() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xff5067e9),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5067e9),
          ),
        ),
      );

  Widget _input(String label, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
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
            if (label == 'Email') {
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(v.trim())) {
                return 'Format email tidak valid';
              }
            }
            return null;
          },
        ),
      );

  Widget _password(String label, TextEditingController ctrl,
          {String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: TextFormField(
          controller: ctrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator ??
              (v) => (v == null || v.length < 6) ? "Minimal 6 karakter" : null,
        ),
      );

  Widget _jenisKelaminDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: DropdownButtonFormField<String>(
          value: _jenisKelamin,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Pilih Jenis Kelamin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Laki-Laki', child: Text('Laki-Laki')),
            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
          ],
          onChanged: (value) {
            setState(() => _jenisKelamin = value);
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
        ),
      );

  Widget _agamaDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: DropdownButtonFormField<String>(
          value: _agama,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Pilih Agama',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'islam', child: Text('Islam')),
            DropdownMenuItem(value: 'kristen', child: Text('Kristen')),
            DropdownMenuItem(value: 'katolik', child: Text('Katolik')),
            DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
            DropdownMenuItem(value: 'budha', child: Text('Buddha')),
            DropdownMenuItem(value: 'konghucu', child: Text('Konghucu')),
          ],
          onChanged: (value) {
            setState(() => _agama = value);
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
        ),
      );

  Widget _golonganDarahDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: DropdownButtonFormField<String>(
          value: _golonganDarah,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Pilih Golongan Darah',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'O', child: Text('O')),
            DropdownMenuItem(value: 'A', child: Text('A')),
            DropdownMenuItem(value: 'B', child: Text('B')),
            DropdownMenuItem(value: 'AB', child: Text('AB')),
          ],
          onChanged: (value) {
            setState(() => _golonganDarah = value);
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
        ),
      );

  Widget _peranKeluargaDropdown() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: DropdownButtonFormField<String>(
          value: _peranKeluarga,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Pilih Peran Keluarga',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: 'kepala keluarga', child: Text('Kepala Keluarga')),
            DropdownMenuItem(
                value: 'ibu rumah tangga', child: Text('Ibu Rumah Tangga')),
            DropdownMenuItem(value: 'anak', child: Text('Anak')),
          ],
          onChanged: (value) {
            setState(() {
              _peranKeluarga = value;
              _selectedKeluargaId = null;
              _selectedRumahId = null;
            });

            // Load data based on peran
            if (value == 'kepala keluarga') {
              _loadRumahList();
            } else if (value != null && value.isNotEmpty) {
              _loadKeluargaList();
            }
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
        ),
      );
}
