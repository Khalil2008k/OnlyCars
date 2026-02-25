import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/role_selector_screen.dart';
import 'screens/workshop/workshop_dashboard.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/shop/shop_dashboard.dart';

final proRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/roles',
    routes: [
      GoRoute(path: '/roles', builder: (_, _) => const RoleSelectorScreen()),
      GoRoute(path: '/workshop', builder: (_, _) => const WorkshopDashboard()),
      GoRoute(path: '/driver', builder: (_, _) => const DriverDashboard()),
      GoRoute(path: '/shop', builder: (_, _) => const ShopDashboard()),
    ],
  );
});
