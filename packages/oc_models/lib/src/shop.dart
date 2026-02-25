import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop.freezed.dart';
part 'shop.g.dart';

@freezed
class ShopProfile with _$ShopProfile {
  const factory ShopProfile({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'name_ar') required String nameAr,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    String? phone,
    required double lat,
    required double lng,
    String? zone,
    @JsonKey(name: 'cover_photo_url') String? coverPhotoUrl,
    @JsonKey(name: 'gallery_urls') @Default([]) List<String> galleryUrls,
    @Default([]) List<String> brands,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_approved') @Default(false) bool isApproved,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ShopProfile;

  factory ShopProfile.fromJson(Map<String, dynamic> json) =>
      _$ShopProfileFromJson(json);
}
