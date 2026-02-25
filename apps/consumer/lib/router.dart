import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/workshops/workshop_list_screen.dart';
import 'screens/workshops/workshop_detail_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/orders/rate_workshop_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/marketplace/cart_screen.dart';
import 'screens/vehicles/vehicle_add_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),

      // Detail screens (outside shell — no bottom nav)
      GoRoute(
        path: '/workshop/:id',
        builder: (_, state) => WorkshopDetailScreen(workshopId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/vehicle/add', builder: (_, _) => const VehicleAddScreen()),
      GoRoute(
        path: '/order/:id',
        builder: (_, state) => OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/rate/:id',
        builder: (_, state) => RateWorkshopScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatDetailScreen(roomId: state.pathParameters['id']!),
      ),

      // Main shell (with bottom nav)
      ShellRoute(
        builder: (_, _, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/workshops', builder: (_, _) => const WorkshopListScreen()),
          GoRoute(path: '/marketplace', builder: (_, _) => const MarketplaceScreen()),
          GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
    ],
    redirect: (context, state) {
      // TODO: Re-enable auth guard for production
      // final isAuth = OcSupabase.isAuthenticated;
      // final authRoutes = ['/login', '/otp', '/splash', '/profile-setup'];
      // if (!isAuth && !authRoutes.contains(state.matchedLocation)) return '/login';
      return null;
    },
  );
});
