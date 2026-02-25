import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_api/oc_api.dart';

/// Real-time order status stream via Supabase Realtime
final orderRealtimeProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, orderId) {
  final controller = StreamController<Map<String, dynamic>?>();

  final channel = OcSupabase.client
      .channel('order-$orderId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: orderId,
        ),
        callback: (payload) {
          controller.add(payload.newRecord);
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

/// Real-time chat messages stream
final chatRealtimeProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, roomId) {
  final controller = StreamController<List<Map<String, dynamic>>>();
  final messages = <Map<String, dynamic>>[];

  // Fetch initial messages
  OcSupabase.client
      .from('messages')
      .select()
      .eq('room_id', roomId)
      .order('created_at', ascending: true)
      .limit(50)
      .then((data) {
    messages.addAll(List<Map<String, dynamic>>.from(data));
    controller.add(List.from(messages));
  });

  // Subscribe to new messages
  final channel = OcSupabase.client
      .channel('chat-$roomId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          messages.add(payload.newRecord);
          controller.add(List.from(messages));
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

/// Real-time notifications count (unread)
final unreadNotificationsProvider = StreamProvider<int>((ref) {
  final controller = StreamController<int>();

  Future<void> fetchCount() async {
    try {
      final userId = OcSupabase.client.auth.currentUser?.id;
      if (userId == null) {
        controller.add(0);
        return;
      }
      final result = await OcSupabase.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact);
      controller.add(result.count);
    } catch (_) {
      controller.add(0);
    }
  }

  fetchCount();

  final channel = OcSupabase.client
      .channel('notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        callback: (_) => fetchCount(),
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

/// Real-time driver location updates (for consumer tracking)
final driverLocationProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, deliveryId) {
  final controller = StreamController<Map<String, dynamic>?>();

  final channel = OcSupabase.client
      .channel('delivery-$deliveryId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'deliveries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: deliveryId,
        ),
        callback: (payload) {
          controller.add(payload.newRecord);
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});
