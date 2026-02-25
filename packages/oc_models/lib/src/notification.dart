import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class OcNotification with _$OcNotification {
  const factory OcNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'title_ar') required String titleAr,
    @JsonKey(name: 'body_ar') required String bodyAr,
    required String type,
    @Default({}) Map<String, dynamic> data,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _OcNotification;

  factory OcNotification.fromJson(Map<String, dynamic> json) =>
      _$OcNotificationFromJson(json);
}
