import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/broadcast_viewmodel.dart';
import 'broadcast_list_page.dart';

class EditBroadcastPage extends StatefulWidget {
  const EditBroadcastPage({super.key, required this.broadcast});

  final BroadcastListItem broadcast;

  @override
  State<EditBroadcastPage> createState() => _EditBroadcastPageState();
}

class _EditBroadcastPageState extends State<EditBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;

  PlatformFile? _selectedFoto;
  PlatformFile? _selectedDokumen;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.broadcast.judulBroadcast);
    _isiController = TextEditingController(text: widget.broadcast.isiBroadcast);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isImage) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.custom,
      allowedExtensions: isImage ? null : ['pdf'],
    );

    if (result != null) {
      setState(() {
        if (isImage) {
          _selectedFoto = result.files.first;
        } else {
          _selectedDokumen = result.files.first;
        }
      });
    }
  }

  void _removeFile(bool isImage) {
    setState(() {
      if (isImage) {
        _selectedFoto = null;
      } else {
        _selectedDokumen = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final broadcastViewModel = context.watch<BroadcastViewModel>();
    final isLoading = broadcastViewModel.isLoading;
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
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Broadcast',
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
                'Judul Broadcast',
                'Masukkan Judul Broadcast',
                _judulController,
              ),
              const SizedBox(height: 16),
              _buildTextAreaField(
                'Isi Broadcast',
                'Masukkan Isi Broadcast',
                _isiController,
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Foto',
                'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar.',
                true,
              ),
              const SizedBox(height: 16),
              _buildUploadField(
                'Dokumen',
                'Maksimal 10 file (.pdf), ukuran maksimal 5MB per file.',
                false,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            await broadcastViewModel.updateBroadcast(
                              id: widget.broadcast.id,
                              judul: _judulController.text.trim(),
                              isi: _isiController.text.trim(),
                            );
                            if (!context.mounted) return;
                            _showSuccessDialog();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal memperbarui broadcast: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
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
          maxLines: 5,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xffC7C7CD),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
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
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUploadField(String label, String hint, bool isImage) {
    final file = isImage ? _selectedFoto : _selectedDokumen;

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
        if (file == null) ...[
          InkWell(
            onTap: () => _pickFile(isImage),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xffE5E5EA),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isImage ? Icons.image_outlined : Icons.picture_as_pdf,
                    size: 48,
                    color: const Color(0xffC7C7CD),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xffC7C7CD),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klik untuk upload',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5067e9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE5E5EA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xff5067e9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isImage ? Icons.image : Icons.picture_as_pdf,
                    color: const Color(0xff5067e9),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xffC7C7CD),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFile(isImage),
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showSuccessDialog() {
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
            'Broadcast berhasil diperbarui',
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
