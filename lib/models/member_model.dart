import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final int points;
  final String level; // 'regular' | 'silver' | 'gold'
  final int totalVisits;
  final double totalSpent;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.points,
    required this.level,
    required this.totalVisits,
    required this.totalSpent,
    required this.createdAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MemberModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      points: map['points'] ?? 0,
      level: map['level'] ?? 'regular',
      totalVisits: map['totalVisits'] ?? 0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'points': points,
      'level': level,
      'totalVisits': totalVisits,
      'totalSpent': totalSpent,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper to calculate next level / discount
  double get discountPercentage {
    if (level == 'gold') return 0.10;
    if (level == 'silver') return 0.05;
    return 0.0;
  }
}
