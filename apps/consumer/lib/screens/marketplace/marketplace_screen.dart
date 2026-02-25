import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(partCategoriesProvider);
    final partsAsync = ref.watch(partsProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(OcSpacing.lg),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن قطعة...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),

            // Categories chips
            SizedBox(
              height: 40,
              child: categoriesAsync.when(
                data: (cats) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg),
                  itemCount: cats.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: OcSpacing.sm),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return OcChip(
                        label: 'الكل',
                        selected: _selectedCategory == null,
                        onSelected: (_) => setState(() => _selectedCategory = null),
                      );
                    }
                    final cat = cats[i - 1];
                    return OcChip(
                      label: cat.nameAr,
                      selected: _selectedCategory == cat.id,
                      onSelected: (_) => setState(() => _selectedCategory = cat.id),
                    );
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: OcSpacing.md),

            // Parts grid
            Expanded(
              child: partsAsync.when(
                data: (parts) => parts.isEmpty
                    ? const OcEmptyState(
                        icon: Icons.inventory_2_outlined,
                        message: 'لا توجد قطع في هذه الفئة',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(OcSpacing.lg),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: parts.length,
                        itemBuilder: (_, i) => _PartCard(part: parts[i]),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => OcErrorState(
                  message: 'تعذر تحميل القطع',
                  onRetry: () => ref.invalidate(partsProvider(_selectedCategory)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final dynamic part;
  const _PartCard({required this.part});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {/* Navigate to part detail */},
      child: Container(
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: OcColors.surfaceLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(OcRadius.lg)),
              ),
              child: Center(
                child: part.imageUrl != null
                    ? Image.network(part.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image_outlined, size: 36, color: OcColors.textSecondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(OcSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.nameAr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (part.brand != null)
                    Text(
                      part.brand!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary),
                    ),
                  const SizedBox(height: OcSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${part.price.toStringAsFixed(0)} ر.ق',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: OcColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: OcColors.primary,
                          borderRadius: BorderRadius.circular(OcRadius.sm),
                        ),
                        child: const Icon(Icons.add, color: OcColors.textOnPrimary, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
