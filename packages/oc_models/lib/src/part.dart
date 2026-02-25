import 'package:freezed_annotation/freezed_annotation.dart';

part 'part.freezed.dart';
part 'part.g.dart';

@freezed
abstract class PartCategory with _$PartCategory {
  const factory PartCategory({
    required String id,
    @JsonKey(name: 'name_ar') required String nameAr,
    @JsonKey(name: 'name_en') String? nameEn,
    String? icon,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _PartCategory;

  factory PartCategory.fromJson(Map<String, dynamic> json) =>
      _$PartCategoryFromJson(json);
}

@freezed
abstract class Part with _$Part {
  const factory Part({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'name_ar') required String nameAr,
    @JsonKey(name: 'name_en') String? nameEn,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    required double price,
    @JsonKey(name: 'stock_qty') @Default(0) int stockQty,
    @Default('aftermarket') String condition,
    @JsonKey(name: 'image_urls') @Default([]) List<String> imageUrls,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Joined data
    @JsonKey(name: 'shop_profiles') Map<String, dynamic>? shop,
    @JsonKey(name: 'part_categories') Map<String, dynamic>? category,
  }) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);
}

@freezed
abstract class PartVehicleCompat with _$PartVehicleCompat {
  const factory PartVehicleCompat({
    required String id,
    @JsonKey(name: 'part_id') required String partId,
    required String make,
    required String model,
    @JsonKey(name: 'year_from') int? yearFrom,
    @JsonKey(name: 'year_to') int? yearTo,
  }) = _PartVehicleCompat;

  factory PartVehicleCompat.fromJson(Map<String, dynamic> json) =>
      _$PartVehicleCompatFromJson(json);
}
