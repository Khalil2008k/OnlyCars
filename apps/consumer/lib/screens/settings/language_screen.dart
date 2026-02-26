import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String _selected = 'ar';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Read current language from profile
    ref.listenManual(userProfileProvider, (_, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          setState(() => _selected = user.lang);
        }
      });
    });
  }

  Future<void> _save(String lang) async {
    setState(() { _selected = lang; _isSaving = true; });
    try {
      final service = ref.read(userServiceProvider);
      await service.updateProfile(lang: lang);
      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير اللغة')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('اللغة')),
      body: Padding(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          children: [
            _LangOption(
              label: 'العربية',
              subtitle: 'Arabic',
              flag: '🇶🇦',
              isSelected: _selected == 'ar',
              onTap: () => _save('ar'),
            ),
            const SizedBox(height: OcSpacing.md),
            _LangOption(
              label: 'English',
              subtitle: 'الإنجليزية',
              flag: '🇬🇧',
              isSelected: _selected == 'en',
              onTap: () => _save('en'),
            ),
            if (_isSaving) ...[
              const SizedBox(height: OcSpacing.xl),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label, subtitle, flag;
  final bool isSelected;
  final VoidCallback onTap;
  const _LangOption({required this.label, required this.subtitle, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: isSelected ? OcColors.primary : OcColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: OcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: OcColors.primary),
          ],
        ),
      ),
    );
  }
}
