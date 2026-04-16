class Medication {
  final String id;
  final String personId;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? scheduledTime; // HH:mm format
  final String? instructions;
  final bool active;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.personId,
    required this.name,
    this.dosage,
    this.frequency,
    this.scheduledTime,
    this.instructions,
    this.active = true,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      scheduledTime: json['scheduled_time'] as String?,
      instructions: json['instructions'] as String?,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'name': name,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (instructions != null) 'instructions': instructions,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
