import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/medication.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _medicationChannelId = 'medication_reminders';
  static const String _medicationChannelName = 'Medication Reminders';
  static const String _checkinChannelId = 'daily_checkin';
  static const String _checkinChannelName = 'Daily Check-in';

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _medicationChannelId,
          _medicationChannelName,
          description: 'Reminders to take your medications',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _checkinChannelId,
          _checkinChannelName,
          description: 'Daily check-in reminder',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Schedule notifications for a medication based on its reminder_times.
  /// Each reminder time is an HH:mm string (e.g. "08:00", "20:00").
  Future<void> scheduleMedicationReminders(Medication medication) async {
    // Cancel existing reminders for this medication first
    await cancelMedicationReminder(medication.id);

    for (int i = 0; i < medication.reminderTimes.length; i++) {
      final timeStr = medication.reminderTimes[i];
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

      final now = DateTime.now();
      var scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Unique notification ID per medication + time slot
      final notificationId = '${medication.id}_$i'.hashCode;

      await _localNotifications.zonedSchedule(
        notificationId,
        'Time for your medication',
        '${medication.name}${medication.dose != null ? " - ${medication.dose}" : ""}',
        _convertToTZDateTime(scheduledDate),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _medicationChannelId,
            _medicationChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> scheduleDailyCheckinReminder({int hour = 9}) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      'daily_checkin'.hashCode,
      'How are you today?',
      'Take a moment to share how you are feeling with your family.',
      _convertToTZDateTime(scheduledDate),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _checkinChannelId,
          _checkinChannelName,
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelMedicationReminder(String medicationId) async {
    // Cancel up to 10 possible time slots per medication
    for (int i = 0; i < 10; i++) {
      await _localNotifications.cancel('${medicationId}_$i'.hashCode);
    }
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigation handled by GoRouter deep links
  }

  // Helper: convert DateTime to TZDateTime-compatible object.
  // In production, use the timezone package for proper tz handling.
  // For the MVP we schedule with local time.
  TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return TZDateTime.from(dateTime, local);
  }
}
