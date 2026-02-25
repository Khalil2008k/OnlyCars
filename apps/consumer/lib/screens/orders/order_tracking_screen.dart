import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Order statuses in Arabic
    final statuses = [
      {'key': 'pending', 'label': 'في الانتظار', 'icon': Icons.hourglass_top_rounded},
      {'key': 'confirmed', 'label': 'مؤكد', 'icon': Icons.check_circle_outline},
      {'key': 'preparing', 'label': 'قيد التجهيز', 'icon': Icons.inventory_outlined},
      {'key': 'ready', 'label': 'جاهز للإستلام', 'icon': Icons.local_shipping_outlined},
      {'key': 'picked_up', 'label': 'تم الاستلام', 'icon': Icons.delivery_dining},
      {'key': 'delivered', 'label': 'تم التوصيل', 'icon': Icons.where_to_vote_rounded},
      {'key': 'completed', 'label': 'مكتمل', 'icon': Icons.done_all_rounded},
    ];

    // Mock current status — in production, get from order provider
    const currentIndex = 2;

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: Text('تتبع الطلب #${orderId.substring(0, 6)}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OcColors.primary, OcColors.secondary],
                ),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: Column(
                children: [
                  Icon(
                    statuses[currentIndex]['icon'] as IconData,
                    size: 48,
                    color: OcColors.textOnPrimary,
                  ),
                  const SizedBox(height: OcSpacing.md),
                  Text(
                    statuses[currentIndex]['label'] as String,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: OcColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Status timeline
            ...List.generate(statuses.length, (i) {
              final isCompleted = i <= currentIndex;
              final isCurrent = i == currentIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot + line
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? OcColors.primary : OcColors.surfaceLight,
                            border: Border.all(
                              color: isCompleted ? OcColors.primary : OcColors.border,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 14, color: OcColors.textOnPrimary)
                              : null,
                        ),
                        if (i < statuses.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: isCompleted ? OcColors.primary : OcColors.border,
                          ),
                      ],
                    ),
                    const SizedBox(width: OcSpacing.md),

                    // Label
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          statuses[i]['label'] as String,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                color: isCompleted ? OcColors.textPrimary : OcColors.textSecondary,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: OcSpacing.xxl),

            // Order info cards
            _InfoCard(
              icon: Icons.store_rounded,
              title: 'المتجر',
              subtitle: 'سيتم عرض بيانات المتجر',
            ),
            const SizedBox(height: OcSpacing.md),
            _InfoCard(
              icon: Icons.build_rounded,
              title: 'الورشة',
              subtitle: 'سيتم عرض بيانات الورشة',
            ),
            const SizedBox(height: OcSpacing.md),
            _InfoCard(
              icon: Icons.delivery_dining,
              title: 'السائق',
              subtitle: 'لم يتم تعيين سائق بعد',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OcColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: Icon(icon, color: OcColors.primary, size: 22),
          ),
          const SizedBox(width: OcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
