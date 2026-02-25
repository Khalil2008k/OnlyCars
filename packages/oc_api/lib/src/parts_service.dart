import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for the parts marketplace — browsing, cart, and ordering.
class PartsService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get all part categories.
  Future<List<PartCategory>> getCategories() async {
    final data = await _client
        .from('part_categories')
        .select()
        .order('sort_order');
    return (data as List).map((e) => PartCategory.fromJson(e)).toList();
  }

  /// Browse parts with optional filters.
  Future<List<Part>> getParts({
    String? categoryId,
    String? searchQuery,
    String? condition,
    String? make,
    String? model,
    int? year,
  }) async {
    var query = _client
        .from('parts')
        .select('*, shop_profiles(*), part_categories(*)')
        .eq('is_active', true);
    
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (condition != null) query = query.eq('condition', condition);
    
    final data = await query.order('created_at', ascending: false);
    var parts = (data as List).map((e) => Part.fromJson(e)).toList();

    // Client-side text search (move to Supabase FTS later)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      parts = parts.where((p) =>
          p.nameAr.toLowerCase().contains(q) ||
          (p.nameEn?.toLowerCase().contains(q) ?? false) ||
          (p.descriptionAr?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return parts;
  }

  /// Get part detail by ID.
  Future<Part?> getPartById(String id) async {
    final data = await _client
        .from('parts')
        .select('*, shop_profiles(*), part_categories(*)')
        .eq('id', id)
        .maybeSingle();
    return data != null ? Part.fromJson(data) : null;
  }

  /// Get compatible parts for a vehicle.
  Future<List<Part>> getCompatibleParts({
    required String make,
    required String model,
    int? year,
  }) async {
    var query = _client
        .from('part_vehicle_compat')
        .select('part_id')
        .eq('make', make)
        .eq('model', model);

    if (year != null) {
      query = query.lte('year_from', year).gte('year_to', year);
    }

    final compatData = await query;
    final partIds = (compatData as List).map((e) => e['part_id'] as String).toList();

    if (partIds.isEmpty) return [];

    final partsData = await _client
        .from('parts')
        .select('*, shop_profiles(*), part_categories(*)')
        .inFilter('id', partIds)
        .eq('is_active', true);

    return (partsData as List).map((e) => Part.fromJson(e)).toList();
  }
}
