import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class StatistikKeuanganPage extends StatefulWidget {
  const StatistikKeuanganPage({super.key});

  @override
  State<StatistikKeuanganPage> createState() => _StatistikKeuanganPageState();
}

class _StatistikKeuanganPageState extends State<StatistikKeuanganPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _saldo = 0;
  double _pemasukanLain = 0;
  double _iuranLunas = 0;
  int _touchedIndex = -1;
  Map<String, double> _kategoriPemasukan = {};
  Map<String, double> _kategoriPengeluaran = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load pemasukan lain dengan kategori
      final pemasukanResponse = await _supabase
          .from('pemasukan_lain')
          .select('jumlah, kategori_pemasukan');
      
      double pemasukanLain = 0;
      Map<String, double> kategoriPemasukan = {};
      for (var item in pemasukanResponse) {
        final jumlah = (item['jumlah'] as num).toDouble();
        final kategori = (item['kategori_pemasukan'] ?? 'Lainnya').toString();
        pemasukanLain += jumlah;
        kategoriPemasukan[kategori] = (kategoriPemasukan[kategori] ?? 0) + jumlah;
      }

      // Load iuran yang sudah dibayar
      final iuranResponse = await _supabase
          .from('tagih_iuran')
          .select('jumlah')
          .eq('status_tagihan', 'sudah_bayar');
      
      double iuranLunas = 0;
      for (var item in iuranResponse) {
        iuranLunas += (item['jumlah'] as num).toDouble();
      }

      // Load pengeluaran dengan kategori
      final pengeluaranResponse = await _supabase
          .from('pengeluaran')
          .select('jumlah, kategori_pengeluaran');
      
      double pengeluaran = 0;
      Map<String, double> kategoriPengeluaran = {};
      for (var item in pengeluaranResponse) {
        final jumlah = (item['jumlah'] as num).toDouble();
        final kategori = (item['kategori_pengeluaran'] ?? 'Lainnya').toString();
        pengeluaran += jumlah;
        kategoriPengeluaran[kategori] = (kategoriPengeluaran[kategori] ?? 0) + jumlah;
      }

      double totalPemasukan = pemasukanLain + iuranLunas;

      if (mounted) {
        setState(() {
          _pemasukanLain = pemasukanLain;
          _iuranLunas = iuranLunas;
          _totalPemasukan = totalPemasukan;
          _totalPengeluaran = pengeluaran;
          _saldo = totalPemasukan - pengeluaran;
          _kategoriPemasukan = kategoriPemasukan;
          _kategoriPengeluaran = kategoriPengeluaran;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading keuangan data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatRupiah(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
        ),
        title: Text(
          'Statistik Keuangan Lengkap',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCard(primaryColor),
                  const SizedBox(height: 24),
                  
                  // Pie Chart - Proporsi Pemasukan
                  _buildPieChartSection(primaryColor),
                  const SizedBox(height: 24),
                  
                  // Bar Chart - Pemasukan vs Pengeluaran
                  _buildBarChartSection(primaryColor),
                  const SizedBox(height: 24),
                  
                  // Kategori Pemasukan & Pengeluaran
                  if (_kategoriPemasukan.isNotEmpty || _kategoriPengeluaran.isNotEmpty)
                    _buildKategoriSection(primaryColor),
                  if (_kategoriPemasukan.isNotEmpty || _kategoriPengeluaran.isNotEmpty)
                    const SizedBox(height: 24),
                  
                  // Detail Cards
                  _buildDetailCards(primaryColor),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xff3a4fcf)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatRupiah(_saldo),
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pemasukan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(_totalPemasukan),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(_totalPengeluaran),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Proporsi Pemasukan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildPieChartSections(primaryColor),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: primaryColor,
                        label: 'Pemasukan Lain',
                        value: _pemasukanLain,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        color: const Color(0xff3a4fcf),
                        label: 'Iuran',
                        value: _iuranLunas,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Color primaryColor) {
    final total = _totalPemasukan;
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: '',
          radius: 50,
        ),
      ];
    }

    final isTouched0 = _touchedIndex == 0;
    final isTouched1 = _touchedIndex == 1;
    
    return [
      PieChartSectionData(
        color: primaryColor,
        value: _pemasukanLain,
        title: '${(_pemasukanLain / total * 100).toStringAsFixed(0)}%',
        radius: isTouched0 ? 60 : 50,
        titleStyle: GoogleFonts.inter(
          fontSize: isTouched0 ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xff3a4fcf),
        value: _iuranLunas,
        title: '${(_iuranLunas / total * 100).toStringAsFixed(0)}%',
        radius: isTouched1 ? 60 : 50,
        titleStyle: GoogleFonts.inter(
          fontSize: isTouched1 ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double value,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _formatRupiah(value),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Pemasukan vs Pengeluaran',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_totalPemasukan > _totalPengeluaran
                        ? _totalPemasukan
                        : _totalPengeluaran) *
                    1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text('Pemasukan',
                                style: GoogleFonts.inter(fontSize: 12));
                          case 1:
                            return Text('Pengeluaran',
                                style: GoogleFonts.inter(fontSize: 12));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatRupiah(value),
                          style: GoogleFonts.inter(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _totalPemasukan,
                        color: primaryColor,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _totalPengeluaran,
                        color: Colors.red.shade400,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_kategoriPemasukan.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Kategori Pemasukan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ..._kategoriPemasukan.entries.map((entry) {
                  final percentage = (_totalPemasukan > 0) 
                      ? (entry.value / _totalPemasukan * 100) 
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatRupiah(entry.value),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_kategoriPengeluaran.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Kategori Pengeluaran',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ..._kategoriPengeluaran.entries.map((entry) {
                  final percentage = (_totalPengeluaran > 0) 
                      ? (entry.value / _totalPengeluaran * 100) 
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatRupiah(entry.value),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailCards(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Keuangan',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.attach_money_rounded,
                label: 'Pemasukan Lain',
                value: _formatRupiah(_pemasukanLain),
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.payment_rounded,
                label: 'Iuran Terbayar',
                value: _formatRupiah(_iuranLunas),
                color: const Color(0xff3a4fcf),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.trending_down_rounded,
                label: 'Total Pengeluaran',
                value: _formatRupiah(_totalPengeluaran),
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Saldo Akhir',
                value: _formatRupiah(_saldo),
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
