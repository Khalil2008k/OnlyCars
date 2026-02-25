import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class PartDetailScreen extends ConsumerWidget {
  final String partId;
  const PartDetailScreen({super.key, required this.partId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing image header
          SliverAppBar(
            expandedHeight: 280,
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
                color: OcColors.surfaceLight,
                child: const Center(child: Icon(Icons.image_outlined, size: 64, color: OcColors.textSecondary)),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Condition badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: OcColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(OcRadius.sm),
                        ),
                        child: const Text('أصلي (OEM)', style: TextStyle(color: OcColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.favorite_outline), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: OcSpacing.md),

                  // Name
                  Text('فلتر زيت تويوتا أصلي', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: OcSpacing.sm),
                  Text('Toyota Genuine Oil Filter 04152-YZZA1', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),

                  const SizedBox(height: OcSpacing.xl),

                  // Price
                  Row(
                    children: [
                      Text('45', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      Text('ر.ق', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.primary)),
                      const Spacer(),
                      const Icon(Icons.inventory_2_outlined, size: 16, color: OcColors.success),
                      const SizedBox(width: 4),
                      Text('متوفر (23 قطعة)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.success)),
                    ],
                  ),

                  const SizedBox(height: OcSpacing.xxl),
                  const Divider(color: OcColors.border),
                  const SizedBox(height: OcSpacing.xl),

                  // Shop info
                  Text('المتجر', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: OcSpacing.md),
                  Container(
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
                          backgroundColor: OcColors.secondary.withValues(alpha: 0.2),
                          child: const Icon(Icons.store_rounded, color: OcColors.secondary),
                        ),
                        const SizedBox(width: OcSpacing.md),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('متجر الخليج للقطع', style: Theme.of(context).textTheme.titleSmall),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: OcColors.warning),
                                const SizedBox(width: 2),
                                Text('4.7', style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(width: 8),
                                Text('الدوحة', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                              ],
                            ),
                          ],
                        )),
                        const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Compatibility
                  Text('التوافق مع السيارات', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: OcSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      OcChip(label: 'تويوتا كامري 2020-2024', selected: true),
                      OcChip(label: 'تويوتا كورولا 2019-2024'),
                      OcChip(label: 'تويوتا RAV4 2020-2024'),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky add-to-cart bar
      bottomNavigationBar: Container(
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
                  Text('45 ر.ق', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: OcButton(label: 'أضف للسلة', onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للسلة ✓')));
                }, icon: Icons.add_shopping_cart_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
