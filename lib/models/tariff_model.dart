class TariffModel {
  final String id;
  final String unitType;
  final double pricePerHour;
  final double? weekendPrice;
  final int minimumMinutes;

  TariffModel({
    required this.id,
    required this.unitType,
    required this.pricePerHour,
    this.weekendPrice,
    required this.minimumMinutes,
  });

  factory TariffModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TariffModel(
      id: documentId,
      unitType: map['unitType'] ?? '',
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      weekendPrice: (map['weekendPrice'] as num?)?.toDouble(),
      minimumMinutes: map['minimumMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitType': unitType,
      'pricePerHour': pricePerHour,
      'weekendPrice': weekendPrice,
      'minimumMinutes': minimumMinutes,
    };
  }
}
