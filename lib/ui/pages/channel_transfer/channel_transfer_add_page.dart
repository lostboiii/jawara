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
          content: Text(
              'Upload gambar tidak didukung di web. Isi URL secara manual.'),
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
    final nomor =
        _nomorCtrl.text.trim().isEmpty ? null : _nomorCtrl.text.trim();
    final pemilik =
        _pemilikCtrl.text.trim().isEmpty ? null : _pemilikCtrl.text.trim();
    final barcode =
        _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim();
    final thumb =
        _thumbCtrl.text.trim().isEmpty ? null : _thumbCtrl.text.trim();
    final catatan =
        _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim();

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
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing
                        ? 'Ubah Channel Transfer'
                        : 'Tambah Channel Transfer',
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
                'Nama Metode',
                'Contoh: Transfer BCA, QRIS RT 08',
                _namaCtrl,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nomor Rekening / Akun',
                'Contoh: 1234567890',
                _nomorCtrl,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nama Pemilik',
                'Contoh: John Doe',
                _pemilikCtrl,
              ),
              const SizedBox(height: 16),
              _buildFileUploadField('Foto Barcode (Opsional)', _barcodeCtrl),
              const SizedBox(height: 16),
              _buildFileUploadField('Thumbnail (Opsional)', _thumbCtrl),
              const SizedBox(height: 16),
              _buildTextAreaField(
                'Catatan (Opsional)',
                'Contoh: Transfer hanya dari bank yang sama agar instan',
                _catatanCtrl,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
    final primaryColor = const Color(0xff5067e9);
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
          validator: (value) => value == null || value.trim().isEmpty
              ? '$label wajib diisi'
              : null,
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
          maxLines: 3,
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
        ),
      ],
    );
  }

  Widget _buildFileUploadField(String label, TextEditingController controller) {
    final primaryColor = const Color(0xff5067e9);
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
        GestureDetector(
          onTap: () => _pickImage(controller),
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
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.text.isNotEmpty
                      ? controller.text.split('/').last
                      : 'Unggah File',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: controller.text.isNotEmpty
                        ? Colors.black87
                        : primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.text.isEmpty)
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
}
