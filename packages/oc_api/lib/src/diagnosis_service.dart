import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for diagnosis reports — workshop creates, consumer reviews.
class DiagnosisService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get diagnosis reports for current consumer.
  Future<List<DiagnosisReport>> getConsumerReports() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('diagnosis_reports')
        .select('*, workshop_profiles(*), diagnosis_parts(*)')
        .eq('consumer_id', uid)
        .order('created_at', ascending: false);
    return (data as List).map((e) => DiagnosisReport.fromJson(e)).toList();
  }

  /// Get report by ID.
  Future<DiagnosisReport?> getReportById(String id) async {
    final data = await _client
        .from('diagnosis_reports')
        .select('*, workshop_profiles(*), diagnosis_parts(*)')
        .eq('id', id)
        .maybeSingle();
    return data != null ? DiagnosisReport.fromJson(data) : null;
  }

  /// Workshop creates a new diagnosis report.
  Future<DiagnosisReport> createReport({
    required String vehicleId,
    required String consumerId,
    required String issueDescriptionAr,
    List<String>? photoUrls,
    double? laborQuote,
    List<Map<String, dynamic>>? parts,
  }) async {
    final workshopProfile = await _client
        .from('workshop_profiles')
        .select('id')
        .eq('user_id', OcSupabase.currentUserId!)
        .single();

    final reportData = await _client.from('diagnosis_reports').insert({
      'workshop_id': workshopProfile['id'],
      'vehicle_id': vehicleId,
      'consumer_id': consumerId,
      'issue_description_ar': issueDescriptionAr,
      'photo_urls': photoUrls ?? [],
      'labor_quote': laborQuote,
    }).select().single();

    final reportId = reportData['id'] as String;

    // Insert parts if provided
    if (parts != null && parts.isNotEmpty) {
      final partInserts = parts.map((p) => {
        'report_id': reportId,
        'part_name_ar': p['part_name_ar'],
        'part_number': p['part_number'],
        'quantity': p['quantity'] ?? 1,
        'notes': p['notes'],
      }).toList();
      await _client.from('diagnosis_parts').insert(partInserts);
    }

    return DiagnosisReport.fromJson(reportData);
  }

  /// Consumer approves/rejects/negotiates on a report.
  Future<void> updateReportStatus(String id, String status) async {
    await _client.from('diagnosis_reports').update({'status': status}).eq('id', id);
  }
}
