import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oc_api/oc_api.dart';

/// FCM Notification Service — handles push notifications for all apps
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM: request permissions, get token, save token, set up handlers
  static Future<void> init() async {
    // Request permission (iOS / web)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: $token');

    // Save token to Supabase user_devices table
    if (token != null) {
      await _saveToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background tap (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  /// Save FCM token to Supabase
  static Future<void> _saveToken(String token) async {
    try {
      final userId = OcSupabase.client.auth.currentUser?.id;
      if (userId == null) return;

      await OcSupabase.client.from('user_devices').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': _getPlatform(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, fcm_token');

      debugPrint('[FCM] Token saved to Supabase');
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  /// Handle foreground notification — show a local snackbar/banner
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');

    // The actual UI notification will be shown via a global scaffold key
    // or an overlay. For now, log it.
    final data = message.data;
    debugPrint('[FCM] Data: $data');
  }

  /// Handle notification tap — navigate to relevant screen
  static void _handleMessageTap(RemoteMessage message) {
    debugPrint('[FCM] Tapped: ${message.data}');

    final data = message.data;
    final type = data['type'] as String?;

    // Navigation will be handled by the router based on notification type
    // Types: order_update, new_message, delivery_assigned, new_order, approval_update
    switch (type) {
      case 'order_update':
        // Navigate to /order/{order_id}
        break;
      case 'new_message':
        // Navigate to /chat/{room_id}
        break;
      case 'delivery_assigned':
        // Navigate to /driver/delivery/{delivery_id}
        break;
      case 'new_order':
        // Navigate to /shop or /workshop dashboard
        break;
      case 'approval_update':
        // Navigate to appropriate screen
        break;
    }
  }

  static String _getPlatform() {
    // Simplified — in production use Platform.isAndroid etc.
    return 'web';
  }

  /// Subscribe to topic (e.g., 'all_users', 'drivers', 'shop_123')
  static Future<void> subscribeTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to: $topic');
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from: $topic');
  }
}
