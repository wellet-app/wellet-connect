enum CheckinMood { good, notGreat, needHelp }

class CheckinResponse {
  final String? id;
  final String personId;
  final CheckinMood mood;
  final DateTime checkedInAt;
  final DateTime? syncedAt;

  CheckinResponse({
    this.id,
    required this.personId,
    required this.mood,
    required this.checkedInAt,
    this.syncedAt,
  });

  String get moodLabel {
    switch (mood) {
      case CheckinMood.good:
        return 'Good day';
      case CheckinMood.notGreat:
        return 'Not great';
      case CheckinMood.needHelp:
        return 'Need help';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case CheckinMood.good:
        return '\u{1F60A}';
      case CheckinMood.notGreat:
        return '\u{1F610}';
      case CheckinMood.needHelp:
        return '\u{1F198}';
    }
  }

  static CheckinMood moodFromString(String value) {
    switch (value) {
      case 'good':
        return CheckinMood.good;
      case 'not_great':
        return CheckinMood.notGreat;
      case 'need_help':
        return CheckinMood.needHelp;
      default:
        return CheckinMood.good;
    }
  }

  static String moodToString(CheckinMood mood) {
    switch (mood) {
      case CheckinMood.good:
        return 'good';
      case CheckinMood.notGreat:
        return 'not_great';
      case CheckinMood.needHelp:
        return 'need_help';
    }
  }

  factory CheckinResponse.fromJson(Map<String, dynamic> json) {
    return CheckinResponse(
      id: json['id'] as String?,
      personId: json['person_id'] as String,
      mood: moodFromString(json['mood'] as String),
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'mood': moodToString(mood),
      'checked_in_at': checkedInAt.toIso8601String(),
      if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
    };
  }
}
