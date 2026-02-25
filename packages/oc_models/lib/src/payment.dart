import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'workshop_bill_id') String? workshopBillId,
    @JsonKey(name: 'sadad_txn_id') String? sadadTxnId,
    required double amount,
    @Default('QAR') String currency,
    required String type,
    @Default('pending') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
class WorkshopBill with _$WorkshopBill {
  const factory WorkshopBill({
    required String id,
    @JsonKey(name: 'workshop_id') required String workshopId,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'consumer_id') required String consumerId,
    @JsonKey(name: 'labor_amount') required double laborAmount,
    @JsonKey(name: 'description_ar') String? descriptionAr,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    @Default('submitted') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _WorkshopBill;

  factory WorkshopBill.fromJson(Map<String, dynamic> json) =>
      _$WorkshopBillFromJson(json);
}

@freezed
class Payout with _$Payout {
  const factory Payout({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'order_id') String? orderId,
    @JsonKey(name: 'recipient_type') required String recipientType,
    required double amount,
    @Default('QAR') String currency,
    @Default('pending') String status,
    String? reference,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Payout;

  factory Payout.fromJson(Map<String, dynamic> json) =>
      _$PayoutFromJson(json);
}
