enum MedicationAction { took, skipped, late_ }

class MedicationLog {
  final String? id;
  final String medicationId;
  final String personId;
  final String userId;
  final MedicationAction action;
  final DateTime takenAt;
  final String? notes;
  final String source;
  final DateTime? createdAt;

  MedicationLog({
    this.id,
    required this.medicationId,
    required this.personId,
    required this.userId,
    required this.action,
    required this.takenAt,
    this.notes,
    this.source = 'wellet_connect',
    this.createdAt,
  });

  static String actionToStatus(MedicationAction action) {
    switch (action) {
      case MedicationAction.took:
        return 'taken';
      case MedicationAction.skipped:
        return 'skipped';
      case MedicationAction.late_:
        return 'late';
    }
  }

  static MedicationAction statusToAction(String status) {
    switch (status) {
      case 'taken':
        return MedicationAction.took;
      case 'skipped':
        return MedicationAction.skipped;
      case 'late':
        return MedicationAction.late_;
      default:
        return MedicationAction.took;
    }
  }

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] as String?,
      medicationId: json['medication_id'] as String,
      personId: json['person_id'] as String,
      userId: json['user_id'] as String? ?? '',
      action: statusToAction(json['status'] as String? ?? 'taken'),
      takenAt: DateTime.parse(json['taken_at'] as String),
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'wellet_connect',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'medication_id': medicationId,
      'person_id': personId,
      'user_id': userId,
      'status': actionToStatus(action),
      'taken_at': takenAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      'source': source,
    };
  }
}
