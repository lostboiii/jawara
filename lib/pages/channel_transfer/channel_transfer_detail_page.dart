import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'channel_item.dart';

class ChannelTransferDetailPage extends StatefulWidget {
  const ChannelTransferDetailPage({super.key, this.item});

  final ChannelItem? item;

  @override
  State<ChannelTransferDetailPage> createState() =>
      _ChannelTransferDetailPageState();
}

class _ChannelTransferDetailPageState extends State<ChannelTransferDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorCtrl = TextEditingController();
  final _anCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  String? _tipe;
  String? _qrPath;
  String? _thumbPath;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    if (it != null) {
      _namaCtrl.text = it.nama;
      _tipe = it.tipe;
      _nomorCtrl.text = it.nomor;
      _anCtrl.text = it.an;
      _qrPath = it.qrPath;
      _thumbPath = it.thumbnailPath;
      _catatanCtrl.text = it.catatan ?? '';
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nomorCtrl.dispose();
    _anCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(String) setPath) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res != null && res.files.isNotEmpty) {
      final path = res.files.single.path;
      if (path != null) setState(() => setPath(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null
              ? 'Buat Transfer Channel'
              : 'Edit Transfer Channel',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Channel',
                  hintText: 'Contoh: BCA, Dana, QRIS RT',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _tipe,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('bank')),
                  DropdownMenuItem(value: 'ewallet', child: Text('ewallet')),
                  DropdownMenuItem(value: 'qris', child: Text('qris')),
                ],
                onChanged: (v) => setState(() => _tipe = v),
                validator: (v) => v == null || v.isEmpty ? 'Pilih tipe' : null,
              ),
              TextFormField(
                controller: _nomorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening / Akun',
                  hintText: 'Contoh: 1234567890',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _anCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Pemilik',
                  hintText: 'Contoh: John Doe',
                ),
              ),
              const SizedBox(height: 12),
              _uploadBox(
                label: 'QR',
                fileName: _qrPath?.split(Platform.pathSeparator).last,
                onPick: () => _pickImage((p) => _qrPath = p),
              ),
              const SizedBox(height: 12),
              _uploadBox(
                label: 'Thumbnail',
                fileName: _thumbPath?.split(Platform.pathSeparator).last,
                onPick: () => _pickImage((p) => _thumbPath = p),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catatanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText:
                      'Contoh: Transfer hanya dari bank yang sama agar instan',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final item = ChannelItem(
                      nama: _namaCtrl.text,
                      tipe: _tipe!,
                      nomor: _nomorCtrl.text,
                      an: _anCtrl.text,
                      qrPath: _qrPath,
                      thumbnailPath: _thumbPath,
                      catatan: _catatanCtrl.text.isEmpty
                          ? null
                          : _catatanCtrl.text,
                    );
                    Navigator.pop(context, item);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadBox({
    required String label,
    required String? fileName,
    required VoidCallback onPick,
  }) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fileName ?? 'Upload ${label.toLowerCase()} (jika ada) png/jpeg/jpg',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload),
            label: Text('Pilih $label'),
          ),
        ],
      ),
    );
  }
}
