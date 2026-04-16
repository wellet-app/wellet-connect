import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/vital.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../models/checkin_response.dart';
import '../models/person.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  SupabaseClient get client => _client;

  // --- Auth ---

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // --- Person ---

  Future<Person?> getPersonForUser(String userId) async {
    final response = await _client
        .from(AppConstants.peopleTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Person.fromJson(response);
  }

  // --- Vitals ---

  Future<void> upsertVitals(List<Vital> vitals) async {
    if (vitals.isEmpty) return;
    await _client
        .from(AppConstants.vitalsTable)
        .upsert(vitals.map((v) => v.toJson()).toList());
  }

  Future<List<Vital>> getRecentVitals(String personId) async {
    final cutoff =
        DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
    final response = await _client
        .from(AppConstants.vitalsTable)
        .select()
        .eq('person_id', personId)
        .gte('recorded_at', cutoff)
        .order('recorded_at', ascending: false);

    return (response as List).map((v) => Vital.fromJson(v)).toList();
  }

  // --- Medications ---

  Future<List<Medication>> getMedications(String personId) async {
    final response = await _client
        .from(AppConstants.medicationsTable)
        .select()
        .eq('person_id', personId)
        .eq('active', true)
        .order('scheduled_time', ascending: true);

    return (response as List).map((m) => Medication.fromJson(m)).toList();
  }

  RealtimeChannel subscribeMedications(
    String personId,
    void Function(List<Medication>) onUpdate,
  ) {
    return _client
        .channel('medications_$personId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.medicationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'person_id',
            value: personId,
          ),
          callback: (payload) async {
            final meds = await getMedications(personId);
            onUpdate(meds);
          },
        )
        .subscribe();
  }

  // --- Medication Logs ---

  Future<void> insertMedicationLog(MedicationLog log) async {
    await _client
        .from(AppConstants.medicationLogsTable)
        .insert(log.toJson());
  }

  Future<List<MedicationLog>> getRecentMedicationLogs(String personId,
      {int limit = 3}) async {
    final response = await _client
        .from(AppConstants.medicationLogsTable)
        .select()
        .eq('person_id', personId)
        .order('logged_at', ascending: false)
        .limit(limit);

    return (response as List).map((l) => MedicationLog.fromJson(l)).toList();
  }

  // --- Check-in ---

  Future<void> insertCheckinResponse(CheckinResponse checkin) async {
    await _client
        .from(AppConstants.checkinResponsesTable)
        .insert(checkin.toJson());
  }

  Future<CheckinResponse?> getTodayCheckin(String personId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await _client
        .from(AppConstants.checkinResponsesTable)
        .select()
        .eq('person_id', personId)
        .gte('checked_in_at', startOfDay.toIso8601String())
        .maybeSingle();

    if (response == null) return null;
    return CheckinResponse.fromJson(response);
  }
}
