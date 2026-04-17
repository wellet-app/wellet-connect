class Vital {
  final String? id;
  final String personId;
  final String vitalType;
  final String value;
  final String? unit;
  final DateTime? effectiveDate;
  final String? loincCode;
  final String source;
  final String? sourceFile;
  final String? exportJobId;
  final DateTime? createdAt;

  Vital({
    this.id,
    required this.personId,
    required this.vitalType,
    required this.value,
    this.unit,
    this.effectiveDate,
    this.loincCode,
    this.source = 'apple_health',
    this.sourceFile,
    this.exportJobId,
    this.createdAt,
  });

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      id: json['id'] as String?,
      personId: json['person_id'] as String,
      vitalType: json['vital_type'] as String,
      value: json['value']?.toString() ?? '0',
      unit: json['unit'] as String?,
      effectiveDate: json['effective_date'] != null
          ? DateTime.parse(json['effective_date'] as String)
          : null,
      loincCode: json['loinc_code'] as String?,
      source: json['source'] as String? ?? 'apple_health',
      sourceFile: json['source_file'] as String?,
      exportJobId: json['export_job_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'vital_type': vitalType,
      'value': value,
      if (unit != null) 'unit': unit,
      if (effectiveDate != null)
        'effective_date': effectiveDate!.toIso8601String(),
      if (loincCode != null) 'loinc_code': loincCode,
      'source': source,
      if (sourceFile != null) 'source_file': sourceFile,
      if (exportJobId != null) 'export_job_id': exportJobId,
    };
  }

  /// Helper to get numeric value for dashboard display
  double get numericValue => double.tryParse(value) ?? 0.0;
}
