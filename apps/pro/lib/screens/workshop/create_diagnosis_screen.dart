import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class CreateDiagnosisScreen extends StatefulWidget {
  const CreateDiagnosisScreen({super.key});

  @override
  State<CreateDiagnosisScreen> createState() => _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends State<CreateDiagnosisScreen> {
  final _issueCtrl = TextEditingController();
  final _laborCtrl = TextEditingController();
  final List<Map<String, String>> _parts = [];
  bool _isLoading = false;
  int _photoCount = 0;

  void _addPart() {
    setState(() {
      _parts.add({'name': '', 'qty': '1'});
    });
  }

  Future<void> _submit() async {
    if (_issueCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى وصف المشكلة')));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال التقرير للعميل ✓')));
    context.pop();
    context.pop(); // Back to dashboard
  }

  @override
  void dispose() {
    _issueCtrl.dispose();
    _laborCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('تقرير الفحص'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle info
            Container(
              padding: const EdgeInsets.all(OcSpacing.lg),
              decoration: BoxDecoration(color: OcColors.surfaceCard, borderRadius: BorderRadius.circular(OcRadius.lg), border: Border.all(color: OcColors.border)),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: OcColors.primary),
                  const SizedBox(width: OcSpacing.md),
                  Text('تويوتا كامري 2022', style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  Text('أحمد محمد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Issue description
            Text('وصف المشكلة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            TextField(
              controller: _issueCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'اوصف المشكلة بالتفصيل...'),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Photos
            Text('صور الفحص', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _photoCount++),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: OcColors.surfaceLight,
                      borderRadius: BorderRadius.circular(OcRadius.md),
                      border: Border.all(color: OcColors.border, style: BorderStyle.solid),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: OcColors.primary),
                  ),
                ),
                const SizedBox(width: OcSpacing.md),
                ...List.generate(_photoCount.clamp(0, 4), (_) => Container(
                  width: 80, height: 80,
                  margin: const EdgeInsets.only(left: OcSpacing.sm),
                  decoration: BoxDecoration(
                    color: OcColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(OcRadius.md),
                  ),
                  child: const Icon(Icons.image, color: OcColors.primary),
                )),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Required parts
            Row(
              children: [
                Text('القطع المطلوبة', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('إضافة'), onPressed: _addPart),
              ],
            ),
            const SizedBox(height: OcSpacing.sm),
            ...List.generate(_parts.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: OcSpacing.sm),
              child: Row(
                children: [
                  Expanded(flex: 3, child: TextField(decoration: InputDecoration(hintText: 'اسم القطعة ${i + 1}'))),
                  const SizedBox(width: OcSpacing.sm),
                  Expanded(child: TextField(decoration: const InputDecoration(hintText: 'الكمية'), keyboardType: TextInputType.number)),
                  IconButton(icon: const Icon(Icons.close, size: 18, color: OcColors.error), onPressed: () => setState(() => _parts.removeAt(i))),
                ],
              ),
            )),

            const SizedBox(height: OcSpacing.xxl),

            // Labor quote
            Text('تكلفة العمالة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            TextField(
              controller: _laborCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'المبلغ بالريال القطري', suffixText: 'ر.ق'),
            ),

            const SizedBox(height: OcSpacing.xxxl),

            OcButton(label: 'إرسال التقرير للعميل', onPressed: _submit, isLoading: _isLoading, icon: Icons.send_rounded),
          ],
        ),
      ),
    );
  }
}
