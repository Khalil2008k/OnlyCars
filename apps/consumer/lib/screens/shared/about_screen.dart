import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

/// About / app info screen shown from settings
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: Padding(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: OcSpacing.xxl),

            // Logo
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [OcColors.primary, OcColors.secondary]),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: const Center(child: Text('OC', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(height: OcSpacing.xl),

            Text('OnlyCars', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('قطع غيار السيارات في قطر', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
            const SizedBox(height: OcSpacing.md),
            Text('الإصدار 1.0.0 (بناء 1)', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: OcColors.textSecondary)),

            const SizedBox(height: OcSpacing.xxl),
            const Divider(color: OcColors.border),
            const SizedBox(height: OcSpacing.lg),

            _InfoTile(icon: Icons.code_rounded, title: 'المطور', value: 'Khalil — OnlyCars Team'),
            _InfoTile(icon: Icons.email_rounded, title: 'البريد', value: 'support@onlycars.qa'),
            _InfoTile(icon: Icons.language_rounded, title: 'الموقع', value: 'www.onlycars.qa'),
            _InfoTile(icon: Icons.phone_rounded, title: 'الدعم', value: '+974 4000 0000'),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text('شروط الاستخدام')),
                const Text(' • ', style: TextStyle(color: OcColors.textSecondary)),
                TextButton(onPressed: () {}, child: const Text('سياسة الخصوصية')),
              ],
            ),
            const SizedBox(height: OcSpacing.md),
            Text('© 2026 OnlyCars. جميع الحقوق محفوظة.', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OcSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: OcColors.primary),
          const SizedBox(width: OcSpacing.md),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
