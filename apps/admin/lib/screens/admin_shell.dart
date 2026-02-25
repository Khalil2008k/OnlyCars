import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';
import 'dashboard_page.dart';
import 'users_page.dart';
import 'orders_page.dart';
import 'approvals_page.dart';
import 'settings_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final _pages = const [
    DashboardPage(),
    UsersPage(),
    OrdersPage(),
    ApprovalsPage(),
    SettingsPage(),
  ];

  final _navItems = const [
    {'icon': Icons.dashboard_rounded, 'label': 'لوحة التحكم'},
    {'icon': Icons.people_rounded, 'label': 'المستخدمون'},
    {'icon': Icons.receipt_long_rounded, 'label': 'الطلبات'},
    {'icon': Icons.verified_rounded, 'label': 'الموافقات'},
    {'icon': Icons.settings_rounded, 'label': 'الإعدادات'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: OcColors.surfaceCard,
              border: Border(left: BorderSide(color: OcColors.border)),
            ),
            child: Column(
              children: [
                // Logo header
                Container(
                  padding: const EdgeInsets.all(OcSpacing.xl),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: OcColors.primary,
                          borderRadius: BorderRadius.circular(OcRadius.md),
                        ),
                        child: const Center(child: Text('OC', style: TextStyle(
                          color: OcColors.textOnPrimary, fontWeight: FontWeight.w900, fontSize: 16,
                        ))),
                      ),
                      const SizedBox(width: OcSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OnlyCars', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text('لوحة الإدارة', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(color: OcColors.border, height: 1),

                // Nav items
                const SizedBox(height: OcSpacing.md),
                ...List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isSelected = i == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: OcSpacing.md, vertical: 2),
                    child: Material(
                      color: isSelected ? OcColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(OcRadius.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(OcRadius.md),
                        onTap: () => setState(() => _selectedIndex = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg, vertical: OcSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 20,
                                color: isSelected ? OcColors.primary : OcColors.textSecondary,
                              ),
                              const SizedBox(width: OcSpacing.md),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? OcColors.primary : OcColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Admin info
                Container(
                  padding: const EdgeInsets.all(OcSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: OcColors.primary.withValues(alpha: 0.2),
                        child: const Icon(Icons.person, size: 18, color: OcColors.primary),
                      ),
                      const SizedBox(width: OcSpacing.sm),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المسؤول', style: Theme.of(context).textTheme.labelMedium),
                          Text('admin@onlycars.qa', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Page content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
