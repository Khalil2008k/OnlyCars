import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    @JsonKey(name: 'participant_1') required String participant1,
    @JsonKey(name: 'participant_2') required String participant2,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Joined
    Map<String, dynamic>? otherUser,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'sender_id') required String senderId,
    String? content,
    @Default('text') String type,
    @JsonKey(name: 'media_url') String? mediaUrl,
    @Default({}) Map<String, dynamic> metadata,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
