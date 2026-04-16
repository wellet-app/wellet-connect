class Vital {
  final String? id;
  final String personId;
  final String type; // steps, heart_rate, blood_pressure, blood_oxygen, sleep, weight
  final double value;
  final String? unit;
  final DateTime recordedAt;
  final DateTime? syncedAt;

  Vital({
    this.id,
    required this.personId,
    required this.type,
    required this.value,
    this.unit,
    required this.recordedAt,
    this.syncedAt,
  });

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      id: json['id'] as String?,
      personId: json['person_id'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'type': type,
      'value': value,
      if (unit != null) 'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
      if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
    };
  }
}
