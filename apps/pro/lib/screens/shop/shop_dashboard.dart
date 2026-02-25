import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class ShopDashboard extends StatelessWidget {
  const ShopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('لوحة المتجر'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/roles'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('إضافة قطعة'),
        backgroundColor: OcColors.primary,
        foregroundColor: OcColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            Row(
              children: [
                Expanded(child: _ShopStat(title: 'المخزون', value: '156', icon: Icons.inventory_2_outlined, color: OcColors.primary)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _ShopStat(title: 'طلبات واردة', value: '4', icon: Icons.shopping_bag_outlined, color: OcColors.warning)),
              ],
            ),
            const SizedBox(height: OcSpacing.md),
            Row(
              children: [
                Expanded(child: _ShopStat(title: 'إيرادات اليوم', value: '820 ر.ق', icon: Icons.trending_up_rounded, color: OcColors.success)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _ShopStat(title: 'التقييم', value: '4.7 ⭐', icon: Icons.star_outline, color: OcColors.secondary)),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Incoming orders
            Text('الطلبات الواردة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _OrderCard(orderId: 'ORD-4F2A', items: 2, total: '340 ر.ق', status: 'جديد', isNew: true),
            const SizedBox(height: OcSpacing.sm),
            _OrderCard(orderId: 'ORD-8B1C', items: 1, total: '175 ر.ق', status: 'قيد التجهيز', isNew: false),
            const SizedBox(height: OcSpacing.sm),
            _OrderCard(orderId: 'ORD-3E7D', items: 4, total: '890 ر.ق', status: 'جاهز للاستلام', isNew: false),

            const SizedBox(height: OcSpacing.xxl),

            // Top products
            Text('المنتجات الأكثر مبيعاً', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _ProductRow(name: 'فلتر زيت تويوتا', sold: 23, price: '45 ر.ق'),
            _ProductRow(name: 'بطارية فارتا 70Ah', sold: 15, price: '380 ر.ق'),
            _ProductRow(name: 'ديسكات فرامل كامري', sold: 12, price: '220 ر.ق'),
          ],
        ),
      ),
    );
  }
}

class _ShopStat extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ShopStat({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: OcSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId, total, status;
  final int items;
  final bool isNew;
  const _OrderCard({required this.orderId, required this.items, required this.total, required this.status, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: isNew ? OcColors.warning : OcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isNew) Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: OcColors.warning),
              ),
              Text(orderId, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              OcStatusBadge(label: status),
            ],
          ),
          const SizedBox(height: OcSpacing.sm),
          Row(
            children: [
              Text('$items قطع', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
              const Spacer(),
              Text(total, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
          if (status == 'جديد') ...[
            const SizedBox(height: OcSpacing.md),
            Row(
              children: [
                Expanded(child: OcButton(label: 'قبول', onPressed: () {}, icon: Icons.check)),
                const SizedBox(width: OcSpacing.sm),
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('التفاصيل'))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name, price;
  final int sold;
  const _ProductRow({required this.name, required this.sold, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: OcSpacing.md, horizontal: OcSpacing.lg),
      margin: const EdgeInsets.only(bottom: OcSpacing.sm),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.md),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              Text('بيع $sold قطعة', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
            ],
          )),
          Text(price, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
