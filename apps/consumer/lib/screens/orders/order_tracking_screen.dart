import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, id) async {
  final service = ref.read(orderServiceProvider);
  return await service.getOrderById(id);
});

final orderStatusLogProvider =
    FutureProvider.family<List<OrderStatusLog>, String>((ref, orderId) async {
  final service = ref.read(orderServiceProvider);
  return await service.getStatusLog(orderId);
});

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  static const _statusFlow = [
    {'key': 'pending', 'label': 'في الانتظار', 'icon': Icons.hourglass_top_rounded},
    {'key': 'confirmed', 'label': 'مؤكد', 'icon': Icons.check_circle_outline},
    {'key': 'preparing', 'label': 'قيد التجهيز', 'icon': Icons.inventory_outlined},
    {'key': 'ready', 'label': 'جاهز للإستلام', 'icon': Icons.local_shipping_outlined},
    {'key': 'picked_up', 'label': 'تم الاستلام', 'icon': Icons.delivery_dining},
    {'key': 'delivered', 'label': 'تم التوصيل', 'icon': Icons.where_to_vote_rounded},
    {'key': 'completed', 'label': 'مكتمل', 'icon': Icons.done_all_rounded},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use real-time stream — status updates live without refresh
    final orderAsync = ref.watch(orderStreamProvider(orderId));

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: Text('تتبع الطلب #${orderId.substring(0, 6)}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) return const OcErrorState(message: 'الطلب غير موجود');

          final currentStatus = order.status;
          final currentIndex = _statusFlow.indexWhere((s) => s['key'] == currentStatus);
          final effectiveIndex = currentIndex >= 0 ? currentIndex : 0;

          final workshop = order.workshop;
          final workshopName = workshop?['name_ar'] ?? 'لم يتم التعيين';

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(orderDetailProvider(orderId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(OcSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: currentStatus == 'cancelled'
                            ? [OcColors.error, OcColors.error.withValues(alpha: 0.7)]
                            : [OcColors.primary, OcColors.primary.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(OcRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          currentStatus == 'cancelled'
                              ? Icons.cancel_rounded
                              : _statusFlow[effectiveIndex]['icon'] as IconData,
                          size: 48,
                          color: OcColors.onAccent,
                        ),
                        const SizedBox(height: OcSpacing.md),
                        Text(
                          currentStatus == 'cancelled'
                              ? 'ملغي'
                              : _statusFlow[effectiveIndex]['label'] as String,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: OcColors.onAccent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Status timeline
                  if (currentStatus != 'cancelled')
                    ...List.generate(_statusFlow.length, (i) {
                      final isCompleted = i <= effectiveIndex;
                      final isCurrent = i == effectiveIndex;

                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                      ? const Icon(Icons.check, size: 14, color: OcColors.onAccent)
                                      : null,
                                ),
                                if (i < _statusFlow.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: isCompleted ? OcColors.primary : OcColors.border,
                                  ),
                              ],
                            ),
                            const SizedBox(width: OcSpacing.md),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  _statusFlow[i]['label'] as String,
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

                  // Order details
                  Text('تفاصيل الطلب', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: OcSpacing.md),
                  _InfoCard(
                    icon: Icons.build_rounded,
                    title: 'الورشة',
                    subtitle: workshopName,
                    onTap: order.workshopId != null
                        ? () => context.push('/workshop/${order.workshopId}')
                        : null,
                  ),
                  const SizedBox(height: OcSpacing.md),

                  // Price summary
                  Container(
                    padding: const EdgeInsets.all(OcSpacing.lg),
                    decoration: BoxDecoration(
                      color: OcColors.surfaceCard,
                      borderRadius: BorderRadius.circular(OcRadius.lg),
                      border: Border.all(color: OcColors.border),
                    ),
                    child: Column(
                      children: [
                        _PriceRow(label: 'تكلفة القطع', value: '${order.partsTotal.toStringAsFixed(0)} ر.ق'),
                        const SizedBox(height: OcSpacing.sm),
                        _PriceRow(label: 'التوصيل', value: '${order.deliveryFee.toStringAsFixed(0)} ر.ق'),
                        const SizedBox(height: OcSpacing.sm),
                        _PriceRow(label: 'رسوم المنصة', value: '${order.platformFee.toStringAsFixed(0)} ر.ق'),
                        const Divider(height: OcSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الإجمالي', style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              '${order.total.toStringAsFixed(0)} ر.ق',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: OcColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Actions
                  if (currentStatus == 'completed')
                    OcButton(
                      label: 'تقييم الورشة',
                      icon: Icons.star_rounded,
                      onPressed: () => context.push('/rate/$orderId'),
                    ),

                  if (currentStatus == 'pending')
                    OcButton(
                      label: 'إلغاء الطلب',
                      icon: Icons.cancel_rounded,
                      outlined: true,
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('إلغاء الطلب'),
                            content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، إلغاء')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(orderServiceProvider).updateStatus(orderId, 'cancelled');
                          ref.invalidate(orderDetailProvider(orderId));
                          ref.invalidate(myOrdersProvider);
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل الطلب',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  const _InfoCard({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textDarkSecondary)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textDarkSecondary)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
