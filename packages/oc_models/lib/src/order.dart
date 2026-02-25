import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'consumer_id') required String consumerId,
    @JsonKey(name: 'workshop_id') String? workshopId,
    @JsonKey(name: 'driver_id') String? driverId,
    @JsonKey(name: 'workshop_code') String? workshopCode,
    @Default('pending') String status,
    @JsonKey(name: 'parts_total') @Default(0) double partsTotal,
    @JsonKey(name: 'delivery_fee') @Default(0) double deliveryFee,
    @JsonKey(name: 'platform_fee') @Default(0) double platformFee,
    @Default(0) double total,
    @JsonKey(name: 'escrow_status') @Default('none') String escrowStatus,
    @JsonKey(name: 'delivery_address_id') String? deliveryAddressId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Joined data
    List<OrderItem>? items,
    @JsonKey(name: 'workshop_profiles') Map<String, dynamic>? workshop,
    @JsonKey(name: 'driver_profiles') Map<String, dynamic>? driver,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'part_id') required String partId,
    @JsonKey(name: 'shop_id') required String shopId,
    @Default(1) int quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required double subtotal,
    // Joined
    @JsonKey(name: 'parts') Map<String, dynamic>? part,
    @JsonKey(name: 'shop_profiles') Map<String, dynamic>? shop,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
abstract class OrderStatusLog with _$OrderStatusLog {
  const factory OrderStatusLog({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'old_status') String? oldStatus,
    @JsonKey(name: 'new_status') required String newStatus,
    @JsonKey(name: 'changed_by') String? changedBy,
    String? note,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _OrderStatusLog;

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusLogFromJson(json);
}
