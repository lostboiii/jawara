import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/pengeluaran_model.dart';
import '../../../viewmodels/pengeluaran_viewmodel.dart';
import '../../../data/repositories/pengeluaran_repository.dart';

class PengeluaranAddPage extends StatefulWidget {
  final PengeluaranModel? item;

  const PengeluaranAddPage({super.key, this.item});

  @override
  State<PengeluaranAddPage> createState() => _PengeluaranAddPageState();
}

class _PengeluaranAddPageState extends State<PengeluaranAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  String? _selectedKategori;
  DateTime? _selectedTanggal;
  String? _buktiPath;
  String? _buktiFileName;
  List<int>? _buktiBytes;
  bool _isSaving = false;
  late PengeluaranRepository _repository;

  static const Map<String, String> _kategoriLabels = {
    'Operasional': 'Operasional',
    'Kegiatan Sosial': 'Kegiatan Sosial',
    'Pemeliharaan Fasilitas': 'Pemeliharaan Fasilitas',
    'Pembangunan': 'Pembangunan',
    'Kegiatan Warga': 'Kegiatan Warga',
    'Keamanan dan Kebersihan': 'Keamanan dan Kebersihan',
    'Lain-lain': 'Lain-lain',
  };

  static const Map<String, String> _legacyKategoriMap = {
    'operasional rt/rw': 'Operasional',
    'operasional_rt_rw': 'Operasional',
    'operasional': 'Operasional',
    'kegiatan warga': 'Kegiatan Warga',
    'kegiatan_warga': 'Kegiatan Warga',
    'kegiatan sosial': 'Kegiatan Sosial',
    'pemeliharaan fasilitas': 'Pemeliharaan Fasilitas',
    'pemeliharaan_fasilitas': 'Pemeliharaan Fasilitas',
    'pembangunan': 'Pembangunan',
    'keamanan': 'Keamanan dan Kebersihan',
    'keamanan dan kebersihan': 'Keamanan dan Kebersihan',
    'lainnya': 'Lain-lain',
    'lain lain': 'Lain-lain',
    'lain-lain': 'Lain-lain',
  };

  @override
  void initState() {
    super.initState();
    _repository = SupabasePengeluaranRepository(client: Supabase.instance.client);
    if (widget.item != null) {
      // Edit mode
      _namaController.text = widget.item!.namaPengeluaran;
      _nominalController.text = widget.item!.jumlah.toStringAsFixed(2);
      _selectedKategori =
          _resolveKategoriValue(widget.item!.kategoriPengeluaran);
      _selectedTanggal = widget.item!.tanggalPengeluaran;
      _buktiPath = widget.item!.buktiPengeluaran;
      _tanggalController.text =
          DateFormat('dd/MM/yyyy').format(_selectedTanggal ?? DateTime.now());
    } else {
      // Add mode
      _selectedTanggal = DateTime.now();
      _tanggalController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  String _resolveKategoriValue(String value) {
    final trimmed = value.trim();
    if (_kategoriLabels.containsKey(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    final legacyMatch = _legacyKategoriMap[lower];
    if (legacyMatch != null) return legacyMatch;
    return trimmed;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb,
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _buktiPath = kIsWeb ? file.name : file.path;
          _buktiFileName = file.name;
          _buktiBytes = kIsWeb ? file.bytes?.toList() : null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSimpan() async {
    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih')),
      );
      return;
    }

    if (_selectedTanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal harus dipilih')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final vm = context.read<PengeluaranViewModel>();
    final sanitizedJumlah =
        _nominalController.text.replaceAll('.', '').replaceAll(',', '.');
    final jumlah = double.parse(sanitizedJumlah);
    final kategori = _selectedKategori!;
    final tanggal = _selectedTanggal ?? DateTime.now();

    try {
      String? buktiUrl;

      // Upload file jika ada
      if (_buktiBytes != null && _buktiPath != null) {
        try {
          buktiUrl = await _repository.uploadBukti(_buktiPath!, _buktiBytes!);
        } catch (e) {
          _showSnack('Gagal upload bukti: $e');
          setState(() => _isSaving = false);
          return;
        }
      }

      if (widget.item != null) {
        // Edit mode
        await vm.updatePengeluaran(
          id: widget.item!.id,
          nama: _namaController.text.trim(),
          kategori: kategori,
          tanggal: tanggal,
          jumlah: jumlah,
          bukti: buktiUrl ?? widget.item!.buktiPengeluaran,
        );
      } else {
        // Add mode
        await vm.addPengeluaran(
          nama: _namaController.text.trim(),
          kategori: kategori,
          tanggal: tanggal,
          jumlah: jumlah,
          bukti: buktiUrl,
        );
      }

      if (!mounted) return;

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
              widget.item != null
                  ? 'Data pengeluaran berhasil diperbarui'
                  : 'Data pengeluaran berhasil disimpan',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
            if (keyboardType == TextInputType.number) {
              final sanitized = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(sanitized) == null) {
                return 'Masukkan nominal yang valid';
              }
              if (double.parse(sanitized) <= 0) {
                return 'Nominal harus lebih dari 0';
              }
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
              initialDate: _selectedTanggal ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xff5067e9),
                    ),
                  ),
                  child: child!,
                );
              },
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
    Map<String, String> options,
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
          items: options.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
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

  Widget _buildFileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xffE5E5EA),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  size: 48,
                  color: const Color(0xff5067e9),
                ),
                const SizedBox(height: 12),
                Text(
                  _buktiFileName ?? 'Unggah Bukti Pengeluaran',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _buktiFileName != null
                        ? Colors.black87
                        : const Color(0xff5067e9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_buktiFileName == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Pilih file dari perangkat',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xffC7C7CD),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
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
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.item != null
                        ? 'Ubah Pengeluaran'
                        : 'Tambah Pengeluaran',
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
                'Nama Pengeluaran',
                'Masukkan Nama Pengeluaran',
                _namaController,
              ),
              const SizedBox(height: 16),
              _buildDateField('Tanggal Pengeluaran', _tanggalController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Kategori Pengeluaran',
                _selectedKategori,
                _kategoriLabels,
                (value) {
                  setState(() => _selectedKategori = value);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nominal',
                'Masukkan Nominal',
                _nominalController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSimpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.item != null ? 'Simpan Perubahan' : 'Simpan',
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
}
