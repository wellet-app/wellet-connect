/// Mirrors the `people` table in Supabase.
/// Schema reality: single `name` column (not first/last), nullable created_at.
class Person {
  final String id;
  final String userId;
  final String? name;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;

  Person({
    required this.id,
    required this.userId,
    this.name,
    this.dateOfBirth,
    this.createdAt,
  });

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'Your loved one';
  }

  /// First word of the name, useful for casual greetings.
  /// Returns null if the person has no name set, so callers can use
  /// their own fallback (e.g. 'there').
  String? get firstName {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : trimmed;
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (name != null) 'name': name,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
