import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('طلباتي')),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? const OcEmptyState(icon: Icons.receipt_long_outlined, message: 'لم تقم بأي طلب بعد')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myOrdersProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(OcSpacing.lg),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return Container(
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      decoration: BoxDecoration(
                        color: OcColors.surfaceCard,
                        borderRadius: BorderRadius.circular(OcRadius.lg),
                        border: Border.all(color: OcColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('طلب #${o.id.substring(0, 8)}',
                                    style: Theme.of(context).textTheme.titleMedium),
                              ),
                              OcStatusBadge.fromOrderStatus(o.status),
                            ],
                          ),
                          const SizedBox(height: OcSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag_rounded, size: 14, color: OcColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${(o.items?.length ?? 0)} قطع',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                              const Spacer(),
                              Text('${o.total.toStringAsFixed(2)} ر.ق',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.secondary)),
                            ],
                          ),
                          if (o.workshop != null) ...[
                            const SizedBox(height: OcSpacing.xs),
                            Row(
                              children: [
                                const Icon(Icons.build_circle_rounded, size: 14, color: OcColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(o.workshop!['name_ar'] ?? '',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل الطلبات', onRetry: () => ref.invalidate(myOrdersProvider)),
      ),
    );
  }
}
