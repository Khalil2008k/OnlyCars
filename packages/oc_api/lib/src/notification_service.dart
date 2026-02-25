import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for in-app notifications.
class NotificationService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get user's notifications.
  Future<List<OcNotification>> getNotifications({int limit = 50}) async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => OcNotification.fromJson(e)).toList();
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  /// Mark all as read.
  Future<void> markAllAsRead() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
  }

  /// Get unread count for badge.
  Future<int> getUnreadCount() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return 0;
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', uid)
        .eq('is_read', false);
    return (data as List).length;
  }

  /// Subscribe to real-time notifications.
  Stream<OcNotification> subscribeToNotifications() {
    final uid = OcSupabase.currentUserId!;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .map((data) => data.map((e) => OcNotification.fromJson(e)).last);
  }
}
