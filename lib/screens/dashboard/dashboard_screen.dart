import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/unit_model.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/unit_card.dart';
import '../../widgets/elapsed_time_text.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcUnitsAsync = ref.watch(pcUnitsStreamProvider);
    final psUnitsAsync = ref.watch(psUnitsStreamProvider);
    final activeSessionsAsync = ref.watch(activeSessionsStreamProvider);
    final todaySessionsAsync = ref.watch(todayCompletedSessionsProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pcUnitsStreamProvider);
          ref.invalidate(psUnitsStreamProvider);
          ref.invalidate(activeSessionsStreamProvider);
          ref.invalidate(todayCompletedSessionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Eyebrow: Branch Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.tintSteel,
                    border: Border.all(color: AppColors.frameInk, width: 1.0),
                  ),
                  child: Text(
                    'JAKARTA OFFICE BRANCH',
                    style: GoogleFonts.arimo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Overview cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 768;
                    return Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Unit Aktif
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              bottom: isDesktop ? 0 : 16,
                              right: isDesktop ? 16 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header bar
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.computer, size: 14, color: AppColors.ink),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SYSTEM STATUS / UNIT AKTIF',
                                        style: GoogleFonts.arimo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tinted Body
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.tintSage,
                                    border: Border(
                                      left: BorderSide(color: AppColors.frameInk),
                                      right: BorderSide(color: AppColors.frameInk),
                                      bottom: BorderSide(color: AppColors.frameInk),
                                    ),
                                  ),
                                  child: activeSessionsAsync.when(
                                    data: (sessions) {
                                      final totalUnits = (pcUnitsAsync.value?.length ?? 0) +
                                          (psUnitsAsync.value?.length ?? 0);
                                      final ratio = totalUnits > 0 ? sessions.length / totalUnits : 0.0;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                '${sessions.length}',
                                                style: GoogleFonts.arimo(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                              Text(
                                                ' UNIT AKTIF / $totalUnits TOTAL',
                                                style: GoogleFonts.tinos(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // Retro flat progress bar
                                          Container(
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: AppColors.canvas,
                                              border: Border.all(color: AppColors.frameInk),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: ratio.clamp(0.0, 1.0),
                                              child: Container(
                                                color: AppColors.tintOlive,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    loading: () => const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      'Error loading data',
                                      style: GoogleFonts.tinos(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Card 2: Pendapatan
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header bar
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.payments, size: 14, color: AppColors.ink),
                                      const SizedBox(width: 6),
                                      Text(
                                        'TODAY\'S REVENUE / PENDAPATAN',
                                        style: GoogleFonts.arimo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tinted Body
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
                                  child: todaySessionsAsync.when(
                                    data: (sessions) {
                                      final total = sessions.fold<double>(0, (sum, s) => sum + (s.total));
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currencyFormatter.format(total),
                                            style: GoogleFonts.tinos(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.arrow_upward, size: 14, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+12% vs Kemarin (Estimasi)',
                                                style: GoogleFonts.tinos(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                    loading: () => const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      'Error loading data',
                                      style: GoogleFonts.tinos(color: AppColors.primary),
                                    ),
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
                const SizedBox(height: 32),

                // Komputer (PC) Section Title (Arial Black Eyebrow style)
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
                    'KOMPUTER WORKSTATION (PC)',
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
                
                pcUnitsAsync.when(
                  data: (units) => _buildGrid(context, ref, units, activeSessionsAsync.value ?? []),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, __) => Text(
                    'Error loading PCs: $e',
                    style: GoogleFonts.tinos(color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 32),

                // Konsol (PS) Section Title
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.tintSalmon,
                    border: Border(
                      top: BorderSide(color: AppColors.frameInk),
                      left: BorderSide(color: AppColors.frameInk),
                      right: BorderSide(color: AppColors.frameInk),
                    ),
                  ),
                  child: Text(
                    'KONSOL GAME (PLAYSTATION)',
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

                psUnitsAsync.when(
                  data: (units) => _buildGrid(context, ref, units, activeSessionsAsync.value ?? []),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, __) => Text(
                    'Error loading PS: $e',
                    style: GoogleFonts.tinos(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<UnitModel> units, List<SessionModel> activeSessions) {
    if (units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Tidak ada unit terdaftar.',
          style: GoogleFonts.tinos(color: AppColors.ink),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; // sm
        if (constraints.maxWidth > 640) crossAxisCount = 3;
        if (constraints.maxWidth > 768) crossAxisCount = 4;
        if (constraints.maxWidth > 1024) crossAxisCount = 6;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 96,
          ),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];

            SessionModel? activeSession;
            if (unit.status == 'in_use' && unit.currentSessionId != null) {
              activeSession = activeSessions.firstWhere(
                (s) => s.id == unit.currentSessionId,
                orElse: () => SessionModel(
                  id: unit.currentSessionId!,
                  unitId: unit.id,
                  unitName: unit.name,
                  startTime: DateTime.now(),
                  customerName: 'Loading...',
                  subtotal: 0,
                  discount: 0,
                  total: 0,
                  extras: [],
                  paymentMethod: 'cash',
                  operatorId: '',
                  status: 'active',
                ),
              );
            }

            final userProfile = ref.watch(userProfileProvider).value;

            return _UnitCardWrapper(
              unit: unit,
              activeSession: activeSession,
              userProfile: userProfile,
            );
          },
        );
      },
    );
  }
}

class _UnitCardWrapper extends ConsumerStatefulWidget {
  final UnitModel unit;
  final SessionModel? activeSession;
  final dynamic userProfile;

  const _UnitCardWrapper({
    required this.unit,
    this.activeSession,
    this.userProfile,
  });

  @override
  ConsumerState<_UnitCardWrapper> createState() => _UnitCardWrapperState();
}

class _UnitCardWrapperState extends ConsumerState<_UnitCardWrapper> {
  @override
  Widget build(BuildContext context) {
    UnitState unitState;
    if (widget.unit.status == 'available') {
      unitState = UnitState.available;
    } else if (widget.unit.status == 'in_use') {
      unitState = UnitState.occupied;
    } else {
      unitState = UnitState.maintenance;
    }

    Widget? timeWidget;
    if (unitState == UnitState.occupied && widget.activeSession != null) {
      timeWidget = ElapsedTimeText(
        startTime: widget.activeSession!.startTime,
        style: GoogleFonts.tinos(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
        ),
      );
    }

    return UnitCard(
      title: widget.unit.name,
      state: unitState,
      timeText: '--:--:--',
      timeWidget: timeWidget,
      onTap: () {
        if (unitState == UnitState.available) {
          context.push('/start-session/${widget.unit.id}');
        } else if (unitState == UnitState.occupied && widget.activeSession != null) {
          context.push('/session-detail/${widget.activeSession!.id}');
        } else if (unitState == UnitState.maintenance) {
          if (widget.userProfile?.role == 'owner') {
            _showMaintenanceOptions(context, ref);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hanya Owner yang dapat mengubah status Maintenance',
                  style: GoogleFonts.tinos(),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        }
      },
    );
  }

  void _setMaintenanceStatus(WidgetRef ref, bool maintenance) async {
    final unitService = ref.read(unitServiceProvider);
    await unitService.updateUnitStatus(
      widget.unit.id,
      maintenance ? 'maintenance' : 'available',
      null,
    );
  }

  void _showMaintenanceOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const Border(
        top: BorderSide(color: AppColors.frameInk, width: 2.0),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS MANAGEMENT / KONTROL UNIT',
                  style: GoogleFonts.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola Status Operasional ${widget.unit.name}:',
                  style: GoogleFonts.tinos(
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: AppColors.tintOlive),
                  title: Text(
                    'Ubah Ke Tersedia (Ready / Online)',
                    style: GoogleFonts.tinos(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _setMaintenanceStatus(ref, false);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: AppColors.primary),
                  title: Text(
                    'Tetap Maintenance (Offline)',
                    style: GoogleFonts.tinos(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
