import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/person.dart';
import '../services/supabase_service.dart';

// Supabase service singleton
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

// Auth state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final Person? person;
  final String? error;
  final bool magicLinkSent;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.person,
    this.error,
    this.magicLinkSent = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Person? person,
    String? error,
    bool? magicLinkSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      person: person ?? this.person,
      error: error,
      magicLinkSent: magicLinkSent ?? this.magicLinkSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = _supabaseService.currentUser;
    if (user != null) {
      _loadPerson(user);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _supabaseService.authStateChanges.listen((authState) {
      final session = authState.session;
      if (session != null) {
        _loadPerson(session.user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> _loadPerson(User user) async {
    try {
      final person = await _supabaseService.getPersonForUser(user.id);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        person: person,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    }
  }

  /// Send a magic link to the given email address
  Future<void> sendMagicLink({required String email}) async {
    state = state.copyWith(error: null, magicLinkSent: false);
    try {
      await _supabaseService.signInWithMagicLink(email: email);
      state = state.copyWith(magicLinkSent: true);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});
