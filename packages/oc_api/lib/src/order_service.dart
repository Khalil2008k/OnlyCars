import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for order lifecycle — create, track, update status.
class OrderService {
  final SupabaseClient _client = OcSupabase.client;

  /// Create a new order with items.
  Future<Order> createOrder({
    String? workshopId,
    String? workshopCode,
    String? deliveryAddressId,
    required List<Map<String, dynamic>> items,
  }) async {
    final uid = OcSupabase.currentUserId!;
    
    // Calculate totals
    double partsTotal = 0;
    for (final item in items) {
      partsTotal += (item['unit_price'] as double) * (item['quantity'] as int);
    }
    
    final deliveryFee = 15.0; // Base fee, will be calculated properly
    final platformFee = partsTotal * 0.05; // 5% commission
    final total = partsTotal + deliveryFee + platformFee;

    // Insert order
    final orderData = await _client.from('orders').insert({
      'consumer_id': uid,
      'workshop_id': workshopId,
      'workshop_code': workshopCode,
      'delivery_address_id': deliveryAddressId,
      'parts_total': partsTotal,
      'delivery_fee': deliveryFee,
      'platform_fee': platformFee,
      'total': total,
    }).select().single();

    final orderId = orderData['id'] as String;

    // Insert order items
    final orderItems = items.map((item) => <String, dynamic>{
      'order_id': orderId,
      'part_id': item['part_id'],
      'shop_id': item['shop_id'],
      'quantity': item['quantity'],
      'unit_price': item['unit_price'],
      'subtotal': (item['unit_price'] as double) * (item['quantity'] as int),
    }).toList();

    await _client.from('order_items').insert(orderItems);

    return Order.fromJson(orderData);
  }

  /// Get consumer's orders.
  Future<List<Order>> getMyOrders() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('orders')
        .select('*, order_items(*, parts(*), shop_profiles(*)), workshop_profiles(*), driver_profiles(*)')
        .eq('consumer_id', uid)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  /// Get order by ID with all details.
  Future<Order?> getOrderById(String id) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, parts(*), shop_profiles(*)), workshop_profiles(*), driver_profiles(*)')
        .eq('id', id)
        .maybeSingle();
    return data != null ? Order.fromJson(data) : null;
  }

  /// Stream order updates in real-time via Supabase Realtime.
  /// Emits the full Order each time the row changes (status, driver, etc).
  Stream<Order?> streamOrder(String id) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
      if (data.isEmpty) return null;
      return Order.fromJson(data.first);
    });
  }

  /// Update order status.
  Future<void> updateStatus(String orderId, String newStatus) async {
    await _client.from('orders').update({'status': newStatus}).eq('id', orderId);
  }

  /// Get order status log.
  Future<List<OrderStatusLog>> getStatusLog(String orderId) async {
    final data = await _client
        .from('order_status_log')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return (data as List).map((e) => OrderStatusLog.fromJson(e)).toList();
  }

  /// Get active orders count for badge.
  Future<int> getActiveOrderCount() async {
    final uid = OcSupabase.currentUserId;
    if (uid == null) return 0;
    final data = await _client
        .from('orders')
        .select('id')
        .eq('consumer_id', uid)
        .not('status', 'in', '(completed,cancelled)');
    return (data as List).length;
  }
}
