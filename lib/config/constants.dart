class AppConstants {
  // Sizing
  static const double minFontSize = 20.0;
  static const double minTouchTarget = 56.0;

  // Health sync
  static const int healthSyncIntervalHours = 4;
  static const int healthDataLookbackHours = 24;

  // Check-in
  static const int defaultCheckinHour = 10; // 10 AM

  // Tables
  static const String vitalsTable = 'vitals';
  static const String healthEventsTable = 'health_events';
  static const String medicationsTable = 'medications';
  static const String medicationRemindersTable = 'medication_reminders';
  static const String medicationLogsTable = 'medication_logs';
  static const String checkInsTable = 'check_ins';
  static const String peopleTable = 'people';
  static const String careCircleMembersTable = 'care_circle_members';

  // Privacy message
  static const String privacyMessage =
      'Your health information is encrypted and isolated with row-level security.';

  // Health permission explanation (iOS)
  static const String healthPermissionIOS =
      'Wellet needs to read your health data so your family can see how '
      "you're doing. We never share this data with anyone else.";

  // Health permission explanation (Android)
  static const String healthPermissionAndroid =
      'Wellet needs to read your health data so your family can see how '
      "you're doing. We never share this data with anyone else.";
}
