import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

/// Bottom navigation shell for the consumer app.
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  static final _tabs = [
    (icon: Icons.home_rounded, label: 'الرئيسية', path: '/home'),
    (icon: Icons.build_circle_rounded, label: 'الورش', path: '/workshops'),
    (icon: Icons.shopping_bag_rounded, label: 'سوق القطع', path: '/marketplace'),
    (icon: Icons.receipt_long_rounded, label: 'الطلبات', path: '/orders'),
    (icon: Icons.person_rounded, label: 'حسابي', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: OcColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex >= 0 ? currentIndex : 0,
          onTap: (index) => context.go(_tabs[index].path),
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    label: t.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
