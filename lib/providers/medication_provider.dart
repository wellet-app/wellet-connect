import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../services/supabase_service.dart';
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
  final String? _personId;
  RealtimeChannel? _subscription;

  MedicationNotifier(
    this._supabaseService,
    this._offlineQueue,
    this._personId,
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
      state = state.copyWith(
        medications: meds,
        recentLogs: logs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeMedications() {
    if (_personId == null) return;
    _subscription = _supabaseService.subscribeMedications(
      _personId!,
      (meds) {
        state = state.copyWith(medications: meds);
      },
    );
  }

  Future<void> logMedication({
    required String medicationId,
    required MedicationAction action,
  }) async {
    if (_personId == null) return;

    final log = MedicationLog(
      medicationId: medicationId,
      personId: _personId!,
      action: action,
      loggedAt: DateTime.now(),
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

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  final auth = ref.watch(authProvider);
  return MedicationNotifier(supabaseService, offlineQueue, auth.person?.id);
});
