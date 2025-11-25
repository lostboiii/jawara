// coverage:ignore-file
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';

// Dialog Form Edit Pengguna
class EditUserDialog extends StatefulWidget {
  final String nama;
  final String email;
  final String nik;
  final String nomorHP;
  final String role;
  final String jenisKelamin;
  final String agama;
  final String golonganDarah;
  final String pekerjaan;
  final String? nomorKk;

  const EditUserDialog({
    super.key,
    required this.nama,
    required this.email,
    required this.nik,
    this.nomorHP = '',
    this.role = '',
    this.jenisKelamin = '',
    this.agama = '',
    this.golonganDarah = '',
    this.pekerjaan = '',
    this.nomorKk,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  // Warga fields
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _telpController;
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  late TextEditingController _pekerjaanController;

  // Keluarga fields
  late TextEditingController _nomorKkController;

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

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _nikController = TextEditingController(text: widget.nik);
    _telpController = TextEditingController(text: widget.nomorHP);
    _pekerjaanController = TextEditingController(text: widget.pekerjaan);
    _nomorKkController = TextEditingController(text: widget.nomorKk ?? '');
    _jenisKelamin = widget.jenisKelamin.isNotEmpty ? widget.jenisKelamin : null;
    _agama = widget.agama.isNotEmpty ? widget.agama : null;
    _golonganDarah = widget.golonganDarah.isNotEmpty ? widget.golonganDarah : null;
    _peranKeluarga = widget.role.isNotEmpty ? widget.role : null;

    if (_peranKeluarga == 'kepala keluarga') {
      _loadRumahList();
    } else if (_peranKeluarga != null && _peranKeluarga!.isNotEmpty) {
      _loadKeluargaList();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _pekerjaanController.dispose();
    _nomorKkController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _fotoIdentitas = File(picked.path));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _input(String label, TextEditingController controller, {FormFieldValidator? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        validator: validator ?? (v) => (v == null || v.isEmpty) ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _password(String label, TextEditingController controller, {FormFieldValidator? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: _inputDecoration(label),
        validator: validator ?? (v) {
          if (v == null || v.isEmpty) return null; // Optional for edit
          if (v.length < 6) return '$label minimal 6 karakter';
          return null;
        },
      ),
    );
  }

  Widget _jenisKelaminDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _jenisKelamin,
        decoration: _inputDecoration('Jenis Kelamin'),
        items: const [
          DropdownMenuItem(value: 'Laki-Laki', child: Text('Laki-Laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged: (value) => setState(() => _jenisKelamin = value),
        validator: (v) => v == null ? 'Jenis kelamin wajib dipilih' : null,
      ),
    );
  }

  Widget _agamaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _agama,
        decoration: _inputDecoration('Agama'),
        items: const [
          DropdownMenuItem(value: 'islam', child: Text('Islam')),
          DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
          DropdownMenuItem(value: 'budha', child: Text('Budha')),
          DropdownMenuItem(value: 'kristen', child: Text('Kristen')),
          DropdownMenuItem(value: 'katolik', child: Text('Katolik')),
          DropdownMenuItem(value: 'konghucu', child: Text('Konghucu')),
        ],
        onChanged: (value) => setState(() => _agama = value),
        validator: (v) => v == null ? 'Agama wajib dipilih' : null,
      ),
    );
  }

  Widget _golonganDarahDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _golonganDarah,
        decoration: _inputDecoration('Golongan Darah'),
        items: const [
          DropdownMenuItem(value: 'A', child: Text('A')),
          DropdownMenuItem(value: 'B', child: Text('B')),
          DropdownMenuItem(value: 'AB', child: Text('AB')),
          DropdownMenuItem(value: 'O', child: Text('O')),
        ],
        onChanged: (value) => setState(() => _golonganDarah = value),
        validator: (v) => v == null ? 'Golongan darah wajib dipilih' : null,
      ),
    );
  }

  Widget _peranKeluargaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _peranKeluarga,
        decoration: _inputDecoration('Peran Keluarga'),
        items: const [
          DropdownMenuItem(value: 'kepala keluarga', child: Text('Kepala Keluarga')),
          DropdownMenuItem(value: 'ibu rumah tangga', child: Text('Ibu Rumah Tangga')),
          DropdownMenuItem(value: 'anak', child: Text('Anak')),
        ],
        onChanged: (value) {
          setState(() => _peranKeluarga = value);
          if (value == 'kepala keluarga') {
            _loadRumahList();
          } else {
            _loadKeluargaList();
          }
        },
        validator: (v) => v == null ? 'Peran keluarga wajib dipilih' : null,
      ),
    );
  }

  Future<void> _loadKeluargaList() async {
    setState(() => _loadingKeluarga = true);
    try {
      final viewModel = context.read<RegisterViewModel>();
      final keluargaList = await viewModel.getKeluargaList();
      if (mounted) {
        setState(() {
          _keluargaList = keluargaList;
          _loadingKeluarga = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading keluarga list: $e');
      if (mounted) {
        setState(() => _loadingKeluarga = false);
      }
    }
  }

  Future<void> _loadRumahList() async {
    setState(() => _loadingRumah = true);
    try {
      final viewModel = context.read<RegisterViewModel>();
      final rumahList = await viewModel.getRumahList();
      if (mounted) {
        setState(() {
          _rumahList = rumahList;
          _loadingRumah = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rumah list: $e');
      if (mounted) {
        setState(() => _loadingRumah = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Akun Pengguna',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Warga Data Section
                _input("Nama Lengkap", _namaController),
                _input("NIK", _nikController),
                _input("No Telepon", _telpController),
                _jenisKelaminDropdown(),
                _agamaDropdown(),
                _golonganDarahDropdown(),
                _input("Pekerjaan", _pekerjaanController),
                _peranKeluargaDropdown(),
                _password("Password Baru (Opsional)", _passwordController),
                if (_passwordController.text.isNotEmpty)
                  _password("Konfirmasi Password", _konfirmasiPasswordController, validator: (v) {
                    if (_passwordController.text.isNotEmpty) {
                      if (v != _passwordController.text) return 'Password tidak cocok';
                    }
                    return null;
                  }),

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
                        const Icon(Icons.camera_alt),
                        const SizedBox(width: 12),
                        Text(_fotoIdentitas == null ? "Upload Foto Identitas (KTP)" : "Foto terpilih"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Keluarga Fields - Conditionally shown
                if (_peranKeluarga == 'kepala keluarga') ...[
                  const Text(
                    "Data Keluarga",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _input("Nomor KK", _nomorKkController),
                  // Rumah/Alamat Dropdown
                  _loadingRumah
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: CircularProgressIndicator(),
                        )
                      : _rumahList.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('Tidak ada rumah tersedia'),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<String>(
                                value: _selectedRumahId,
                                decoration: _inputDecoration('Pilih Alamat/Rumah'),
                                items: _rumahList
                                    .map((rumah) => DropdownMenuItem<String>(
                                          value: rumah['id'] as String,
                                          child: Text(rumah['alamat'] as String? ?? 'Alamat tidak diketahui'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedRumahId = value);
                                },
                                validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih rumah/alamat' : null,
                              ),
                            ),
                  const SizedBox(height: 20),
                ] else if (_peranKeluarga != null && _peranKeluarga!.isNotEmpty) ...[
                  const Text(
                    "Pilih Keluarga",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _loadingKeluarga
                      ? const CircularProgressIndicator()
                      : _keluargaList.isEmpty
                          ? const Text('Tidak ada keluarga tersedia')
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DropdownButtonFormField<String>(
                                value: _selectedKeluargaId,
                                decoration: _inputDecoration('Pilih Keluarga'),
                                items: _keluargaList
                                    .map((keluarga) {
                                      final wargaProfiles = keluarga['warga_profiles'];
                                      final namaKepalakeluarga = (wargaProfiles is Map)
                                          ? wargaProfiles['nama_lengkap'] ?? 'Nama tidak diketahui'
                                          : 'Nama tidak diketahui';
                                      final nomorKk = keluarga['nomor_kk'] as String? ?? '';
                                      return DropdownMenuItem<String>(
                                        value: keluarga['id'] as String,
                                        child: Text('KK $nomorKk - $namaKepalakeluarga'),
                                      );
                                    })
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedKeluargaId = value);
                                },
                                validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih keluarga' : null,
                              ),
                            ),
                  const SizedBox(height: 20),
                ],

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengguna berhasil diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Simpan'),
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
}
