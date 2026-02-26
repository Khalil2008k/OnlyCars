import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for workshop bills — fetch, approve, dispute.
class BillService {
  final SupabaseClient _client = OcSupabase.client;

  /// Get bill by ID with related order and workshop data.
  Future<WorkshopBill?> getBillById(String id) async {
    final data = await _client
        .from('workshop_bills')
        .select('*, orders(*), workshop_profiles(*)')
        .eq('id', id)
        .maybeSingle();
    return data != null ? WorkshopBill.fromJson(data) : null;
  }

  /// Get bills for an order.
  Future<List<WorkshopBill>> getBillsByOrderId(String orderId) async {
    final data = await _client
        .from('workshop_bills')
        .select('*, workshop_profiles(*)')
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => WorkshopBill.fromJson(e)).toList();
  }

  /// Consumer approves the bill.
  Future<void> approveBill(String id) async {
    await _client.from('workshop_bills').update({'status': 'approved'}).eq('id', id);
  }

  /// Consumer disputes the bill with a reason.
  Future<void> disputeBill(String id, String reason) async {
    await _client.from('workshop_bills').update({
      'status': 'disputed',
      'dispute_reason': reason,
    }).eq('id', id);
  }
}
