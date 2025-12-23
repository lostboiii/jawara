import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/tagih_iuran_repository.dart';
import '../../../viewmodels/bayar_iuran_viewmodel.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';

class BayarIuranPage extends StatelessWidget {
  const BayarIuranPage({super.key, required this.tagihanId});

  final String tagihanId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BayarIuranViewModel(
        repository: SupabaseTagihIuranRepository(
          client: Supabase.instance.client,
        ),
      ),
      child: _BayarIuranPageContent(tagihanId: tagihanId),
    );
  }
}

class _BayarIuranPageContent extends StatefulWidget {
  const _BayarIuranPageContent({required this.tagihanId});

  final String tagihanId;

  @override
  State<_BayarIuranPageContent> createState() => _BayarIuranPageContentState();
}

class _BayarIuranPageContentState extends State<_BayarIuranPageContent> {
  final TextEditingController _catatanController = TextEditingController();
  String? _selectedMetodeId;
  String? _buktiPath;
  String? _buktiFileName;
  List<int>? _buktiBytes;
  bool _isProcessing = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BayarIuranViewModel>();
      viewModel.loadTagihan(widget.tagihanId);
      viewModel.loadMetodePembayaran();
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb, // Penting untuk web: load bytes
      );

      if (result != null) {
        final file = result.files.single;
        
        setState(() {
          // Di web gunakan name, di mobile gunakan path
          _buktiPath = kIsWeb ? file.name : (file.path ?? file.name);
          _buktiFileName = file.name;
          _buktiBytes = file.bytes?.toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _prosessPembayaran() async {
    setState(() => _isProcessing = true);

    try {
      final viewModel = context.read<BayarIuranViewModel>();

      debugPrint('💳 Processing payment...');
      
      final success = await viewModel.prosessPembayaran(
        tagihanId: widget.tagihanId,
        metodePembayaranId: _selectedMetodeId,
        catatanPembayaran: _catatanController.text.trim().isEmpty 
            ? null 
            : _catatanController.text.trim(),
        filePath: _buktiPath,
        fileBytes: _buktiBytes,
      );

      debugPrint('📊 Payment result: $success');

      if (!mounted) return;

      if (success) {
        // Reload financial data di DashboardViewModel
        final dashboardVM = Provider.of<DashboardViewModel>(context, listen: false);
        await dashboardVM.loadFinancialData();
        
        showDialog(
          context: context,
          barrierDismissible: false,
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
                'Pembayaran iuran berhasil diproses',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5067e9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memproses pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<BayarIuranViewModel>(
          builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.tagihan == null) {
                return Center(
                  child: Text(
                    'Tagihan tidak ditemukan',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                );
              }

              final tagihan = viewModel.tagihan!;
              final kategori = tagihan['kategori_iuran'];
              final keluarga = tagihan['keluarga'];
              final kepalaKeluarga = keluarga?['warga_profiles'];

              return ListView(
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
                        'Bayar Iuran',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Tagihan
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Tagihan',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Jenis Iuran', kategori['nama_iuran'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Nama Kepala Keluarga', kepalaKeluarga?['nama_lengkap'] ?? '-'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Tanggal Tagihan',
                          DateFormat('dd MMMM yyyy', 'id_ID').format(
                            DateTime.parse(tagihan['tanggal_tagihan']),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Jumlah',
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(tagihan['jumlah']),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Metode Pembayaran
                  Text(
                    'Metode Pembayaran *',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetodePembayaranList(viewModel),

                  const SizedBox(height: 24),

                  // Upload Bukti
                  Text(
                    'Bukti Pembayaran (Opsional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUploadBukti(),

                  const SizedBox(height: 24),

                  // Catatan Pembayaran (Optional)
                  Text(
                    'Catatan Pembayaran (Opsional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan catatan jika diperlukan, misalnya nomor referensi transfer',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Transfer melalui BCA, nomor referensi: TRF123456789',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
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
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tombol Bayar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _prosessPembayaran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Bayar',
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
          ),
        ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMetodePembayaranList(BayarIuranViewModel viewModel) {
    if (viewModel.metodePembayaran.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Tidak ada metode pembayaran tersedia',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return Column(
      children: viewModel.metodePembayaran.map((metode) {
        final isSelected = _selectedMetodeId == metode['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMetodeId = isSelected ? null : metode['id'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff5067e9).withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xff5067e9) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xff5067e9) : Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metode['nama_metode'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (metode['nomor_rekening'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${metode['nomor_rekening']} - ${metode['atas_nama'] ?? ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadBukti() {
    return Column(
      children: [
        if (_buktiFileName != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _buktiFileName!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _buktiPath = null;
                      _buktiFileName = null;
                      _buktiBytes = null;
                    });
                  },
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: Text(
            _buktiFileName == null ? 'Pilih Bukti Pembayaran' : 'Ganti File',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
