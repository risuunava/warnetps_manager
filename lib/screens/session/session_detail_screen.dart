import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../widgets/elapsed_time_text.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Timer? _refreshTimer;
  Map<String, dynamic>? _billingDetails;
  bool _isLoadingBilling = true;
  String? _billingError;

  @override
  void initState() {
    super.initState();
    _fetchBilling();
    // Refresh billing details every 10 seconds to update running cost
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchBilling();
    });
  }

  Future<void> _fetchBilling() async {
    final sessionService = ref.read(sessionServiceProvider);
    try {
      final details = await sessionService.calculateCosts(
        sessionId: widget.sessionId,
        endTime: DateTime.now(),
      );
      if (mounted) {
        setState(() {
          _billingDetails = details;
          _isLoadingBilling = false;
          _billingError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _billingError = e.toString();
          _isLoadingBilling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionsStream = ref.watch(activeSessionsStreamProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('DETAIL SESI AKTIF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: activeSessionsStream.when(
        data: (sessions) {
          // Find the active session matching the ID
          final session = sessions.firstWhere((s) => s.id == widget.sessionId, orElse: () => null as dynamic);
          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 48),
                  const SizedBox(height: 16),
                  const Text('Sesi ini telah diselesaikan.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Kembali ke Dashboard'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit & Player Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          session.unitName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00D4FF),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Nama Pelanggan', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            Text(
                              session.customerName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mulai Bermain', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            Text(
                              DateFormat('HH:mm  •  dd MMM yyyy').format(session.startTime),
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Durasi Sesi', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            ElapsedTimeText(
                              startTime: session.startTime,
                              style: const TextStyle(
                                color: Color(0xFFFF1744),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Billing summary (Running cost)
                  const Text(
                    'BIAYA BERJALAN SAAT INI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: _isLoadingBilling
                        ? const Center(child: CircularProgressIndicator())
                        : _billingError != null
                            ? Text('Error billing: $_billingError', style: const TextStyle(color: Colors.redAccent))
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tarif Unit (${_billingDetails!['durationMinutes']} Menit)',
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      Text(
                                        currencyFormatter.format(_billingDetails!['baseSubtotal']),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (session.memberId != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Diskon Member (${(_billingDetails!['discountPercentage'] * 100).toInt()}%)',
                                          style: const TextStyle(color: Color(0xFF00C853), fontSize: 13),
                                        ),
                                        Text(
                                          '- ${currencyFormatter.format(_billingDetails!['discount'])}',
                                          style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (_billingDetails!['extrasSubtotal'] > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Item Tambahan (Snack)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        Text(
                                          currencyFormatter.format(_billingDetails!['extrasSubtotal']),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Divider(color: Colors.white10),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Estimasi Total',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        currencyFormatter.format(_billingDetails!['total']),
                                        style: const TextStyle(
                                          color: Color(0xFF00C853),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                  ),
                  const SizedBox(height: 24),

                  // Extras / Snacks section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TAMBAHAN MAKANAN & MINUMAN',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddExtraSheet(context),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF0088FF)),
                        label: const Text('TAMBAH', style: TextStyle(color: Color(0xFF0088FF), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: session.extras.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Belum ada makanan/minuman ditambahkan.',
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: session.extras.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) {
                              final extra = session.extras[index];
                              return ListTile(
                                leading: const Icon(Icons.local_pizza_outlined, color: Color(0xFF00D4FF), size: 20),
                                title: Text(extra.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                trailing: Text(
                                  currencyFormatter.format(extra.price),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 48),

                  // Checkout Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/checkout/${session.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1744), // red stop accent
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'STOP SESI & KASIR',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error loading session: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  void _showAddExtraSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final presetExtras = [
      {'name': 'Teh Botol Sosro', 'price': 4000.0},
      {'name': 'Coca Cola / Fanta', 'price': 5000.0},
      {'name': 'Indomie Goreng + Telur', 'price': 8000.0},
      {'name': 'Kopi Hitam', 'price': 3000.0},
      {'name': 'Chitato / Snack Lays', 'price': 6000.0},
      {'name': 'Aqua Gelas', 'price': 1000.0},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TAMBAH MINUMAN / MAKANAN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Presets Title
                const Text('Menu Terlaris', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Preset Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetExtras.map((item) {
                    return ActionChip(
                      backgroundColor: const Color(0xFF0A0A0F),
                      side: const BorderSide(color: Colors.white10),
                      label: Text('${item['name']} (Rp ${(item['price'] as num).toInt()})'),
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                      onPressed: () {
                        _addExtraItem(item['name'] as String, item['price'] as double);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),

                // Custom Input Form
                const Text('Item Kustom', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nama Item',
                          labelStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Nama item wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga (Rp)',
                          labelStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Harga wajib diisi';
                          if (double.tryParse(value) == null) return 'Harga harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _addExtraItem(
                                nameController.text.trim(),
                                double.parse(priceController.text),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088FF)),
                          child: const Text('Tambah Item Kustom', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addExtraItem(String name, double price) async {
    final sessionService = ref.read(sessionServiceProvider);
    try {
      await sessionService.addExtraToSession(
        widget.sessionId,
        SessionExtra(name: name, price: price),
      );
      _fetchBilling(); // Update billing running cost
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan item: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
