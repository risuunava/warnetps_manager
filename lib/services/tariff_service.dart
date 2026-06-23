import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tariff_model.dart';

class TariffService {
  final _db = FirebaseFirestore.instance;

  // Stream all tariffs
  Stream<List<TariffModel>> streamTariffs() {
    return _db.collection('tariffs').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TariffModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get tariff by ID
  Future<TariffModel?> getTariff(String tariffId) async {
    try {
      final doc = await _db.collection('tariffs').doc(tariffId).get();
      if (doc.exists && doc.data() != null) {
        return TariffModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error getting tariff: $e');
    }
    return null;
  }

  // Update tariff
  Future<void> updateTariff(TariffModel tariff) async {
    await _db.collection('tariffs').doc(tariff.id).set(tariff.toMap(), SetOptions(merge: true));
  }

  // Initialize default tariffs (helper in case db is empty)
  Future<void> initializeDefaultTariffs() async {
    final defaultTariffs = [
      TariffModel(id: 'tariff_pc', unitType: 'pc', pricePerHour: 5000.0, minimumMinutes: 15),
      TariffModel(id: 'tariff_ps4', unitType: 'ps4', pricePerHour: 8000.0, minimumMinutes: 15),
      TariffModel(id: 'tariff_ps3', unitType: 'ps3', pricePerHour: 6000.0, minimumMinutes: 15),
      TariffModel(id: 'tariff_ps2', unitType: 'ps2', pricePerHour: 4000.0, minimumMinutes: 15),
    ];

    for (var tariff in defaultTariffs) {
      final doc = await _db.collection('tariffs').doc(tariff.id).get();
      if (!doc.exists) {
        await _db.collection('tariffs').doc(tariff.id).set(tariff.toMap());
      }
    }
  }
}
