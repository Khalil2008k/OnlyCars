import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for user profile and vehicle management.
class UserService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get current user profile.
  Future<OcUser?> getProfile() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return null;
    final data = await _client.from('users').select().eq('id', uid).maybeSingle();
    return data != null ? OcUser.fromJson(data) : null;
  }

  /// Update user profile.
  Future<void> updateProfile({String? name, String? avatarUrl, String? lang}) async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (lang != null) updates['lang'] = lang;
    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', uid);
    }
  }

  /// Upload avatar and return URL.
  Future<String> uploadAvatar(String filePath, List<int> bytes) async {
    final uid = OcSupabase.currentUserId!;
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('avatars').uploadBinary(path, bytes as dynamic);
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  // ===== VEHICLES =====

  /// Get user's vehicles.
  Future<List<Vehicle>> getVehicles() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client.from('vehicles').select().eq('user_id', uid).order('created_at');
    return (data as List).map((e) => Vehicle.fromJson(e)).toList();
  }

  /// Add a vehicle.
  Future<Vehicle> addVehicle({
    required String make,
    required String model,
    required int year,
    String? plateNumber,
    String? color,
    String? vin,
  }) async {
    final uid = OcSupabase.currentUserId!;
    final data = await _client.from('vehicles').insert({
      'user_id': uid,
      'make': make,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'color': color,
      'vin': vin,
    }).select().single();
    return Vehicle.fromJson(data);
  }

  /// Delete a vehicle.
  Future<void> deleteVehicle(String id) async {
    await _client.from('vehicles').delete().eq('id', id);
  }

  // ===== ADDRESSES =====

  /// Get user's addresses.
  Future<List<Address>> getAddresses() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client.from('addresses').select().eq('user_id', uid);
    return (data as List).map((e) => Address.fromJson(e)).toList();
  }

  /// Add address.
  Future<Address> addAddress({
    required String label,
    String? zone,
    String? street,
    String? building,
    double? lat,
    double? lng,
    bool isDefault = false,
  }) async {
    final uid = OcSupabase.currentUserId!;
    final data = await _client.from('addresses').insert({
      'user_id': uid,
      'label': label,
      'zone': zone,
      'street': street,
      'building': building,
      'lat': lat,
      'lng': lng,
      'is_default': isDefault,
    }).select().single();
    return Address.fromJson(data);
  }

  /// Delete an address.
  Future<void> deleteAddress(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }

  /// Update an address.
  Future<void> updateAddress(String id, {
    String? label,
    String? zone,
    String? street,
    String? building,
    double? lat,
    double? lng,
    bool? isDefault,
  }) async {
    final updates = <String, dynamic>{};
    if (label != null) updates['label'] = label;
    if (zone != null) updates['zone'] = zone;
    if (street != null) updates['street'] = street;
    if (building != null) updates['building'] = building;
    if (lat != null) updates['lat'] = lat;
    if (lng != null) updates['lng'] = lng;
    if (isDefault != null) updates['is_default'] = isDefault;
    if (updates.isNotEmpty) {
      await _client.from('addresses').update(updates).eq('id', id);
    }
  }
}
