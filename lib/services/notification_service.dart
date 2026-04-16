import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/medication.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _medicationChannelId = 'medication_reminders';
  static const String _medicationChannelName = 'Medication Reminders';
  static const String _checkinChannelId = 'daily_checkin';
  static const String _checkinChannelName = 'Daily Check-in';
  static const String _caregiverChannelId = 'caregiver_messages';
  static const String _caregiverChannelName = 'Messages from Family';

  Future<void> initialize() async {
    // Request FCM permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
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

    // Get FCM token for remote push
    final token = await _fcm.getToken();
    if (token != null) {
      // Token would be stored in Supabase for the caregiver to send push
      // notifications via edge functions.
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
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
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _caregiverChannelId,
          _caregiverChannelName,
          description: 'Messages from your family members',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> scheduleMedicationReminder(Medication medication) async {
    if (medication.scheduledTime == null) return;

    final parts = medication.scheduledTime!.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      medication.id.hashCode,
      'Time for your medication',
      '${medication.name}${medication.dosage != null ? " - ${medication.dosage}" : ""}',
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

  Future<void> scheduleDailyCheckinReminder({int hour = 10}) async {
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
    await _localNotifications.cancel(medicationId.hashCode);
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Wellet',
      message.notification?.body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _caregiverChannelId,
          _caregiverChannelName,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
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
