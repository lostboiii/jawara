import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/viewmodels/tambah_warga_viewmodel.dart';

class TambahWargaPage extends StatelessWidget {
  const TambahWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TambahWargaViewModel(
        repository: context.read<WargaRepository>(),
      )..loadKeluargaList()
        ..loadRumahList(),
      child: const _TambahWargaPageContent(),
    );
  }
}

class _TambahWargaPageContent extends StatefulWidget {
  const _TambahWargaPageContent();

  @override
  State<_TambahWargaPageContent> createState() => _TambahWargaPageContentState();
}

class _TambahWargaPageContentState extends State<_TambahWargaPageContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _nomorKkController = TextEditingController();

  // Dropdown values
  String? _selectedKeluarga;
  String? _selectedRumah;
  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedGolonganDarah;
  String? _selectedPeranKeluarga;
  String? _selectedPendidikan;

  DateTime? _selectedDate;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _noTeleponController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _pekerjaanController.dispose();
    _nomorKkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.goNamed('home-warga'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Warga',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField('Nama Lengkap', 'Masukan Nama Lengkap', _namaController),
              const SizedBox(height: 16),
              _buildTextField('NIK', 'Masukan NIK sesuai KTP (16 digit)', _nikController,
                  keyboardType: TextInputType.number, maxLength: 16),
              const SizedBox(height: 16),
              _buildTextField('Email', 'Masukan Email', _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildPasswordField('Password', 'Masukan Password', _passwordController),
              const SizedBox(height: 16),
              _buildPhoneField(
                  'Nomor Telepon', 'Masukan Nomor Telepon', _noTeleponController),
              const SizedBox(height: 16),
              Consumer<TambahWargaViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      _buildDropdownField('Jenis Kelamin', _selectedJenisKelamin,
                          viewModel.jenisKelaminOptions, (value) {
                        setState(() => _selectedJenisKelamin = value);
                      }),
                      const SizedBox(height: 16),
                      _buildTextField('Tempat Lahir', 'Masukan Tempat Lahir',
                          _tempatLahirController),
                      const SizedBox(height: 16),
                      _buildDateField('Tanggal Lahir', _tanggalLahirController),
                      const SizedBox(height: 16),
                      _buildDropdownField('Agama', _selectedAgama,
                          viewModel.agamaOptions, (value) {
                        setState(() => _selectedAgama = value);
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownField('Golongan Darah', _selectedGolonganDarah,
                          viewModel.golonganDarahOptions, (value) {
                        setState(() => _selectedGolonganDarah = value);
                      }),
                      const SizedBox(height: 16),
                      _buildDropdownField('Pendidikan', _selectedPendidikan,
                          viewModel.pendidikanOptions, (value) {
                        setState(() => _selectedPendidikan = value);
                      }),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Pekerjaan', 'Masukan Pekerjaan', _pekerjaanController),
                      const SizedBox(height: 16),
                      _buildDropdownField('Peran dalam Keluarga', _selectedPeranKeluarga,
                          viewModel.peranKeluargaOptions, (value) {
                        setState(() {
                          _selectedPeranKeluarga = value;
                          // Load data berdasarkan peran
                          if (value == 'kepala keluarga') {
                            viewModel.loadRumahList();
                          }
                        });
                      }),
                      const SizedBox(height: 16),
                      // Kondisional field berdasarkan peran keluarga
                      if (_selectedPeranKeluarga == 'kepala keluarga') ...[
                        _buildTextField('Nomor KK', 'Masukan Nomor KK (16 digit)', 
                            _nomorKkController, keyboardType: TextInputType.number, maxLength: 16),
                        const SizedBox(height: 16),
                        _buildRumahDropdown(viewModel),
                      ] else if (_selectedPeranKeluarga != null && _selectedPeranKeluarga!.isNotEmpty) ...[
                        _buildKeluargaDropdown(viewModel),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSimpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            counterText: maxLength != null ? '' : null,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        '🇮🇩',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 20,
                    color: Color(0xffE5E5EA),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            suffixIcon: const Icon(Icons.calendar_today,
                size: 20, color: Color(0xffC7C7CD)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKeluargaDropdown(TambahWargaViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Keluarga',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedKeluarga,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Pilih Keluarga',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          items: viewModel.keluargaList.map((keluarga) {
            return DropdownMenuItem<String>(
              value: keluarga['id'],
              child: Text(keluarga['nama_kepala_keluarga'] ?? 'Tidak ada nama'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedKeluarga = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Keluarga tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRumahDropdown(TambahWargaViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Alamat Rumah',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (viewModel.rumahList.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak ada rumah kosong tersedia',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedRumah,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Pilih Rumah yang Kosong',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xffC7C7CD),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffE5E5EA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffE5E5EA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xff5067e9), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            items: viewModel.rumahList.map((rumah) {
              return DropdownMenuItem<String>(
                value: rumah['id'],
                child: Text(rumah['alamat'] ?? 'Tidak ada alamat'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRumah = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat rumah tidak boleh kosong';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Pilih $label',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffE5E5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi field yang diperlukan
    if (_selectedJenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis kelamin harus dipilih')),
      );
      return;
    }

    if (_selectedAgama == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agama harus dipilih')),
      );
      return;
    }

    if (_selectedGolonganDarah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Golongan darah harus dipilih')),
      );
      return;
    }

    if (_selectedPeranKeluarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peran keluarga harus dipilih')),
      );
      return;
    }

    if (_pekerjaanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pekerjaan harus diisi')),
      );
      return;
    }

    // Validasi khusus untuk kepala keluarga
    if (_selectedPeranKeluarga == 'kepala keluarga') {
      if (_nomorKkController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor KK harus diisi untuk kepala keluarga')),
        );
        return;
      }
      if (_selectedRumah == null || _selectedRumah!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat rumah harus dipilih untuk kepala keluarga')),
        );
        return;
      }
    } else {
      // Validasi untuk anggota keluarga
      if (_selectedKeluarga == null || _selectedKeluarga!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keluarga harus dipilih untuk anggota')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<TambahWargaViewModel>();
      
      // Step 1: Create auth user di Supabase Auth
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (authResponse.user == null) {
        throw 'Gagal membuat akun. Email mungkin sudah terdaftar.';
      }
      
      final userId = authResponse.user!.id;
      debugPrint('Auth user created with ID: $userId');
      
      // Convert tanggal lahir dari format dd/MM/yyyy ke yyyy-MM-dd untuk database
      String? tanggalLahirFormatted;
      if (_tanggalLahirController.text.isNotEmpty) {
        try {
          final dateFormat = DateFormat('dd/MM/yyyy');
          final parsedDate = dateFormat.parse(_tanggalLahirController.text);
          tanggalLahirFormatted = DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          debugPrint('Error parsing date: $e');
          tanggalLahirFormatted = null;
        }
      }
      
      // Step 2: Create warga profile
      final success = await viewModel.saveWarga(
        userId: userId,
        namaLengkap: _namaController.text,
        nik: _nikController.text,
        noHp: _noTeleponController.text,
        jenisKelamin: _selectedJenisKelamin!,
        agama: _selectedAgama!,
        golonganDarah: _selectedGolonganDarah!,
        pekerjaan: _pekerjaanController.text,
        peranKeluarga: _selectedPeranKeluarga!,
        tempatLahir: _tempatLahirController.text.isNotEmpty ? _tempatLahirController.text : null,
        tanggalLahir: tanggalLahirFormatted,
        pendidikan: _selectedPendidikan,
        keluargaId: _selectedKeluarga,
        nomorKk: _nomorKkController.text.isNotEmpty ? _nomorKkController.text : null,
        rumahId: _selectedRumah,
      );

      if (!mounted) return;
      
      setState(() => _isLoading = false);

      if (success) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xff34C759),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Berhasil!',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Data warga berhasil disimpan',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      context.goNamed('home-warga'); // Go back to previous page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5067e9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Show error from ViewModel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Gagal menyimpan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
