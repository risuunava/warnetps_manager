import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/unit_model.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/elapsed_time_text.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcUnitsAsync = ref.watch(pcUnitsStreamProvider);
    final psUnitsAsync = ref.watch(psUnitsStreamProvider);
    final activeSessionsAsync = ref.watch(activeSessionsStreamProvider);
    final todaySessionsAsync = ref.watch(todayCompletedSessionsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pcUnitsStreamProvider);
            ref.invalidate(psUnitsStreamProvider);
            ref.invalidate(activeSessionsStreamProvider);
            ref.invalidate(todayCompletedSessionsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Profile Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userProfileAsync.when(
                            data: (profile) => Text(
                              'Halo, ${profile?.name ?? "Operator"}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            loading: () => const Text('Halo...', style: TextStyle(fontSize: 20, color: Colors.white)),
                            error: (_, __) => const Text('Halo!', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                          const Text(
                            'Selamat bekerja. Pantau unit secara real-time.',
                            style: TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                      // Role Badge
                      userProfileAsync.when(
                        data: (profile) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: profile?.role == 'owner'
                                ? const Color(0xFF0088FF).withOpacity(0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: profile?.role == 'owner'
                                  ? const Color(0xFF0088FF)
                                  : Colors.white30,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (profile?.role ?? 'operator').toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: profile?.role == 'owner'
                                  ? const Color(0xFF00D4FF)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Statistics Widgets
                  Row(
                    children: [
                      // Active Units Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.play_circle_outline, color: Color(0xFF00D4FF), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Unit Aktif',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              activeSessionsAsync.when(
                                data: (sessions) => Text(
                                  '${sessions.length} / 10',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const Text('Error', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Today's Income Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00C853), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pendapatan Hari Ini',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              todaySessionsAsync.when(
                                data: (sessions) {
                                  final total = sessions.fold<double>(0, (sum, s) => sum + (s.total));
                                  return Text(
                                    currencyFormatter.format(total),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const Text('Error', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // PC GRID SECTION
                  _buildSectionHeader(context, '💻 KOMPUTER (PC)'),
                  const SizedBox(height: 10),
                  pcUnitsAsync.when(
                    data: (units) => _buildGrid(context, units, activeSessionsAsync.value ?? []),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),
                    error: (e, __) => Text('Error loading PCs: $e', style: const TextStyle(color: Colors.redAccent)),
                  ),

                  const SizedBox(height: 28),

                  // PS GRID SECTION
                  _buildSectionHeader(context, '🎮 PLAYSTATION (PS)'),
                  const SizedBox(height: 10),
                  psUnitsAsync.when(
                    data: (units) => _buildGrid(context, units, activeSessionsAsync.value ?? []),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),
                    error: (e, __) => Text('Error loading PS: $e', style: const TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<UnitModel> units, List<SessionModel> activeSessions) {
    if (units.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Tidak ada unit terdaftar.', style: TextStyle(color: Colors.white38)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        // Find matching active session if status is in_use
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

        return _UnitCard(unit: unit, activeSession: activeSession);
      },
    );
  }
}

class _UnitCard extends ConsumerWidget {
  final UnitModel unit;
  final SessionModel? activeSession;

  const _UnitCard({
    required this.unit,
    this.activeSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = unit.status;
    final isAvailable = status == 'available';
    final isInUse = status == 'in_use';
    final isMaintenance = status == 'maintenance';

    final Color statusColor;
    if (isAvailable) {
      statusColor = const Color(0xFF00C853); // Green
    } else if (isInUse) {
      statusColor = const Color(0xFFFF1744); // Red
    } else {
      statusColor = const Color(0xFF616161); // Grey
    }

    // Role check to allow maintenance status changing on the fly
    final userProfile = ref.watch(userProfileProvider).value;

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          // Go to start session screen
          context.push('/start-session/${unit.id}');
        } else if (isInUse && activeSession != null) {
          // Go to session detail screen
          context.push('/session-detail/${activeSession!.id}');
        } else if (isMaintenance) {
          if (userProfile?.role == 'owner') {
            _showMaintenanceOptions(context, ref);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hanya Owner yang dapat mengubah status Maintenance')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Unit Name & Type Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    unit.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  unit.type == 'pc' ? Icons.computer : Icons.sports_esports,
                  color: statusColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 2),
            // PS Type indicator if any (PS4/PS3/PS2)
            if (unit.psType != null)
              Text(
                unit.psType!.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

            const Spacer(),

            // Dynamic Content middle section
            if (isInUse && activeSession != null) ...[
              Text(
                activeSession!.customerName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              ElapsedTimeText(
                startTime: activeSession!.startTime,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (isMaintenance) ...[
              const Text(
                'Perbaikan / Rusak',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 14),
            ] else ...[
              const Text(
                'Ready to play',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 14),
            ],

            const Spacer(),

            // Bottom Row: Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAvailable
                        ? 'TERSEDIA'
                        : isInUse
                            ? 'DIPAKAI'
                            : 'MAINTENANCE',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (isAvailable && userProfile?.role == 'owner')
                  GestureDetector(
                    onTap: () {
                      _setMaintenanceStatus(ref, true);
                    },
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setMaintenanceStatus(WidgetRef ref, bool maintenance) async {
    final unitService = ref.read(unitServiceProvider);
    await unitService.updateUnitStatus(
      unit.id,
      maintenance ? 'maintenance' : 'available',
      null,
    );
  }

  void _showMaintenanceOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kelola Status ${unit.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Color(0xFF00C853)),
                  title: const Text('Ubah Ke Tersedia (Ready)', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    _setMaintenanceStatus(ref, false);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Colors.white54),
                  title: const Text('Tetap Maintenance', style: TextStyle(color: Colors.white70)),
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
