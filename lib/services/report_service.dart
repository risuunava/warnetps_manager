import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;

  // Fetch completed sessions in a time range
  Future<List<SessionModel>> getCompletedSessions(DateTime start, DateTime end) async {
    try {
      final snapshot = await _db
          .collection('sessions')
          .where('status', isEqualTo: 'completed')
          .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('endTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting completed sessions for report: $e');
      return [];
    }
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
      start = DateTime(now.year, now.month - 1, now.day);
    } else {
      start = DateTime(now.year, now.month, now.day);
    }

    final sessions = await getCompletedSessions(start, end);
    return generateReportStats(sessions);
  }
}
