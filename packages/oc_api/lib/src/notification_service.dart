import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for in-app notifications — fetch, mark, and real-time stream.
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

  /// Get unread count for badge (one-shot).
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

  /// Stream all notifications for the current user via Supabase Realtime.
  /// Emits the full list each time a row is inserted/updated/deleted.
  Stream<List<OcNotification>> streamNotifications() {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return Stream.value([]);
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .map((data) => data.map((e) => OcNotification.fromJson(e)).toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000))));
  }

  /// Stream unread count — derived from the realtime notifications stream.
  /// Badge auto-updates without polling.
  Stream<int> streamUnreadCount() {
    return streamNotifications().map((list) => list.where((n) => !n.isRead).length);
  }

  /// Create a notification (for manual triggers from the app).
  Future<void> createNotification({
    required String userId,
    required String titleAr,
    required String bodyAr,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title_ar': titleAr,
      'body_ar': bodyAr,
      'type': type,
      'data': data ?? {},
    });
  }
}
