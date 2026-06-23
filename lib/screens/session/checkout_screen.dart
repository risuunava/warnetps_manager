import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CheckoutScreen({super.key, required this.sessionId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Map<String, dynamic>? _billingDetails;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateFinalBilling();
  }

  Future<void> _calculateFinalBilling() async {
    final sessionService = ref.read(sessionServiceProvider);
    try {
      final details = await sessionService.calculateCosts(
        sessionId: widget.sessionId,
        endTime: DateTime.now(),
      );
      if (mounted) {
        setState(() {
          _billingDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
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
        title: const Text('KASIR & PEMBAYARAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.redAccent)))
              : activeSessionsStream.when(
                  data: (sessions) {
                    SessionModel? session;
                    for (final s in sessions) {
                      if (s.id == widget.sessionId) {
                        session = s;
                        break;
                      }
                    }

                    if (session == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outlined, color: Color(0xFF00C853), size: 54),
                            const SizedBox(height: 16),
                            const Text('Pembayaran Sukses & Selesai', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088FF)),
                              child: const Text('Kembali ke Dashboard'),
                            ),
                          ],
                        ),
                      );
                    }

                    final currentSession = session;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Receipt Card
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF12121A),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.sports_esports_outlined, color: Color(0xFF0088FF), size: 36),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'WARNET & PS MANAGER',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                                        ),
                                        const Text(
                                          'Jl. Raya Cyber No. 404, Jakarta',
                                          style: TextStyle(fontSize: 10, color: Colors.white38),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'STRUK DIGITAL RESMI',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF), letterSpacing: 1.0),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Sesi: ${currentSession.id.substring(0, 8).toUpperCase()}',
                                          style: const TextStyle(fontSize: 10, color: Colors.white38),
                                        ),
                                      ],
                                    ),
                                  ),

                                  _buildDashedLine(),

                                  // Details
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildReceiptRow('Unit Bermain', currentSession.unitName),
                                        _buildReceiptRow('Pelanggan', currentSession.customerName),
                                        _buildReceiptRow('Waktu Mulai', DateFormat('HH:mm').format(currentSession.startTime)),
                                        _buildReceiptRow('Waktu Selesai', DateFormat('HH:mm').format(DateTime.now())),
                                        _buildReceiptRow('Durasi Total', '${_billingDetails!['durationMinutes']} Menit'),
                                        const SizedBox(height: 12),
                                        const Divider(color: Colors.white24),
                                        const SizedBox(height: 12),

                                        _buildReceiptRow(
                                          'Tarif Unit (${currencyFormatter.format(_billingDetails!['hourlyRate'])}/j)',
                                          currencyFormatter.format(_billingDetails!['baseSubtotal']),
                                        ),
                                        if (currentSession.memberId != null)
                                          _buildReceiptRow(
                                            'Diskon Member (${(_billingDetails!['discountPercentage'] * 100).toInt()}%)',
                                            '- ${currencyFormatter.format(_billingDetails!['discount'])}',
                                            isDiscount: true,
                                          ),

                                        if (currentSession.extras.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Makanan & Minuman:',
                                            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          ...currentSession.extras.map((extra) => Padding(
                                                padding: const EdgeInsets.only(left: 10.0, top: 4.0),
                                                child: _buildReceiptRow(extra.name, currencyFormatter.format(extra.price), isExtra: true),
                                              )),
                                        ],

                                        const SizedBox(height: 16),
                                        const Divider(color: Colors.white24),
                                        const SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'TOTAL BAYAR',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                            ),
                                            Text(
                                              currencyFormatter.format(_billingDetails!['total']),
                                              style: const TextStyle(
                                                color: Color(0xFF00C853),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 24),
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFF00C853), width: 2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'LUNAS / CASH',
                                              style: TextStyle(
                                                color: Color(0xFF00C853),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Confirm Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _confirmPayment(currentSession),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSaving
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'KONFIRMASI BAYAR & SELESAI',
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
                  error: (e, __) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
                ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isDiscount = false, bool isExtra = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isExtra ? Colors.white38 : Colors.white54,
              fontSize: isExtra ? 11 : 12,
              fontStyle: isExtra ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? const Color(0xFF00C853) : isExtra ? Colors.white70 : Colors.white70,
              fontWeight: isDiscount || !isExtra ? FontWeight.bold : FontWeight.normal,
              fontSize: isExtra ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white24),
              ),
            );
          }),
        );
      },
    );
  }

  void _confirmPayment(SessionModel session) async {
    setState(() {
      _isSaving = true;
    });

    final sessionService = ref.read(sessionServiceProvider);

    try {
      await sessionService.checkoutSession(
        sessionId: session.id,
        subtotal: (_billingDetails!['subtotal'] as num).toDouble(),
        discount: (_billingDetails!['discount'] as num).toDouble(),
        total: (_billingDetails!['total'] as num).toDouble(),
        durationMinutes: _billingDetails!['durationMinutes'] as int,
        extras: session.extras,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dicatat. Sesi selesai.')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan pembayaran: $e')),
        );
      }
    }
  }
}
