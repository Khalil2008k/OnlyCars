import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class ShopProfileScreen extends ConsumerWidget {
  final String shopId;
  const ShopProfileScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: CustomScrollView(
        slivers: [
          // Cover photo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [OcColors.secondary, OcColors.secondary.withValues(alpha: 0.6)],
                  ),
                ),
                child: const Center(child: Icon(Icons.store_rounded, size: 64, color: Colors.white54)),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name + rating
                  Text('متجر الخليج للقطع', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: OcSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: OcColors.warning),
                      const SizedBox(width: 4),
                      Text('4.7', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Text('(156 تقييم)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, size: 16, color: OcColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('الدوحة، المنطقة الصناعية', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                    ],
                  ),

                  const SizedBox(height: OcSpacing.xl),

                  // Stats
                  Row(
                    children: [
                      _ShopStat(label: 'المنتجات', value: '156'),
                      const SizedBox(width: OcSpacing.md),
                      _ShopStat(label: 'الطلبات', value: '1.2K'),
                      const SizedBox(width: OcSpacing.md),
                      _ShopStat(label: 'العلامات', value: '12'),
                    ],
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Brands
                  Text('العلامات التجارية', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: OcSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      OcChip(label: 'Toyota'),
                      OcChip(label: 'Nissan'),
                      OcChip(label: 'Honda'),
                      OcChip(label: 'Hyundai'),
                      OcChip(label: 'Denso'),
                      OcChip(label: 'Bosch'),
                    ],
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Products list
                  Row(
                    children: [
                      Text('المنتجات', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text('عرض الكل')),
                    ],
                  ),
                  const SizedBox(height: OcSpacing.md),

                  ...List.generate(5, (i) => _ProductTile(
                    name: ['فلتر زيت تويوتا', 'بطارية فارتا 70Ah', 'ديسكات فرامل', 'شمعات إشعال', 'فلتر هواء'][i],
                    price: ['45', '380', '220', '95', '35'][i],
                    condition: ['أصلي', 'أصلي', 'بديل', 'أصلي', 'بديل'][i],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopStat extends StatelessWidget {
  final String label, value;
  const _ShopStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name, price, condition;
  const _ProductTile({required this.name, required this.price, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: OcSpacing.sm),
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: OcColors.surfaceLight, borderRadius: BorderRadius.circular(OcRadius.md)),
            child: const Icon(Icons.image_outlined, color: OcColors.textSecondary, size: 24),
          ),
          const SizedBox(width: OcSpacing.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(condition, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
            ],
          )),
          Text('$price ر.ق', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
