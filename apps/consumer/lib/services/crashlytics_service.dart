import 'dart:async';
import 'package:flutter/foundation.dart';

/// Crashlytics service — wraps Firebase Crashlytics
/// In production, add firebase_crashlytics dependency and enable
class CrashlyticsService {
  static bool _initialized = false;

  static Future<void> init() async {
    _initialized = true;
    debugPrint('[Crashlytics] Initialized');

    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      debugPrint('[Crashlytics] Flutter error: ${details.exceptionAsString()}');
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Catch async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[Crashlytics] Platform error: $error');
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Record a non-fatal error
  static void recordError(dynamic error, StackTrace? stack, {String? reason}) {
    if (!_initialized) return;
    debugPrint('[Crashlytics] Error: $error ${reason != null ? '($reason)' : ''}');
    // FirebaseCrashlytics.instance.recordError(error, stack, reason: reason ?? '');
  }

  /// Log a message for crash context
  static void log(String message) {
    if (!_initialized) return;
    debugPrint('[Crashlytics] Log: $message');
    // FirebaseCrashlytics.instance.log(message);
  }

  /// Set user identifier for crash reports
  static void setUserId(String userId) {
    if (!_initialized) return;
    debugPrint('[Crashlytics] UserID: $userId');
    // FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Set custom key-value for crash context
  static void setCustomKey(String key, dynamic value) {
    if (!_initialized) return;
    // FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  }
}
