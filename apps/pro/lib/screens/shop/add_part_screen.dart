import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class AddPartScreen extends StatefulWidget {
  const AddPartScreen({super.key});

  @override
  State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _nameArCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _condition = 'oem';
  int _photoCount = 0;
  bool _isLoading = false;

  // Mock compatible vehicles
  final Map<String, bool> _compatibility = {
    'تويوتا كامري 2020-2024': false,
    'تويوتا لاندكروزر 2022-2024': false,
    'نيسان باترول 2020-2024': false,
    'هوندا أكورد 2021-2024': false,
  };

  Future<void> _save() async {
    if (_nameArCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة الحقول المطلوبة')));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة القطعة بنجاح ✓')));
    context.pop();
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('إضافة قطعة'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photos
            Text('صور القطعة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Row(children: [
              GestureDetector(
                onTap: () => setState(() => _photoCount++),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: OcColors.surfaceLight, borderRadius: BorderRadius.circular(OcRadius.md), border: Border.all(color: OcColors.border)),
                  child: const Icon(Icons.add_a_photo_rounded, color: OcColors.primary),
                ),
              ),
              const SizedBox(width: OcSpacing.sm),
              ...List.generate(_photoCount.clamp(0, 4), (_) => Container(
                width: 80, height: 80,
                margin: const EdgeInsets.only(left: OcSpacing.sm),
                decoration: BoxDecoration(color: OcColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(OcRadius.md)),
                child: const Icon(Icons.image, color: OcColors.primary),
              )),
            ]),

            const SizedBox(height: OcSpacing.xxl),

            // Name AR
            TextField(controller: _nameArCtrl, decoration: const InputDecoration(labelText: 'اسم القطعة (عربي) *', hintText: 'مثال: فلتر زيت')),
            const SizedBox(height: OcSpacing.lg),

            // Name EN
            TextField(controller: _nameEnCtrl, decoration: const InputDecoration(labelText: 'Part Name (English)', hintText: 'e.g. Oil Filter')),
            const SizedBox(height: OcSpacing.lg),

            // Price + stock row
            Row(children: [
              Expanded(child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر *', suffixText: 'ر.ق'))),
              const SizedBox(width: OcSpacing.md),
              Expanded(child: TextField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية', hintText: '1'))),
            ]),

            const SizedBox(height: OcSpacing.xxl),

            // Condition
            Text('الحالة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Row(children: [
              _ConditionChip(label: 'أصلي (OEM)', value: 'oem', selected: _condition, onTap: (v) => setState(() => _condition = v)),
              const SizedBox(width: OcSpacing.sm),
              _ConditionChip(label: 'بديل', value: 'aftermarket', selected: _condition, onTap: (v) => setState(() => _condition = v)),
              const SizedBox(width: OcSpacing.sm),
              _ConditionChip(label: 'مستعمل', value: 'used', selected: _condition, onTap: (v) => setState(() => _condition = v)),
            ]),

            const SizedBox(height: OcSpacing.xxl),

            // Compatibility
            Text('التوافق مع السيارات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            ..._compatibility.entries.map((e) => CheckboxListTile(
              value: e.value,
              title: Text(e.key, style: const TextStyle(fontSize: 14)),
              onChanged: (v) => setState(() => _compatibility[e.key] = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            )),

            const SizedBox(height: OcSpacing.xxl),

            OcButton(label: 'حفظ القطعة', onPressed: _save, isLoading: _isLoading, icon: Icons.save_rounded),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _ConditionChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? OcColors.primary : OcColors.surfaceLight,
          borderRadius: BorderRadius.circular(OcRadius.md),
          border: Border.all(color: isSelected ? OcColors.primary : OcColors.border),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? OcColors.textOnPrimary : OcColors.textPrimary,
          fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }
}
