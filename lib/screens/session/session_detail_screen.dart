import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_model.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/elapsed_time_text.dart';
import '../../widgets/shared/retro_scaffold.dart';
import '../../widgets/shared/retro_bevel_container.dart';

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

    return RetroScaffold(
      showBackButton: true,
      onBackTap: () => context.go('/'),
      child: activeSessionsStream.when(
        data: (sessions) {
          // Find the active session matching the ID
          final session = sessions.firstWhere(
            (s) => s.id == widget.sessionId,
            orElse: () => null as dynamic,
          );
          
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
                    const Icon(Icons.check_circle_outline, color: AppColors.tintOlive, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'SESSION COMPLETED / SESI SELESAI',
                      style: GoogleFonts.arimo(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sesi ini telah diselesaikan atau tidak aktif.',
                      style: GoogleFonts.tinos(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
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

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unit & Player Card Title
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.tintPeach, // Peach ribbon background
                          border: Border(
                            top: BorderSide(color: AppColors.frameInk),
                            left: BorderSide(color: AppColors.frameInk),
                            right: BorderSide(color: AppColors.frameInk),
                          ),
                        ),
                        child: Text(
                          'SYSTEM SPECIFICATION / DETAIL UNIT',
                          style: GoogleFonts.arimo(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      
                      // Unit Details Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: Column(
                          children: [
                            // Unit Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  session.unitName.toUpperCase(),
                                  style: GoogleFonts.arimo(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                  ),
                                ),
                                // Badge Client Type
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.tintSteel,
                                    border: Border.all(color: AppColors.frameInk),
                                  ),
                                  child: Text(
                                    'ACTIVE SESSION',
                                    style: GoogleFonts.arimo(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(height: 1, color: AppColors.frameInk),
                            const SizedBox(height: 12),
                            
                            // Spec rows
                            _buildSpecRow('Nama Pelanggan / Cust. Name', session.customerName),
                            _buildSpecDivider(),
                            _buildSpecRow('Mulai Bermain / Start Time', DateFormat('HH:mm  •  dd MMM yyyy').format(session.startTime)),
                            _buildSpecDivider(),
                            _buildSpecWidgetRow('Durasi Sesi / Active Duration', ElapsedTimeText(
                              startTime: session.startTime,
                              style: GoogleFonts.tinos(
                                color: AppColors.primary, // Dell Red
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Billing Summary
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.tintSky, // Sky tint background
                          border: Border(
                            top: BorderSide(color: AppColors.frameInk),
                            left: BorderSide(color: AppColors.frameInk),
                            right: BorderSide(color: AppColors.frameInk),
                          ),
                        ),
                        child: Text(
                          'PRICING & BILLING / ESTIMASI BIAYA BERJALAN',
                          style: GoogleFonts.arimo(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      
                      // Billing Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: _isLoadingBilling
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(color: AppColors.frameInk),
                                ),
                              )
                            : _billingError != null
                                ? Text('Error billing: $_billingError', style: GoogleFonts.tinos(color: AppColors.primary))
                                : Column(
                                    children: [
                                      _buildSpecRow(
                                        'Tarif Unit / Base Rate (${_billingDetails!['durationMinutes']} Menit)',
                                        currencyFormatter.format(_billingDetails!['baseSubtotal']),
                                      ),
                                      if (session.memberId != null) ...[
                                        _buildSpecDivider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Diskon Member (${(_billingDetails!['discountPercentage'] * 100).toInt()}%)',
                                                style: GoogleFonts.tinos(
                                                  color: AppColors.tintOlive,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '- ${currencyFormatter.format(_billingDetails!['discount'])}',
                                                style: GoogleFonts.tinos(
                                                  color: AppColors.tintOlive,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (_billingDetails!['extrasSubtotal'] > 0) ...[
                                        _buildSpecDivider(),
                                        _buildSpecRow(
                                          'Item Tambahan (Makanan & Minuman)',
                                          currencyFormatter.format(_billingDetails!['extrasSubtotal']),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Container(height: 1.5, color: AppColors.frameInk),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Estimasi Total Biaya / Total Cost:',
                                            style: GoogleFonts.tinos(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            currencyFormatter.format(_billingDetails!['total']),
                                            style: GoogleFonts.arimo(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                      const SizedBox(height: 24),

                      // Extras / Snacks Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TAMBAHAN MAKANAN & MINUMAN',
                            style: GoogleFonts.arimo(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAddExtraSheet(context),
                            child: RetroBevelContainer(
                              color: AppColors.yellowSticker,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Text(
                                '+ TAMBAH',
                                style: GoogleFonts.arimo(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Extras List/Table
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: session.extras.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'Belum ada makanan/minuman ditambahkan.',
                                    style: GoogleFonts.tinos(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            : Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(1),
                                },
                                border: TableBorder.symmetric(
                                  inside: BorderSide(color: Colors.grey[300]!, width: 1.0),
                                ),
                                children: [
                                  // Header Row
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: AppColors.tintSteel,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'NAMA ITEM / MENU',
                                          style: GoogleFonts.arimo(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'HARGA',
                                          style: GoogleFonts.arimo(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Data Rows
                                  ...session.extras.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final extra = entry.value;
                                    final rowColor = idx % 2 == 0 ? AppColors.canvas : const Color(0xFFF9F9F9);
                                    return TableRow(
                                      decoration: BoxDecoration(
                                        color: rowColor,
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                          child: Text(
                                            extra.name,
                                            style: GoogleFonts.tinos(fontSize: 13),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                          child: Text(
                                            currencyFormatter.format(extra.price),
                                            style: GoogleFonts.tinos(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                      ),
                      const SizedBox(height: 36),

                      // Checkout Action Button
                      GestureDetector(
                        onTap: () {
                          context.push('/checkout/${session.id}');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.frameInk,
                            border: Border.all(color: AppColors.frameInk, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              'STOP SESI & KASIR',
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.frameInk)),
        error: (e, __) => Center(
          child: Text(
            'Error loading session: $e',
            style: GoogleFonts.tinos(color: AppColors.primary, fontSize: 14),
          ),
        ),
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
      backgroundColor: AppColors.canvas,
      shape: const Border(
        top: BorderSide(color: AppColors.frameInk, width: 2.0),
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
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'TAMBAH MINUMAN / MAKANAN',
                  style: GoogleFonts.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),

                // Presets Title
                Text(
                  'Menu Terlaris / Best Sellers:',
                  style: GoogleFonts.tinos(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Preset Chips using ActionChip with flat border
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presetExtras.map((item) {
                    return ActionChip(
                      backgroundColor: AppColors.canvas,
                      side: const BorderSide(color: AppColors.frameInk),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      label: Text(
                        '${item['name']} (Rp ${(item['price'] as num).toInt()})',
                        style: GoogleFonts.tinos(
                          color: AppColors.ink,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        _addExtraItem(item['name'] as String, item['price'] as double);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                Container(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 16),

                // Custom Input Form
                Text(
                  'Item Kustom / Custom Item:',
                  style: GoogleFonts.tinos(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: GoogleFonts.tinos(color: AppColors.ink),
                        decoration: const InputDecoration(
                          labelText: 'Nama Item / Item Name',
                          hintText: 'e.g. Indomie Rebus',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Nama item wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        style: GoogleFonts.tinos(color: AppColors.ink),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rp) / Price',
                          hintText: 'e.g. 5000',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Harga wajib diisi';
                          if (double.tryParse(value) == null) return 'Harga harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            _addExtraItem(
                              nameController.text.trim(),
                              double.parse(priceController.text),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.frameInk,
                            border: Border.all(color: AppColors.frameInk),
                          ),
                          child: Center(
                            child: Text(
                              'TAMBAH ITEM KUSTOM',
                              style: GoogleFonts.arimo(
                                color: AppColors.canvas,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
          SnackBar(
            content: Text(
              'Gagal menambahkan item: $e',
              style: GoogleFonts.tinos(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tinos(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.tinos(
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecWidgetRow(String label, Widget widgetValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tinos(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          widgetValue,
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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
