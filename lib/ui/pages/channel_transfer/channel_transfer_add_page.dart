import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/metode_pembayaran_model.dart';
import '../../../viewmodels/metode_pembayaran_viewmodel.dart';

class ChannelTransferAddPage extends StatefulWidget {
  final MetodePembayaranModel? item;

  const ChannelTransferAddPage({super.key, this.item});

  @override
  State<ChannelTransferAddPage> createState() => _ChannelTransferAddPageState();
}

class _ChannelTransferAddPageState extends State<ChannelTransferAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorCtrl = TextEditingController();
  final _pemilikCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _thumbCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _namaCtrl.text = widget.item!.namaMetode;
      _nomorCtrl.text = widget.item!.nomorRekening ?? '';
      _pemilikCtrl.text = widget.item!.namaPemilik ?? '';
      _barcodeCtrl.text = widget.item!.fotoBarcode ?? '';
      _thumbCtrl.text = widget.item!.thumbnail ?? '';
      _catatanCtrl.text = widget.item!.catatan ?? '';
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nomorCtrl.dispose();
    _pemilikCtrl.dispose();
    _barcodeCtrl.dispose();
    _thumbCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(TextEditingController controller) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload gambar tidak didukung di web. Isi URL secara manual.'),
        ),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() => controller.text = path);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final viewModel = context.read<MetodePembayaranViewModel>();
    final namaMetode = _namaCtrl.text.trim();
    final nomor = _nomorCtrl.text.trim().isEmpty ? null : _nomorCtrl.text.trim();
    final pemilik = _pemilikCtrl.text.trim().isEmpty ? null : _pemilikCtrl.text.trim();
    final barcode = _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim();
    final thumb = _thumbCtrl.text.trim().isEmpty ? null : _thumbCtrl.text.trim();
    final catatan = _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim();

    try {
      if (widget.item != null) {
        await viewModel.updateMetodePembayaran(
          id: widget.item!.id,
          namaMetode: namaMetode,
          nomorRekening: nomor,
          namaPemilik: pemilik,
          fotoBarcode: barcode,
          thumbnail: thumb,
          catatan: catatan,
        );
      } else {
        await viewModel.addMetodePembayaran(
          namaMetode: namaMetode,
          nomorRekening: nomor,
          namaPemilik: pemilik,
          fotoBarcode: barcode,
          thumbnail: thumb,
          catatan: catatan,
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
    final isEditing = widget.item != null;

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
                    isEditing ? 'Ubah Channel Transfer' : 'Tambah Channel Transfer',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Nama Metode',
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
                  hintText: 'Contoh: Transfer BCA, QRIS RT 08',
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
                'Nomor Rekening / Akun',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomorCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Contoh: 1234567890',
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
              ),
              const SizedBox(height: 20),
              Text(
                'Nama Pemilik',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pemilikCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Contoh: John Doe',
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
              ),
              const SizedBox(height: 20),
              Text(
                'Foto Barcode (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _barcodeCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Masukkan URL atau pilih file',
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
                  suffixIcon: IconButton(
                    onPressed: () => _pickImage(_barcodeCtrl),
                    icon: Icon(Icons.upload_file, color: primaryColor),
                    tooltip: 'Pilih file',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Thumbnail (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _thumbCtrl,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  hintText: 'Masukkan URL atau pilih file',
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
                  suffixIcon: IconButton(
                    onPressed: () => _pickImage(_thumbCtrl),
                    icon: Icon(Icons.upload_file, color: primaryColor),
                    tooltip: 'Pilih file',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Catatan (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _catatanCtrl,
                style: GoogleFonts.inter(),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Transfer hanya dari bank yang sama agar instan',
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
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSubmit,
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
                          isEditing ? 'Simpan Perubahan' : 'Simpan Channel',
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
