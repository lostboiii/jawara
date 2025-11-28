import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/register_viewmodel.dart';
import 'mutasi_keluarga_detail_page.dart';

class MutasiKeluargaItem {
  final String keluarga_id;
  final String rumah_id;
  final DateTime tanggal_mutasi;
  final String alasan_mutasi;

  MutasiKeluargaItem({
    required this.keluarga_id,
    required this.rumah_id,
    required this.tanggal_mutasi,
    required this.alasan_mutasi,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMutasiList();
      // Use refactored reload method
      _reloadDropdownData();
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
        return MutasiKeluargaItem(
          keluarga_id: (m['keluarga_id'] as String?) ?? '',
          rumah_id: (m['rumah_id'] as String?) ?? '',
          tanggal_mutasi: tanggal_mutasi,
          alasan_mutasi: (m['alasan_mutasi'] as String?) ?? '',
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
    return _rumahCache[id] ?? id;
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
    // Use nomor_kk for label (can adjust to name later if available)
    if (found.isNotEmpty) {
      return found['nomor_kk'] as String? ?? id;
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
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keluarga',
                        style: t.labelLarge?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.keluarga_id,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_rumahLabelById(m.rumah_id)),
                  backgroundColor: _chipBg(), 
                  labelStyle: t.labelMedium?.copyWith(color: _chipFg()),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _kvRow('No', '${index + 1}'),
            const Divider(height: 1),
            _kvRow('Rumah', _rumahLabelById(m.rumah_id)),
            const Divider(height: 1),
            _kvRow('Tanggal Mutasi', _formatDate(m.tanggal_mutasi)),
            const Divider(height: 1),
            _kvRow('Alasan_Mutasi', m.alasan_mutasi),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MutasiKeluargaDetailPage(item: m),
                  ),
                );
              },
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() async {
    _selectedKeluargaId = null;
    _selectedRumahId = null;
    _alasanCtrl.clear();
    _pickedDate = DateTime.now();
    // Use refactored reload method to ensure dropdowns have latest data
    await _reloadDropdownData();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Mutasi Keluarga'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedKeluargaId,
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
                  onChanged: (v) => setState(() => _selectedKeluargaId = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib pilih keluarga' : null,
                ),
                // Rumah dropdown (loaded from DB)
                _loadingRumah
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: CircularProgressIndicator(),
                      )
                    : _rumahList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text('Tidak ada rumah tersedia'),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRumahId,
                              decoration: const InputDecoration(labelText: 'Pilih Rumah / Alamat'),
                              items: _rumahList
                                  .where((rumah) => rumah['id'] != null)
                                  .map((rumah) => DropdownMenuItem<String>(
                                        value: rumah['id'] as String,
                                        child: Text(rumah['alamat'] as String? ?? 'Alamat tidak diketahui'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedRumahId = v),
                              validator: (v) => (v == null || v.isEmpty) ? 'Wajib pilih rumah' : null,
                            ),
                          ),
                TextFormField(
                  controller: _alasanCtrl,
                  decoration: const InputDecoration(labelText: 'Alasan'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alasan mutasi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('Tanggal: ${_formatDate(_pickedDate!)}'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _pickedDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _pickedDate = d);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pilih'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // create mutasi via viewmodel with runtime checks and error handling
                try {
                  final vm = context.read<RegisterViewModel>();
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
                    setState(() {
                      _items.add(MutasiKeluargaItem(
                        keluarga_id: created['keluarga_id'] as String? ?? (_selectedKeluargaId ?? ''),
                        rumah_id: created['rumah_id'] as String? ?? (_selectedRumahId ?? ''),
                        tanggal_mutasi: tanggal_mutasi,
                        alasan_mutasi: created['alasan_mutasi'] as String? ?? _alasanCtrl.text,
                      ));
                      _filtered = List.from(_items);
                    });
                    Navigator.pop(context);
                  });
                } catch (e, st) {
                  debugPrint('Exception while calling createMutasi: $e\n$st');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memanggil fungsi createMutasi: $e')));
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home-warga'),
        ),
        title: const Text('Mutasi Keluarga',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _mutasiCard(_filtered[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
