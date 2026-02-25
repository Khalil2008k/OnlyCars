import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OcSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: OcColors.secondary,
                    borderRadius: BorderRadius.circular(OcRadius.lg),
                  ),
                  child: const Center(
                    child: Text('PRO', style: TextStyle(
                      color: OcColors.textOnPrimary, fontSize: 28, fontWeight: FontWeight.w900,
                    )),
                  ),
                ),
              ),
              const SizedBox(height: OcSpacing.xl),

              Text(
                'OnlyCars Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OcSpacing.sm),
              Text(
                'اختر نوع حسابك',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Role cards
              _RoleCard(
                icon: Icons.build_rounded,
                title: 'ورشة',
                subtitle: 'فحص السيارات وتقديم الفواتير',
                color: OcColors.primary,
                onTap: () => context.go('/workshop'),
              ),
              const SizedBox(height: OcSpacing.lg),

              _RoleCard(
                icon: Icons.delivery_dining,
                title: 'سائق',
                subtitle: 'توصيل قطع الغيار بين المتاجر والورش',
                color: OcColors.secondary,
                onTap: () => context.go('/driver'),
              ),
              const SizedBox(height: OcSpacing.lg),

              _RoleCard(
                icon: Icons.store_rounded,
                title: 'متجر',
                subtitle: 'بيع قطع الغيار وإدارة المخزون',
                color: OcColors.warning,
                onTap: () => context.go('/shop'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.xl),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.xl),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(OcRadius.lg),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: OcSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
