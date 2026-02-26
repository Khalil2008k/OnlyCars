import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';

// ===== SERVICE PROVIDERS =====
final authServiceProvider = Provider((_) => AuthService());
final userServiceProvider = Provider((_) => UserService());
final workshopServiceProvider = Provider((_) => WorkshopService());
final partsServiceProvider = Provider((_) => PartsService());
final orderServiceProvider = Provider((_) => OrderService());
final chatServiceProvider = Provider((_) => ChatService());
final notificationServiceProvider = Provider((_) => NotificationService());
final diagnosisServiceProvider = Provider((_) => DiagnosisService());
final paymentServiceProvider = Provider((_) => PaymentService());
final billServiceProvider = Provider((_) => BillService());
final favoritesServiceProvider = Provider((_) => FavoritesService());

// ===== AUTH STATE =====
final authStateProvider = StreamProvider<bool>((ref) {
  final auth = ref.read(authServiceProvider);
  return auth.onAuthStateChange.map((user) => user != null);
});

// ===== USER PROFILE =====
final userProfileProvider = FutureProvider<OcUser?>((ref) async {
  final service = ref.read(userServiceProvider);
  return await service.getProfile();
});

// ===== USER ROLES =====
final userRolesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(authServiceProvider);
  return await service.getUserRoles();
});

// ===== VEHICLES =====
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final service = ref.read(userServiceProvider);
  return await service.getVehicles();
});

// ===== ADDRESSES =====
final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final service = ref.read(userServiceProvider);
  return await service.getAddresses();
});

// ===== WORKSHOPS =====
final workshopsProvider = FutureProvider<List<WorkshopProfile>>((ref) async {
  final service = ref.read(workshopServiceProvider);
  return await service.getWorkshops();
});

// ===== PART CATEGORIES =====
final partCategoriesProvider = FutureProvider<List<PartCategory>>((ref) async {
  final service = ref.read(partsServiceProvider);
  return await service.getCategories();
});

// ===== ORDERS =====
final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final service = ref.read(orderServiceProvider);
  return await service.getMyOrders();
});

final activeOrderCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(orderServiceProvider);
  return await service.getActiveOrderCount();
});

// ===== CHAT ROOMS =====
final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final service = ref.read(chatServiceProvider);
  return await service.getRooms();
});

// ===== NOTIFICATIONS =====
final notificationsProvider = FutureProvider<List<OcNotification>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.getNotifications();
});

/// Real-time stream of all notifications — used on notifications screen.
final notificationsStreamProvider = StreamProvider<List<OcNotification>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return service.streamNotifications();
});

/// Real-time unread count — badge auto-updates without polling.
final unreadNotifCountProvider = StreamProvider<int>((ref) {
  final service = ref.read(notificationServiceProvider);
  return service.streamUnreadCount();
});

// ===== DIAGNOSIS REPORTS =====
final diagnosisReportsProvider = FutureProvider<List<DiagnosisReport>>((ref) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.getConsumerReports();
});

// ===== ORDER STREAM (real-time) =====
final orderStreamProvider = StreamProvider.family<Order?, String>((ref, orderId) {
  final service = ref.read(orderServiceProvider);
  return service.streamOrder(orderId);
});

// ===== PARTS (filtered by category) =====
final partsProvider = FutureProvider.family<List<Part>, String?>((ref, categoryId) async {
  final service = ref.read(partsServiceProvider);
  return await service.getParts(categoryId: categoryId);
});

// ===== PART DETAIL =====
final partDetailProvider = FutureProvider.family<Part?, String>((ref, partId) async {
  final service = ref.read(partsServiceProvider);
  return await service.getPartById(partId);
});

// ===== FAVORITES =====
final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(favoritesServiceProvider);
  return await service.getFavorites();
});

final favoritesCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(favoritesServiceProvider);
  return await service.getFavoritesCount();
});

// ===== MY REVIEWS =====
final myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final service = ref.read(workshopServiceProvider);
  return await service.getMyReviews();
});

// ===== CART =====
/// Represents one item in the cart with full Part data and quantity.
class CartItem {
  final Part part;
  int quantity;
  CartItem({required this.part, this.quantity = 1});
}

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() => {};

  void add(Part part) {
    final existing = state[part.id];
    if (existing != null) {
      state = {
        ...state,
        part.id: CartItem(part: part, quantity: existing.quantity + 1),
      };
    } else {
      state = {...state, part.id: CartItem(part: part)};
    }
  }

  void remove(String partId) {
    final updated = {...state};
    final existing = updated[partId];
    if (existing == null) return;
    if (existing.quantity > 1) {
      updated[partId] = CartItem(part: existing.part, quantity: existing.quantity - 1);
    } else {
      updated.remove(partId);
    }
    state = updated;
  }

  void clear() => state = {};

  int get totalItems => state.values.fold(0, (a, b) => a + b.quantity);

  double get totalPrice =>
      state.values.fold(0.0, (a, b) => a + b.part.price * b.quantity);

  /// Build items list for OrderService.createOrder()
  List<Map<String, dynamic>> toOrderItems() {
    return state.values.map((ci) => <String, dynamic>{
      'part_id': ci.part.id,
      'shop_id': ci.part.shopId,
      'quantity': ci.quantity,
      'unit_price': ci.part.price,
    }).toList();
  }
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(CartNotifier.new);
