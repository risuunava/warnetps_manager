import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/member_model.dart';
import '../../models/unit_model.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';
import '../../widgets/shared/retro_bevel_container.dart';

class StartSessionScreen extends ConsumerStatefulWidget {
  final String unitId;

  const StartSessionScreen({super.key, required this.unitId});

  @override
  ConsumerState<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends ConsumerState<StartSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  MemberModel? _selectedMember;
  bool _isLoading = false;
  String _searchMemberQuery = '';
  final _searchMemberController = TextEditingController();
  int? _selectedDurationMinutes; // null = custom
  final _customDurationController = TextEditingController();

  static const _quickDurations = [60, 120, 180]; // 1j, 2j, 3j

  int get _effectiveDuration {
    if (_selectedDurationMinutes != null) return _selectedDurationMinutes!;
    return int.tryParse(_customDurationController.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final unitsStream = ref.watch(unitsStreamProvider);
    final membersStream = ref.watch(membersStreamProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RetroScaffold(
      showBackButton: true,
      child: unitsStream.when(
        data: (units) {
          final unit = units.firstWhere(
            (u) => u.id == widget.unitId,
            orElse: () => null as dynamic,
          );
          if (unit == null) {
            return Center(
              child: Text(
                'Unit tidak ditemukan',
                style: GoogleFonts.tinos(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ref.watch(tariffsStreamProvider).when(
            data: (tariffs) {
              final tariff = tariffs.firstWhere(
                (t) => t.id == unit.tariffId,
                orElse: () => null as dynamic,
              );

              final estimatedCost = _effectiveDuration > 0 && tariff != null
                  ? ((_effectiveDuration / 60) * tariff.pricePerHour)
                  : 0.0;

              return Column(
                children: [
                  // Main Body Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 672),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Unit Header Eyebrow
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
                                    'SELECTED WORKSTATION / UNIT TERPILIH',
                                    style: GoogleFonts.arimo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),

                                // Unit Info Block
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.tintSteel,
                                          border: Border.all(color: AppColors.frameInk),
                                        ),
                                        child: Icon(
                                          unit.type == 'pc' ? Icons.desktop_windows : Icons.sports_esports,
                                          color: AppColors.ink,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              unit.name.toUpperCase(),
                                              style: GoogleFonts.arimo(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (tariff != null)
                                              Text(
                                                'Tarif Sewa: ${currencyFormatter.format(tariff.pricePerHour)}/jam  •  Minimal Sesi: ${tariff.minimumMinutes} Menit',
                                                style: GoogleFonts.tinos(
                                                  fontSize: 12,
                                                  color: AppColors.ink,
                                                ),
                                              )
                                            else
                                              Text(
                                                'Memuat tarif sewa...',
                                                style: GoogleFonts.tinos(
                                                  fontSize: 12,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Customer Info Header
                                Text(
                                  'CUSTOMER CONFIGURATION / INFORMASI PELANGGAN',
                                  style: GoogleFonts.arimo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (_selectedMember != null)
                                  _buildSelectedMemberCard(context)
                                else ...[
                                  // Member selector trigger
                                  GestureDetector(
                                    onTap: () => _showMemberSelectionSheet(context, membersStream),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvas,
                                        border: Border.all(color: AppColors.frameInk),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person, color: AppColors.ink, size: 18),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'PILIH MEMBER DARI DATABASE (OPSIONAL)',
                                              style: GoogleFonts.arimo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down, color: AppColors.ink),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Manual name input label
                                  Text(
                                    'Atau Masukkan Nama Manual / Walk-in:',
                                    style: GoogleFonts.tinos(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Manual name input
                                  TextFormField(
                                    controller: _customerNameController,
                                    style: GoogleFonts.tinos(),
                                    decoration: const InputDecoration(
                                      hintText: 'Masukkan nama pelanggan walk-in...',
                                    ),
                                    validator: (value) {
                                      if (_selectedMember == null && (value == null || value.trim().isEmpty)) {
                                        return 'Nama pelanggan wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 20),

                                // Duration Header
                                Text(
                                  'SESSION DURATION / DURASI BERMAIN',
                                  style: GoogleFonts.arimo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Quick select buttons
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 400;
                                    return GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: isWide ? 4 : 2,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: isWide ? 2.5 : 2,
                                      children: [
                                        ..._quickDurations.map((d) => _buildDurationButton(context, d, '${d ~/ 60} JAM')),
                                        _buildCustomDurationButton(context),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Custom duration text input
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule, color: AppColors.ink, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _customDurationController,
                                          keyboardType: TextInputType.number,
                                          style: GoogleFonts.tinos(),
                                          onChanged: (_) {
                                            setState(() {
                                              _selectedDurationMinutes = null;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Masukkan durasi manual...',
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'MENIT',
                                        style: GoogleFonts.arimo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sticky Action Bar at Bottom
                  _buildActionBar(context, currencyFormatter, estimatedCost, unit),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(
              child: Text(
                'Gagal memuat tarif: $e',
                style: GoogleFonts.tinos(color: AppColors.primary),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(
          child: Text(
            'Gagal memuat data unit: $e',
            style: GoogleFonts.tinos(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMemberCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tintPeach,
        border: Border.all(color: AppColors.frameInk),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMember!.name.toUpperCase(),
                  style: GoogleFonts.arimo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TINGKAT ${_selectedMember!.level.toUpperCase()} • DISKON AUTOMATIS ${(_selectedMember!.discountPercentage * 100).toInt()}%',
                  style: GoogleFonts.tinos(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMember = null;
                _customerNameController.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.frameInk),
              ),
              child: const Icon(Icons.close, color: AppColors.ink, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationButton(BuildContext context, int minutes, String label) {
    final isSelected = _selectedDurationMinutes == minutes;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDurationMinutes = minutes;
          _customDurationController.clear();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.frameInk : AppColors.canvas,
          border: Border.all(
            color: AppColors.frameInk,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.arimo(
            color: isSelected ? AppColors.canvas : AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDurationButton(BuildContext context) {
    final isSelected = _selectedDurationMinutes == null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDurationMinutes = null;
          _customDurationController.clear();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.frameInk : AppColors.canvas,
          border: Border.all(
            color: AppColors.frameInk,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'WALK-IN / PERS',
          style: GoogleFonts.arimo(
            color: isSelected ? AppColors.canvas : AppColors.ink,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(
    BuildContext context,
    NumberFormat currencyFormatter,
    double estimatedCost,
    UnitModel unit,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(top: BorderSide(color: AppColors.frameInk, width: 2.0)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ESTIMATED COST / ESTIMASI BIAYA:',
                    style: GoogleFonts.arimo(
                      color: AppColors.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    estimatedCost > 0 ? currencyFormatter.format(estimatedCost) : 'Rp 0',
                    style: GoogleFonts.tinos(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Start button - primary flat button
              GestureDetector(
                onTap: _isLoading ? null : () => _startSession(unit),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.frameInk,
                    border: Border.all(color: AppColors.frameInk),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: AppColors.canvas, strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow, color: AppColors.canvas, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'MULAI BERMAIN / START SESSION',
                        style: GoogleFonts.arimo(
                          color: AppColors.canvas,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberSelectionSheet(BuildContext context, AsyncValue<List<MemberModel>> membersStream) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const Border(
        top: BorderSide(color: AppColors.frameInk, width: 2.0),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'SELECT MEMBER / DATA PELANGGAN',
                    style: GoogleFonts.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchMemberController,
                    style: GoogleFonts.tinos(),
                    decoration: const InputDecoration(
                      hintText: 'Cari berdasarkan nama atau no HP...',
                      prefixIcon: Icon(Icons.search, color: AppColors.ink),
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        _searchMemberQuery = val.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: membersStream.when(
                      data: (members) {
                        final filtered = members.where((m) {
                          return m.name.toLowerCase().contains(_searchMemberQuery) ||
                              m.phone.contains(_searchMemberQuery);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada member.',
                              style: GoogleFonts.tinos(color: Colors.grey[600]),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const Divider(color: AppColors.frameInk, height: 1),
                          itemBuilder: (context, index) {
                            final member = filtered[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                member.name,
                                style: GoogleFonts.tinos(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                              ),
                              subtitle: Text(
                                member.phone,
                                style: GoogleFonts.tinos(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: member.level == 'gold'
                                      ? AppColors.yellowSticker
                                      : (member.level == 'silver'
                                          ? const Color(0xFFDCDCDC)
                                          : AppColors.canvas),
                                  border: Border.all(color: AppColors.frameInk),
                                ),
                                child: Text(
                                  member.level.toUpperCase(),
                                  style: GoogleFonts.arimo(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedMember = member;
                                  _customerNameController.text = member.name;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, __) => Center(
                        child: Text(
                          'Error: $e',
                          style: GoogleFonts.tinos(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startSession(UnitModel unit) async {
    if (_selectedMember == null && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final operatorProfile = ref.read(userProfileProvider).value;
    final sessionService = ref.read(sessionServiceProvider);

    try {
      await sessionService.startSession(
        unitId: widget.unitId,
        unitName: unit.name,
        customerName: _selectedMember != null ? _selectedMember!.name : _customerNameController.text.trim(),
        memberId: _selectedMember?.id,
        operatorId: operatorProfile?.id ?? 'default_operator',
        tariffId: unit.tariffId,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memulai sesi: $e',
              style: GoogleFonts.tinos(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _searchMemberController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }
}
