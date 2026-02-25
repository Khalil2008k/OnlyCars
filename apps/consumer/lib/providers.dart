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

// ===== AUTH STATE =====
final authStateProvider = StreamProvider<bool>((ref) {
  final auth = ref.read(authServiceProvider);
  return auth.onAuthStateChange.map((state) => state.session != null);
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

final unreadNotifCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.getUnreadCount();
});

// ===== DIAGNOSIS REPORTS =====
final diagnosisReportsProvider = FutureProvider<List<DiagnosisReport>>((ref) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.getConsumerReports();
});

// ===== PARTS (filtered by category) =====
final partsProvider = FutureProvider.family<List<Part>, String?>((ref, categoryId) async {
  final service = ref.read(partsServiceProvider);
  return await service.getParts(categoryId: categoryId);
});

// ===== CART =====
class CartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void add(String partId) {
    state = {...state, partId: (state[partId] ?? 0) + 1};
  }

  void remove(String partId) {
    final updated = {...state};
    if ((updated[partId] ?? 0) > 1) {
      updated[partId] = updated[partId]! - 1;
    } else {
      updated.remove(partId);
    }
    state = updated;
  }

  void clear() => state = {};

  int get totalItems => state.values.fold(0, (a, b) => a + b);
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, int>>(CartNotifier.new);
