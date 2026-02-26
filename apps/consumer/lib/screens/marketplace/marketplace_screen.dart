import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.toLowerCase());
    });
  }

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
                onChanged: _onSearchChanged,
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
                  separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.sm),
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
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: OcSpacing.md),

            // Parts grid
            Expanded(
              child: partsAsync.when(
                data: (parts) {
                  // Client-side search filter
                  final filtered = _searchQuery.isEmpty
                      ? parts
                      : parts.where((p) =>
                          p.nameAr.toLowerCase().contains(_searchQuery) ||
                          (p.nameEn?.toLowerCase().contains(_searchQuery) ?? false) ||
                          (p.descriptionAr?.toLowerCase().contains(_searchQuery) ?? false)
                        ).toList();

                  if (filtered.isEmpty) {
                    return const OcEmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'لا توجد قطع في هذه الفئة',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(partsProvider(_selectedCategory)),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _PartCard(part: filtered[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => OcErrorState(
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

class _PartCard extends ConsumerWidget {
  final dynamic part;
  const _PartCard({required this.part});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = part.imageUrls.isNotEmpty ? part.imageUrls.first as String : null;

    return GestureDetector(
      onTap: () => context.push('/part/${part.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: OcColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(OcRadius.lg)),
                image: imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null
                  ? const Center(child: Icon(Icons.image_outlined, size: 36, color: OcColors.textSecondary))
                  : null,
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
                  if (part.shop != null)
                    Text(
                      part.shop!['name_ar'] ?? '',
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
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).add(part);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('تمت الإضافة إلى السلة'),
                              action: SnackBarAction(label: 'السلة', onPressed: () => context.push('/cart')),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: OcColors.primary,
                            borderRadius: BorderRadius.circular(OcRadius.sm),
                          ),
                          child: const Icon(Icons.add, color: OcColors.textOnPrimary, size: 16),
                        ),
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
