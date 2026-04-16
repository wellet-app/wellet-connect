import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_sync_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService();
});

class HealthSummary {
  final int steps;
  final int? heartRate;
  final double? sleepHours;
  final bool permissionsGranted;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const HealthSummary({
    this.steps = 0,
    this.heartRate,
    this.sleepHours,
    this.permissionsGranted = false,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  HealthSummary copyWith({
    int? steps,
    int? heartRate,
    double? sleepHours,
    bool? permissionsGranted,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return HealthSummary(
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      sleepHours: sleepHours ?? this.sleepHours,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class HealthNotifier extends StateNotifier<HealthSummary> {
  final HealthSyncService _healthService;
  final SupabaseService _supabaseService;
  final String? _personId;

  HealthNotifier(this._healthService, this._supabaseService, this._personId)
      : super(const HealthSummary());

  Future<void> requestPermissions() async {
    final granted = await _healthService.requestPermissions();
    state = state.copyWith(permissionsGranted: granted);
    if (granted) {
      await refreshSummary();
    }
  }

  Future<void> checkPermissions() async {
    final granted = await _healthService.hasPermissions();
    state = state.copyWith(permissionsGranted: granted);
  }

  Future<void> refreshSummary() async {
    state = state.copyWith(isSyncing: true);
    try {
      final summary = await _healthService.getTodaySummary();
      state = state.copyWith(
        steps: summary['steps'] as int? ?? 0,
        heartRate: summary['heart_rate'] as int?,
        sleepHours: summary['sleep_hours'] as double?,
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> syncToCloud() async {
    if (_personId == null) return;
    state = state.copyWith(isSyncing: true);
    try {
      await _healthService.syncToSupabase(_supabaseService, _personId!);
      state = state.copyWith(isSyncing: false, lastSyncTime: DateTime.now());
    } catch (_) {
      state = state.copyWith(isSyncing: false);
    }
  }
}

final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthSummary>((ref) {
  final healthService = ref.watch(healthSyncServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final auth = ref.watch(authProvider);
  return HealthNotifier(healthService, supabaseService, auth.person?.id);
});
