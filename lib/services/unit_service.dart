import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_model.dart';

class UnitService {
  final _db = FirebaseFirestore.instance;

  // Stream all units
  Stream<List<UnitModel>> streamUnits() {
    return _db.collection('units').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UnitModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream units by type ('pc' | 'ps')
  Stream<List<UnitModel>> streamUnitsByType(String type) {
    return _db
        .collection('units')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => UnitModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort alphabetically by name
          list.sort((a, b) => a.name.compareTo(b.name));
          return list;
        });
  }

  // Update unit status
  Future<void> updateUnitStatus(String unitId, String status, String? sessionId) async {
    await _db.collection('units').doc(unitId).update({
      'status': status,
      'currentSessionId': sessionId,
    });
  }

  // Update complete unit settings
  Future<void> updateUnit(UnitModel unit) async {
    await _db.collection('units').doc(unit.id).set(unit.toMap(), SetOptions(merge: true));
  }

  // Add unit
  Future<void> addUnit(UnitModel unit) async {
    await _db.collection('units').doc(unit.id).set(unit.toMap());
  }

  // Delete unit
  Future<void> deleteUnit(String unitId) async {
    await _db.collection('units').doc(unitId).delete();
  }

  // Initialize default units
  Future<void> initializeDefaultUnits() async {
    final defaultUnits = [
      // Computers
      UnitModel(id: 'pc_01', name: 'PC 01', type: 'pc', status: 'available', tariffId: 'tariff_pc'),
      UnitModel(id: 'pc_02', name: 'PC 02', type: 'pc', status: 'available', tariffId: 'tariff_pc'),
      UnitModel(id: 'pc_03', name: 'PC 03', type: 'pc', status: 'available', tariffId: 'tariff_pc'),
      UnitModel(id: 'pc_04', name: 'PC 04', type: 'pc', status: 'available', tariffId: 'tariff_pc'),
      UnitModel(id: 'pc_05', name: 'PC 05', type: 'pc', status: 'available', tariffId: 'tariff_pc'),
      // PlayStations
      UnitModel(id: 'ps_01', name: 'PS Station 1', type: 'ps', psType: 'ps4', status: 'available', tariffId: 'tariff_ps4'),
      UnitModel(id: 'ps_02', name: 'PS Station 2', type: 'ps', psType: 'ps3', status: 'available', tariffId: 'tariff_ps3'),
      UnitModel(id: 'ps_03', name: 'PS Station 3', type: 'ps', psType: 'ps3', status: 'available', tariffId: 'tariff_ps3'),
      UnitModel(id: 'ps_04', name: 'PS Station 4', type: 'ps', psType: 'ps2', status: 'available', tariffId: 'tariff_ps2'),
      UnitModel(id: 'ps_05', name: 'PS Station 5', type: 'ps', psType: 'ps2', status: 'available', tariffId: 'tariff_ps2'),
    ];

    for (var unit in defaultUnits) {
      final doc = await _db.collection('units').doc(unit.id).get();
      if (!doc.exists) {
        await _db.collection('units').doc(unit.id).set(unit.toMap());
      }
    }
  }
}
