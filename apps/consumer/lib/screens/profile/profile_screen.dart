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
      appBar: AppBar(title: const Text('حسابي')),
      body: profileAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(OcSpacing.lg),
          children: [
            // Avatar + Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: OcColors.surfaceLight,
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null ? const Icon(Icons.person_rounded, size: 40, color: OcColors.textSecondary) : null,
                  ),
                  const SizedBox(height: OcSpacing.md),
                  Text(user?.name ?? '—', style: Theme.of(context).textTheme.headlineMedium),
                  Text(user?.phone ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: OcSpacing.xxl),

            _MenuItem(icon: Icons.directions_car_rounded, label: 'سياراتي', onTap: () {}),
            _MenuItem(icon: Icons.location_on_rounded, label: 'عناويني', onTap: () {}),
            _MenuItem(icon: Icons.health_and_safety_rounded, label: 'سجل صحة السيارة', onTap: () {}),
            _MenuItem(icon: Icons.language_rounded, label: 'اللغة', trailing: user?.lang == 'ar' ? 'العربية' : 'English', onTap: () {}),
            const Divider(height: 32),
            _MenuItem(icon: Icons.help_outline_rounded, label: 'المساعدة والدعم', onTap: () {}),
            _MenuItem(icon: Icons.info_outline_rounded, label: 'عن التطبيق', onTap: () {}),
            const Divider(height: 32),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'تسجيل الخروج',
              color: OcColors.error,
              onTap: () async {
                await AuthService().signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل الملف الشخصي', onRetry: () => ref.invalidate(userProfileProvider)),
      ),
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
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c)),
      trailing: trailing != null
          ? Text(trailing!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary))
          : const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.md)),
    );
  }
}
