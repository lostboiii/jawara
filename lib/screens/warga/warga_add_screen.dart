// lib/screens/warga/warga_add_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WargaAddScreen extends StatefulWidget {
  const WargaAddScreen({super.key});

  @override
  _WargaAddScreenState createState() => _WargaAddScreenState();
}

class _WargaAddScreenState extends State<WargaAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tempatLahirController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController pekerjaanController = TextEditingController();
  TextEditingController noTeleponController = TextEditingController();

  // Dropdown values
  String? jenisKelamin;
  String? agama;
  String? pendidikan;
  String? statusPerkawinan;
  String? statusDalamKeluarga;
  String? rumahDipilih;

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Tambah Warga Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Data Identitas'),
            _buildCard([
              _buildTextField(
                'NIK',
                'Masukkan NIK 16 digit',
                nikController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField('Nama Lengkap', 'Masukkan nama lengkap', namaController),
              SizedBox(height: 16),
              _buildDropdown(
                'Jenis Kelamin',
                jenisKelamin,
                ['Laki-laki', 'Perempuan'],
                (value) => setState(() => jenisKelamin = value),
              ),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Tempat & Tanggal Lahir'),
            _buildCard([
              _buildTextField('Tempat Lahir', 'Masukkan tempat lahir', tempatLahirController),
              SizedBox(height: 16),
              _buildDateField(),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Data Lainnya'),
            _buildCard([
              _buildDropdown(
                'Agama',
                agama,
                ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
                (value) => setState(() => agama = value),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                'Pendidikan Terakhir',
                pendidikan,
                ['Tidak Sekolah', 'SD', 'SMP', 'SMA', 'D3', 'S1', 'S2', 'S3'],
                (value) => setState(() => pendidikan = value),
              ),
              SizedBox(height: 16),
              _buildTextField('Pekerjaan', 'Masukkan pekerjaan', pekerjaanController),
              SizedBox(height: 16),
              _buildDropdown(
                'Status Perkawinan',
                statusPerkawinan,
                ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
                (value) => setState(() => statusPerkawinan = value),
              ),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Data Keluarga & Rumah'),
            _buildCard([
              _buildDropdown(
                'Status dalam Keluarga',
                statusDalamKeluarga,
                [
                  'Kepala Keluarga',
                  'Istri',
                  'Anak',
                  'Menantu',
                  'Cucu',
                  'Orang Tua',
                  'Lainnya'
                ],
                (value) => setState(() => statusDalamKeluarga = value),
              ),
              SizedBox(height: 16),
              _buildDropdown(
                'Pilih Rumah',
                rumahDipilih,
                [
                  'Jl. Raya Surabaya No. 123',
                  'Jl. Merdeka No. 45',
                  'Jl. Pahlawan No. 78'
                ],
                (value) => setState(() => rumahDipilih = value),
              ),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Kontak'),
            _buildCard([
              _buildTextField(
                'No. Telepon',
                'Masukkan nomor telepon',
                noTeleponController,
                keyboardType: TextInputType.phone,
              ),
            ]),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showSuccessDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'SIMPAN DATA WARGA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // === Widget Helper ===

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: Text('Pilih $label'),
          items: items
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal Lahir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: tanggalLahirController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal lahir',
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            setState(() {
              selectedDate = pickedDate;
              tanggalLahirController.text =
                  DateFormat('dd/MM/yyyy').format(pickedDate!);
            });
                    },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal lahir wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Data warga berhasil disimpan',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
