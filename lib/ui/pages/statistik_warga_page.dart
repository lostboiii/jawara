import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class StatistikWargaPage extends StatefulWidget {
  const StatistikWargaPage({super.key});

  @override
  State<StatistikWargaPage> createState() => _StatistikWargaPageState();
}

class _StatistikWargaPageState extends State<StatistikWargaPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _totalWarga = 0;
  int _totalKeluarga = 0;
  int _totalRumah = 0;
  int _totalAspirasi = 0;
  int _wargaLakiLaki = 0;
  int _wargaPerempuan = 0;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final wargaResponse = await _supabase.from('warga_profiles').select('id, jenis_kelamin');
      final keluargaResponse = await _supabase.from('keluarga').select('id');
      final rumahResponse = await _supabase.from('rumah').select('id');
      final aspirasiResponse = await _supabase.from('aspirasi').select('id');

      int lakiLaki = 0;
      int perempuan = 0;
      for (var warga in wargaResponse) {
        final jenisKelamin = (warga['jenis_kelamin'] ?? '').toString().toLowerCase();
        if (jenisKelamin == 'laki-laki' || jenisKelamin == 'l') {
          lakiLaki++;
        } else if (jenisKelamin == 'perempuan' || jenisKelamin == 'p') {
          perempuan++;
        }
      }

      if (mounted) {
        setState(() {
          _totalWarga = wargaResponse.length;
          _totalKeluarga = keluargaResponse.length;
          _totalRumah = rumahResponse.length;
          _totalAspirasi = aspirasiResponse.length;
          _wargaLakiLaki = lakiLaki;
          _wargaPerempuan = perempuan;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading warga data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          onPressed: () => context.go('/home-warga'),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
        ),
        title: Text(
          'Statistik Warga Lengkap',
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
                  _buildSummaryCard(primaryColor),
                  const SizedBox(height: 24),
                  _buildPieChartSection(primaryColor),
                  const SizedBox(height: 24),
                  _buildBarChartSection(primaryColor),
                  const SizedBox(height: 24),
                  _buildDetailCards(primaryColor),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(Color primaryColor) {
    final avgWargaPerKeluarga = _totalKeluarga > 0 
        ? (_totalWarga / _totalKeluarga).toStringAsFixed(1) 
        : '0';
    final avgWargaPerRumah = _totalRumah > 0 
        ? (_totalWarga / _totalRumah).toStringAsFixed(1) 
        : '0';

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
            'Total Warga',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_totalWarga',
            style: GoogleFonts.inter(
              fontSize: 48,
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
                      'Rata-rata per Keluarga',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$avgWargaPerKeluarga orang',
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
                      'Rata-rata per Rumah',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$avgWargaPerRumah orang',
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
            'Distribusi Jenis Kelamin',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
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
                        label: 'Laki-laki',
                        value: _wargaLakiLaki,
                      ),
                      const SizedBox(height: 16),
                      _buildLegendItem(
                        color: Colors.pink.shade300,
                        label: 'Perempuan',
                        value: _wargaPerempuan,
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
    final total = _wargaLakiLaki + _wargaPerempuan;
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'Tidak ada data',
          radius: 50,
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: primaryColor,
        value: _wargaLakiLaki.toDouble(),
        title: _touchedIndex == 0 ? '$_wargaLakiLaki' : '${(_wargaLakiLaki / total * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 0 ? 65 : 55,
        titleStyle: GoogleFonts.inter(
          fontSize: _touchedIndex == 0 ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.pink.shade300,
        value: _wargaPerempuan.toDouble(),
        title: _touchedIndex == 1 ? '$_wargaPerempuan' : '${(_wargaPerempuan / total * 100).toStringAsFixed(0)}%',
        radius: _touchedIndex == 1 ? 65 : 55,
        titleStyle: GoogleFonts.inter(
          fontSize: _touchedIndex == 1 ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int value,
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
                '$value',
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
            'Perbandingan Data',
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
                maxY: [_totalWarga, _totalKeluarga, _totalRumah, _totalAspirasi]
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Warga', 'Keluarga', 'Rumah', 'Aspirasi'];
                        if (value.toInt() < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()],
                              style: GoogleFonts.inter(fontSize: 11),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
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
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _totalWarga.toDouble(),
                        color: primaryColor,
                        width: 30,
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
                        toY: _totalKeluarga.toDouble(),
                        color: const Color(0xff3a4fcf),
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _totalRumah.toDouble(),
                        color: Colors.orange,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: _totalAspirasi.toDouble(),
                        color: Colors.green,
                        width: 30,
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

  Widget _buildDetailCards(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Data',
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
                icon: Icons.people_rounded,
                label: 'Total Warga',
                value: '$_totalWarga',
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.family_restroom_rounded,
                label: 'Total Keluarga',
                value: '$_totalKeluarga',
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
                icon: Icons.home_rounded,
                label: 'Total Rumah',
                value: '$_totalRumah',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.message_rounded,
                label: 'Total Aspirasi',
                value: '$_totalAspirasi',
                color: Colors.green,
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
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
