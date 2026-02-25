import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/role_selector_screen.dart';
import 'screens/workshop/workshop_dashboard.dart';
import 'screens/workshop/find_customer_screen.dart';
import 'screens/workshop/create_diagnosis_screen.dart';
import 'screens/workshop/submit_bill_screen.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/driver/delivery_flow_screen.dart';
import 'screens/shop/shop_dashboard.dart';
import 'screens/shop/add_part_screen.dart';

final proRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/roles',
    routes: [
      GoRoute(path: '/roles', builder: (_, _) => const RoleSelectorScreen()),

      // Workshop routes
      GoRoute(path: '/workshop', builder: (_, _) => const WorkshopDashboard()),
      GoRoute(path: '/workshop/find-customer', builder: (_, _) => const FindCustomerScreen()),
      GoRoute(path: '/workshop/diagnosis', builder: (_, _) => const CreateDiagnosisScreen()),
      GoRoute(path: '/workshop/bill', builder: (_, _) => const SubmitBillScreen()),

      // Driver routes
      GoRoute(path: '/driver', builder: (_, _) => const DriverDashboard()),
      GoRoute(
        path: '/driver/delivery/:id',
        builder: (_, state) => DeliveryFlowScreen(deliveryId: state.pathParameters['id']!),
      ),

      // Shop routes
      GoRoute(path: '/shop', builder: (_, _) => const ShopDashboard()),
      GoRoute(path: '/shop/add-part', builder: (_, _) => const AddPartScreen()),
    ],
  );
});
