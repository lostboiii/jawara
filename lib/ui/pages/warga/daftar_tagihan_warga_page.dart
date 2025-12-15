import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarTagihanWargaPage extends StatefulWidget {
  const DaftarTagihanWargaPage({super.key});

  @override
  State<DaftarTagihanWargaPage> createState() => _DaftarTagihanWargaPageState();
}

class _DaftarTagihanWargaPageState extends State<DaftarTagihanWargaPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _tagihan = [];
  String _filterStatus = 'semua'; // semua, belum_bayar, sudah_bayar

  @override
  void initState() {
    super.initState();
    _loadTagihan();
  }

  Future<void> _loadTagihan() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load profile untuk mendapatkan keluarga_id
      final profileResponse = await _supabase
          .from('warga_profiles')
          .select('keluarga_id')
          .eq('id', userId)
          .single();

      final keluargaId = profileResponse['keluarga_id'];

      if (keluargaId != null) {
        // Build query dengan filter
        PostgrestFilterBuilder query = _supabase
            .from('tagih_iuran')
            .select('''
              id,
              tanggal_tagihan,
              jumlah,
              status_tagihan,
              kategori_iuran:kategori_id (
                nama_iuran,
                kategori_iuran
              )
            ''')
            .eq('keluarga_id', keluargaId);

        // Apply status filter
        if (_filterStatus != 'semua') {
          query = query.eq('status_tagihan', _filterStatus);
        }

        final response = await query
            .order('tanggal_tagihan', ascending: false);
        _tagihan = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint('Error loading tagihan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff5067e9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
        ),
        title: Text(
          'Daftar Tagihan',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'semua', primaryColor),
                const SizedBox(width: 8),
                _buildFilterChip('Belum Bayar', 'belum_bayar', primaryColor),
                const SizedBox(width: 8),
                _buildFilterChip('Sudah Bayar', 'sudah_bayar', primaryColor),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tagihan.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada tagihan',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTagihan,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _tagihan.length,
                          itemBuilder: (context, index) {
                            return _buildTagihanCard(_tagihan[index], primaryColor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color primaryColor) {
    final isSelected = _filterStatus == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _filterStatus = value);
          _loadTagihan();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagihanCard(Map<String, dynamic> tagihan, Color primaryColor) {
    final kategori = tagihan['kategori_iuran'];
    final status = tagihan['status_tagihan'];
    final isBelumBayar = status == 'belum_bayar';
    
    final tanggal = tagihan['tanggal_tagihan'] != null
        ? DateFormat('dd MMM yyyy', 'id_ID')
            .format(DateTime.parse(tagihan['tanggal_tagihan']))
        : 'N/A';

    final jumlah = tagihan['jumlah'] != null
        ? NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(tagihan['jumlah'])
        : 'Rp 0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategori?['nama_iuran'] ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tanggal,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBelumBayar
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBelumBayar ? 'Belum Bayar' : 'Sudah Bayar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isBelumBayar ? Colors.orange[700] : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jumlah,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (isBelumBayar)
                ElevatedButton(
                  onPressed: () {
                    context.goNamed(
                      'bayar-iuran',
                      pathParameters: {'tagihanId': tagihan['id']},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Bayar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
