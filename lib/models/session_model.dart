import 'package:cloud_firestore/cloud_firestore.dart';

class SessionExtra {
  final String name;
  final double price;

  SessionExtra({required this.name, required this.price});

  factory SessionExtra.fromMap(Map<String, dynamic> map) {
    return SessionExtra(
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}

class SessionModel {
  final String id;
  final String unitId;
  final String unitName;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String? memberId;
  final String customerName;
  final double subtotal;
  final double discount;
  final double total;
  final List<SessionExtra> extras;
  final String paymentMethod; // 'cash'
  final String operatorId;
  final String status; // 'active' | 'completed'

  SessionModel({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.memberId,
    required this.customerName,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.extras,
    required this.paymentMethod,
    required this.operatorId,
    required this.status,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String documentId) {
    var extrasList = <SessionExtra>[];
    if (map['extras'] != null) {
      extrasList = (map['extras'] as List)
          .map((e) => SessionExtra.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return SessionModel(
      id: documentId,
      unitId: map['unitId'] ?? '',
      unitName: map['unitName'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      durationMinutes: map['durationMinutes'],
      memberId: map['memberId'],
      customerName: map['customerName'] ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      extras: extrasList,
      paymentMethod: map['paymentMethod'] ?? 'cash',
      operatorId: map['operatorId'] ?? '',
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'unitName': unitName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'memberId': memberId,
      'customerName': customerName,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'extras': extras.map((e) => e.toMap()).toList(),
      'paymentMethod': paymentMethod,
      'operatorId': operatorId,
      'status': status,
    };
  }
}
