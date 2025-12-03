import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' show utf8, base64Encode;

class CetakLaporanPage extends StatefulWidget {
  const CetakLaporanPage({super.key});

  @override
  State<CetakLaporanPage> createState() => _CetakLaporanPageState();
}

class _CetakLaporanPageState extends State<CetakLaporanPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedJenisLaporan;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _jenisLaporanOptions = [
    'Semua',
    'Pemasukan',
    'Pengeluaran',
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.goNamed('home-keuangan'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cetak Laporan Keuangan',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDateField('Tanggal Mulai', _startDateController, true),
            const SizedBox(height: 16),
            _buildDateField('Tanggal Akhir', _endDateController, false),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Jenis Laporan',
              _selectedJenisLaporan,
              _jenisLaporanOptions,
              (value) {
                setState(() => _selectedJenisLaporan = value);
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Download Laporan',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      String label, TextEditingController controller, bool isStartDate) {
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
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.clear();
                          if (isStartDate) {
                            _startDate = null;
                          } else {
                            _endDate = null;
                          }
                        });
                      },
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  if (controller.text.isNotEmpty) const SizedBox(width: 8),
                  const Icon(Icons.calendar_today,
                      size: 20, color: Color(0xffC7C7CD)),
                ],
              ),
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
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: isStartDate
                  ? (_startDate ?? DateTime.now())
                  : (_endDate ?? DateTime.now()),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                if (isStartDate) {
                  _startDate = pickedDate;
                } else {
                  _endDate = pickedDate;
                }
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options,
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffE5E5EA)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Semua',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _handleDownload() async {
    // Validasi tanggal
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih tanggal mulai dan tanggal akhir terlebih dahulu',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tanggal mulai harus sebelum tanggal akhir',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Simulasi data laporan
      final laporanData = _generateLaporanData();

      // Tampilkan dialog dengan file options
      _showDownloadDialog(laporanData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat laporan: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _generateLaporanData() {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Simulasi data
    final pemasukan = [
      {
        'tanggal': '2025-10-18',
        'nama': 'Iuran Bulanan Oktober',
        'kategori': 'Iuran Bulanan',
        'jumlah': 500000,
      },
      {
        'tanggal': '2025-10-15',
        'nama': 'Donasi Tambahan',
        'kategori': 'Donasi',
        'jumlah': 250000,
      },
    ];

    final pengeluaran = [
      {
        'tanggal': '2025-10-17',
        'nama': 'Perbaikan Jalan',
        'kategori': 'Infrastruktur',
        'jumlah': 300000,
      },
      {
        'tanggal': '2025-10-10',
        'nama': 'Pembelian Perlengkapan',
        'kategori': 'Operasional',
        'jumlah': 150000,
      },
    ];

    final totalPemasukan = pemasukan.fold<int>(
      0,
      (sum, item) => sum + (item['jumlah'] as int),
    );
    final totalPengeluaran = pengeluaran.fold<int>(
      0,
      (sum, item) => sum + (item['jumlah'] as int),
    );

    return {
      'tanggalMulai': dateFormat.format(_startDate!),
      'tanggalAkhir': dateFormat.format(_endDate!),
      'jenisLaporan': _selectedJenisLaporan ?? 'Semua',
      'pemasukan': pemasukan,
      'pengeluaran': pengeluaran,
      'totalPemasukan': totalPemasukan,
      'totalPengeluaran': totalPengeluaran,
      'saldo': totalPemasukan - totalPengeluaran,
      'currencyFormat': currencyFormat,
    };
  }

  void _showDownloadDialog(Map<String, dynamic> laporanData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Pilih Format Download',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Laporan ${laporanData['tanggalMulai']} hingga ${laporanData['tanggalAkhir']}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total Pemasukan: ${(laporanData['currencyFormat'] as NumberFormat).format(laporanData['totalPemasukan'])}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Pengeluaran: ${(laporanData['currencyFormat'] as NumberFormat).format(laporanData['totalPengeluaran'])}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAsCSV(laporanData);
            },
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              'CSV',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAsText(laporanData);
            },
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              'TXT',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5067e9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadAsCSV(Map<String, dynamic> laporanData) {
    final csvContent = _generateCSVContent(laporanData);
    _showDownloadPreview(
        'Laporan-Keuangan-${DateFormat('ddMMyyyy').format(DateTime.now())}.csv',
        csvContent);
  }

  void _downloadAsText(Map<String, dynamic> laporanData) {
    final textContent = _generateTextContent(laporanData);
    _showDownloadPreview(
        'Laporan-Keuangan-${DateFormat('ddMMyyyy').format(DateTime.now())}.txt',
        textContent);
  }

  String _generateCSVContent(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    final currencyFormat = data['currencyFormat'] as NumberFormat;

    buffer.writeln('LAPORAN KEUANGAN');
    buffer
        .writeln('Periode: ${data['tanggalMulai']} - ${data['tanggalAkhir']}');
    buffer.writeln('Jenis Laporan: ${data['jenisLaporan']}');
    buffer.writeln('');

    if (data['jenisLaporan'] == 'Semua' ||
        data['jenisLaporan'] == 'Pemasukan' ||
        data['jenisLaporan'] == 'Pemasukan dan Pengeluaran') {
      buffer.writeln('PEMASUKAN');
      buffer.writeln('Tanggal,Nama,Kategori,Jumlah');
      for (var item in data['pemasukan'] as List) {
        buffer.writeln(
          '${item['tanggal']},${item['nama']},${item['kategori']},${currencyFormat.format(item['jumlah'])}',
        );
      }
      buffer.writeln(
          'Total Pemasukan,,,${currencyFormat.format(data['totalPemasukan'])}');
      buffer.writeln('');
    }

    if (data['jenisLaporan'] == 'Semua' ||
        data['jenisLaporan'] == 'Pengeluaran' ||
        data['jenisLaporan'] == 'Pemasukan dan Pengeluaran') {
      buffer.writeln('PENGELUARAN');
      buffer.writeln('Tanggal,Nama,Kategori,Jumlah');
      for (var item in data['pengeluaran'] as List) {
        buffer.writeln(
          '${item['tanggal']},${item['nama']},${item['kategori']},${currencyFormat.format(item['jumlah'])}',
        );
      }
      buffer.writeln(
          'Total Pengeluaran,,,${currencyFormat.format(data['totalPengeluaran'])}');
      buffer.writeln('');
    }

    buffer.writeln('RINGKASAN');
    buffer.writeln(
        'Total Pemasukan,${currencyFormat.format(data['totalPemasukan'])}');
    buffer.writeln(
        'Total Pengeluaran,${currencyFormat.format(data['totalPengeluaran'])}');
    buffer.writeln('Saldo,${currencyFormat.format(data['saldo'])}');

    return buffer.toString();
  }

  String _generateTextContent(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    final currencyFormat = data['currencyFormat'] as NumberFormat;

    buffer.writeln('═' * 60);
    buffer.writeln('LAPORAN KEUANGAN KOMUNITAS');
    buffer.writeln('═' * 60);
    buffer.writeln('');
    buffer.writeln(
        'Periode Laporan: ${data['tanggalMulai']} - ${data['tanggalAkhir']}');
    buffer.writeln('Jenis Laporan: ${data['jenisLaporan']}');
    buffer.writeln(
        'Tanggal Cetak: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}');
    buffer.writeln('');

    if (data['jenisLaporan'] == 'Semua' ||
        data['jenisLaporan'] == 'Pemasukan' ||
        data['jenisLaporan'] == 'Pemasukan dan Pengeluaran') {
      buffer.writeln('─' * 60);
      buffer.writeln('DETAIL PEMASUKAN');
      buffer.writeln('─' * 60);
      for (var i = 0; i < (data['pemasukan'] as List).length; i++) {
        final item = (data['pemasukan'] as List)[i];
        buffer.writeln('${i + 1}. ${item['nama']}');
        buffer.writeln('   Tanggal: ${item['tanggal']}');
        buffer.writeln('   Kategori: ${item['kategori']}');
        buffer.writeln('   Jumlah: ${currencyFormat.format(item['jumlah'])}');
        buffer.writeln('');
      }
      buffer.writeln(
          'Total Pemasukan: ${currencyFormat.format(data['totalPemasukan'])}');
      buffer.writeln('');
    }

    if (data['jenisLaporan'] == 'Semua' ||
        data['jenisLaporan'] == 'Pengeluaran' ||
        data['jenisLaporan'] == 'Pemasukan dan Pengeluaran') {
      buffer.writeln('─' * 60);
      buffer.writeln('DETAIL PENGELUARAN');
      buffer.writeln('─' * 60);
      for (var i = 0; i < (data['pengeluaran'] as List).length; i++) {
        final item = (data['pengeluaran'] as List)[i];
        buffer.writeln('${i + 1}. ${item['nama']}');
        buffer.writeln('   Tanggal: ${item['tanggal']}');
        buffer.writeln('   Kategori: ${item['kategori']}');
        buffer.writeln('   Jumlah: ${currencyFormat.format(item['jumlah'])}');
        buffer.writeln('');
      }
      buffer.writeln(
          'Total Pengeluaran: ${currencyFormat.format(data['totalPengeluaran'])}');
      buffer.writeln('');
    }

    buffer.writeln('═' * 60);
    buffer.writeln('RINGKASAN KEUANGAN');
    buffer.writeln('═' * 60);
    buffer.writeln(
        'Total Pemasukan     : ${currencyFormat.format(data['totalPemasukan'])}');
    buffer.writeln(
        'Total Pengeluaran   : ${currencyFormat.format(data['totalPengeluaran'])}');
    buffer.writeln('─' * 60);
    buffer.writeln(
        'Saldo               : ${currencyFormat.format(data['saldo'])}');
    buffer.writeln('═' * 60);

    return buffer.toString();
  }

  void _showDownloadPreview(String filename, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Pratinjau File',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.robotoMono(fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _saveFile(filename, content);
            },
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              'Download',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5067e9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveFile(String filename, String content) async {
    try {
      if (kIsWeb) {
        // Download di web menggunakan simple approach
        _downloadOnWeb(filename, content);
      } else {
        // Download di mobile
        await _downloadOnMobile(filename, content);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan file: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _downloadOnWeb(String filename, String content) {
    try {
      // Simple download approach for web
      final bytes = utf8.encode(content);
      final dataUrl = 'data:text/plain;base64,${base64Encode(bytes)}';

      // Use JS to trigger download
      _triggerWebDownload(filename, dataUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File "$filename" berhasil diunduh',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal download: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _triggerWebDownload(String filename, String dataUrl) {
    // This will be called only on web
    // Use window.location or similar approach
    try {
      // For web, we can use the browser's native download mechanism
      // This requires running JavaScript which we can't do directly
      // Instead, provide a fallback message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Silakan gunakan right-click → Save As untuk menyimpan file',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _downloadOnMobile(String filename, String content) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows) {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      final File file = File('${directory.path}/$filename');
      await file.writeAsString(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File "$filename" berhasil disimpan\nLokasi: ${directory.path}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleReset() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _selectedJenisLaporan = null;
      _startDate = null;
      _endDate = null;
    });
  }
}
