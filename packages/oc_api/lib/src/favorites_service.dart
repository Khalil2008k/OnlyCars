import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for user favorites — parts and workshops.
class FavoritesService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get all favorites for current user with joined part/workshop data.
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('favorites')
        .select('*, parts(*, shop_profiles(*)), workshop_profiles(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Check if a part is favorited.
  Future<bool> isFavorite({String? partId, String? workshopId}) async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return false;
    var query = _client.from('favorites').select('id').eq('user_id', uid);
    if (partId != null) query = query.eq('part_id', partId);
    if (workshopId != null) query = query.eq('workshop_id', workshopId);
    final data = await query.maybeSingle();
    return data != null;
  }

  /// Add a favorite (part or workshop).
  Future<void> addFavorite({String? partId, String? workshopId}) async {
    final uid = OcSupabase.currentUserId!;
    await _client.from('favorites').insert({
      'user_id': uid,
      'part_id': partId,
      'workshop_id': workshopId,
    });
  }

  /// Remove a favorite by ID.
  Future<void> removeFavorite(String id) async {
    await _client.from('favorites').delete().eq('id', id);
  }

  /// Toggle favorite state — returns true if now favorited.
  Future<bool> toggleFavorite({String? partId, String? workshopId}) async {
    final uid = OcSupabase.currentUserId!;
    var query = _client.from('favorites').select('id').eq('user_id', uid);
    if (partId != null) query = query.eq('part_id', partId);
    if (workshopId != null) query = query.eq('workshop_id', workshopId);

    final existing = await query.maybeSingle();
    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
      return false;
    } else {
      await addFavorite(partId: partId, workshopId: workshopId);
      return true;
    }
  }

  /// Get favorites count for badge.
  Future<int> getFavoritesCount() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return 0;
    final data = await _client.from('favorites').select('id').eq('user_id', uid);
    return (data as List).length;
  }
}
