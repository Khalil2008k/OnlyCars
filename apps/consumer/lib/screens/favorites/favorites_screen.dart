import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('المفضلة')),
      body: favsAsync.when(
        data: (favs) {
          if (favs.isEmpty) {
            return const OcEmptyState(
              icon: Icons.favorite_border_rounded,
              message: 'لا توجد مفضلات\nأضف قطع أو ورش لقائمتك',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(favoritesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) {
                final fav = favs[i];
                final part = fav['parts'] as Map<String, dynamic>?;
                final workshop = fav['workshop_profiles'] as Map<String, dynamic>?;
                final favId = fav['id'] as String;

                if (part != null) {
                  return _FavPartCard(
                    name: part['name_ar'] ?? '',
                    price: (part['price'] as num?)?.toDouble() ?? 0,
                    imageUrl: (part['image_urls'] as List?)?.firstOrNull as String?,
                    shopName: (part['shop_profiles'] as Map?)?['name_ar'] ?? '',
                    onTap: () => context.push('/part/${fav['part_id']}'),
                    onRemove: () async {
                      final service = ref.read(favoritesServiceProvider);
                      await service.removeFavorite(favId);
                      ref.invalidate(favoritesProvider);
                      ref.invalidate(favoritesCountProvider);
                    },
                  );
                }

                if (workshop != null) {
                  return _FavWorkshopCard(
                    name: workshop['name_ar'] ?? '',
                    rating: (workshop['avg_rating'] as num?)?.toDouble() ?? 0,
                    onTap: () => context.push('/workshop/${fav['workshop_id']}'),
                    onRemove: () async {
                      final service = ref.read(favoritesServiceProvider);
                      await service.removeFavorite(favId);
                      ref.invalidate(favoritesProvider);
                      ref.invalidate(favoritesCountProvider);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل المفضلة',
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
      ),
    );
  }
}

class _FavPartCard extends StatelessWidget {
  final String name, shopName;
  final double price;
  final String? imageUrl;
  final VoidCallback onTap, onRemove;
  const _FavPartCard({required this.name, required this.price, this.imageUrl, required this.shopName, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.md),
        decoration: BoxDecoration(color: OcColors.surfaceCard, borderRadius: BorderRadius.circular(OcRadius.lg), border: Border.all(color: OcColors.border)),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: OcColors.surfaceLight,
                borderRadius: BorderRadius.circular(OcRadius.md),
                image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null,
              ),
              child: imageUrl == null ? const Icon(Icons.image_outlined, color: OcColors.textSecondary) : null,
            ),
            const SizedBox(width: OcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                  if (shopName.isNotEmpty) Text(shopName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                  Text('${price.toStringAsFixed(0)} ر.ق', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.secondary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.favorite, color: OcColors.error), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}

class _FavWorkshopCard extends StatelessWidget {
  final String name;
  final double rating;
  final VoidCallback onTap, onRemove;
  const _FavWorkshopCard({required this.name, required this.rating, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.md),
        decoration: BoxDecoration(color: OcColors.surfaceCard, borderRadius: BorderRadius.circular(OcRadius.lg), border: Border.all(color: OcColors.border)),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: OcColors.surfaceLight, borderRadius: BorderRadius.circular(OcRadius.md)),
              child: const Icon(Icons.build_circle_rounded, color: OcColors.textSecondary, size: 28),
            ),
            const SizedBox(width: OcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 14, color: OcColors.secondary),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.favorite, color: OcColors.error), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}
