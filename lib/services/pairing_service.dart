import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pairs a Wellet Connect user (the loved one) with the family member who
/// invited them, using a 6-char short invite code that maps to a row in
/// `care_circle_members` on the Wellet backend.
///
/// All flow goes through the `care-circle-invite` edge function:
///   - lookup_short_code → resolve code, get inviter + person info
///   - accept            → link the authenticated auth.user to the member row
///
/// We never read or write `care_circle_invites` (no such table) and we never
/// touch `care_circle_members` directly — the edge function owns those writes.
class PairingService {
  final SupabaseClient _client;
  static const _pairedPersonIdKey = 'paired_person_id';
  static const _pairedCaregiverNameKey = 'paired_caregiver_name';
  static const _pairedShortCodeKey = 'paired_short_code';

  PairingService(this._client);

  /// Validates a short invite code by calling the care-circle-invite
  /// edge function. Returns the lookup payload on success, or null if
  /// the code is invalid / already accepted.
  ///
  /// Payload shape on success:
  ///   {
  ///     success: true,
  ///     person_name: String,
  ///     member_name: String,
  ///     member_role: String,
  ///     inviter_name: String,
  ///     invite_token: String,   // canonical token, used by accept()
  ///   }
  Future<Map<String, dynamic>?> validateInviteCode(String code) async {
    final cleaned = code.trim().toUpperCase();
    if (cleaned.isEmpty) return null;

    try {
      final response = await _client.functions.invoke(
        'care-circle-invite',
        body: {
          'action': 'lookup_short_code',
          'short_code': cleaned,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Accepts an invite and links the signed-in user to the member row.
  /// Caller must already be authenticated against Supabase (auth.user
  /// non-null) — the edge function uses the JWT to set user_id on the row.
  Future<bool> acceptInvite({
    required String inviteCode,
    required String userId,
    required String userEmail,
  }) async {
    final cleaned = inviteCode.trim().toUpperCase();
    if (cleaned.isEmpty) return false;

    // First look up to grab inviter name + person_id for local storage,
    // and to fail early if the code is invalid.
    final lookup = await validateInviteCode(cleaned);
    if (lookup == null) return false;

    try {
      final response = await _client.functions.invoke(
        'care-circle-invite',
        body: {
          'action': 'accept',
          'short_code': cleaned,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data['success'] != true) {
        return false;
      }

      final personId = data['person_id'] as String?;
      if (personId == null) return false;

      // Store pairing locally so the rest of the app knows who we sync for.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pairedPersonIdKey, personId);
      await prefs.setString(_pairedShortCodeKey, cleaned);
      final inviterName = lookup['inviter_name'] as String?;
      if (inviterName != null && inviterName.isNotEmpty) {
        await prefs.setString(_pairedCaregiverNameKey, inviterName);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Gets the locally stored paired person ID.
  Future<String?> getPairedPersonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pairedPersonIdKey);
  }

  /// Gets the locally stored caregiver name (the family member who invited).
  Future<String?> getCaregiverName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pairedCaregiverNameKey);
  }

  /// Returns true if the app is paired with a family member.
  Future<bool> get isPaired async {
    final personId = await getPairedPersonId();
    return personId != null;
  }

  /// Unpairs from the family member's care circle (local-only — does not
  /// touch the server row, since the loved one usually shouldn't unilaterally
  /// remove themselves from their own care circle).
  Future<void> unpair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pairedPersonIdKey);
    await prefs.remove(_pairedCaregiverNameKey);
    await prefs.remove(_pairedShortCodeKey);
  }
}
