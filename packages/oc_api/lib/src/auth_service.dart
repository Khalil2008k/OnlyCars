import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Authentication service — phone OTP login via Supabase Auth.
class AuthService {
  final SupabaseClient _client = OcSupabase.client;

  /// Send OTP to phone number.
  Future<void> signInWithOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Verify OTP code.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Stream auth state changes.
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  /// Get current session.
  Session? get currentSession => _client.auth.currentSession;

  /// Get current user.
  User? get currentUser => _client.auth.currentUser;

  /// Check if user has completed profile setup.
  Future<bool> hasCompletedProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final data = await _client
        .from('users')
        .select('name')
        .eq('id', user.id)
        .maybeSingle();

    return data != null && data['name'] != null && data['name'].toString().isNotEmpty;
  }

  /// Get user roles.
  Future<List<String>> getUserRoles() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', user.id)
        .eq('is_active', true);

    return (data as List).map((r) => r['role'] as String).toList();
  }

  /// Update FCM token for push notifications.
  Future<void> updateFcmToken(String token) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('users')
        .update({'fcm_token': token})
        .eq('id', user.id);
  }
}
