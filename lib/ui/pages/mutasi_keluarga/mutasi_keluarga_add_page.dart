import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jawara/viewmodels/register_viewmodel.dart';

class MutasiKeluargaAddPage extends StatefulWidget {
  const MutasiKeluargaAddPage({super.key});

  @override
  _MutasiKeluargaAddPageState createState() => _MutasiKeluargaAddPageState();
}

class _MutasiKeluargaAddPageState extends State<MutasiKeluargaAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _alasanCtrl = TextEditingController();
  DateTime? _pickedDate = DateTime.now();

  String? _selectedRumahId;
  String? _selectedKeluargaId;
  String? _selectedTipeMutasi; // 'pindah_rumah' or 'keluar_perumahan'
  String? _rumahAsalId;
  
  List<Map<String, dynamic>> _rumahList = [];
  List<Map<String, dynamic>> _keluargaList = [];
  bool _loadingRumah = false;
  bool _loadingKeluarga = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRumahList(),
      _loadKeluargaList(),
    ]);
  }

  Future<void> _loadRumahList() async {
    setState(() => _loadingRumah = true);
    try {
      final viewModel = context.read<RegisterViewModel>();
      final list = await viewModel.getRumahList();
      final validList = list.where((r) => r['id'] != null).toList();
      if (mounted) {
        setState(() {
          _rumahList = validList;
          _loadingRumah = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rumah list: $e');
      if (mounted) setState(() => _loadingRumah = false);
    }
  }

  Future<void> _loadKeluargaList() async {
    setState(() => _loadingKeluarga = true);
    try {
      final viewModel = context.read<RegisterViewModel>();
      final list = await viewModel.getKeluargaList();
      if (mounted) {
        setState(() {
          _keluargaList = list;
          _loadingKeluarga = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading keluarga list: $e');
      if (mounted) setState(() => _loadingKeluarga = false);
    }
  }

  Future<void> _getRumahAsalFromKeluarga() async {
    if (_selectedKeluargaId == null) return;
    
    try {
      final vm = context.read<RegisterViewModel>();
      // Get penghuni list to find current rumah
      final penghuniList = await vm.wargaRepository.getAllPenghuni();
      
      // Find penghuni with matching keluarga_id
      final penghuni = penghuniList.firstWhere(
        (p) => p['keluarga_id'] == _selectedKeluargaId,
        orElse: () => <String, dynamic>{},
      );
      
      if (penghuni.isNotEmpty && penghuni['alamat_id'] != null) {
        setState(() {
          _rumahAsalId = penghuni['alamat_id'];
        });
      } else {
        setState(() {
          _rumahAsalId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting rumah asal: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveMutasi() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation based on tipe mutasi
    if (_selectedTipeMutasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tipe mutasi terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTipeMutasi == 'pindah_rumah') {
      if (_selectedRumahId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih rumah tujuan terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_rumahAsalId != null && _rumahAsalId == _selectedRumahId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rumah tujuan tidak boleh sama dengan rumah asal'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedTipeMutasi == 'keluar_perumahan') {
      if (_rumahAsalId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keluarga ini tidak memiliki rumah yang ditempati'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final vm = context.read<RegisterViewModel>();
      
      // Create mutasi record
      await vm.createMutasi(
        keluarga_id: _selectedKeluargaId ?? '',
        rumah_id: _selectedTipeMutasi == 'pindah_rumah' ? _selectedRumahId ?? '' : _rumahAsalId ?? '',
        tanggal_mutasi: _pickedDate ?? DateTime.now(),
        alasan_mutasi: _alasanCtrl.text.trim(),
      );

      // Update rumah status based on tipe mutasi
      if (_selectedTipeMutasi == 'pindah_rumah') {
        // Update rumah asal to kosong FIRST (only if exists)
        if (_rumahAsalId != null) {
          debugPrint('Updating rumah asal $_rumahAsalId to kosong');
          await vm.wargaRepository.updateRumahStatus(_rumahAsalId!, 'kosong');
        }
        
        // Then update rumah tujuan to ditempati
        if (_selectedRumahId != null) {
          debugPrint('Updating rumah tujuan $_selectedRumahId to ditempati');
          await vm.wargaRepository.updateRumahStatus(_selectedRumahId!, 'ditempati');
        }
        
        // Update keluarga alamat to new rumah
        await vm.wargaRepository.updateKeluargaAlamat(
          _selectedKeluargaId!,
          _selectedRumahId,
        );
        
        // Update or create penghuni record
        final penghuniList = await vm.wargaRepository.getAllPenghuni();
        final penghuni = penghuniList.firstWhere(
          (p) => p['keluarga_id'] == _selectedKeluargaId,
          orElse: () => <String, dynamic>{},
        );
        
        if (penghuni.isNotEmpty && penghuni['id'] != null) {
          // Update existing penghuni
          await vm.wargaRepository.updatePenghuniRumah(
            penghuni['id'],
            _selectedRumahId!,
          );
        } else {
          // Create new penghuni record (keluarga baru masuk)
          await vm.wargaRepository.createPenghuni(
            keluargaId: _selectedKeluargaId!,
            rumahId: _selectedRumahId!,
          );
        }
      } else if (_selectedTipeMutasi == 'keluar_perumahan') {
        // Update rumah asal to kosong
        if (_rumahAsalId != null) {
          await vm.wargaRepository.updateRumahStatus(_rumahAsalId!, 'kosong');
        }
        
        // Update keluarga alamat to null (tidak punya rumah)
        await vm.wargaRepository.updateKeluargaAlamat(
          _selectedKeluargaId!,
          null,
        );
        
        // Delete penghuni record
        final penghuniList = await vm.wargaRepository.getAllPenghuni();
        final penghuni = penghuniList.firstWhere(
          (p) => p['keluarga_id'] == _selectedKeluargaId,
          orElse: () => <String, dynamic>{},
        );
        
        if (penghuni.isNotEmpty && penghuni['id'] != null) {
          await vm.wargaRepository.deletePenghuni(penghuni['id']);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mutasi berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan mutasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Mutasi Keluarga',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Tipe Mutasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTipeMutasi,
                decoration: InputDecoration(
                  hintText: 'Pilih Tipe Mutasi',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String>(
                    value: 'pindah_rumah',
                    child: Text(
                      'Pindah Rumah',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'keluar_perumahan',
                    child: Text(
                      'Keluar Perumahan',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedTipeMutasi = v;
                    _selectedRumahId = null;
                    _rumahAsalId = null;
                  });
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib pilih tipe mutasi' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Keluarga',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _loadingKeluarga
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedKeluargaId,
                      decoration: InputDecoration(
                        hintText: 'Pilih Keluarga',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      isExpanded: true,
                      items: _keluargaList
                          .map(
                            (k) => DropdownMenuItem<String>(
                              value: k['id'] as String?,
                              child: Text(
                                k['nama_kepala_keluarga'] as String? ?? k['nomor_kk'] as String? ?? '-',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedKeluargaId = v);
                        _getRumahAsalFromKeluarga();
                      },
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib pilih keluarga' : null,
                    ),
              const SizedBox(height: 16),
              if (_rumahAsalId != null) ...[
                Text(
                  'Rumah Asal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.home, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _rumahList.firstWhere(
                            (r) => r['id'] == _rumahAsalId,
                            orElse: () => {'alamat': 'Rumah tidak ditemukan'},
                          )['alamat'] as String? ?? '-',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_selectedTipeMutasi == 'pindah_rumah') ...[
                Text(
                  'Rumah Tujuan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _loadingRumah
                    ? const Center(child: CircularProgressIndicator())
                    : _rumahList.isEmpty
                        ? Text(
                            'Tidak ada rumah tersedia',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedRumahId,
                            decoration: InputDecoration(
                              hintText: 'Pilih Rumah / Alamat',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            items: _rumahList
                                .where((rumah) => rumah['id'] != null && rumah['id'] != _rumahAsalId)
                                .map((rumah) => DropdownMenuItem<String>(
                                      value: rumah['id'] as String,
                                      child: Text(
                                        rumah['alamat'] as String? ?? 'Alamat tidak diketahui',
                                        style: GoogleFonts.inter(fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedRumahId = v),
                            validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih rumah' : null,
                          ),
                const SizedBox(height: 16),
              ],
              Text(
                'Tanggal Mutasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _pickedDate!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (d != null) setState(() => _pickedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_pickedDate!),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alasan Mutasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alasanCtrl,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan mutasi',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan mutasi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMutasi,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Simpan',
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
}
