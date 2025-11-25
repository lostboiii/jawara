import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/metode_pembayaran_model.dart';
import '../../../viewmodels/metode_pembayaran_viewmodel.dart';

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
        const SnackBar(content: Text('Upload gambar tidak didukung di web. Isi URL secara manual.')),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? 'Edit Channel' : 'Tambah Channel',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _namaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Metode',
                      hintText: 'Contoh: Transfer BCA, QRIS RT 08',
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Rekening / Akun',
                      hintText: 'Contoh: 1234567890',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pemilikCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pemilik',
                      hintText: 'Contoh: John Doe',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _imageField(
                    label: 'Foto Barcode (Opsional)',
                    controller: _barcodeCtrl,
                    onPick: () => _pickImage(_barcodeCtrl),
                  ),
                  const SizedBox(height: 12),
                  _imageField(
                    label: 'Thumbnail (Opsional)',
                    controller: _thumbCtrl,
                    onPick: () => _pickImage(_thumbCtrl),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catatanCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      hintText: 'Contoh: Transfer hanya dari bank yang sama agar instan',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: viewModel.isLoading ? null : () => _handleSubmit(viewModel, isEditing),
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    MetodePembayaranViewModel viewModel,
    bool isEditing,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final namaMetode = _namaCtrl.text.trim();
    final nomor = _nomorCtrl.text.trim().isEmpty ? null : _nomorCtrl.text.trim();
    final pemilik = _pemilikCtrl.text.trim().isEmpty ? null : _pemilikCtrl.text.trim();
    final barcode = _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim();
    final thumb = _thumbCtrl.text.trim().isEmpty ? null : _thumbCtrl.text.trim();
    final catatan = _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim();

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
        if (mounted) context.pop(true);
      } else {
        await viewModel.addMetodePembayaran(
          namaMetode: namaMetode,
          nomorRekening: nomor,
          namaPemilik: pemilik,
          fotoBarcode: barcode,
          thumbnail: thumb,
          catatan: catatan,
        );
        if (mounted) context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  Widget _imageField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onPick,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Masukkan URL atau pilih file',
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.upload),
          tooltip: 'Pilih file',
        ),
      ),
    );
  }
}
