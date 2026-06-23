import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/services_provider.dart';

final reportPeriodProvider = StateProvider<String>((ref) => 'today');

final periodStatsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, period) async {
  final service = ref.watch(reportServiceProvider);
  return await service.getPeriodStats(period);
});

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final statsAsync = ref.watch(periodStatsProvider(selectedPeriod));

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text(
          'LAPORAN KEUANGAN & UNIT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh Data',
            onPressed: () {
              ref.invalidate(periodStatsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Filter Row
              Row(
                children: [
                  _buildFilterButton(ref, 'Hari Ini', 'today', selectedPeriod),
                  const SizedBox(width: 8),
                  _buildFilterButton(ref, '7 Hari', 'week', selectedPeriod),
                  const SizedBox(width: 8),
                  _buildFilterButton(ref, 'Bulan Ini', 'month', selectedPeriod),
                ],
              ),
              const SizedBox(height: 24),

              statsAsync.when(
                data: (stats) {
                  final totalRevenue = stats['totalRevenue'] as double;
                  final pcRevenue = stats['pcRevenue'] as double;
                  final psRevenue = stats['psRevenue'] as double;
                  final pcCount = stats['pcCount'] as int;
                  final psCount = stats['psCount'] as int;
                  final busiestUnits = stats['busiestUnits'] as List<dynamic>;
                  final hourlyCount = stats['hourlyCount'] as List<int>;
                  final dailyRevenue = stats['dailyRevenue'] as Map<String, double>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Revenue Display Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0088FF), Color(0xFF00D4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0088FF).withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL PENDAPATAN',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormatter.format(totalRevenue),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Dari ${stats['totalCount']} total sesi terselesaikan',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // breakdown PC vs PS (Horizontal stats split)
                      Row(
                        children: [
                          Expanded(
                            child: _buildBreakdownCard(
                              title: '💻 PC Revenue',
                              amount: currencyFormatter.format(pcRevenue),
                              count: '$pcCount Sesi',
                              color: const Color(0xFF0088FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBreakdownCard(
                              title: '🎮 PS Revenue',
                              amount: currencyFormatter.format(psRevenue),
                              count: '$psCount Sesi',
                              color: const Color(0xFF00D4FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chart section (Daily breakdown if week or month is selected)
                      if (dailyRevenue.isNotEmpty && selectedPeriod != 'today') ...[
                        const Text(
                          'GRAFIK PENDAPATAN HARIAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dailyRevenue.values.fold<double>(0.0, (m, e) => e > m ? e : m) * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => const Color(0xFF12121A),
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final dateKey = dailyRevenue.keys.elementAt(group.x);
                                    return BarTooltipItem(
                                      '$dateKey\n${currencyFormatter.format(rod.toY)}',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < dailyRevenue.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            dailyRevenue.keys.elementAt(index),
                                            style: const TextStyle(color: Colors.white54, fontSize: 9),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                    reservedSize: 22,
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(dailyRevenue.length, (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: dailyRevenue.values.elementAt(index),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF0088FF), Color(0xFF00D4FF)],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      width: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ranking unit tersibuk
                      const Text(
                        '🏆 RANKING UNIT TERSIBUK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: busiestUnits.isEmpty
                            ? const Center(
                                child: Text('Belum ada data sesi untuk periode ini.', style: TextStyle(color: Colors.white38)),
                              )
                            : Column(
                                children: List.generate(busiestUnits.length > 5 ? 5 : busiestUnits.length, (index) {
                                  final unit = busiestUnits[index];
                                  final numSesi = unit['count'] as int;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        // Rank Circle
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: index == 0
                                                ? const Color(0xFFFFD700).withOpacity(0.2)
                                                : index == 1
                                                    ? const Color(0xFFC0C0C0).withOpacity(0.2)
                                                    : Colors.white10,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: index == 0
                                                  ? const Color(0xFFFFD700)
                                                  : index == 1
                                                      ? const Color(0xFFC0C0C0)
                                                      : Colors.transparent,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: index == 0
                                                  ? const Color(0xFFFFD700)
                                                  : index == 1
                                                      ? const Color(0xFFC0C0C0)
                                                      : Colors.white54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            unit['name'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$numSesi Sesi',
                                          style: const TextStyle(
                                            color: Color(0xFF00D4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Peak Hour summary
                      const Text(
                        '⏰ JAM TERSIBUK (TRAFIK SESI)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Distribusi jam operasional (08:00 - 24:00)',
                              style: TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            const SizedBox(height: 16),
                            // Simple horizontal distribution chart
                            Column(
                              children: List.generate(8, (i) {
                                // Group into 2-hour slots for cleanliness (e.g. 08:00-10:00, 10:00-12:00...)
                                final startH = 8 + (i * 2);
                                final count = hourlyCount[startH] + hourlyCount[startH + 1];
                                final maxCount = hourlyCount.reduce((a, b) => a > b ? a : b) * 2;

                                final percentage = maxCount > 0 ? count / maxCount : 0.0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          '${startH.toString().padLeft(2, '0')}:00-${(startH + 2).toString().padLeft(2, '0')}:00',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            backgroundColor: Colors.white10,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0088FF)),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '$count Sesi',
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text('Gagal memuat laporan: $e', style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(WidgetRef ref, String label, String period, String currentPeriod) {
    final isSelected = period == currentPeriod;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(reportPeriodProvider.notifier).state = period;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0088FF) : const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF00D4FF) : Colors.white10,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required String amount,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
