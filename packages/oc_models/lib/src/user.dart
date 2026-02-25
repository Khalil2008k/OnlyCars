import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class OcUser with _$OcUser {
  const factory OcUser({
    required String id,
    required String phone,
    String? name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('ar') String lang,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OcUser;

  factory OcUser.fromJson(Map<String, dynamic> json) => _$OcUserFromJson(json);
}

@freezed
class UserRole with _$UserRole {
  const factory UserRole({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String role,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'granted_at') DateTime? grantedAt,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);
}

@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @Default('بيت') String label,
    String? zone,
    String? street,
    String? building,
    double? lat,
    double? lng,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}
