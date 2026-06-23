import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../models/tariff_model.dart';
import 'unit_service.dart';
import 'member_service.dart';
import 'tariff_service.dart';

class SessionService {
  final _db = FirebaseFirestore.instance;
  final _unitService = UnitService();
  final _memberService = MemberService();
  final _tariffService = TariffService();

  // Stream active sessions
  Stream<List<SessionModel>> streamActiveSessions() {
    return _db
        .collection('sessions')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Stream history sessions (completed)
  Stream<List<SessionModel>> streamSessionHistory() {
    return _db
        .collection('sessions')
        .where('status', isEqualTo: 'completed')
        .orderBy('endTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get active session for a unit
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc = await _db.collection('sessions').doc(sessionId).get();
      if (doc.exists && doc.data() != null) {
        return SessionModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error getting session: $e');
    }
    return null;
  }

  // Start a new session
  Future<String> startSession({
    required String unitId,
    required String unitName,
    required String customerName,
    String? memberId,
    required String operatorId,
    required String tariffId,
  }) async {
    final sessionRef = _db.collection('sessions').doc();
    final newSession = SessionModel(
      id: sessionRef.id,
      unitId: unitId,
      unitName: unitName,
      startTime: DateTime.now(),
      customerName: customerName,
      memberId: memberId,
      subtotal: 0.0,
      discount: 0.0,
      total: 0.0,
      extras: [],
      paymentMethod: 'cash',
      operatorId: operatorId,
      status: 'active',
    );

    // Run in transaction to make sure unit status updates atomically
    await _db.runTransaction((transaction) async {
      transaction.set(sessionRef, newSession.toMap());
      transaction.update(_db.collection('units').doc(unitId), {
        'status': 'in_use',
        'currentSessionId': sessionRef.id,
      });
    });

    return sessionRef.id;
  }

  // Add extra items to active session
  Future<void> addExtraToSession(String sessionId, SessionExtra extra) async {
    final docRef = _db.collection('sessions').doc(sessionId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final session = SessionModel.fromMap(snapshot.data()!, snapshot.id);
      final updatedExtras = List<SessionExtra>.from(session.extras)..add(extra);

      transaction.update(docRef, {
        'extras': updatedExtras.map((e) => e.toMap()).toList(),
      });
    });
  }

  // Calculate costs helper
  Future<Map<String, dynamic>> calculateCosts({
    required String sessionId,
    required DateTime endTime,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) throw Exception('Sesi tidak ditemukan');

    final unitDoc = await _db.collection('units').doc(session.unitId).get();
    if (!unitDoc.exists) throw Exception('Unit tidak ditemukan');

    final tariffId = unitDoc.data()?['tariffId'];
    final tariff = await _tariffService.getTariff(tariffId);
    if (tariff == null) throw Exception('Tarif tidak ditemukan');

    // Calculate duration
    final durationMillis = endTime.difference(session.startTime).inMilliseconds;
    var durationMinutes = (durationMillis / (1000 * 60)).ceil();
    if (durationMinutes < 1) durationMinutes = 1; // minimum 1 minute

    // Minimum minutes check
    int billableMinutes = durationMinutes;
    if (billableMinutes < tariff.minimumMinutes) {
      billableMinutes = tariff.minimumMinutes;
    }

    // Determine weekend rate if applicable (Saturday/Sunday)
    final dayOfWeek = endTime.weekday;
    final isWeekend = dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday;
    final hourlyRate = (isWeekend && tariff.weekendPrice != null)
        ? tariff.weekendPrice!
        : tariff.pricePerHour;

    // Calculate base subtotal
    double baseSubtotal = (billableMinutes / 60.0) * hourlyRate;

    // Extras subtotal
    double extrasSubtotal = 0.0;
    for (var extra in session.extras) {
      extrasSubtotal += extra.price;
    }

    // Grand subtotal
    double subtotal = baseSubtotal + extrasSubtotal;

    // Discount from membership
    double discount = 0.0;
    double discountPercentage = 0.0;
    if (session.memberId != null) {
      final member = await _memberService.getMember(session.memberId!);
      if (member != null) {
        discountPercentage = member.discountPercentage;
        discount = baseSubtotal * discountPercentage;
      }
    }

    double total = subtotal - discount;

    // Round total to nearest Rp 100 for clean cash transactions
    total = (total / 100).round() * 100.0;

    return {
      'durationMinutes': durationMinutes,
      'billableMinutes': billableMinutes,
      'hourlyRate': hourlyRate,
      'baseSubtotal': baseSubtotal,
      'extrasSubtotal': extrasSubtotal,
      'subtotal': subtotal,
      'discount': discount,
      'discountPercentage': discountPercentage,
      'total': total,
    };
  }

  // Complete session & Checkout
  Future<void> checkoutSession({
    required String sessionId,
    required double subtotal,
    required double discount,
    required double total,
    required int durationMinutes,
    required List<SessionExtra> extras,
  }) async {
    final sessionRef = _db.collection('sessions').doc(sessionId);
    final sessionSnapshot = await sessionRef.get();
    if (!sessionSnapshot.exists) return;

    final session = SessionModel.fromMap(sessionSnapshot.data()!, sessionId);
    final unitId = session.unitId;

    await _db.runTransaction((transaction) async {
      // Update session to completed
      transaction.update(sessionRef, {
        'endTime': Timestamp.now(),
        'durationMinutes': durationMinutes,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'extras': extras.map((e) => e.toMap()).toList(),
        'status': 'completed',
      });

      // Reset unit status to available
      transaction.update(_db.collection('units').doc(unitId), {
        'status': 'available',
        'currentSessionId': null,
      });
    });

    // Record member points and visits outside of transaction if member exists
    if (session.memberId != null) {
      await _memberService.recordVisitAndPoints(
        memberId: session.memberId!,
        amountSpent: total,
        sessionId: sessionId,
      );
    }
  }
}
