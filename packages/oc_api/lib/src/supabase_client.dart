import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton Supabase client for the OnlyCars platform.
///
/// Must be initialized in main() before use:
/// ```dart
/// await OcSupabase.init(url: '...', anonKey: '...');
/// ```
class OcSupabase {
  OcSupabase._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// Current authenticated user or null.
  static User? get currentUser => client.auth.currentUser;

  /// Current user ID or null.
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Whether a user is currently signed in.
  static bool get isAuthenticated => client.auth.currentUser != null;
}
