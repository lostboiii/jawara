import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:jawara/data/repositories/warga_repositories.dart';
import 'package:jawara/viewmodels/daftar_warga_viewmodel.dart';

class EditWargaPage extends StatefulWidget {
  const EditWargaPage({super.key, required this.warga});

  final WargaListItem warga;

  @override
  State<EditWargaPage> createState() => _EditWargaPageState();
}

class _EditWargaPageState extends State<EditWargaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();

  final List<String> _jenisKelaminOptions = <String>[
    'Laki-Laki',
    'Perempuan',
  ];

  final List<String> _agamaOptions = <String>[
    'islam',
    'kristen',
    'katolik',
    'hindu',
    'buddha',
    'konghucu',
  ];

  final List<String> _golonganDarahOptions = <String>[
    'A',
    'B',
    'AB',
    'O',
  ];

  final List<String> _peranKeluargaOptions = <String>[
    'kepala keluarga',
    'ibu rumah tangga',
    'anak',
    'lainnya',
  ];

  final List<String> _pendidikanOptions = <String>[
    'Tidak/Belum Sekolah',
    'SD',
    'SMP',
    'SMA',
    'D3',
    'S1',
    'S2',
    'S3',
  ];

  final List<String> _statusAktifOptions = <String>[
    'Aktif',
    'Nonaktif',
  ];

  String? _selectedJenisKelamin;
  String? _selectedAgama;
  String? _selectedGolonganDarah;
  String? _selectedPeranKeluarga;
  String? _selectedPendidikan;
  String? _selectedKeluargaId;
  String? _selectedStatusAktif;

  List<Map<String, dynamic>> _keluargaList = <Map<String, dynamic>>[];
  String? _keluargaError;

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isLoadingKeluarga = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKeluargaList();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noTeleponController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final WargaListItem warga = widget.warga;

    _namaController.text = warga.namaLengkap;
    _nikController.text = warga.nik;
    _noTeleponController.text = warga.noTelepon ?? '';
    _tempatLahirController.text = warga.tempatLahir ?? '';
    _pekerjaanController.text = warga.pekerjaan;

    _selectedDate = warga.tanggalLahir;
    if (_selectedDate != null) {
      _tanggalLahirController.text =
          DateFormat('dd/MM/yyyy').format(_selectedDate!);
    }

    _selectedJenisKelamin =
        _matchOption(warga.jenisKelamin, _jenisKelaminOptions);
    _selectedAgama = _matchOption(warga.agama, _agamaOptions);
    _selectedGolonganDarah =
        _matchOption(warga.golonganDarah, _golonganDarahOptions);
    _selectedPeranKeluarga =
        _matchOption(warga.peranKeluarga, _peranKeluargaOptions);
    _selectedPendidikan = _matchOption(warga.pendidikan, _pendidikanOptions);
    _selectedKeluargaId = warga.keluargaId;
    _selectedStatusAktif = (widget.warga.isActive ? 'Aktif' : 'Nonaktif');
  }

  bool get _isKepalaKeluargaSelected {
    final String? role = _selectedPeranKeluarga;
    if (role == null) {
      return false;
    }
    return role.trim().toLowerCase() == 'kepala keluarga';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Warga',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                  'Nama Lengkap', 'Masukan Nama Lengkap', _namaController),
              const SizedBox(height: 16),
              _buildTextField(
                'NIK',
                'Masukan NIK sesuai KTP (16 digit)',
                _nikController,
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              _buildPhoneField('Nomor Telepon', 'Masukan Nomor Telepon',
                  _noTeleponController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Jenis Kelamin',
                _selectedJenisKelamin,
                _jenisKelaminOptions,
                (String? value) {
                  setState(() {
                    _selectedJenisKelamin = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField('Tempat Lahir', 'Masukan Tempat Lahir',
                  _tempatLahirController,
                  isOptional: true),
              const SizedBox(height: 16),
              _buildDateField('Tanggal Lahir', _tanggalLahirController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Agama',
                _selectedAgama,
                _agamaOptions,
                (String? value) {
                  setState(() {
                    _selectedAgama = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Golongan Darah',
                _selectedGolonganDarah,
                _golonganDarahOptions,
                (String? value) {
                  setState(() {
                    _selectedGolonganDarah = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Pendidikan',
                _selectedPendidikan,
                _pendidikanOptions,
                (String? value) {
                  setState(() {
                    _selectedPendidikan = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Pekerjaan', 'Masukan Pekerjaan', _pekerjaanController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Peran dalam Keluarga',
                _selectedPeranKeluarga,
                _peranKeluargaOptions,
                (String? value) {
                  setState(() {
                    _selectedPeranKeluarga = value;
                    if (value != null &&
                        value.trim().toLowerCase() == 'kepala keluarga') {
                      _selectedKeluargaId = widget.warga.keluargaId;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Status Keaktifan',
                _selectedStatusAktif,
                _statusAktifOptions,
                (String? value) {
                  setState(() {
                    _selectedStatusAktif = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildKeluargaDropdown(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
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
                            strokeWidth: 2,
                            color: Colors.white,
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
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            counterText: '',
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
          validator: (String? value) {
            if (isOptional) {
              return null;
            }
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
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
      children: <Widget>[
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
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red,
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
                    color: const Color(0xffE5E5EA),
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
          validator: (String? value) {
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
      children: <Widget>[
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
            final DateTime now = DateTime.now();
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? now,
              firstDate: DateTime(1900),
              lastDate: now,
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
              child: Text(_formatOptionLabel(option)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (String? selected) {
            if (selected == null || selected.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKeluargaDropdown() {
    final bool hasData = _keluargaList.isNotEmpty;
    final bool canInteract = !_isKepalaKeluargaSelected &&
        hasData &&
        !_isLoadingKeluarga &&
        _keluargaError == null;

    String? currentValue;
    if (_selectedKeluargaId != null && _selectedKeluargaId!.isNotEmpty) {
      final bool exists = _keluargaList.any((Map<String, dynamic> keluarga) {
        final dynamic id = keluarga['id'];
        return id != null && id.toString() == _selectedKeluargaId;
      });
      currentValue = exists ? _selectedKeluargaId : null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Keluarga',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingKeluarga)
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE5E5EA)),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_keluargaError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Text(
              _keluargaError!,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.redAccent),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: currentValue,
            isExpanded: true,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText:
                  canInteract ? 'Pilih Keluarga' : 'Tidak ada data keluarga',
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffE5E5EA)),
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
            items: _keluargaList
                .map((Map<String, dynamic> keluarga) {
                  final dynamic id = keluarga['id'];
                  if (id == null || id.toString().isEmpty) {
                    return null;
                  }
                  return DropdownMenuItem<String>(
                    value: id.toString(),
                    child: Text(_composeKeluargaLabel(keluarga)),
                  );
                })
                .whereType<DropdownMenuItem<String>>()
                .toList(),
            onChanged: canInteract
                ? (String? value) {
                    setState(() {
                      _selectedKeluargaId = value;
                    });
                  }
                : null,
            validator: (String? value) {
              if (!canInteract) {
                return null;
              }
              if (value == null || value.isEmpty) {
                return 'Keluarga harus dipilih';
              }
              return null;
            },
          ),
        if (!_isLoadingKeluarga &&
            _keluargaError == null &&
            _keluargaList.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Belum ada data keluarga yang tersedia.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ),
        if (_isKepalaKeluargaSelected)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Peran Kepala Keluarga tidak dapat dipindahkan ke keluarga lain.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ),
      ],
    );
  }

  String _composeKeluargaLabel(Map<String, dynamic> keluarga) {
    final String kepala =
        (keluarga['nama_kepala_keluarga'] ?? '').toString().trim();
    final String rumah = (keluarga['nama_rumah'] ?? '').toString().trim();
    if (kepala.isEmpty && rumah.isEmpty) {
      return 'Nama keluarga tidak tersedia';
    }
    if (rumah.isEmpty) {
      return kepala;
    }
    return '$kepala • $rumah';
  }

  Future<void> _loadKeluargaList() async {
    setState(() {
      _isLoadingKeluarga = true;
      _keluargaError = null;
    });

    try {
      final WargaRepository repository = context.read<WargaRepository>();
      final List<Map<String, dynamic>> result =
          await repository.getAllKeluarga();

      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>> sanitized = result
          .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
          .toList();

      sanitized.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        return _composeKeluargaLabel(a)
            .toLowerCase()
            .compareTo(_composeKeluargaLabel(b).toLowerCase());
      });

      if (_selectedKeluargaId != null && _selectedKeluargaId!.isNotEmpty) {
        final bool exists = sanitized.any((Map<String, dynamic> keluarga) {
          final dynamic id = keluarga['id'];
          return id != null && id.toString() == _selectedKeluargaId;
        });

        if (!exists) {
          sanitized.add(<String, dynamic>{
            'id': _selectedKeluargaId,
            'nama_kepala_keluarga':
                widget.warga.namaKeluarga ?? 'Keluarga saat ini',
            'nama_rumah': '',
          });
        }
      }

      String? nextSelection = _selectedKeluargaId;
      if ((nextSelection == null || nextSelection.isEmpty) &&
          sanitized.isNotEmpty &&
          !_isKepalaKeluargaSelected) {
        nextSelection = sanitized.first['id']?.toString();
      }

      setState(() {
        _keluargaList = sanitized;
        _selectedKeluargaId = nextSelection;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _keluargaError = 'Gagal memuat daftar keluarga: $error';
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingKeluarga = false;
      });
    }
  }

  String? _matchOption(String? initialValue, List<String> options) {
    if (initialValue == null) {
      return null;
    }

    final String candidate = initialValue.trim();
    if (candidate.isEmpty) {
      return null;
    }

    for (final String option in options) {
      if (option.trim().toLowerCase() == candidate.toLowerCase()) {
        return option;
      }
    }

    options.add(candidate);
    return candidate;
  }

  String _formatOptionLabel(String option) {
    final String trimmed = option.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    if (trimmed.toUpperCase() == trimmed) {
      return trimmed;
    }

    final List<String> words = trimmed.split(' ');
    final Iterable<String> formatted = words.map((String word) {
      if (word.isEmpty || word.toUpperCase() == word) {
        return word;
      }
      final List<String> slashParts = word.split('/');
      final Iterable<String> formattedSlashParts =
          slashParts.map((String part) {
        if (part.isEmpty || part.toUpperCase() == part) {
          return part;
        }
        return part[0].toUpperCase() + part.substring(1).toLowerCase();
      });
      return formattedSlashParts.join('/');
    });

    return formatted.join(' ');
  }

  Future<void> _handleUpdate() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final WargaRepository repository = context.read<WargaRepository>();

      await repository.updateWarga(
        wargaId: widget.warga.id,
        namaLengkap: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        noTelepon: _noTeleponController.text.trim(),
        jenisKelamin: (_selectedJenisKelamin ?? '').trim(),
        agama: (_selectedAgama ?? '').trim(),
        golonganDarah: (_selectedGolonganDarah ?? '').trim(),
        pekerjaan: _pekerjaanController.text.trim(),
        peranKeluarga: (_selectedPeranKeluarga ?? '').trim(),
        tempatLahir: _tempatLahirController.text.trim().isEmpty
            ? null
            : _tempatLahirController.text.trim(),
        tanggalLahir: _selectedDate?.toIso8601String(),
        pendidikan: (_selectedPendidikan != null &&
                _selectedPendidikan!.trim().isNotEmpty)
            ? _selectedPendidikan!.trim()
            : null,
        keluargaId: _selectedKeluargaId,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: <Widget>[
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
              'Data warga berhasil diperbarui',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.pop(true);
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
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
