import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: OcColors.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 44, color: OcColors.primary),
            ),
            const SizedBox(height: OcSpacing.md),
            Text('ورشة الاصالة', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('+974 5000 1234', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),

            const SizedBox(height: OcSpacing.xl),

            // Verified badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: OcColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(OcRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 18, color: OcColors.success),
                  const SizedBox(width: 6),
                  Text('حساب موثق', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: OcColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Stats
            Row(
              children: [
                _Stat(label: 'التقييم', value: '4.8 ⭐'),
                const SizedBox(width: OcSpacing.md),
                _Stat(label: 'الطلبات', value: '234'),
                const SizedBox(width: OcSpacing.md),
                _Stat(label: 'الشهر', value: '1.2K ر.ق'),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Menu items
            _MenuItem(icon: Icons.account_balance_wallet_rounded, title: 'الأرباح', onTap: () => context.push('/earnings')),
            _MenuItem(icon: Icons.notifications_rounded, title: 'الإشعارات', onTap: () {}),
            _MenuItem(icon: Icons.description_rounded, title: 'المستندات', onTap: () {}),
            _MenuItem(icon: Icons.settings_rounded, title: 'الإعدادات', onTap: () {}),
            _MenuItem(icon: Icons.help_outline_rounded, title: 'المساعدة', onTap: () {}),
            _MenuItem(icon: Icons.logout_rounded, title: 'تسجيل الخروج', onTap: () => context.go('/roles'), isDestructive: true),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuItem({required this.icon, required this.title, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: OcSpacing.sm),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.lg)),
        tileColor: OcColors.surfaceCard,
        leading: Icon(icon, color: isDestructive ? OcColors.error : OcColors.primary),
        title: Text(title, style: TextStyle(color: isDestructive ? OcColors.error : null)),
        trailing: const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
      ),
    );
  }
}
