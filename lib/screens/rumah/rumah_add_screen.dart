// lib/screens/rumah/rumah_add_screen.dart
import 'package:flutter/material.dart';

class RumahAddScreen extends StatefulWidget {
  const RumahAddScreen({super.key});

  @override
  _RumahAddScreenState createState() => _RumahAddScreenState();
}

class _RumahAddScreenState extends State<RumahAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController nomorRumahController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController rtController = TextEditingController();
  TextEditingController rwController = TextEditingController();
  TextEditingController kelurahanController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController luasTanahController = TextEditingController();
  TextEditingController luasBangunanController = TextEditingController();
  
  String? statusKepemilikan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Tambah Rumah Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Identitas Rumah'),
            _buildCard([
              _buildTextField('Nomor Rumah', 'Contoh: 123', nomorRumahController),
              SizedBox(height: 16),
              _buildTextField('Alamat Lengkap', 'Masukkan alamat lengkap', alamatController,
                  maxLines: 2),
            ]),
            
            SizedBox(height: 16),
            _buildSectionTitle('Wilayah'),
            _buildCard([
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('RT', 'Contoh: 01', rtController,
                        keyboardType: TextInputType.number),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('RW', 'Contoh: 02', rwController,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField('Kelurahan', 'Masukkan kelurahan', kelurahanController),
              SizedBox(height: 16),
              _buildTextField('Kecamatan', 'Masukkan kecamatan', kecamatanController),
            ]),
            
            SizedBox(height: 16),
            _buildSectionTitle('Detail Properti'),
            _buildCard([
              _buildDropdown(
                'Status Kepemilikan',
                statusKepemilikan,
                ['Milik Sendiri', 'Sewa', 'Kontrak', 'Lainnya'],
                (value) => setState(() => statusKepemilikan = value),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Luas Tanah (m²)', 'Contoh: 200', luasTanahController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Luas Bangunan (m²)', 'Contoh: 150', luasBangunanController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  ),
                ],
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
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'SIMPAN DATA RUMAH',
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

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
              borderSide: BorderSide(color: Colors.green, width: 2),
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

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
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
              borderSide: BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: Text('Pilih $label'),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
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
            'Data rumah berhasil disimpan',
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