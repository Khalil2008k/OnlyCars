import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
abstract class DeliveryZone with _$DeliveryZone {
  const factory DeliveryZone({
    required String id,
    @JsonKey(name: 'name_ar') required String nameAr,
    @JsonKey(name: 'name_en') String? nameEn,
    @JsonKey(name: 'base_fee') @Default(15.0) double baseFee,
    @JsonKey(name: 'per_km_fee') @Default(2.0) double perKmFee,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _DeliveryZone;

  factory DeliveryZone.fromJson(Map<String, dynamic> json) =>
      _$DeliveryZoneFromJson(json);
}

@freezed
abstract class PlatformConfig with _$PlatformConfig {
  const factory PlatformConfig({
    required String id,
    required String key,
    required dynamic value,
    String? description,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PlatformConfig;

  factory PlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$PlatformConfigFromJson(json);
}
