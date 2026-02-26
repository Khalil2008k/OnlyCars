import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

final shopDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, shopId) async {
  final client = OcSupabase.client;
  final data = await client
      .from('shop_profiles')
      .select()
      .eq('id', shopId)
      .maybeSingle();
  return data;
});

final shopPartsProvider =
    FutureProvider.family<List<Part>, String>((ref, shopId) async {
  final service = ref.read(partsServiceProvider);
  return await service.getPartsByShopId(shopId);
});

class ShopProfileScreen extends ConsumerWidget {
  final String shopId;
  const ShopProfileScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopDetailProvider(shopId));
    final partsAsync = ref.watch(shopPartsProvider(shopId));

    return Scaffold(
      backgroundColor: OcColors.background,
      body: shopAsync.when(
        data: (shop) {
          if (shop == null) return const OcErrorState(message: 'المتجر غير موجود');

          final name = shop['name_ar'] ?? 'متجر';
          final rating = (shop['avg_rating'] as num?)?.toDouble() ?? 0;
          final totalProducts = (shop['total_products'] as num?)?.toInt() ?? 0;
          final location = [shop['zone'], shop['city']].where((s) => s != null && s.toString().isNotEmpty).join(', ');
          final brands = (shop['brands'] as List?)?.cast<String>() ?? [];

          return CustomScrollView(
            slivers: [
              // Cover
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                  ),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [OcColors.primary, OcColors.primary.withValues(alpha: 0.5)],
                          ),
                        ),
                        child: Center(
                          child: shop['logo_url'] != null
                              ? Image.network(shop['logo_url'], width: 80, height: 80, fit: BoxFit.cover)
                              : const Icon(Icons.store_rounded, size: 64, color: Colors.white54),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black45],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(OcSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating
                      Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: OcSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: OcColors.starAmber),
                          const SizedBox(width: 4),
                          Text(rating.toStringAsFixed(1), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          if (location.isNotEmpty) ...[
                            const Spacer(),
                            Icon(Icons.location_on_outlined, size: 16, color: OcColors.textDarkSecondary),
                            const SizedBox(width: 4),
                            Text(location, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textDarkSecondary)),
                          ],
                        ],
                      ),

                      const SizedBox(height: OcSpacing.xl),

                      // Stats
                      Row(
                        children: [
                          _ShopStat(label: 'المنتجات', value: '$totalProducts'),
                          const SizedBox(width: OcSpacing.md),
                          _ShopStat(label: 'التقييم', value: rating.toStringAsFixed(1)),
                          const SizedBox(width: OcSpacing.md),
                          _ShopStat(label: 'العلامات', value: '${brands.length}'),
                        ],
                      ),

                      const SizedBox(height: OcSpacing.xxl),

                      // Brands
                      if (brands.isNotEmpty) ...[
                        Text('العلامات التجارية', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: OcSpacing.md),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: brands.map((b) => OcChip(label: b)).toList(),
                        ),
                        const SizedBox(height: OcSpacing.xxl),
                      ],

                      // Products header
                      Row(
                        children: [
                          Text('المنتجات', style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          partsAsync.when(
                            data: (parts) => Text('${parts.length} منتج', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: OcSpacing.md),
                    ],
                  ),
                ),
              ),

              // Products list
              partsAsync.when(
                data: (parts) {
                  if (parts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(OcSpacing.xl),
                        child: OcEmptyState(icon: Icons.inventory_2_outlined, message: 'لا توجد منتجات'),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: OcSpacing.xl, vertical: OcSpacing.xs),
                        child: _ProductTile(part: parts[i]),
                      ),
                      childCount: parts.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(message: 'تعذر تحميل المتجر', onRetry: () => ref.invalidate(shopDetailProvider(shopId))),
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

class _ProductTile extends ConsumerWidget {
  final Part part;
  const _ProductTile({required this.part});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = part.imageUrls.isNotEmpty ? part.imageUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/part/${part.id}'),
      child: Container(
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: OcColors.surfaceLight,
                borderRadius: BorderRadius.circular(OcRadius.md),
                image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
              ),
              child: imageUrl == null ? const Icon(Icons.image_outlined, color: OcColors.textSecondary, size: 24) : null,
            ),
            const SizedBox(width: OcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part.nameAr, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    part.condition ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${part.price.toStringAsFixed(0)} ر.ق',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    ref.read(cartProvider.notifier).add(part);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الإضافة للسلة')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: OcColors.primary, borderRadius: BorderRadius.circular(OcRadius.sm)),
                    child: const Icon(Icons.add_shopping_cart, size: 14, color: OcColors.onAccent),
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
