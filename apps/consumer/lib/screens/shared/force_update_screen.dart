import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

/// Force update dialog — shown when app version is below minimum
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OcSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Update icon
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: OcColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update_rounded, size: 60, color: OcColors.primary),
              ),
              const SizedBox(height: OcSpacing.xxl),

              Text(
                'تحديث مطلوب',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OcSpacing.md),

              Text(
                'يتوفر إصدار جديد من التطبيق يحتوي على تحسينات مهمة. يرجى التحديث للمتابعة.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Update button
              SizedBox(
                width: double.infinity,
                child: OcButton(
                  label: 'تحديث الآن',
                  onPressed: () {
                    // TODO: Open Play Store / App Store link
                    // final url = Platform.isAndroid ? 'market://details?id=com.onlycars.app' : 'itms-apps://...';
                    // launchUrl(Uri.parse(url));
                  },
                  icon: Icons.download_rounded,
                ),
              ),
              const SizedBox(height: OcSpacing.md),

              // App version
              Text('الإصدار الحالي: 1.0.0', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
              const SizedBox(height: OcSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Version check utility
class AppVersionService {
  static const currentVersion = '1.0.0';

  /// Check if force update is needed
  /// Fetches min_app_version from platform_settings table
  static Future<bool> needsForceUpdate() async {
    try {
      // In production, fetch from Supabase
      // final settings = await OcSupabase.client.from('platform_settings').select().single();
      // final minVersion = settings['min_app_version'] as String;
      // return _compareVersions(currentVersion, minVersion) < 0;
      return false;
    } catch (_) {
      return false;
    }
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final a = i < parts1.length ? parts1[i] : 0;
      final b = i < parts2.length ? parts2[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }
}
