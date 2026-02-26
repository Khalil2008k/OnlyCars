import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oc_models/oc_models.dart';
import 'supabase_client.dart';

/// Service for payment lifecycle — create, track, update.
class PaymentService {
  final SupabaseClient _client = OcSupabase.client;

  /// Create a payment record for an order.
  Future<Payment> createPayment({
    required String orderId,
    required double amount,
    required String type, // 'cod' | 'card' | 'apple_pay'
  }) async {
    final data = await _client.from('payments').insert({
      'order_id': orderId,
      'amount': amount,
      'type': type,
      'status': type == 'cod' ? 'completed' : 'pending',
    }).select().single();
    return Payment.fromJson(data);
  }

  /// Get payment by order ID.
  Future<Payment?> getPaymentByOrderId(String orderId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();
    return data != null ? Payment.fromJson(data) : null;
  }

  /// Update payment status (e.g. after gateway callback).
  Future<void> updatePaymentStatus(String id, String status, {String? txnId}) async {
    final updates = <String, dynamic>{'status': status};
    if (txnId != null) updates['sadad_txn_id'] = txnId;
    await _client.from('payments').update(updates).eq('id', id);
  }
}
