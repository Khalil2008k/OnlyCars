import 'package:flutter/foundation.dart';

/// Analytics service — wraps Firebase Analytics + custom events
/// In production, replace with firebase_analytics package
class AnalyticsService {
  static bool _initialized = false;

  static Future<void> init() async {
    _initialized = true;
    debugPrint('[Analytics] Initialized');
  }

  /// Track screen view
  static void screenView(String screenName) {
    if (!_initialized) return;
    debugPrint('[Analytics] Screen: $screenName');
    // await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  /// Track custom event
  static void event(String name, {Map<String, dynamic>? params}) {
    if (!_initialized) return;
    debugPrint('[Analytics] Event: $name ${params ?? ''}');
    // await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }

  // ── Business Events ──────────────────────────────────────

  static void login(String method) => event('login', params: {'method': method});
  static void signUp() => event('sign_up');
  static void addToCart(String partId, double price) => event('add_to_cart', params: {'part_id': partId, 'price': price});
  static void removeFromCart(String partId) => event('remove_from_cart', params: {'part_id': partId});
  static void beginCheckout(double total) => event('begin_checkout', params: {'value': total, 'currency': 'QAR'});
  static void purchase(String orderId, double total) => event('purchase', params: {'order_id': orderId, 'value': total, 'currency': 'QAR'});
  static void viewPart(String partId) => event('view_item', params: {'item_id': partId});
  static void viewShop(String shopId) => event('view_shop', params: {'shop_id': shopId});
  static void viewWorkshop(String workshopId) => event('view_workshop', params: {'workshop_id': workshopId});
  static void searchParts(String query) => event('search', params: {'search_term': query});
  static void rateWorkshop(String workshopId, int stars) => event('rate', params: {'workshop_id': workshopId, 'rating': stars});
  static void startChat(String roomId) => event('start_chat', params: {'room_id': roomId});
  static void addVehicle(String make, String model) => event('add_vehicle', params: {'make': make, 'model': model});

  // ── Pro Events ────────────────────────────────────────────

  static void selectRole(String role) => event('select_role', params: {'role': role});
  static void acceptDelivery(String deliveryId) => event('accept_delivery', params: {'delivery_id': deliveryId});
  static void completeDelivery(String deliveryId) => event('complete_delivery', params: {'delivery_id': deliveryId});
  static void submitDiagnosis(String diagnosisId) => event('submit_diagnosis', params: {'diagnosis_id': diagnosisId});
  static void submitBill(String billId, double amount) => event('submit_bill', params: {'bill_id': billId, 'amount': amount});
  static void addPart(String partId, double price) => event('add_part', params: {'part_id': partId, 'price': price});

  // ── Admin Events ──────────────────────────────────────────

  static void approveProvider(String providerId) => event('approve_provider', params: {'provider_id': providerId});
  static void rejectProvider(String providerId) => event('reject_provider', params: {'provider_id': providerId});
  static void suspendUser(String userId) => event('suspend_user', params: {'user_id': userId});

  /// Set user properties
  static void setUserId(String userId) {
    debugPrint('[Analytics] UserID: $userId');
    // await FirebaseAnalytics.instance.setUserId(id: userId);
  }

  static void setUserRole(String role) {
    debugPrint('[Analytics] Role: $role');
    // await FirebaseAnalytics.instance.setUserProperty(name: 'role', value: role);
  }
}
