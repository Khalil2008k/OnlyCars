import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class MaintenanceLogScreen extends ConsumerWidget {
  const MaintenanceLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);
    final diagnosisAsync = ref.watch(diagnosisReportsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('سجل الصيانة')),
      body: ordersAsync.when(
        data: (orders) => diagnosisAsync.when(
          data: (reports) {
            // Merge completed orders and diagnosis reports into a timeline
            final timeline = <_TimelineItem>[];

            for (final order in orders.where((o) => o.status == 'completed')) {
              timeline.add(_TimelineItem(
                date: order.createdAt ?? DateTime.now(),
                type: 'order',
                title: 'طلب قطع #${order.id.substring(0, 6)}',
                subtitle: order.workshop?['name_ar'] ?? 'طلب مباشر',
                amount: '${order.total.toStringAsFixed(0)} ر.ق',
                icon: Icons.shopping_bag_rounded,
                color: OcColors.primary,
                onTap: () => context.push('/order/${order.id}'),
              ));
            }

            for (final report in reports) {
              timeline.add(_TimelineItem(
                date: report.createdAt ?? DateTime.now(),
                type: 'diagnosis',
                title: 'فحص: ${report.issueDescriptionAr.length > 30 ? '${report.issueDescriptionAr.substring(0, 30)}...' : report.issueDescriptionAr}',
                subtitle: report.workshop?['name_ar'] ?? '',
                amount: report.laborQuote != null ? '${report.laborQuote!.toStringAsFixed(0)} ر.ق' : '',
                icon: Icons.assignment_rounded,
                color: OcColors.info,
                onTap: () => context.push('/diagnosis/${report.id}'),
              ));
            }

            // Sort by date descending
            timeline.sort((a, b) => b.date.compareTo(a.date));

            if (timeline.isEmpty) {
              return const OcEmptyState(
                icon: Icons.build_circle_outlined,
                message: 'لا يوجد سجل صيانة بعد',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: timeline.length,
              separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) => _TimelineCard(item: timeline[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const OcErrorState(message: 'تعذر تحميل البيانات'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل الطلبات', onRetry: () => ref.invalidate(myOrdersProvider)),
      ),
    );
  }
}

class _TimelineItem {
  final DateTime date;
  final String type, title, subtitle, amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _TimelineItem({required this.date, required this.type, required this.title, required this.subtitle, required this.amount, required this.icon, required this.color, required this.onTap});
}

class _TimelineCard extends StatelessWidget {
  final _TimelineItem item;
  const _TimelineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(color: OcColors.surfaceCard, borderRadius: BorderRadius.circular(OcRadius.lg), border: Border.all(color: OcColors.border)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: item.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(OcRadius.md)),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: OcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                  if (item.subtitle.isNotEmpty) Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                  Text('${item.date.day}/${item.date.month}/${item.date.year}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
            ),
            if (item.amount.isNotEmpty) Text(item.amount, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: OcColors.primary)),
          ],
        ),
      ),
    );
  }
}
