import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class WorkshopListScreen extends ConsumerWidget {
  const WorkshopListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(OcSpacing.lg),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن ورشة...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showFilters(context),
                  ),
                ),
              ),
            ),

            // Workshop list
            Expanded(
              child: workshopsAsync.when(
                data: (workshops) => workshops.isEmpty
                    ? const OcEmptyState(
                        icon: Icons.build_circle_outlined,
                        message: 'لا توجد ورش متاحة حالياً',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(workshopsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OcSpacing.lg,
                          ),
                          itemCount: workshops.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: OcSpacing.md),
                          itemBuilder: (_, index) {
                            final w = workshops[index];
                            return _WorkshopCard(
                              nameAr: w.nameAr,
                              zone: w.zone ?? '',
                              specialties: w.specialties,
                              avgRating: w.avgRating,
                              totalReviews: w.totalReviews,
                              isVerified: w.isVerified,
                              isOpenNow: w.isOpenNow,
                              coverPhotoUrl: w.coverPhotoUrl,
                              onTap: () => context.push('/workshop/${w.id}'),
                            );
                          },
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => OcErrorState(
                  message: 'تعذر تحميل الورش',
                  onRetry: () => ref.invalidate(workshopsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OcColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OcRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OcColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OcSpacing.xl),
            Text('التخصصات',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: OcSpacing.md),
            Wrap(
              spacing: OcSpacing.sm,
              children: const [
                OcChip(label: 'ميكانيكا'),
                OcChip(label: 'كهرباء'),
                OcChip(label: 'سمكرة وبودي'),
                OcChip(label: 'تكييف'),
                OcChip(label: 'عفشة'),
                OcChip(label: 'برمجة'),
              ],
            ),
            const SizedBox(height: OcSpacing.xl),
            Text('الترتيب',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: OcSpacing.md),
            Wrap(
              spacing: OcSpacing.sm,
              children: const [
                OcChip(label: 'الأقرب', selected: true),
                OcChip(label: 'الأعلى تقييماً'),
                OcChip(label: 'مفتوح الآن'),
              ],
            ),
            const SizedBox(height: OcSpacing.xxl),
            const OcButton(label: 'تطبيق الفلتر'),
            const SizedBox(height: OcSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final String nameAr;
  final String zone;
  final List<String> specialties;
  final double avgRating;
  final int totalReviews;
  final bool isVerified;
  final bool isOpenNow;
  final String? coverPhotoUrl;
  final VoidCallback onTap;

  const _WorkshopCard({
    required this.nameAr,
    required this.zone,
    required this.specialties,
    required this.avgRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isOpenNow,
    this.coverPhotoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: OcColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OcRadius.lg),
                ),
                image: coverPhotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(coverPhotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: coverPhotoUrl == null
                  ? const Center(
                      child: Icon(Icons.build_circle_rounded,
                          size: 40, color: OcColors.textSecondary))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(OcSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nameAr,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        const Icon(Icons.verified_rounded,
                            color: OcColors.info, size: 18),
                      const SizedBox(width: OcSpacing.sm),
                      OcStatusBadge(
                        label: isOpenNow ? 'مفتوح' : 'مغلق',
                        color: isOpenNow ? OcColors.success : OcColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: OcSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: OcColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        zone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: OcColors.textSecondary,
                            ),
                      ),
                      const Spacer(),
                      OcRating(
                        rating: avgRating,
                        totalReviews: totalReviews,
                        starSize: 14,
                      ),
                    ],
                  ),
                  if (specialties.isNotEmpty) ...[
                    const SizedBox(height: OcSpacing.sm),
                    Wrap(
                      spacing: OcSpacing.xs,
                      children: specialties.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: OcColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(OcRadius.pill),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: OcColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
