import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/home/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Placeholder(), // Will be HomeScreen
          ),
          GoRoute(
            path: '/workshops',
            builder: (_, __) => const Placeholder(), // Will be WorkshopMapScreen
          ),
          GoRoute(
            path: '/marketplace',
            builder: (_, __) => const Placeholder(), // Will be MarketplaceScreen
          ),
          GoRoute(
            path: '/orders',
            builder: (_, __) => const Placeholder(), // Will be OrdersScreen
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const Placeholder(), // Will be ProfileScreen
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuth = OcSupabase.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/profile-setup';

      if (!isAuth && !isAuthRoute) return '/login';
      return null;
    },
  );
});
