import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'kegiatan_list_page.dart'; 

class EditKegiatanPage extends StatefulWidget {
  const EditKegiatanPage({super.key, required this.kegiatan});

  final KegiatanListItem kegiatan;

  @override
  State<EditKegiatanPage> createState() => _EditKegiatanPageState();
}

class _EditKegiatanPageState extends State<EditKegiatanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _penanggungJawabController;
  late TextEditingController _deskripsiController;
  late TextEditingController _tanggalController;

  String? _selectedKategori;
  DateTime? _selectedTanggal;

  final List<String> _kategoriOptions = [
    'Komunitas & Sosial',
    'Kebersihan & Keamanan',
    'Keagamaan',
    'Pendidikan',
    'Kesehatan & Olahraga',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kegiatan.namaKegiatan);
    _lokasiController = TextEditingController(text: widget.kegiatan.lokasiKegiatan);
    _penanggungJawabController = TextEditingController(text: widget.kegiatan.penanggungJawab);
    _deskripsiController = TextEditingController(text: widget.kegiatan.deskripsi);
    
    if (widget.kegiatan.tanggalKegiatan != null) {
      _selectedTanggal = widget.kegiatan.tanggalKegiatan;
      _tanggalController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedTanggal!)
      );
    } else {
      _tanggalController = TextEditingController();
    }

    if (_kategoriOptions.contains(widget.kegiatan.kategoriKegiatan)) {
      _selectedKategori = widget.kegiatan.kategoriKegiatan;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _penanggungJawabController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
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
                    onPressed: () => context.goNamed('list-kegiatan'),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Kegiatan',
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
                'Nama Kegiatan',
                'Masukan Nama Kegiatan',
                _namaController,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Kategori Kegiatan',
                _selectedKategori,
                _kategoriOptions,
                (value) {
                  setState(() => _selectedKategori = value);
                },
              ),
              const SizedBox(height: 16),
              _buildDateField('Tanggal Kegiatan', _tanggalController),
              const SizedBox(height: 16),
              _buildTextField(
                'Lokasi Kegiatan',
                'Masukan Lokasi Kegiatan',
                _lokasiController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Penanggung Jawab',
                'Masukan Nama Penanggung Jawab',
                _penanggungJawabController,
              ),
              const SizedBox(height: 16),
              _buildTextAreaField(
                'Deskripsi',
                'Masukan Deskripsi Kegiatan',
                _deskripsiController,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Perbarui Data',
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

  Widget _buildTextAreaField(
    String label,
    String hint,
    TextEditingController controller,
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
        TextFormField(
          controller: controller,
          maxLines: 6,
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
          ),
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
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedTanggal ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedTanggal = pickedDate;
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

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
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
              'Data kegiatan berhasil diperbarui',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop();
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
    }
  }
}