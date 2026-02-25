import 'package:freezed_annotation/freezed_annotation.dart';

part 'workshop.freezed.dart';
part 'workshop.g.dart';

@freezed
abstract class WorkshopProfile with _$WorkshopProfile {
  const factory WorkshopProfile({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'name_ar') required String nameAr,
    required String code,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    String? phone,
    required double lat,
    required double lng,
    String? zone,
    String? street,
    String? building,
    @JsonKey(name: 'cover_photo_url') String? coverPhotoUrl,
    @JsonKey(name: 'gallery_urls') @Default([]) List<String> galleryUrls,
    @Default([]) List<String> specialties,
    @JsonKey(name: 'working_hours') @Default('08:00-18:00') String workingHours,
    @JsonKey(name: 'working_days') @Default('Sun-Thu') String workingDays,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'total_jobs_completed') @Default(0) int totalJobsCompleted,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_open_now') @Default(true) bool isOpenNow,
    @JsonKey(name: 'is_approved') @Default(false) bool isApproved,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _WorkshopProfile;

  factory WorkshopProfile.fromJson(Map<String, dynamic> json) =>
      _$WorkshopProfileFromJson(json);
}
