import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnosis.freezed.dart';
part 'diagnosis.g.dart';

@freezed
class DiagnosisReport with _$DiagnosisReport {
  const factory DiagnosisReport({
    required String id,
    @JsonKey(name: 'workshop_id') required String workshopId,
    @JsonKey(name: 'vehicle_id') required String vehicleId,
    @JsonKey(name: 'consumer_id') required String consumerId,
    @JsonKey(name: 'issue_description_ar') required String issueDescriptionAr,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    @JsonKey(name: 'labor_quote') double? laborQuote,
    @Default('draft') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Joined data
    @JsonKey(name: 'workshop_profiles') Map<String, dynamic>? workshop,
    Map<String, dynamic>? vehicle,
    List<DiagnosisPart>? parts,
  }) = _DiagnosisReport;

  factory DiagnosisReport.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisReportFromJson(json);
}

@freezed
class DiagnosisPart with _$DiagnosisPart {
  const factory DiagnosisPart({
    required String id,
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'part_name_ar') required String partNameAr,
    @JsonKey(name: 'part_number') String? partNumber,
    @Default(1) int quantity,
    String? notes,
  }) = _DiagnosisPart;

  factory DiagnosisPart.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisPartFromJson(json);
}
