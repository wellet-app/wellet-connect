import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pairing_service.dart';

class PairingState {
  final bool isPaired;
  final String? personId;
  final String? caregiverName;
  final bool isValidating;
  final String? error;

  const PairingState({
    this.isPaired = false,
    this.personId,
    this.caregiverName,
    this.isValidating = false,
    this.error,
  });

  PairingState copyWith({
    bool? isPaired,
    String? personId,
    String? caregiverName,
    bool? isValidating,
    String? error,
    bool clearError = false,
  }) {
    return PairingState(
      isPaired: isPaired ?? this.isPaired,
      personId: personId ?? this.personId,
      caregiverName: caregiverName ?? this.caregiverName,
      isValidating: isValidating ?? this.isValidating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PairingNotifier extends StateNotifier<PairingState> {
  final PairingService _service;

  PairingNotifier(this._service) : super(const PairingState()) {
    _loadPairingState();
  }

  Future<void> _loadPairingState() async {
    final personId = await _service.getPairedPersonId();
    final caregiverName = await _service.getCaregiverName();
    state = PairingState(
      isPaired: personId != null,
      personId: personId,
      caregiverName: caregiverName,
    );
  }

  Future<bool> validateAndAcceptInvite({
    required String code,
    required String userId,
    required String userEmail,
  }) async {
    state = state.copyWith(isValidating: true, clearError: true);

    try {
      final success = await _service.acceptInvite(
        inviteCode: code,
        userId: userId,
        userEmail: userEmail,
      );

      if (success) {
        final personId = await _service.getPairedPersonId();
        final caregiverName = await _service.getCaregiverName();
        state = PairingState(
          isPaired: true,
          personId: personId,
          caregiverName: caregiverName,
        );
        return true;
      } else {
        state = state.copyWith(
          isValidating: false,
          error: 'That invite code is not valid. Please check and try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isValidating: false,
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> unpair() async {
    await _service.unpair();
    state = const PairingState();
  }
}

final pairingServiceProvider = Provider<PairingService>((ref) {
  return PairingService(Supabase.instance.client);
});

final pairingProvider =
    StateNotifierProvider<PairingNotifier, PairingState>((ref) {
  final service = ref.watch(pairingServiceProvider);
  return PairingNotifier(service);
});
