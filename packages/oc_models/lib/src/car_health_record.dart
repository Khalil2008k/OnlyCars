import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_health_record.freezed.dart';
part 'car_health_record.g.dart';

@freezed
class CarHealthRecord with _$CarHealthRecord {
  const factory CarHealthRecord({
    required String id,
    @JsonKey(name: 'vehicle_id') required String vehicleId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'event_type') required String eventType,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    String? hash,
    @JsonKey(name: 'previous_hash') String? previousHash,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _CarHealthRecord;

  factory CarHealthRecord.fromJson(Map<String, dynamic> json) =>
      _$CarHealthRecordFromJson(json);
}
