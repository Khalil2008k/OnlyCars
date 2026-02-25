import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for workshop discovery, details, and reviews.
class WorkshopService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get all approved workshops.
  Future<List<WorkshopProfile>> getWorkshops() async {
    final data = await _client
        .from('workshop_profiles')
        .select()
        .eq('is_approved', true)
        .order('avg_rating', ascending: false);
    return (data as List).map((e) => WorkshopProfile.fromJson(e)).toList();
  }

  /// Get workshop by ID with reviews.
  Future<WorkshopProfile?> getWorkshopById(String id) async {
    final data = await _client
        .from('workshop_profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    return data != null ? WorkshopProfile.fromJson(data) : null;
  }

  /// Get workshop by unique code.
  Future<WorkshopProfile?> getWorkshopByCode(String code) async {
    final data = await _client
        .from('workshop_profiles')
        .select()
        .eq('code', code)
        .maybeSingle();
    return data != null ? WorkshopProfile.fromJson(data) : null;
  }

  /// Get reviews for a workshop.
  Future<List<Review>> getReviews(String workshopId) async {
    final data = await _client
        .from('reviews')
        .select('*, users:consumer_id(name, avatar_url)')
        .eq('workshop_id', workshopId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Review.fromJson(e)).toList();
  }

  /// Submit a review.
  Future<void> submitReview({
    required String workshopId,
    required int rating,
    String? commentAr,
    String? orderId,
  }) async {
    final uid = OcSupabase.currentUserId!;
    await _client.from('reviews').insert({
      'consumer_id': uid,
      'workshop_id': workshopId,
      'order_id': orderId,
      'rating': rating,
      'comment_ar': commentAr,
    });
  }

  /// Nearby workshops within radius (basic distance calc).
  Future<List<WorkshopProfile>> getNearbyWorkshops({
    required double lat,
    required double lng,
    double radiusKm = 20,
  }) async {
    // PostGIS rpc for distance would be better, but for now:
    final data = await _client
        .from('workshop_profiles')
        .select()
        .eq('is_approved', true);
    
    final workshops = (data as List).map((e) => WorkshopProfile.fromJson(e)).toList();
    
    // Filter by approximate distance
    return workshops.where((w) {
      final dLat = (w.lat - lat).abs();
      final dLng = (w.lng - lng).abs();
      final approxKm = ((dLat * dLat + dLng * dLng) * 111 * 111);
      return approxKm <= radiusKm * radiusKm;
    }).toList();
  }
}
