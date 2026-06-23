import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';

final reportPeriodProvider = StateProvider<String>((ref) => 'today');

final periodStatsProvider = StreamProvider.autoDispose.family<Map<String, dynamic>, String>((ref, period) {
  final service = ref.watch(reportServiceProvider);
  return service.streamPeriodStats(period);
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
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title Eyebrow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.tintOlive,
                  border: Border(
                    top: BorderSide(color: AppColors.frameInk),
                    left: BorderSide(color: AppColors.frameInk),
                    right: BorderSide(color: AppColors.frameInk),
                  ),
                ),
                child: Text(
                  'FINANCIAL REPORTING / LAPORAN KEUANGAN',
                  style: GoogleFonts.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.frameInk,
              ),
              const SizedBox(height: 16),

              // Retro Period Selector
              _buildPeriodFilter(context, ref, selectedPeriod),
              const SizedBox(height: 20),

              // Content stats loader
              statsAsync.when(
                data: (stats) {
                  final totalRevenue = (stats['totalRevenue'] as num).toDouble();
                  final pcRevenue = (stats['pcRevenue'] as num).toDouble();
                  final psRevenue = (stats['psRevenue'] as num).toDouble();
                  final recentTransactions = (stats['recentTransactions'] as List<dynamic>?) ?? [];

                  final totalForPercentage = pcRevenue + psRevenue;
                  final pcPct = totalForPercentage > 0 ? (pcRevenue / totalForPercentage * 100).round() : 0;
                  final psPct = totalForPercentage > 0 ? (psRevenue / totalForPercentage * 100).round() : 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Revenue & distribution stack
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 768;
                          return Flex(
                            direction: isWide ? Axis.horizontal : Axis.vertical,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Revenue block
                              Expanded(
                                flex: isWide ? 5 : 0,
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                    right: isWide ? 16 : 0,
                                    bottom: isWide ? 0 : 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.canvas,
                                          border: Border.all(color: AppColors.frameInk),
                                        ),
                                        child: Text(
                                          'TOTAL REVENUE / PENDAPATAN KOTOR',
                                          style: GoogleFonts.arimo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: AppColors.tintPeach,
                                          border: Border(
                                            left: BorderSide(color: AppColors.frameInk),
                                            right: BorderSide(color: AppColors.frameInk),
                                            bottom: BorderSide(color: AppColors.frameInk),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currencyFormatter.format(totalRevenue),
                                              style: GoogleFonts.tinos(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(Icons.trending_up, size: 16, color: AppColors.ink),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Berdasarkan durasi sewa selesai.',
                                                  style: GoogleFonts.tinos(
                                                    fontSize: 12,
                                                    color: AppColors.ink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Platform distribution block
                              Expanded(
                                flex: isWide ? 7 : 0,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.canvas,
                                          border: Border.all(color: AppColors.frameInk),
                                        ),
                                        child: Text(
                                          'PLATFORM SHARE / DISTRIBUSI PENDAPATAN',
                                          style: GoogleFonts.arimo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: AppColors.tintSky,
                                          border: Border(
                                            left: BorderSide(color: AppColors.frameInk),
                                            right: BorderSide(color: AppColors.frameInk),
                                            bottom: BorderSide(color: AppColors.frameInk),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildDistributionBar(context, 'Komputer Workstation (PC)', '$pcPct%', AppColors.tintOlive, pcPct / 100),
                                            const SizedBox(height: 12),
                                            _buildDistributionBar(context, 'Konsol Playstation (PS)', '$psPct%', AppColors.tintSalmon, psPct / 100),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Busiest/recent transactions section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.tintSteel,
                          border: Border(
                            top: BorderSide(color: AppColors.frameInk),
                            left: BorderSide(color: AppColors.frameInk),
                            right: BorderSide(color: AppColors.frameInk),
                          ),
                        ),
                        child: Text(
                          'TRANSACTION LOGS / LOG TRANSAKSI',
                          style: GoogleFonts.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: recentTransactions.isEmpty
                            ? Container(
                                color: AppColors.canvas,
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Belum ada data sesi untuk periode ini.',
                                    style: GoogleFonts.tinos(color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  // Table Headers
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.tintSteel,
                                      border: Border(
                                        bottom: BorderSide(color: AppColors.frameInk),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 3, child: Text('UNIT', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 4, child: Text('ID TRANSAKSI', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 3, child: Text('NOMINAL', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 2, child: Text('WAKTU', style: GoogleFonts.arimo(fontSize: 10, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                  ),
                                  // Table Rows
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: recentTransactions.length > 5 ? 5 : recentTransactions.length,
                                    separatorBuilder: (context, index) => const Divider(color: AppColors.frameInk, height: 1),
                                    itemBuilder: (context, index) {
                                      final tx = recentTransactions[index];
                                      final Color rowBg = index.isEven ? AppColors.canvas : const Color(0xFFF9F9F9);
                                      final isPC = tx.unitName.toLowerCase().contains('pc');
                                      final timeStr = tx.endTime != null ? DateFormat('HH:mm').format(tx.endTime!) : '-';

                                      return Container(
                                        color: rowBg,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isPC ? Icons.computer : Icons.sports_esports,
                                                    size: 14,
                                                    color: AppColors.ink,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    tx.unitName.replaceFirst('PS Station ', 'PS '),
                                                    style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                '${tx.id.substring(0, 8)} • ${tx.memberId != null ? 'Member' : 'Walk-in'}',
                                                style: GoogleFonts.tinos(fontSize: 12),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                currencyFormatter.format(tx.total),
                                                style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.tintOlive),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                timeStr,
                                                style: GoogleFonts.tinos(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Underlined Link blue button -> Updated to button-secondary
                      Center(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              border: Border.all(color: AppColors.frameInk),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MUAT LEBIH BANYAK LOG TRANSAKSI',
                                  style: GoogleFonts.arimo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.ink),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'Gagal memuat laporan: $e',
                      style: GoogleFonts.tinos(color: AppColors.primary),
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

  Widget _buildPeriodFilter(BuildContext context, WidgetRef ref, String selectedPeriod) {
    final periods = [
      {'label': 'HARI INI', 'key': 'today'},
      {'label': '7 HARI TERAKHIR', 'key': 'week'},
      {'label': 'BULAN INI', 'key': 'month'},
    ];

    return Row(
      children: periods.map((p) {
        final isSelected = p['key'] == selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () => ref.read(reportPeriodProvider.notifier).state = p['key']!,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.frameInk : AppColors.canvas,
                border: Border.all(color: AppColors.frameInk, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Text(
                p['label']!,
                style: GoogleFonts.arimo(
                  color: isSelected ? AppColors.canvas : AppColors.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistributionBar(BuildContext context, String label, String pct, Color color, double fraction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.tinos(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
            Text(
              pct,
              style: GoogleFonts.arimo(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Flat 1px border progress bar
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.canvas,
            border: Border.all(color: AppColors.frameInk),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
