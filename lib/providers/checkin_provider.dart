import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/checkin_response.dart';
import '../services/supabase_service.dart';
import '../services/offline_queue_service.dart';
import 'auth_provider.dart';
import 'medication_provider.dart';

class CheckinState {
  final CheckinResponse? todayCheckin;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CheckinState({
    this.todayCheckin,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  bool get hasCheckedInToday => todayCheckin != null;

  CheckinState copyWith({
    CheckinResponse? todayCheckin,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearCheckin = false,
  }) {
    return CheckinState(
      todayCheckin: clearCheckin ? null : (todayCheckin ?? this.todayCheckin),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class CheckinNotifier extends StateNotifier<CheckinState> {
  final SupabaseService _supabaseService;
  final OfflineQueueService? _offlineQueue;
  final String? _personId;
  final String? _userId;

  CheckinNotifier(
    this._supabaseService,
    this._offlineQueue,
    this._personId,
    this._userId,
  ) : super(const CheckinState()) {
    if (_personId != null) {
      loadTodayCheckin();
    }
  }

  Future<void> loadTodayCheckin() async {
    if (_personId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final checkin = await _supabaseService.getTodayCheckin(_personId!);
      state = state.copyWith(
        todayCheckin: checkin,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitCheckin(CheckinMood mood) async {
    if (_personId == null || _userId == null) return;
    state = state.copyWith(isSubmitting: true, error: null);

    final response = CheckinResponse(
      personId: _personId!,
      userId: _userId!,
      mood: mood,
      checkedInAt: DateTime.now(),
      source: 'wellet_connect',
    );

    try {
      final hasConnection = _offlineQueue != null
          ? await _offlineQueue!.hasConnectivity
          : true;

      if (hasConnection) {
        await _supabaseService.insertCheckin(response);
      } else {
        await _offlineQueue?.enqueue(
          table: AppConstants.checkInsTable,
          operation: 'insert',
          data: response.toJson(),
        );
      }

      state = state.copyWith(
        todayCheckin: response,
        isSubmitting: false,
      );
    } catch (e) {
      // Queue offline if network error
      await _offlineQueue?.enqueue(
        table: AppConstants.checkInsTable,
        operation: 'insert',
        data: response.toJson(),
      );
      state = state.copyWith(
        todayCheckin: response,
        isSubmitting: false,
      );
    }
  }
}

final checkinProvider =
    StateNotifierProvider<CheckinNotifier, CheckinState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  final auth = ref.watch(authProvider);
  return CheckinNotifier(
    supabaseService,
    offlineQueue,
    auth.person?.id,
    auth.user?.id,
  );
});
