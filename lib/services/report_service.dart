import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;

  // Fetch completed sessions in a time range
  // Query hanya pakai endTime range (1 field) untuk menghindari kebutuhan composite index.
  // Filter status='completed' dilakukan di sisi client.
  Future<List<SessionModel>> getCompletedSessions(DateTime start, DateTime end) async {
    // Pastikan end mencakup akhir hari (23:59:59)
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final snapshot = await _db
        .collection('sessions')
        .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    // Filter completed di client side - tidak butuh composite index
    return snapshot.docs
        .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
        .where((s) => s.status == 'completed')
        .toList();
  }

  // Generate Report Statistics from sessions
  Map<String, dynamic> generateReportStats(List<SessionModel> sessions) {
    double totalRevenue = 0.0;
    double pcRevenue = 0.0;
    double psRevenue = 0.0;
    int pcCount = 0;
    int psCount = 0;

    // Unit usage tracker
    final unitCountMap = <String, int>{};
    final unitNameMap = <String, String>{};

    // Hourly usage tracker (00:00 to 23:00)
    final hourlyCount = List.filled(24, 0);

    // Daily breakdown of revenue
    final dailyRevenueMap = <String, double>{};

    for (var session in sessions) {
      totalRevenue += session.total;

      // Count sessions and revenue by type
      final isPC = session.unitName.toLowerCase().contains('pc');
      if (isPC) {
        pcRevenue += session.total;
        pcCount++;
      } else {
        psRevenue += session.total;
        psCount++;
      }

      // Track unit activity
      unitCountMap[session.unitId] = (unitCountMap[session.unitId] ?? 0) + 1;
      unitNameMap[session.unitId] = session.unitName;

      // Track peak hours using startTime hour
      final startHour = session.startTime.hour;
      hourlyCount[startHour]++;

      // Track daily revenue
      if (session.endTime != null) {
        final dayStr = DateFormat('dd/MM').format(session.endTime!);
        dailyRevenueMap[dayStr] = (dailyRevenueMap[dayStr] ?? 0.0) + session.total;
      }
    }

    // Sort unit activity to find busiest units
    final sortedUnits = unitCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final busiestUnits = sortedUnits.map((entry) => {
      'unitId': entry.key,
      'name': unitNameMap[entry.key] ?? 'Unknown',
      'count': entry.value,
    }).toList();

    // Get recent transactions sorted by endTime descending
    final recentTransactions = List<SessionModel>.from(sessions)
      ..sort((a, b) => (b.endTime ?? DateTime.now()).compareTo(a.endTime ?? DateTime.now()));

    return {
      'totalRevenue': totalRevenue,
      'pcRevenue': pcRevenue,
      'psRevenue': psRevenue,
      'pcCount': pcCount,
      'psCount': psCount,
      'totalCount': sessions.length,
      'busiestUnits': busiestUnits,
      'hourlyCount': hourlyCount,
      'dailyRevenue': dailyRevenueMap,
      'recentTransactions': recentTransactions,
    };
  }

  // Fetch stats for specific period
  Future<Map<String, dynamic>> getPeriodStats(String period) async {
    final now = DateTime.now();
    late DateTime start;
    final end = now;

    if (period == 'today') {
      start = DateTime(now.year, now.month, now.day);
    } else if (period == 'week') {
      start = now.subtract(const Duration(days: 7));
    } else if (period == 'month') {
      start = DateTime(now.year, now.month, 1);
    } else {
      start = DateTime(now.year, now.month, now.day);
    }

    final sessions = await getCompletedSessions(start, end);
    return generateReportStats(sessions);
  }

  // Stream stats for specific period to auto-update without refresh
  Stream<Map<String, dynamic>> streamPeriodStats(String period) {
    final now = DateTime.now();
    late DateTime start;
    final end = now;

    if (period == 'today') {
      start = DateTime(now.year, now.month, now.day);
    } else if (period == 'week') {
      start = now.subtract(const Duration(days: 7));
    } else if (period == 'month') {
      start = DateTime(now.year, now.month, 1);
    } else {
      start = DateTime(now.year, now.month, now.day);
    }

    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _db
        .collection('sessions')
        .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
           final sessions = snapshot.docs
              .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
              .where((s) => s.status == 'completed')
              .toList();
           return generateReportStats(sessions);
        });
  }
}
