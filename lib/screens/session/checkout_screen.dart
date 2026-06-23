import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';

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

    return RetroScaffold(
      showBackButton: true,
      onBackTap: () => context.pop(),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.frameInk),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tintSalmon, // Salmon warning/error fill
                      border: Border.all(color: AppColors.frameInk, width: 2.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BILLING ERROR / KESALAHAN BIAYA',
                          style: GoogleFonts.arimo(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.tinos(
                            fontSize: 13,
                            color: AppColors.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
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
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            border: Border.all(color: AppColors.frameInk, width: 2.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColors.tintOlive, size: 54),
                              const SizedBox(height: 16),
                              Text(
                                'TRANSACTION SUCCESSFUL / PEMBAYARAN SUKSES',
                                style: GoogleFonts.arimo(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: AppColors.ink,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sesi telah diselesaikan & pembayaran berhasil disimpan.',
                                style: GoogleFonts.tinos(
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => context.go('/'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.frameInk,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Text(
                                    'KEMBALI KE DASHBOARD',
                                    style: GoogleFonts.arimo(
                                      color: AppColors.canvas,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final currentSession = session;

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              children: [
                                // Receipt / Invoice Card
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    border: Border.all(color: AppColors.frameInk, width: 2.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header Band
                                      Container(
                                        width: double.infinity,
                                        color: AppColors.tintSteel,
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'WARNET & PS MANAGER',
                                              style: GoogleFonts.arimo(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.ink,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Jl. Raya Cyber No. 404, Jakarta',
                                              style: GoogleFonts.tinos(
                                                fontSize: 12,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'DIGITAL INVOICE / STRUK RESMI',
                                              style: GoogleFonts.arimo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.primary, // Dell Red
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            Text(
                                              'Sesi: ${currentSession.id.substring(0, 8).toUpperCase()}',
                                              style: GoogleFonts.tinos(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        height: 2,
                                        color: AppColors.frameInk,
                                      ),

                                      // Details section
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildReceiptRow('Unit Bermain / Station Name', currentSession.unitName),
                                            _buildSpecDivider(),
                                            _buildReceiptRow('Nama Pelanggan / Cust. Name', currentSession.customerName),
                                            _buildSpecDivider(),
                                            _buildReceiptRow('Waktu Mulai / Start Time', DateFormat('HH:mm').format(currentSession.startTime)),
                                            _buildSpecDivider(),
                                            _buildReceiptRow('Waktu Selesai / End Time', DateFormat('HH:mm').format(DateTime.now())),
                                            _buildSpecDivider(),
                                            _buildReceiptRow('Durasi Bermain / Play Duration', '${_billingDetails!['durationMinutes']} Menit'),
                                            
                                            const SizedBox(height: 16),
                                            Container(
                                              height: 1,
                                              color: AppColors.frameInk,
                                            ),
                                            const SizedBox(height: 16),

                                            _buildReceiptRow(
                                              'Tarif Unit (${currencyFormatter.format(_billingDetails!['hourlyRate'])}/jam)',
                                              currencyFormatter.format(_billingDetails!['baseSubtotal']),
                                            ),
                                            
                                            if (currentSession.memberId != null) ...[
                                              _buildSpecDivider(),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Diskon Member (${(_billingDetails!['discountPercentage'] * 100).toInt()}%)',
                                                      style: GoogleFonts.tinos(
                                                        color: AppColors.tintOlive,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      '- ${currencyFormatter.format(_billingDetails!['discount'])}',
                                                      style: GoogleFonts.tinos(
                                                        color: AppColors.tintOlive,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],

                                            if (currentSession.extras.isNotEmpty) ...[
                                              _buildSpecDivider(),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Makanan & Minuman / Extras:',
                                                style: GoogleFonts.tinos(
                                                  color: AppColors.ink,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ...currentSession.extras.map(
                                                (extra) => Padding(
                                                  padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        extra.name,
                                                        style: GoogleFonts.tinos(
                                                          fontSize: 12,
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.grey[700],
                                                        ),
                                                      ),
                                                      Text(
                                                        currencyFormatter.format(extra.price),
                                                        style: GoogleFonts.tinos(
                                                          fontSize: 12,
                                                          color: AppColors.ink,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 16),
                                            Container(
                                              height: 1.5,
                                              color: AppColors.frameInk,
                                            ),
                                            const SizedBox(height: 16),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'TOTAL BAYAR / TOTAL DUE',
                                                  style: GoogleFonts.arimo(
                                                    color: AppColors.ink,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  currencyFormatter.format(_billingDetails!['total']),
                                                  style: GoogleFonts.arimo(
                                                    color: AppColors.primary, // Dell Red
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
                                                  border: Border.all(color: AppColors.tintOlive, width: 2.0),
                                                ),
                                                child: Text(
                                                  'LUNAS / CASH ONLY',
                                                  style: GoogleFonts.arimo(
                                                    color: AppColors.tintOlive,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
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
                                const SizedBox(height: 24),

                                // Confirm Button
                                GestureDetector(
                                  onTap: _isSaving ? null : () => _confirmPayment(currentSession),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.frameInk,
                                      border: Border.all(color: AppColors.frameInk),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                color: AppColors.canvas,
                                                strokeWidth: 2.0,
                                              ),
                                            )
                                          : Text(
                                              'KONFIRMASI BAYAR & SELESAI',
                                              style: GoogleFonts.arimo(
                                                color: AppColors.canvas,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.frameInk),
                  ),
                  error: (e, __) => Center(
                    child: Text(
                      'Error: $e',
                      style: GoogleFonts.tinos(color: AppColors.primary),
                    ),
                  ),
                ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
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
            value,
            style: GoogleFonts.tinos(
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecDivider() {
    return Container(
      height: 1,
      color: Colors.grey[300],
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
          SnackBar(
            content: Text(
              'Pembayaran berhasil dicatat. Sesi selesai.',
              style: GoogleFonts.tinos(),
            ),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyelesaikan pembayaran: $e',
              style: GoogleFonts.tinos(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }
}
