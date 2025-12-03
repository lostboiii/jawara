import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/metode_pembayaran_model.dart';
import '../../../viewmodels/metode_pembayaran_viewmodel.dart';
import '../home_page.dart';

class ChannelTransferDetailPage extends StatefulWidget {
  const ChannelTransferDetailPage({super.key, this.item});

  final MetodePembayaranModel? item;

  @override
  State<ChannelTransferDetailPage> createState() =>
      _ChannelTransferDetailPageState();
}

class _ChannelTransferDetailPageState extends State<ChannelTransferDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorCtrl = TextEditingController();
  final _pemilikCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _thumbCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _namaCtrl.text = item.namaMetode;
      _nomorCtrl.text = item.nomorRekening ?? '';
      _pemilikCtrl.text = item.namaPemilik ?? '';
      _barcodeCtrl.text = item.fotoBarcode ?? '';
      _thumbCtrl.text = item.thumbnail ?? '';
      _catatanCtrl.text = item.catatan ?? '';
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
      // On web we cannot access local file path. Let user input URL manually.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Upload gambar tidak didukung di web. Isi URL secara manual.')),
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MetodePembayaranViewModel>();
    final isEditing = widget.item != null;

    return HomePage(
      initialIndex: 2,
      sectionBuilders: {
        2: (ctx, scope) => _buildSection(ctx, scope, viewModel, isEditing),
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    HomePageScope scope,
    MetodePembayaranViewModel viewModel,
    bool isEditing,
  ) {
    final primaryColor = scope.primaryColor;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isEditing
                      ? 'Edit Channel Transfer'
                      : 'Tambah Channel Transfer',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildFormCard(context, viewModel, isEditing, primaryColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    MetodePembayaranViewModel viewModel,
    bool isEditing,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Informasi Channel' : 'Informasi Channel Baru',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Nama Metode',
              hint: 'Contoh: Transfer BCA, QRIS RT 08',
              controller: _namaCtrl,
              icon: Icons.account_balance_rounded,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Nomor Rekening / Akun',
              hint: 'Contoh: 1234567890',
              controller: _nomorCtrl,
              icon: Icons.credit_card_rounded,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Nama Pemilik',
              hint: 'Contoh: John Doe',
              controller: _pemilikCtrl,
              icon: Icons.person_rounded,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _buildImageField(
              label: 'Foto Barcode (Opsional)',
              controller: _barcodeCtrl,
              onPick: () => _pickImage(_barcodeCtrl),
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _buildImageField(
              label: 'Thumbnail (Opsional)',
              controller: _thumbCtrl,
              onPick: () => _pickImage(_thumbCtrl),
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Catatan (Opsional)',
              hint: 'Contoh: Transfer hanya dari bank yang sama agar instan',
              controller: _catatanCtrl,
              icon: Icons.notes_rounded,
              primaryColor: primaryColor,
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handleSubmit(context, viewModel, isEditing),
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Simpan Perubahan' : 'Simpan Channel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color primaryColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          validator: label == 'Nama Metode'
              ? (value) => value == null || value.trim().isEmpty
                  ? 'Nama wajib diisi'
                  : null
              : null,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildImageField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onPick,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image_rounded, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan URL atau pilih file',
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: onPick,
                icon: Icon(Icons.upload_file_rounded,
                    color: primaryColor, size: 20),
                tooltip: 'Pilih file',
              ),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    MetodePembayaranViewModel viewModel,
    bool isEditing,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
      if (isEditing) {
        await viewModel.updateMetodePembayaran(
          id: widget.item!.id,
          namaMetode: namaMetode,
          nomorRekening: nomor,
          namaPemilik: pemilik,
          fotoBarcode: barcode,
          thumbnail: thumb,
          catatan: catatan,
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        await viewModel.addMetodePembayaran(
          namaMetode: namaMetode,
          nomorRekening: nomor,
          namaPemilik: pemilik,
          fotoBarcode: barcode,
          thumbnail: thumb,
          catatan: catatan,
        );
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }
}
