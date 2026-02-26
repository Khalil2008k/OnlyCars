import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class PartDetailScreen extends ConsumerWidget {
  final String partId;
  const PartDetailScreen({super.key, required this.partId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partAsync = ref.watch(partDetailProvider(partId));

    return Scaffold(
      backgroundColor: OcColors.background,
      body: partAsync.when(
        data: (part) {
          if (part == null) return const OcErrorState(message: 'القطعة غير موجودة');

          final imageUrl = part.imageUrls.isNotEmpty ? part.imageUrls.first : null;
          final shop = part.shop;
          final shopName = shop?['name_ar'] ?? 'متجر';
          final shopId = shop?['id'] as String?;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Image header
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.white),
                        ),
                        onPressed: () async {
                          final favService = ref.read(favoritesServiceProvider);
                          final isFav = await favService.toggleFavorite(partId: partId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isFav ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة')),
                            );
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: OcColors.surfaceLight,
                              child: const Center(child: Icon(Icons.image_outlined, size: 64, color: OcColors.textSecondary)),
                            ),
                    ),
                  ),

                  // Image gallery dots
                  if (part.imageUrls.length > 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: OcSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(part.imageUrls.length, (i) => Container(
                            width: i == 0 ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i == 0 ? OcColors.primary : OcColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(OcSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Condition badge + share
                          Row(
                            children: [
                              if (part.condition != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: part.condition == 'genuine'
                                        ? OcColors.success.withValues(alpha: 0.15)
                                        : OcColors.info.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(OcRadius.sm),
                                  ),
                                  child: Text(
                                    part.condition == 'genuine' ? 'أصلي (OEM)' : 'بديل',
                                    style: TextStyle(
                                      color: part.condition == 'genuine' ? OcColors.success : OcColors.info,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (part.category != null)
                                OcChip(label: part.category!['name_ar'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: OcSpacing.md),

                          // Name
                          Text(
                            part.nameAr,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (part.nameEn != null && part.nameEn!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                part.nameEn!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textDarkSecondary),
                              ),
                            ),

                          const SizedBox(height: OcSpacing.xl),

                          // Price
                          Row(
                            children: [
                              Text(
                                part.price.toStringAsFixed(0),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: OcColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('ر.ق', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.primary)),
                              const Spacer(),
                              Icon(
                                part.stockQty > 0 ? Icons.inventory_2_outlined : Icons.cancel_outlined,
                                size: 16,
                                color: part.stockQty > 0 ? OcColors.success : OcColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                part.stockQty > 0 ? 'متوفر (${part.stockQty} قطعة)' : 'غير متوفر',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: part.stockQty > 0 ? OcColors.success : OcColors.error,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: OcSpacing.xxl),
                          const Divider(color: OcColors.border),
                          const SizedBox(height: OcSpacing.xl),

                          // Description
                          if (part.descriptionAr != null && part.descriptionAr!.isNotEmpty) ...[
                            Text('الوصف', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: OcSpacing.sm),
                            Text(
                              part.descriptionAr!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: OcColors.textDarkSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: OcSpacing.xxl),
                          ],

                          // Shop info
                          Text('المتجر', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: OcSpacing.md),
                          GestureDetector(
                            onTap: shopId != null ? () => context.push('/shop/$shopId') : null,
                            child: Container(
                              padding: const EdgeInsets.all(OcSpacing.lg),
                              decoration: BoxDecoration(
                                color: OcColors.surfaceCard,
                                borderRadius: BorderRadius.circular(OcRadius.lg),
                                border: Border.all(color: OcColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: OcColors.primary.withValues(alpha: 0.15),
                                    child: const Icon(Icons.store_rounded, color: OcColors.primary),
                                  ),
                                  const SizedBox(width: OcSpacing.md),
                                  Expanded(
                                    child: Text(shopName, style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky add-to-cart bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(OcSpacing.lg),
                  decoration: const BoxDecoration(
                    color: OcColors.surfaceCard,
                    border: Border(top: BorderSide(color: OcColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('السعر', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                            Text(
                              '${part.price.toStringAsFixed(0)} ر.ق',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: OcColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 180,
                          child: OcButton(
                            label: 'أضف للسلة',
                            onPressed: part.stockQty > 0 ? () {
                              ref.read(cartProvider.notifier).add(part);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تمت الإضافة للسلة ✓')),
                              );
                            } : null,
                            icon: Icons.add_shopping_cart_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل القطعة',
          onRetry: () => ref.invalidate(partDetailProvider(partId)),
        ),
      ),
    );
  }
}
