import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    String? vin,
    required String make,
    required String model,
    required int year,
    @JsonKey(name: 'plate_number') String? plateNumber,
    String? color,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}
