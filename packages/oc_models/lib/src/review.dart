import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    @JsonKey(name: 'consumer_id') required String consumerId,
    @JsonKey(name: 'workshop_id') required String workshopId,
    @JsonKey(name: 'order_id') String? orderId,
    required int rating,
    @JsonKey(name: 'comment_ar') String? commentAr,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Joined
    Map<String, dynamic>? consumer,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}
