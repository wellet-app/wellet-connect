import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/offline_queue_service.dart';
import 'auth_provider.dart';

class MedicationState {
  final List<Medication> medications;
  final List<MedicationLog> recentLogs;
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.medications = const [],
    this.recentLogs = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    List<MedicationLog>? recentLogs,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      recentLogs: recentLogs ?? this.recentLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final SupabaseService _supabaseService;
  final OfflineQueueService? _offlineQueue;
  final NotificationService? _notificationService;
  final String? _personId;
  final String? _userId;
  RealtimeChannel? _subscription;

  MedicationNotifier(
    this._supabaseService,
    this._offlineQueue,
    this._notificationService,
    this._personId,
    this._userId,
  ) : super(const MedicationState()) {
    if (_personId != null) {
      loadMedications();
      _subscribeMedications();
    }
  }

  Future<void> loadMedications() async {
    if (_personId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final meds = await _supabaseService.getMedications(_personId!);
      final logs =
          await _supabaseService.getRecentMedicationLogs(_personId!);

      // Load medication reminders and attach to medications
      final reminders =
          await _supabaseService.getMedicationReminders(_personId!);
      final medsWithReminders = _attachReminders(meds, reminders);

      // Schedule local notifications for each medication's reminders
      if (_notificationService != null) {
        for (final med in medsWithReminders) {
          if (med.reminderTimes.isNotEmpty) {
            await _notificationService!.scheduleMedicationReminders(med);
          }
        }
      }

      state = state.copyWith(
        medications: medsWithReminders,
        recentLogs: logs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  List<Medication> _attachReminders(
    List<Medication> meds,
    List<Map<String, dynamic>> reminders,
  ) {
    return meds.map((med) {
      final matching = reminders.where(
        (r) => r['medication_id'] == med.id,
      );
      if (matching.isEmpty) return med;

      final times = <String>[];
      for (final r in matching) {
        final reminderTimes = r['reminder_times'];
        if (reminderTimes is List) {
          times.addAll(reminderTimes.cast<String>());
        }
      }
      return med.copyWith(reminderTimes: times);
    }).toList();
  }

  void _subscribeMedications() {
    if (_personId == null) return;
    _subscription = _supabaseService.subscribeMedications(
      _personId!,
      (meds) async {
        // Re-attach reminders on realtime update
        final reminders =
            await _supabaseService.getMedicationReminders(_personId!);
        final medsWithReminders = _attachReminders(meds, reminders);
        state = state.copyWith(medications: medsWithReminders);
      },
    );
  }

  Future<void> logMedication({
    required String medicationId,
    required MedicationAction action,
  }) async {
    if (_personId == null || _userId == null) return;

    final log = MedicationLog(
      medicationId: medicationId,
      personId: _personId!,
      userId: _userId!,
      action: action,
      takenAt: DateTime.now(),
      source: 'wellet_connect',
    );

    try {
      final hasConnection = _offlineQueue != null
          ? await _offlineQueue!.hasConnectivity
          : true;

      if (hasConnection) {
        await _supabaseService.insertMedicationLog(log);
      } else {
        await _offlineQueue?.enqueue(
          table: AppConstants.medicationLogsTable,
          operation: 'insert',
          data: log.toJson(),
        );
      }

      // Refresh recent logs
      final logs =
          await _supabaseService.getRecentMedicationLogs(_personId!);
      state = state.copyWith(recentLogs: logs);
    } catch (e) {
      // Queue offline if network error
      await _offlineQueue?.enqueue(
        table: AppConstants.medicationLogsTable,
        operation: 'insert',
        data: log.toJson(),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final offlineQueueProvider = Provider<OfflineQueueService?>((ref) {
  // Initialized in main.dart and overridden
  return null;
});

final notificationServiceProvider = Provider<NotificationService?>((ref) {
  // Initialized in main.dart and overridden
  return null;
});

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final auth = ref.watch(authProvider);
  return MedicationNotifier(
    supabaseService,
    offlineQueue,
    notificationService,
    auth.person?.id,
    auth.user?.id,
  );
});
