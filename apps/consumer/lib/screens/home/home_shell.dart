import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

/// Bottom navigation shell — floating dark pill nav bar.
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  static final _tabs = [
    (
      item: OcNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'الرئيسية',
      ),
      path: '/home',
    ),
    (
      item: OcNavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map_rounded,
        label: 'الخريطة',
      ),
      path: '/workshops',
    ),
    (
      item: OcNavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'القطع',
      ),
      path: '/marketplace',
    ),
    (
      item: OcNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'الطلبات',
      ),
      path: '/orders',
    ),
    (
      item: OcNavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'المحادثات',
      ),
      path: '/chat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: OcFloatingNavBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        onTap: (index) => context.go(_tabs[index].path),
        items: _tabs.map((t) => t.item).toList(),
      ),
    );
  }
}
