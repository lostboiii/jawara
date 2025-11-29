import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home_page.dart';

class TambahMutasiPage extends StatefulWidget {
  const TambahMutasiPage({super.key});

  @override
  State<TambahMutasiPage> createState() => _TambahMutasiPageState();
}

class _TambahMutasiPageState extends State<TambahMutasiPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _alasanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  final List<String> _jenisOptions = <String>[
    'Pindah Datang',
    'Pindah Pergi',
    'Perubahan Kepala Keluarga',
  ];

  final List<String> _keluargaOptions = <String>[
    'Keluarga Rahmawati',
    'Keluarga Wijaya',
    'Keluarga Santoso',
    'Keluarga Handoko',
  ];

  String? _selectedJenis;
  String? _selectedKeluarga;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _alasanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xff5067e9);

    return HomePage(
      initialIndex: 2,
      sectionBuilders: <int, HomeSectionBuilder>{
        2: (BuildContext context, HomePageScope scope) =>
            _buildSection(context, primaryColor),
      },
    );
  }

  Widget _buildSection(BuildContext context, Color primaryColor) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => context.goNamed('home-warga'),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tambah Mutasi',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Catat perubahan domisili atau status keluarga dengan lengkap agar data warga selalu akurat.',
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDropdownField(
                  label: 'Jenis Mutasi',
                  value: _selectedJenis,
                  options: _jenisOptions,
                  onChanged: (String? value) =>
                      setState(() => _selectedJenis = value),
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Keluarga',
                  value: _selectedKeluarga,
                  options: _keluargaOptions,
                  onChanged: (String? value) =>
                      setState(() => _selectedKeluarga = value),
                ),
                const SizedBox(height: 16),
                _buildDateField(primaryColor),
                const SizedBox(height: 16),
                _buildAlasanField(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan Mutasi',
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
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
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
          items: options
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tanggal Mutasi',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tanggalController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal mutasi',
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
            suffixIcon: const Icon(Icons.calendar_today,
                size: 18, color: Color(0xffA1A1A1)),
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
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal mutasi harus dipilih';
            }
            return null;
          },
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime initial = _selectedDate ?? now;
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _tanggalController.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAlasanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Alasan Mutasi',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _alasanController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tuliskan alasan mutasi secara singkat',
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xff5067e9), width: 1.5),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Alasan mutasi tidak boleh kosong';
            }
            if (value.trim().length < 10) {
              return 'Alasan mutasi terlalu singkat';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Simpan Mutasi',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Pastikan data mutasi sudah benar sebelum disimpan.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSheet();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xffD1FAE5),
                child: Icon(Icons.check_rounded,
                    color: Color(0xff059669), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Mutasi Tersimpan',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mutasi berhasil dicatat. Lihat daftar mutasi atau input data lainnya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed('daftar-mutasi');
                  },
                  child: const Text('Lihat Daftar Mutasi'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedJenis = null;
                      _selectedKeluarga = null;
                      _selectedDate = null;
                    });
                    _alasanController.clear();
                    _tanggalController.clear();
                  },
                  child: const Text('Tambah Mutasi Lagi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
