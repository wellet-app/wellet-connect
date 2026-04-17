import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'services/offline_queue_service.dart';
import 'services/notification_service.dart';
import 'providers/medication_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize offline queue database
  final offlineDb = OfflineQueueDatabase();
  final supabaseService = SupabaseService(Supabase.instance.client);
  final offlineQueue = OfflineQueueService(offlineDb, supabaseService);
  await offlineQueue.initialize();

  // Initialize local notifications (no Firebase dependency)
  NotificationService? notificationService;
  try {
    notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.scheduleDailyCheckinReminder();
  } catch (_) {
    // Local notifications not available on this platform
  }

  // Flush any pending offline operations
  try {
    await offlineQueue.flushQueue();
  } catch (_) {
    // Will retry on next connectivity change
  }

  runApp(
    ProviderScope(
      overrides: [
        offlineQueueProvider.overrideWithValue(offlineQueue),
        if (notificationService != null)
          notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const WelletConnectApp(),
    ),
  );
}
