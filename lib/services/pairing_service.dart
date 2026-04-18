import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PairingService {
  final SupabaseClient _client;
  static const _pairedPersonIdKey = 'paired_person_id';
  static const _pairedCaregiverNameKey = 'paired_caregiver_name';

  PairingService(this._client);

  /// Validates an invite code against Supabase care_circle_invites table.
  /// Returns the invite data if valid, null otherwise.
  Future<Map<String, dynamic>?> validateInviteCode(String code) async {
    final response = await _client
        .from('care_circle_invites')
        .select()
        .eq('code', code.trim().toUpperCase())
        .eq('status', 'pending')
        .maybeSingle();

    return response;
  }

  /// Accepts an invite and links the care recipient to the caregiver's care circle.
  Future<bool> acceptInvite({
    required String inviteCode,
    required String userId,
    required String userEmail,
  }) async {
    // Validate the invite code
    final invite = await validateInviteCode(inviteCode);
    if (invite == null) return false;

    final personId = invite['person_id'] as String?;
    final careCircleId = invite['care_circle_id'] as String?;

    if (personId == null) return false;

    // Update the person record to link to this user
    await _client
        .from('people')
        .update({'user_id': userId})
        .eq('id', personId);

    // Mark the invite as accepted
    await _client
        .from('care_circle_invites')
        .update({
          'status': 'accepted',
          'accepted_at': DateTime.now().toIso8601String(),
        })
        .eq('code', inviteCode.trim().toUpperCase());

    // Look up the caregiver's name from the care circle
    String? caregiverName;
    if (careCircleId != null) {
      final circle = await _client
          .from('care_circle_members')
          .select('people!inner(first_name)')
          .eq('care_circle_id', careCircleId)
          .eq('role', 'caregiver')
          .maybeSingle();

      if (circle != null) {
        final people = circle['people'];
        if (people is Map) {
          caregiverName = people['first_name'] as String?;
        }
      }
    }

    // Store pairing locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pairedPersonIdKey, personId);
    if (caregiverName != null) {
      await prefs.setString(_pairedCaregiverNameKey, caregiverName);
    }

    return true;
  }

  /// Gets the locally stored paired person ID.
  Future<String?> getPairedPersonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pairedPersonIdKey);
  }

  /// Gets the locally stored caregiver name.
  Future<String?> getCaregiverName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pairedCaregiverNameKey);
  }

  /// Returns true if the app is paired with a caregiver.
  Future<bool> get isPaired async {
    final personId = await getPairedPersonId();
    return personId != null;
  }

  /// Unpairs from the caregiver's care circle.
  Future<void> unpair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pairedPersonIdKey);
    await prefs.remove(_pairedCaregiverNameKey);
  }
}
