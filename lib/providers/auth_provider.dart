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

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.person,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Person? person,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      person: person ?? this.person,
      error: error,
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

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _loadPerson(response.user!);
      }
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
