import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class DiagnosisReportScreen extends StatelessWidget {
  final String reportId;
  const DiagnosisReportScreen({super.key, required this.reportId});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [OcColors.primary, OcColors.secondary]),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: Column(
                children: [
                  const Icon(Icons.assignment_outlined, size: 40, color: Colors.white),
                  const SizedBox(height: OcSpacing.md),
                  Text('تقرير فحص #${reportId.substring(0, 6)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('25 فبراير 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Vehicle
            _SectionCard(title: 'السيارة', icon: Icons.directions_car_rounded, children: [
              _DetailRow(label: 'الشركة/الموديل', value: 'تويوتا كامري 2022'),
              _DetailRow(label: 'رقم اللوحة', value: '12345'),
              _DetailRow(label: 'الكيلومترات', value: '45,000 كم'),
            ]),

            const SizedBox(height: OcSpacing.lg),

            // Issue
            _SectionCard(title: 'المشكلة', icon: Icons.report_problem_outlined, children: [
              Padding(
                padding: const EdgeInsets.all(OcSpacing.lg),
                child: Text(
                  'صوت غير طبيعي من المحرك عند التسارع، مع ارتفاع بسيط في حرارة المحرك',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
            ]),

            const SizedBox(height: OcSpacing.lg),

            // Required parts
            _SectionCard(title: 'القطع المطلوبة', icon: Icons.inventory_2_outlined, children: [
              _PartRow(name: 'فلتر زيت', qty: 1, price: '45 ر.ق'),
              _PartRow(name: 'فلتر هواء', qty: 1, price: '35 ر.ق'),
              _PartRow(name: 'زيت محرك 5W-40', qty: 4, price: '120 ر.ق'),
            ]),

            const SizedBox(height: OcSpacing.lg),

            // Photos
            Text('صور الفحص', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Row(
              children: List.generate(3, (_) => Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(left: OcSpacing.sm),
                  decoration: BoxDecoration(
                    color: OcColors.surfaceLight,
                    borderRadius: BorderRadius.circular(OcRadius.md),
                  ),
                  child: const Icon(Icons.image_outlined, color: OcColors.textSecondary),
                ),
              )),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Labor estimate
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'تكلفة القطع', value: '200 ر.ق'),
                  const SizedBox(height: OcSpacing.sm),
                  _DetailRow(label: 'تكلفة العمالة', value: '150 ر.ق'),
                  const Divider(height: OcSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي التقديري', style: Theme.of(context).textTheme.titleMedium),
                      Text('350 ر.ق', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(child: OcButton(label: 'طلب القطع', onPressed: () => context.push('/marketplace'), icon: Icons.shopping_cart_rounded)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('مشاركة'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(OcSpacing.lg),
            child: Row(children: [
              Icon(icon, size: 20, color: OcColors.primary),
              const SizedBox(width: OcSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
          const Divider(height: 1, color: OcColors.border),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg, vertical: OcSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final String name, price;
  final int qty;
  const _PartRow({required this.name, required this.qty, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg, vertical: OcSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyMedium)),
          Text('×$qty', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
          const SizedBox(width: OcSpacing.lg),
          Text(price, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
