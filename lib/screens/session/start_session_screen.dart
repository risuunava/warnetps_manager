import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/member_model.dart';
import '../../models/unit_model.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final unitsStream = ref.watch(unitsStreamProvider);
    final membersStream = ref.watch(membersStreamProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('MULAI SESI BARU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: unitsStream.when(
        data: (units) {
          // Find unit
          final unit = units.firstWhere((u) => u.id == widget.unitId, orElse: () => null as dynamic);
          if (unit == null) {
            return const Center(child: Text('Unit tidak ditemukan', style: TextStyle(color: Colors.redAccent)));
          }

          // Fetch tariff
          return ref.watch(tariffsStreamProvider).when(
            data: (tariffs) {
              final tariff = tariffs.firstWhere((t) => t.id == unit.tariffId, orElse: () => null as dynamic);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Unit Summary card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF0088FF).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF0088FF).withOpacity(0.15),
                                child: Icon(
                                  unit.type == 'pc' ? Icons.computer : Icons.sports_esports,
                                  color: const Color(0xFF0088FF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      unit.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    if (tariff != null)
                                      Text(
                                        'Tarif: ${currencyFormatter.format(tariff.pricePerHour)}/jam  • Min: ${tariff.minimumMinutes}m',
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      )
                                    else
                                      const Text('Tarif: Loading...', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form Section title
                        const Text(
                          'INFORMASI PELANGGAN',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 12),

                        // Member Selection Box (Inline Toggle or selector)
                        if (_selectedMember != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00C853).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: Color(0xFF00C853)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedMember!.name,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Member ${_selectedMember!.level.toUpperCase()} • Diskon ${(_selectedMember!.discountPercentage * 100).toInt()}%',
                                        style: const TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white54),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMember = null;
                                      _customerNameController.clear();
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // Dropdown / searchable member option trigger
                          GestureDetector(
                            onTap: () {
                              _showMemberSelectionSheet(context, membersStream);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12121A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.person_search_outlined, color: Color(0xFF0088FF)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Pilih dari Daftar Member (Opsional)',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.white30),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Manual Customer Name Field
                          TextFormField(
                            controller: _customerNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nama Pelanggan / Nomor PC',
                              labelStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF12121A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF0088FF)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama pelanggan wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 48),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _startSession(unit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0088FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'MULAI BERMAIN',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Gagal memuat tarif: $e', style: const TextStyle(color: Colors.redAccent))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Gagal memuat data unit: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  void _showMemberSelectionSheet(BuildContext context, AsyncValue<List<MemberModel>> membersStream) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  const Text(
                    'PILIH MEMBER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchMemberController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari nama/nomor HP...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0088FF)),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        _searchMemberQuery = val.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: membersStream.when(
                      data: (members) {
                        final filtered = members.where((m) {
                          return m.name.toLowerCase().contains(_searchMemberQuery) ||
                              m.phone.contains(_searchMemberQuery);
                        }).toList();

                        if (filtered.isEmpty) {
                          return const Center(child: Text('Tidak ada member.', style: TextStyle(color: Colors.white38)));
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final member = filtered[index];
                            return ListTile(
                              title: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(member.phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              trailing: Text(
                                member.level.toUpperCase(),
                                style: TextStyle(
                                  color: member.level == 'gold'
                                      ? const Color(0xFFFFD700)
                                      : member.level == 'silver'
                                          ? const Color(0xFFC0C0C0)
                                          : const Color(0xFF0088FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
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
                      error: (e, __) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
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
        context.pop(); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai sesi: $e')),
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
    super.dispose();
  }
}
