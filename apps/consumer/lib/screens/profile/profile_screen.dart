import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final vehicleCount = ref.watch(vehiclesProvider).value?.length ?? 0;
    final orderCount = ref.watch(activeOrderCountProvider).value ?? 0;
    final favCount = ref.watch(favoritesCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OcSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: OcSpacing.xl),

              // Avatar + name
              userAsync.when(
                data: (user) => Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: OcColors.surfaceLight,
                      backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                      child: user?.avatarUrl == null
                          ? const Icon(Icons.person_rounded, size: 40, color: OcColors.textSecondary)
                          : null,
                    ),
                    const SizedBox(height: OcSpacing.md),
                    Text(
                      user?.name ?? 'مستخدم',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phone ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Icon(Icons.error_outline, size: 40),
              ),

              const SizedBox(height: OcSpacing.xxl),

              // Quick stats
              Row(
                children: [
                  _StatCard(label: 'سياراتي', value: '$vehicleCount', icon: Icons.directions_car_rounded, color: OcColors.info),
                  const SizedBox(width: OcSpacing.md),
                  _StatCard(label: 'طلبات نشطة', value: '$orderCount', icon: Icons.receipt_long_rounded, color: OcColors.secondary),
                  const SizedBox(width: OcSpacing.md),
                  _StatCard(label: 'المفضلة', value: '$favCount', icon: Icons.favorite_rounded, color: OcColors.error),
                ],
              ),

              const SizedBox(height: OcSpacing.xxl),

              // Menu sections
              _MenuSection(title: 'الحساب', items: [
                _MenuItem(icon: Icons.edit_rounded, label: 'تعديل الملف الشخصي', onTap: () => context.push('/profile/edit')),
                _MenuItem(icon: Icons.directions_car_rounded, label: 'سياراتي', onTap: () => context.push('/vehicle/add')),
                _MenuItem(icon: Icons.location_on_rounded, label: 'عناويني', onTap: () => context.push('/addresses')),
              ]),

              const SizedBox(height: OcSpacing.lg),

              _MenuSection(title: 'النشاط', items: [
                _MenuItem(icon: Icons.receipt_long_rounded, label: 'طلباتي', onTap: () => context.go('/orders')),
                _MenuItem(icon: Icons.favorite_rounded, label: 'المفضلة', onTap: () => context.push('/favorites')),
                _MenuItem(icon: Icons.build_circle_rounded, label: 'سجل الصيانة', onTap: () => context.push('/maintenance-log')),
                _MenuItem(icon: Icons.star_rounded, label: 'تقييماتي', onTap: () => context.push('/my-reviews')),
              ]),

              const SizedBox(height: OcSpacing.lg),

              _MenuSection(title: 'الإعدادات', items: [
                _MenuItem(icon: Icons.notifications_rounded, label: 'إعدادات الإشعارات', onTap: () => context.push('/notification-settings')),
                _MenuItem(icon: Icons.language_rounded, label: 'اللغة', onTap: () => context.push('/settings/language')),
                _MenuItem(icon: Icons.info_outline_rounded, label: 'حول التطبيق', onTap: () => context.push('/about')),
              ]),

              const SizedBox(height: OcSpacing.xxl),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('تسجيل الخروج'),
                        content: const Text('هل تريد تسجيل الخروج؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خروج', style: TextStyle(color: OcColors.error))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final auth = AuthService();
                      await auth.signOut();
                      if (context.mounted) context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: OcColors.error),
                  label: const Text('تسجيل الخروج', style: TextStyle(color: OcColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OcColors.error),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),

              const SizedBox(height: OcSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.md),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: OcSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.textSecondary)),
        const SizedBox(height: OcSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: OcColors.surfaceCard,
            borderRadius: BorderRadius.circular(OcRadius.lg),
            border: Border.all(color: OcColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1) const Divider(height: 1, indent: 52, color: OcColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: OcColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(OcRadius.sm),
        ),
        child: Icon(icon, size: 18, color: OcColors.primary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded, color: OcColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
