import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../services/unit_service.dart';
import '../services/session_service.dart';
import '../services/member_service.dart';
import '../services/tariff_service.dart';
import '../services/report_service.dart';

final unitServiceProvider = Provider<UnitService>((ref) {
  return UnitService();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

final memberServiceProvider = Provider<MemberService>((ref) {
  return MemberService();
});

final tariffServiceProvider = Provider<TariffService>((ref) {
  return TariffService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

// Stream of all units (sorted by name)
final unitsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(unitServiceProvider);
  return service.streamUnits();
});

// Stream of PC units
final pcUnitsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(unitServiceProvider);
  return service.streamUnitsByType('pc');
});

// Stream of PS units
final psUnitsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(unitServiceProvider);
  return service.streamUnitsByType('ps');
});

// Stream of all active sessions
final activeSessionsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(sessionServiceProvider);
  return service.streamActiveSessions();
});

// Stream of all members
final membersStreamProvider = StreamProvider((ref) {
  final service = ref.watch(memberServiceProvider);
  return service.streamMembers();
});

// Stream of all tariffs
final tariffsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(tariffServiceProvider);
  return service.streamTariffs();
});

// Stream of today's completed sessions for revenue calculation
final todayCompletedSessionsProvider = StreamProvider<List<SessionModel>>((ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  // Use only single-field range filter (no composite index required),
  // then filter 'completed' status client-side.
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
          .where((session) => session.status == 'completed')
          .toList());
});

