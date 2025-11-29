import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/register_viewmodel.dart';
import 'mutasi_keluarga_detail_page.dart';
import 'mutasi_keluarga_add_page.dart';

class MutasiKeluargaItem {
  final String keluarga_id;
  final String rumah_id;
  final DateTime tanggal_mutasi;
  final String alasan_mutasi;
  final String nama_keluarga;
  final String nama_rumah;

  MutasiKeluargaItem({
    required this.keluarga_id,
    required this.rumah_id,
    required this.tanggal_mutasi,
    required this.alasan_mutasi,
    this.nama_keluarga = '',
    this.nama_rumah = '',
  });
}

class MutasiKeluargaPage extends StatefulWidget {
  const MutasiKeluargaPage({super.key});

  @override
  State<MutasiKeluargaPage> createState() => _MutasiKeluargaPageState();
}

class _MutasiKeluargaPageState extends State<MutasiKeluargaPage> {
  final List<MutasiKeluargaItem> _items = [
    // starts empty; will load from backend
  ];

  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _keluargaCtrl = TextEditingController();
  // removed free-text rumah controller; we use rumah selection from DB
  // final _rumahCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();
  DateTime? _pickedDate = DateTime.now();

  // Filter states (dropdowns)
  String? _fNama; // selected keluarga id (filter)
  String? _fRumah; // selected rumah id (filter)
  List<Map<String, dynamic>> _rumahList = [];
  Map<String, String> _rumahCache = {}; // id -> alamat
  bool _loadingRumah = false;

  // New family list for dropdown
  List<Map<String, dynamic>> _keluargaList = [];
  bool _loadingKeluarga = false;

  String? _selectedRumahId;
  String? _selectedKeluargaId; // selected keluarga id (for add dialog)
  List<MutasiKeluargaItem> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = [];
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load dropdown data first, then load mutasi list
      _reloadDropdownData().then((_) => _loadMutasiList());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_items);
      } else {
        _filtered = _items.where((m) {
          final namaKeluarga = m.nama_keluarga.toLowerCase();
          final namaRumah = m.nama_rumah.toLowerCase();
          return namaKeluarga.contains(query) || namaRumah.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _reloadDropdownData() async {
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
      // Filter out entries with null id to prevent null safety errors
      final validList = list.where((r) => r['id'] != null).toList();
      if (mounted) {
        setState(() {
          _rumahList = validList;
          _rumahCache = {for (var r in validList) (r['id'] as String): (r['alamat'] as String? ?? '')};
          _loadingRumah = false;
        });
        debugPrint('Loaded ${_rumahList.length} rumah, cache size: ${_rumahCache.length}');
        debugPrint('Rumah cache keys: ${_rumahCache.keys.take(3).join(", ")}...');
      }
    } catch (e) {
      debugPrint('Error loading rumah list: $e');
      if (mounted) setState(() => _loadingRumah = false);
    }
  }

  Future<void> _loadMutasiList() async {
    try {
      final vm = context.read<RegisterViewModel>();
      final list = await vm.getMutasiList();
      final items = list.map((m) {
        final tanggalRaw = m['tanggal_mutasi'];
        DateTime tanggal_mutasi;
        if (tanggalRaw is String) {
          tanggal_mutasi = DateTime.tryParse(tanggalRaw) ?? DateTime.now();
        } else if (tanggalRaw is DateTime) {
          tanggal_mutasi = tanggalRaw;
        } else {
          tanggal_mutasi = DateTime.now();
        }
        
        // Get nama keluarga
        final keluargaId = (m['keluarga_id'] as String?) ?? '';
        final keluarga = _keluargaList.firstWhere(
          (k) => (k['id'] as String?) == keluargaId,
          orElse: () => {},
        );
        final namaKeluarga = keluarga.isNotEmpty 
            ? (keluarga['nama_kepala_keluarga'] as String? ?? keluargaId)
            : keluargaId;
        
        // Get nama rumah - with better fallback
        final rumahId = (m['rumah_id'] as String?) ?? '';
        String namaRumah = rumahId;
        
        if (rumahId.isNotEmpty) {
          debugPrint('Looking for rumah_id: $rumahId');
          // First try cache
          if (_rumahCache.containsKey(rumahId)) {
            namaRumah = _rumahCache[rumahId]!;
            debugPrint('Found in cache: $namaRumah');
          } else {
            debugPrint('NOT in cache, searching _rumahList (${_rumahList.length} items)');
            // Try to find in _rumahList
            final rumah = _rumahList.firstWhere(
              (r) => (r['id'] as String?) == rumahId,
              orElse: () => {},
            );
            if (rumah.isNotEmpty) {
              namaRumah = rumah['alamat'] as String? ?? rumahId;
              // Update cache
              _rumahCache[rumahId] = namaRumah;
              debugPrint('Found in list and cached: $namaRumah');
            } else {
              debugPrint('NOT FOUND in list, using ID: $rumahId');
            }
          }
        }
        
        return MutasiKeluargaItem(
          keluarga_id: keluargaId,
          rumah_id: rumahId,
          tanggal_mutasi: tanggal_mutasi,
          alasan_mutasi: (m['alasan_mutasi'] as String?) ?? '',
          nama_keluarga: namaKeluarga,
          nama_rumah: namaRumah,
        );
      }).toList();
      if (mounted) setState(() { _items.clear(); _items.addAll(items); _filtered = List.from(_items); });
    } catch (e) {
      debugPrint('Error loading mutasi list: $e');
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

  String _rumahLabelById(String id) {
    if (id.isEmpty) return '-';
    
    // Try cache first
    if (_rumahCache.containsKey(id)) {
      return _rumahCache[id]!;
    }
    
    // Try to find in _rumahList
    final rumah = _rumahList.firstWhere(
      (r) => (r['id'] as String?) == id,
      orElse: () => {},
    );
    
    if (rumah.isNotEmpty) {
      final alamat = rumah['alamat'] as String? ?? id;
      _rumahCache[id] = alamat; // Update cache
      return alamat;
    }
    
    return id;
  }

  String _formatDate(DateTime date) =>
      DateFormat('d MMMM y', 'id_ID').format(date);

  void _applyFilter() {
    setState(() {
      _filtered = _items.where((e) {
        final byNama = _fNama == null || _fNama == '' || e.keluarga_id == _fNama;
        final byRumah = _fRumah == null || _fRumah == '' || e.rumah_id == _fRumah;

        return byNama && byRumah;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _fNama = null;
      _fRumah = null;
      _filtered = List<MutasiKeluargaItem>.from(_items);
    });
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter Mutasi Keluarga',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // Nama Keluarga filter (uses _fNama)
                DropdownButtonFormField<String>(
                  value: _fNama,
                  decoration: const InputDecoration(labelText: 'Nama Keluarga'),
                  isExpanded: true,
                  items: _keluargaList
                      .map(
                        (k) => DropdownMenuItem<String>(
                            value: k['id'] as String?,
                            child: Text(k['nomor_kk'] as String? ?? '-'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _fNama = v),
                ),
                const SizedBox(height: 8),
                // Rumah filter: now uses _rumahList instead of _items
                DropdownButtonFormField<String>(
                  value: _fRumah,
                  decoration: const InputDecoration(labelText: 'Rumah'),
                  isExpanded: true,
                  items: _rumahList
                      .map((r) => DropdownMenuItem<String>(
                            value: r['id'] as String?,
                            child: Text(r['alamat'] as String? ?? '-'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _fRumah = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _resetFilter();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          _applyFilter();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // simple chip color helper (not type-based anymore)
  Color _chipBg() => Colors.grey.shade200;
  Color _chipFg() => Colors.black87;

  // Helper: get keluarga name by id
  String _findKeluargaNameById(String id) {
    final found = _keluargaList.firstWhere(
      (k) => (k['id'] as String?) == id,
      orElse: () => {},
    );
    // Use nama_kepala_keluarga for label
    if (found.isNotEmpty) {
      return found['nama_kepala_keluarga'] as String? ?? found['nomor_kk'] as String? ?? id;
    }
    return id;
  }

  Widget _kvRow(String label, String value) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: t.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutasiCard(MutasiKeluargaItem m, int index) {
    final primaryColor = const Color(0xff5067e9);
    final keluargaName = m.nama_keluarga.isNotEmpty ? m.nama_keluarga : _findKeluargaNameById(m.keluarga_id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keluargaName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 14,
                          color: Color(0xffA1A1A1),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            m.nama_rumah.isNotEmpty ? m.nama_rumah : _rumahLabelById(m.rumah_id),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color(0xffA1A1A1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(m.tanggal_mutasi),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  'MUTASI',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (m.alasan_mutasi.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Alasan:',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m.alasan_mutasi,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MutasiKeluargaDetailPage(item: m),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Detail',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() async {
    _selectedKeluargaId = null;
    _selectedRumahId = null;
    _alasanCtrl.clear();
    _pickedDate = DateTime.now();
    await _reloadDropdownData();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Tambah Mutasi Keluarga',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keluarga',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
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
                        borderSide: const BorderSide(color: Color(0xff5067e9), width: 2),
                      ),
                    ),
                    isExpanded: true,
                    items: _keluargaList
                        .map(
                          (k) => DropdownMenuItem<String>(
                            value: k['id'] as String?,
                            child: Text(
                              k['nomor_kk'] as String? ?? '-',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => _selectedKeluargaId = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib pilih keluarga' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rumah',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _loadingRumah
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _rumahList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Tidak ada rumah tersedia',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
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
                                  borderSide: const BorderSide(color: Color(0xff5067e9), width: 2),
                                ),
                              ),
                              items: _rumahList
                                  .where((rumah) => rumah['id'] != null)
                                  .map((rumah) => DropdownMenuItem<String>(
                                        value: rumah['id'] as String,
                                        child: Text(
                                          rumah['alamat'] as String? ?? 'Alamat tidak diketahui',
                                          style: GoogleFonts.inter(fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) => setDialogState(() => _selectedRumahId = v),
                              validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih rumah' : null,
                            ),
                  const SizedBox(height: 16),
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
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xff5067e9),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (d != null) setDialogState(() => _pickedDate = d);
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
                          const Icon(Icons.calendar_today, size: 18, color: Color(0xffA1A1A1)),
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
                        borderSide: const BorderSide(color: Color(0xff5067e9), width: 2),
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // create mutasi via viewmodel with runtime checks and error handling
                  try {
                    final vm = Provider.of<RegisterViewModel>(context, listen: false);
                    debugPrint('RegisterViewModel runtimeType: ${vm.runtimeType}');
                    vm.createMutasi(
                      keluarga_id: _selectedKeluargaId ?? '',
                      rumah_id: _selectedRumahId ?? '',
                      tanggal_mutasi: _pickedDate ?? DateTime.now(),
                      alasan_mutasi: _alasanCtrl.text.trim(),
                    ).then((created) {
                      final tanggalRaw = created['tanggal_mutasi'];
                      DateTime tanggal_mutasi;
                      if (tanggalRaw is String) {
                        tanggal_mutasi = DateTime.tryParse(tanggalRaw) ?? DateTime.now();
                      } else if (tanggalRaw is DateTime) {
                        tanggal_mutasi = tanggalRaw;
                      } else {
                        tanggal_mutasi = DateTime.now();
                      }
                      if (mounted) {
                        setState(() {
                          _items.add(MutasiKeluargaItem(
                            keluarga_id: created['keluarga_id'] as String? ?? (_selectedKeluargaId ?? ''),
                            rumah_id: created['rumah_id'] as String? ?? (_selectedRumahId ?? ''),
                            tanggal_mutasi: tanggal_mutasi,
                            alasan_mutasi: created['alasan_mutasi'] as String? ?? _alasanCtrl.text,
                          ));
                          _filtered = List.from(_items);
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mutasi berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }).catchError((e, st) {
                      debugPrint('Error creating mutasi: $e\n$st');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menambahkan mutasi: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  } catch (e, st) {
                    debugPrint('Exception while calling createMutasi: $e\n$st');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambahkan mutasi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5067e9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/home-warga'),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Mutasi Keluarga',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari keluarga atau rumah...',
                      hintStyle: GoogleFonts.inter(fontSize: 14),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MutasiKeluargaAddPage(),
                      ),
                    );
                    if (result == true) {
                      // Reload data after adding
                      _reloadDropdownData().then((_) => _loadMutasiList());
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.swap_horiz_outlined,
                        size: 48, color: Color(0xffA1A1A1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada mutasi keluarga.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tambahkan mutasi baru dengan menekan tombol +',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ..._filtered.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _mutasiCard(m, _filtered.indexOf(m)),
                  )),
          ],
        ),
      ),
    );
  }
}
