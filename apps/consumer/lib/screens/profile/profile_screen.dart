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
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (user) => ListView(
            padding: const EdgeInsets.fromLTRB(
              OcSpacing.page, OcSpacing.lg, OcSpacing.page,
              OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.xl,
            ),
            children: [
              const SizedBox(height: OcSpacing.md),

              // Avatar + Name + Phone
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: OcColors.accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: OcColors.accent, width: 2),
                      ),
                      child: user?.avatarUrl != null
                          ? ClipOval(child: Image.network(user!.avatarUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.person_rounded, size: 40, color: OcColors.accent),
                    ),
                    const SizedBox(height: OcSpacing.md),
                    Text(
                      user?.name ?? 'مستخدم OnlyCars',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phone ?? '',
                      style: const TextStyle(fontSize: 14, color: OcColors.textSecondary),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OcSpacing.xxl),

              // Quick stats row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OcColors.surfaceCard,
                  borderRadius: BorderRadius.circular(OcRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(icon: Icons.directions_car_rounded, count: '0', label: 'سيارات'),
                    ),
                    Container(width: 1, height: 40, color: OcColors.border),
                    Expanded(
                      child: _StatItem(icon: Icons.receipt_long_rounded, count: '0', label: 'طلبات'),
                    ),
                    Container(width: 1, height: 40, color: OcColors.border),
                    Expanded(
                      child: _StatItem(icon: Icons.favorite_rounded, count: '0', label: 'مفضلة'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OcSpacing.xl),

              // Account section
              _SectionLabel(label: 'الحساب'),
              const SizedBox(height: OcSpacing.sm),
              _MenuItem(icon: Icons.person_outline_rounded, label: 'تعديل الملف الشخصي', onTap: () {}),
              _MenuItem(icon: Icons.directions_car_rounded, label: 'سياراتي', onTap: () {}),
              _MenuItem(icon: Icons.location_on_outlined, label: 'عناويني', onTap: () {}),
              _MenuItem(icon: Icons.favorite_outline_rounded, label: 'المفضلة', onTap: () {}),

              const SizedBox(height: OcSpacing.lg),

              // Orders & activity
              _SectionLabel(label: 'الطلبات والنشاط'),
              const SizedBox(height: OcSpacing.sm),
              _MenuItem(icon: Icons.receipt_long_outlined, label: 'طلباتي', onTap: () => context.push('/orders')),
              _MenuItem(icon: Icons.build_outlined, label: 'سجل الصيانة', onTap: () {}),
              _MenuItem(icon: Icons.star_outline_rounded, label: 'تقييماتي', onTap: () {}),

              const SizedBox(height: OcSpacing.lg),

              // Settings
              _SectionLabel(label: 'الإعدادات'),
              const SizedBox(height: OcSpacing.sm),
              _MenuItem(
                icon: Icons.language_rounded,
                label: 'اللغة',
                trailing: user?.lang == 'ar' ? 'العربية' : 'English',
                onTap: () {},
              ),
              _MenuItem(icon: Icons.notifications_outlined, label: 'الإشعارات', onTap: () {}),
              _MenuItem(icon: Icons.help_outline_rounded, label: 'المساعدة والدعم', onTap: () {}),
              _MenuItem(icon: Icons.info_outline_rounded, label: 'عن التطبيق', onTap: () => context.push('/about')),

              const SizedBox(height: OcSpacing.lg),

              // Logout
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                color: OcColors.error,
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) context.go('/login');
                },
              ),

              const SizedBox(height: OcSpacing.lg),

              // App branding footer
              Center(
                child: Column(
                  children: [
                    const OcLogo(size: 40, assetPath: OcLogoAssets.horizontal),
                    const SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 11, color: OcColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: OcColors.accent)),
          error: (_, __) => OcErrorState(
            message: 'تعذر تحميل الملف الشخصي',
            onRetry: () => ref.invalidate(userProfileProvider),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OcColors.textMuted),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _StatItem({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: OcColors.accent, size: 22),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: OcColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: OcColors.textSecondary)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, this.trailing, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? OcColors.textPrimary;
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: (color ?? OcColors.accent).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(OcRadius.sm),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(label, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: trailing != null
          ? Text(trailing!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary))
          : Icon(Icons.chevron_left_rounded, color: OcColors.textMuted, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.md)),
    );
  }
}
