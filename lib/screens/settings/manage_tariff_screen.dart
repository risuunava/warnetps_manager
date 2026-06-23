import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/tariff_model.dart';
import '../../providers/services_provider.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: const Text('KELOLA TARIF SESI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: tariffsAsync.when(
        data: (tariffs) {
          if (tariffs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tarif belum diinisialisasi.', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final service = ref.read(tariffServiceProvider);
                      await service.initializeDefaultTariffs();
                    },
                    child: const Text('Inisialisasi Tarif Default'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tariffs.length,
            itemBuilder: (context, index) {
              final tariff = tariffs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0088FF).withOpacity(0.1),
                    child: Icon(
                      tariff.unitType == 'pc' ? Icons.computer : Icons.sports_esports,
                      color: const Color(0xFF0088FF),
                    ),
                  ),
                  title: Text(
                    tariff.unitType.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Harga: ${currencyFormatter.format(tariff.pricePerHour)}/jam\nMin Sesi: ${tariff.minimumMinutes} Menit',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF00D4FF)),
                    onPressed: () {
                      _showEditTariffDialog(context, ref, tariff);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Gagal memuat tarif: $e', style: const TextStyle(color: Colors.redAccent))),
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
          backgroundColor: const Color(0xFF12121A),
          title: Text('Edit Tarif ${tariff.unitType.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per jam (Rp)',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Harga per jam wajib diisi';
                    if (double.tryParse(value) == null) return 'Harga harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minMinutesController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi Minimum Sesi (Menit)',
                    labelStyle: TextStyle(color: Colors.white54),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
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
                      SnackBar(content: Text('Tarif ${tariff.unitType.toUpperCase()} berhasil diperbarui')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0088FF)),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
