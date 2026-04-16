enum MedicationAction { took, skipped }

class MedicationLog {
  final String? id;
  final String medicationId;
  final String personId;
  final MedicationAction action;
  final DateTime loggedAt;
  final DateTime? syncedAt;

  MedicationLog({
    this.id,
    required this.medicationId,
    required this.personId,
    required this.action,
    required this.loggedAt,
    this.syncedAt,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] as String?,
      medicationId: json['medication_id'] as String,
      personId: json['person_id'] as String,
      action: json['action'] == 'took'
          ? MedicationAction.took
          : MedicationAction.skipped,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'medication_id': medicationId,
      'person_id': personId,
      'action': action == MedicationAction.took ? 'took' : 'skipped',
      'logged_at': loggedAt.toIso8601String(),
      if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
    };
  }
}
