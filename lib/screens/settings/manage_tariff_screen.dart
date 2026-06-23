import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/tariff_model.dart';
import '../../providers/services_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared/retro_scaffold.dart';

class ManageTariffScreen extends ConsumerWidget {
  const ManageTariffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tariffsAsync = ref.watch(tariffsStreamProvider);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return RetroScaffold(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Eyebrow
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
                'RENTAL TARIFFS / TARIFF & PAKET SEWA',
                style: GoogleFonts.arimo(
                  fontSize: 12,
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

            tariffsAsync.when(
              data: (tariffs) {
                if (tariffs.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.frameInk),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tarif belum diinisialisasi.',
                            style: GoogleFonts.tinos(color: AppColors.ink),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final service = ref.read(tariffServiceProvider);
                              await service.initializeDefaultTariffs();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.frameInk,
                                border: Border.all(color: AppColors.frameInk),
                              ),
                              child: Text(
                                'INISIALISASI TARIF DEFAULT',
                                style: GoogleFonts.arimo(
                                  color: AppColors.canvas,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tariffs.length,
                  itemBuilder: (context, index) {
                    final tariff = tariffs[index];
                    final isPC = tariff.unitType == 'pc';
                    final Color cardTint = isPC ? AppColors.tintSage : AppColors.tintPeach;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              border: Border.all(color: AppColors.frameInk),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPC ? Icons.computer : Icons.sports_esports,
                                  size: 14,
                                  color: AppColors.ink,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tariff.unitType == 'pc'
                                      ? 'KOMPUTER WORKSTATION (PC)'
                                      : 'KONSOL PLAYSTATION (PS)',
                                  style: GoogleFonts.arimo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Body
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardTint,
                              border: const Border(
                                left: BorderSide(color: AppColors.frameInk),
                                right: BorderSide(color: AppColors.frameInk),
                                bottom: BorderSide(color: AppColors.frameInk),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Harga Sewa: ${currencyFormatter.format(tariff.pricePerHour)} / jam',
                                      style: GoogleFonts.tinos(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sesi Minimum: ${tariff.minimumMinutes} Menit',
                                      style: GoogleFonts.tinos(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showEditTariffDialog(context, ref, tariff);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.frameInk,
                                      border: Border.all(color: AppColors.frameInk),
                                    ),
                                    child: Text(
                                      'UBAH TARIF',
                                      style: GoogleFonts.arimo(
                                        color: AppColors.canvas,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(
                child: Text(
                  'Gagal memuat tarif: $e',
                  style: GoogleFonts.tinos(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTariffDialog(BuildContext context, WidgetRef ref, TariffModel tariff) {
    final priceController = TextEditingController(text: tariff.pricePerHour.toInt().toString());
    final minMinutesController = TextEditingController(text: tariff.minimumMinutes.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.canvas,
          shape: const Border(
            top: BorderSide(color: AppColors.frameInk, width: 4.0),
            left: BorderSide(color: AppColors.frameInk, width: 2.0),
            right: BorderSide(color: AppColors.frameInk, width: 2.0),
            bottom: BorderSide(color: AppColors.frameInk, width: 2.0),
          ),
          title: Text(
            'UBAH KONFIGURASI TARIF ${tariff.unitType.toUpperCase()}',
            style: GoogleFonts.arimo(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarif per jam (Rupiah):',
                  style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: priceController,
                  style: GoogleFonts.tinos(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 5000',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Harga per jam wajib diisi';
                    if (double.tryParse(value) == null) return 'Harga harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Durasi Minimum Sesi (Menit):',
                  style: GoogleFonts.tinos(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: minMinutesController,
                  style: GoogleFonts.tinos(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 15',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Durasi minimum wajib diisi';
                    if (int.tryParse(value) == null) return 'Durasi harus berupa angka bulat';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'BATAL',
                  style: GoogleFonts.arimo(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  final service = ref.read(tariffServiceProvider);
                  final updatedTariff = TariffModel(
                    id: tariff.id,
                    unitType: tariff.unitType,
                    pricePerHour: double.parse(priceController.text),
                    minimumMinutes: int.parse(minMinutesController.text),
                  );

                  await service.updateTariff(updatedTariff);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tarif ${tariff.unitType.toUpperCase()} berhasil diperbarui',
                          style: GoogleFonts.tinos(),
                        ),
                        backgroundColor: AppColors.tintSage,
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.frameInk,
                  border: Border.all(color: AppColors.frameInk),
                ),
                child: Text(
                  'SIMPAN PERUBAHAN',
                  style: GoogleFonts.arimo(
                    color: AppColors.canvas,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
