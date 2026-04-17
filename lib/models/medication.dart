class Medication {
  final String id;
  final String personId;
  final String name;
  final String? dose;
  final String? frequency;
  final String? prescriber;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final String source;
  final String? ehrSystem;
  final DateTime createdAt;

  /// Local-only field populated from medication_reminders table
  final List<String> reminderTimes;

  Medication({
    required this.id,
    required this.personId,
    required this.name,
    this.dose,
    this.frequency,
    this.prescriber,
    this.startDate,
    this.endDate,
    this.active = true,
    this.source = 'manual',
    this.ehrSystem,
    required this.createdAt,
    this.reminderTimes = const [],
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      name: json['name'] as String,
      dose: json['dose'] as String?,
      frequency: json['frequency'] as String?,
      prescriber: json['prescriber'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      active: json['active'] as bool? ?? true,
      source: json['source'] as String? ?? 'manual',
      ehrSystem: json['ehr_system'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Medication copyWith({List<String>? reminderTimes}) {
    return Medication(
      id: id,
      personId: personId,
      name: name,
      dose: dose,
      frequency: frequency,
      prescriber: prescriber,
      startDate: startDate,
      endDate: endDate,
      active: active,
      source: source,
      ehrSystem: ehrSystem,
      createdAt: createdAt,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'name': name,
      if (dose != null) 'dose': dose,
      if (frequency != null) 'frequency': frequency,
      if (prescriber != null) 'prescriber': prescriber,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'active': active,
      'source': source,
      if (ehrSystem != null) 'ehr_system': ehrSystem,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
