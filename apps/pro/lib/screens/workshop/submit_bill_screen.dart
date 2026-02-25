import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class SubmitBillScreen extends StatefulWidget {
  const SubmitBillScreen({super.key});

  @override
  State<SubmitBillScreen> createState() => _SubmitBillScreenState();
}

class _SubmitBillScreenState extends State<SubmitBillScreen> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;
  int _beforePhotos = 0;
  int _afterPhotos = 0;

  Future<void> _submit() async {
    if (_descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول')));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الفاتورة للعميل ✓')));
    context.pop();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('إنشاء فاتورة'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Work description
            Text('وصف العمل المنجز', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'اوصف الأعمال التي تم تنفيذها...')),

            const SizedBox(height: OcSpacing.xxl),

            // Before photos
            Text('صور قبل العمل', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            _photoRow(_beforePhotos, () => setState(() => _beforePhotos++)),

            const SizedBox(height: OcSpacing.xl),

            // After photos
            Text('صور بعد العمل', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            _photoRow(_afterPhotos, () => setState(() => _afterPhotos++)),

            const SizedBox(height: OcSpacing.xxl),

            // Labor amount
            Text('مبلغ العمالة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'المبلغ', suffixText: 'ر.ق', prefixIcon: Icon(Icons.payments_rounded)),
            ),

            const SizedBox(height: OcSpacing.xxxl),

            OcButton(label: 'إرسال الفاتورة', onPressed: _submit, isLoading: _isLoading, icon: Icons.receipt_long_rounded),
          ],
        ),
      ),
    );
  }

  Widget _photoRow(int count, VoidCallback onAdd) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: OcColors.surfaceLight, borderRadius: BorderRadius.circular(OcRadius.md), border: Border.all(color: OcColors.border)),
            child: const Icon(Icons.add_a_photo_rounded, color: OcColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: OcSpacing.sm),
        ...List.generate(count.clamp(0, 3), (_) => Container(
          width: 72, height: 72,
          margin: const EdgeInsets.only(left: OcSpacing.sm),
          decoration: BoxDecoration(color: OcColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(OcRadius.md)),
          child: const Icon(Icons.image, color: OcColors.primary, size: 22),
        )),
      ],
    );
  }
}
