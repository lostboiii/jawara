import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../viewmodels/aspirasi_warga_viewmodel.dart';

class EditAspirasiPage extends StatefulWidget {
  const EditAspirasiPage({super.key, required this.aspirasi});

  final AspirasiItem aspirasi;

  @override
  State<EditAspirasiPage> createState() => _EditAspirasiPageState();
}

class _EditAspirasiPageState extends State<EditAspirasiPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _selectedStatus;

  final List<String> _statusOptions = <String>[
    'pending',
    'diterima',
    'ditolak'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.aspirasi.status.trim().toLowerCase();
    if (!_statusOptions.contains(_selectedStatus)) {
      _selectedStatus = 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Aspirasi',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoCard(),
              const SizedBox(height: 24),
              Text(
                'Status Aspirasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                isExpanded: true,
                decoration: InputDecoration(
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
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
                items: _statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_statusLabel(value)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Perubahan',
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

  Widget _buildInfoCard() {
    final AspirasiItem item = widget.aspirasi;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.judul,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.person_outline,
                  size: 14, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Text(
                item.pengirim,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.calendar_today,
                  size: 14, color: Color(0xffA1A1A1)),
              const SizedBox(width: 6),
              Text(
                'Dibuat: ${item.tanggalLabel}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop<String>(context, _selectedStatus);
  }
}
