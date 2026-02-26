import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for real-time chat — rooms, messages, and subscriptions.
class ChatService {
  final SupabaseClient _client = OcSupabase.client;
  StreamSubscription? _messageSubscription;

  /// Get or create a chat room between two users.
  Future<ChatRoom> getOrCreateRoom({
    required String otherUserId,
    String? orderId,
  }) async {
    final uid = OcSupabase.currentUserId!;

    // Check existing room
    final existing = await _client
        .from('chat_rooms')
        .select()
        .or('and(participant_1.eq.$uid,participant_2.eq.$otherUserId),and(participant_1.eq.$otherUserId,participant_2.eq.$uid)')
        .maybeSingle();

    if (existing != null) return ChatRoom.fromJson(existing);

    // Create new room
    final data = await _client.from('chat_rooms').insert({
      'participant_1': uid,
      'participant_2': otherUserId,
      'order_id': orderId,
    }).select().single();
    
    return ChatRoom.fromJson(data);
  }

  /// Get all chat rooms for current user with participant details.
  Future<List<ChatRoom>> getRooms() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('chat_rooms')
        .select('*, p1:users!chat_rooms_participant_1_fkey(id, name, avatar_url), p2:users!chat_rooms_participant_2_fkey(id, name, avatar_url)')
        .or('participant_1.eq.$uid,participant_2.eq.$uid')
        .order('last_message_at', ascending: false, nullsFirst: false);

    final uid0 = uid;
    return (data as List).map((e) {
      // Determine which participant is the "other" user
      final map = Map<String, dynamic>.from(e);
      if (map['participant_1'] == uid0) {
        map['otherUser'] = map['p2'];
      } else {
        map['otherUser'] = map['p1'];
      }
      map.remove('p1');
      map.remove('p2');
      return ChatRoom.fromJson(map);
    }).toList();
  }

  /// Get unread message count for a room.
  Future<int> getUnreadCount(String roomId) async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return 0;
    final data = await _client
        .from('chat_messages')
        .select('id')
        .eq('room_id', roomId)
        .neq('sender_id', uid)
        .eq('is_read', false);
    return (data as List).length;
  }

  /// Get messages for a room.
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  /// Send a text message.
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = OcSupabase.currentUserId!;
    final data = await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': uid,
      'content': content,
      'type': type,
      'media_url': mediaUrl,
      'metadata': metadata ?? {},
    }).select().single();
    return ChatMessage.fromJson(data);
  }

  /// Subscribe to new messages in a room (Supabase Realtime).
  Stream<ChatMessage> subscribeToMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((e) => ChatMessage.fromJson(e)).last);
  }

  /// Mark messages as read.
  Future<void> markAsRead(String roomId) async {
    final uid = OcSupabase.currentUserId!;
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('sender_id', uid);
  }

  /// Dispose subscriptions.
  void dispose() {
    _messageSubscription?.cancel();
  }
}
