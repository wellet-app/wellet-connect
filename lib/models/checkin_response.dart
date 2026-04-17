enum CheckinMood { great, good, okay, notGreat, bad }

class CheckinResponse {
  final String? id;
  final String personId;
  final String userId;
  final CheckinMood mood;
  final int? painLevel;
  final String? sleepQuality;
  final String? notes;
  final String? energyLevel;
  final String? appetite;
  final String source;
  final DateTime? createdAt;
  final DateTime checkedInAt;

  CheckinResponse({
    this.id,
    required this.personId,
    required this.userId,
    required this.mood,
    this.painLevel,
    this.sleepQuality,
    this.notes,
    this.energyLevel,
    this.appetite,
    this.source = 'wellet_connect',
    this.createdAt,
    required this.checkedInAt,
  });

  String get moodLabel {
    switch (mood) {
      case CheckinMood.great:
        return 'Great';
      case CheckinMood.good:
        return 'Good day';
      case CheckinMood.okay:
        return 'Okay';
      case CheckinMood.notGreat:
        return 'Not great';
      case CheckinMood.bad:
        return 'Bad';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case CheckinMood.great:
        return '\u{1F60A}';
      case CheckinMood.good:
        return '\u{1F642}';
      case CheckinMood.okay:
        return '\u{1F610}';
      case CheckinMood.notGreat:
        return '\u{1F614}';
      case CheckinMood.bad:
        return '\u{1F198}';
    }
  }

  static CheckinMood moodFromString(String value) {
    switch (value) {
      case 'great':
        return CheckinMood.great;
      case 'good':
        return CheckinMood.good;
      case 'okay':
        return CheckinMood.okay;
      case 'not_great':
        return CheckinMood.notGreat;
      case 'bad':
        return CheckinMood.bad;
      default:
        return CheckinMood.good;
    }
  }

  static String moodToString(CheckinMood mood) {
    switch (mood) {
      case CheckinMood.great:
        return 'great';
      case CheckinMood.good:
        return 'good';
      case CheckinMood.okay:
        return 'okay';
      case CheckinMood.notGreat:
        return 'not_great';
      case CheckinMood.bad:
        return 'bad';
    }
  }

  factory CheckinResponse.fromJson(Map<String, dynamic> json) {
    return CheckinResponse(
      id: json['id'] as String?,
      personId: json['person_id'] as String,
      userId: json['user_id'] as String? ?? '',
      mood: moodFromString(json['mood'] as String),
      painLevel: json['pain_level'] as int?,
      sleepQuality: json['sleep_quality'] as String?,
      notes: json['notes'] as String?,
      energyLevel: json['energy_level'] as String?,
      appetite: json['appetite'] as String?,
      source: json['source'] as String? ?? 'wellet_connect',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'person_id': personId,
      'user_id': userId,
      'mood': moodToString(mood),
      if (painLevel != null) 'pain_level': painLevel,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (notes != null) 'notes': notes,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (appetite != null) 'appetite': appetite,
      'source': source,
      'checked_in_at': checkedInAt.toIso8601String(),
    };
  }
}
