import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class WorkshopBillScreen extends StatelessWidget {
  final String billId;
  const WorkshopBillScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('فاتورة الورشة'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop info
            Container(
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: OcColors.primary.withValues(alpha: 0.2),
                    child: const Icon(Icons.build_rounded, color: OcColors.primary),
                  ),
                  const SizedBox(width: OcSpacing.lg),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ورشة الاصالة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('تويوتا كامري 2022 — أحمد محمد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                    ],
                  )),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Work description
            Text('وصف العمل', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OcSpacing.lg),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Text(
                'تم تغيير فلتر الزيت وفلتر الهواء وتغيير زيت المحرك. تم فحص جميع السوائل والفرامل والإطارات.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Before/After photos
            Text('صور قبل وبعد', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Row(
              children: [
                Expanded(child: _PhotoCard(label: 'قبل')),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _PhotoCard(label: 'بعد')),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Amount
            Container(
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [OcColors.primary, OcColors.secondary]),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مبلغ العمالة', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.textOnPrimary)),
                  Text('150 ر.ق', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: OcColors.textOnPrimary, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OcButton(
                    label: 'الموافقة والدفع',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الموافقة على الفاتورة ✓')));
                      context.pop();
                    },
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: OcSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('نزاع'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: OcColors.error,
                      side: const BorderSide(color: OcColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String label;
  const _PhotoCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: OcColors.surfaceLight,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 32, color: OcColors.textSecondary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
