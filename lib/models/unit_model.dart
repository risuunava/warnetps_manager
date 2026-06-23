class UnitModel {
  final String id;
  final String name;
  final String type; // 'pc' | 'ps'
  final String? psType; // 'ps4' | 'ps3' | 'ps2' | null
  final String status; // 'available' | 'in_use' | 'maintenance'
  final String? currentSessionId;
  final String tariffId;

  UnitModel({
    required this.id,
    required this.name,
    required this.type,
    this.psType,
    required this.status,
    this.currentSessionId,
    required this.tariffId,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UnitModel(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      psType: map['psType'],
      status: map['status'] ?? 'available',
      currentSessionId: map['currentSessionId'],
      tariffId: map['tariffId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'psType': psType,
      'status': status,
      'currentSessionId': currentSessionId,
      'tariffId': tariffId,
    };
  }
}
