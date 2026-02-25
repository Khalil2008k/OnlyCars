import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OcSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإعدادات', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: OcSpacing.xxl),

          // Platform config
          _Section(title: 'إعدادات المنصة', children: [
            _SettingRow(label: 'نسبة العمولة', value: '15%', icon: Icons.percent),
            _SettingRow(label: 'رسوم التوصيل الافتراضية', value: '25 ر.ق', icon: Icons.local_shipping),
            _SettingRow(label: 'الحد الأدنى للطلب', value: '50 ر.ق', icon: Icons.shopping_cart),
            _SettingRow(label: 'الحد الأقصى لمسافة التوصيل', value: '30 كم', icon: Icons.map),
          ]),

          const SizedBox(height: OcSpacing.xxl),

          _Section(title: 'التطبيق', children: [
            _SettingRow(label: 'الإصدار الأدنى المطلوب', value: '1.0.0', icon: Icons.system_update),
            _SettingRow(label: 'وضع الصيانة', value: 'معطل', icon: Icons.engineering),
          ]),

          const SizedBox(height: OcSpacing.xxl),

          _Section(title: 'مناطق التوصيل', children: [
            _SettingRow(label: 'الدوحة', value: '15 ر.ق', icon: Icons.location_on),
            _SettingRow(label: 'الوكرة', value: '25 ر.ق', icon: Icons.location_on),
            _SettingRow(label: 'الخور', value: '35 ر.ق', icon: Icons.location_on),
            _SettingRow(label: 'الريان', value: '20 ر.ق', icon: Icons.location_on),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: OcSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: OcColors.surfaceCard,
            borderRadius: BorderRadius.circular(OcRadius.lg),
            border: Border.all(color: OcColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SettingRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.xl, vertical: OcSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: OcColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: OcColors.textSecondary),
          const SizedBox(width: OcSpacing.md),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.primary)),
          const SizedBox(width: OcSpacing.sm),
          const Icon(Icons.edit_outlined, size: 16, color: OcColors.textSecondary),
        ],
      ),
    );
  }
}
