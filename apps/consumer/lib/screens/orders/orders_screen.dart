import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _filter = 'all';

  static const _filters = [
    {'key': 'all', 'label': 'الكل'},
    {'key': 'pending', 'label': 'قيد الانتظار'},
    {'key': 'confirmed', 'label': 'مؤكد'},
    {'key': 'in_transit', 'label': 'في الطريق'},
    {'key': 'completed', 'label': 'مكتمل'},
    {'key': 'cancelled', 'label': 'ملغي'},
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(OcSpacing.lg, OcSpacing.lg, OcSpacing.lg, 0),
              child: Row(
                children: [
                  Text('طلباتي', style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  ref.watch(activeOrderCountProvider).when(
                    data: (count) => count > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: OcColors.primary,
                              borderRadius: BorderRadius.circular(OcRadius.pill),
                            ),
                            child: Text('$count نشطة', style: const TextStyle(color: OcColors.textOnPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.md),

            // Filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.sm),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  return OcChip(
                    label: f['label']!,
                    selected: _filter == f['key'],
                    onSelected: (_) => setState(() => _filter = f['key']!),
                  );
                },
              ),
            ),

            const SizedBox(height: OcSpacing.md),

            // Orders list
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  final filtered = _filter == 'all'
                      ? orders
                      : orders.where((o) => o.status == _filter).toList();

                  if (filtered.isEmpty) {
                    return const OcEmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'لا توجد طلبات',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(myOrdersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
                      itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => OcErrorState(
                  message: 'تعذر تحميل الطلبات',
                  onRetry: () => ref.invalidate(myOrdersProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => OcColors.warning,
      'confirmed' => OcColors.info,
      'in_transit' => OcColors.secondary,
      'delivered' => OcColors.success,
      'completed' => OcColors.success,
      'cancelled' => OcColors.error,
      _ => OcColors.textSecondary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'قيد الانتظار',
      'confirmed' => 'مؤكد',
      'in_transit' => 'في الطريق',
      'delivered' => 'تم التوصيل',
      'completed' => 'مكتمل',
      'cancelled' => 'ملغي',
      _ => status,
    };
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items?.length ?? 0;
    final workshopName = order.workshop?['name_ar'] ?? '';

    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: order number + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'طلب #${order.id.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                OcStatusBadge(
                  label: _statusLabel(order.status),
                  color: _statusColor(order.status),
                ),
              ],
            ),

            const SizedBox(height: OcSpacing.md),

            // Workshop name
            if (workshopName.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.build_circle_outlined, size: 16, color: OcColors.textSecondary),
                  const SizedBox(width: OcSpacing.xs),
                  Text(workshopName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ),
              const SizedBox(height: OcSpacing.sm),
            ],

            // Items + total
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: OcColors.textSecondary),
                const SizedBox(width: OcSpacing.xs),
                Text('$itemCount قطعة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                const Spacer(),
                Text(
                  '${order.total.toStringAsFixed(0)} ر.ق',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: OcColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),

            const SizedBox(height: OcSpacing.sm),

            // Date
            Text(
              _formatDate(order.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
