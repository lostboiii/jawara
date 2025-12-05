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
  final _namaCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  String? _selectedKategori;
  DateTime? _selectedDate;
  String? _buktiPath;
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
      _namaCtrl.text = widget.item!.namaPengeluaran;
      _nominalCtrl.text = widget.item!.jumlah.toStringAsFixed(2);
      _selectedKategori = _resolveKategoriValue(widget.item!.kategoriPengeluaran);
      _selectedDate = widget.item!.tanggalPengeluaran;
      _buktiPath = widget.item!.buktiPengeluaran;
    } else {
      // Add mode
      _selectedDate = DateTime.now();
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
    _namaCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickBukti() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: kIsWeb,
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        _buktiPath = file.name;
        _buktiBytes = kIsWeb ? file.bytes?.toList() : null;
      });
    }
  }

  bool _validateForm() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return false;
    if (_selectedKategori == null || _selectedKategori!.isEmpty) {
      _showSnack('Kategori wajib dipilih');
      return false;
    }
    if (_selectedDate == null) {
      _showSnack('Tanggal pengeluaran wajib diisi');
      return false;
    }
    return true;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    final vm = context.read<PengeluaranViewModel>();
    final sanitizedJumlah = _nominalCtrl.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final jumlah = double.parse(sanitizedJumlah);
    final kategori = _selectedKategori!;
    final tanggal = _selectedDate ?? DateTime.now();

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
          nama: _namaCtrl.text.trim(),
          kategori: kategori,
          tanggal: tanggal,
          jumlah: jumlah,
          bukti: buktiUrl ?? widget.item!.buktiPengeluaran,
        );
      } else {
        // Add mode
        await vm.addPengeluaran(
          nama: _namaCtrl.text.trim(),
          kategori: kategori,
          tanggal: tanggal,
          jumlah: jumlah,
          bukti: buktiUrl,
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Gagal menyimpan data: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.item != null ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Nama Pengeluaran',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengeluaran',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Kategori Pengeluaran',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                style: GoogleFonts.inter(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Pilih kategori',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: _kategoriLabels.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedKategori = value),
                validator: (value) => value == null || value.isEmpty
                    ? 'Kategori wajib dipilih'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Jumlah (Rp)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nominalCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah pengeluaran',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  final sanitized =
                      value.replaceAll('.', '').replaceAll(',', '.');
                  final parsed = double.tryParse(sanitized);
                  if (parsed == null) {
                    return 'Masukkan angka valid';
                  }
                  if (parsed <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Tanggal Pengeluaran',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTanggal,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih tanggal'
                            : _formatDate(_selectedDate!),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedDate == null ? Colors.grey[400] : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bukti Pengeluaran (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBukti,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _buktiPath == null || _buktiPath!.isEmpty
                              ? 'Upload bukti (jpg, png, pdf)'
                              : 'File: ${_buktiPath!.split(RegExp(r"[\\/]+")).last}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _buktiPath == null ? Colors.grey[400] : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.item != null ? 'Simpan Perubahan' : 'Simpan Pengeluaran',
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
}
