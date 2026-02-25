import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';

final workshopDetailProvider =
    FutureProvider.family<WorkshopProfile?, String>((ref, id) async {
  final service = ref.read(workshopServiceProvider);
  return await service.getWorkshopById(id);
});

final workshopReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, workshopId) async {
  final service = ref.read(workshopServiceProvider);
  return await service.getReviews(workshopId);
});

final workshopServiceProvider = Provider((_) => WorkshopService());

class WorkshopDetailScreen extends ConsumerWidget {
  final String workshopId;
  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopAsync = ref.watch(workshopDetailProvider(workshopId));
    final reviewsAsync = ref.watch(workshopReviewsProvider(workshopId));

    return Scaffold(
      backgroundColor: OcColors.background,
      body: workshopAsync.when(
        data: (workshop) => workshop == null
            ? const OcErrorState(message: 'الورشة غير موجودة')
            : CustomScrollView(
                slivers: [
                  // Cover + back button
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: OcColors.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: OcColors.surfaceLight,
                        child: workshop.coverPhotoUrl != null
                            ? Image.network(workshop.coverPhotoUrl!,
                                fit: BoxFit.cover)
                            : const Center(
                                child: Icon(Icons.build_circle_rounded,
                                    size: 64, color: OcColors.textSecondary)),
                      ),
                    ),
                  ),

                  // Workshop info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(OcSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  workshop.nameAr,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                              if (workshop.isVerified)
                                const Icon(Icons.verified_rounded,
                                    color: OcColors.info, size: 24),
                            ],
                          ),
                          const SizedBox(height: OcSpacing.sm),
                          Row(
                            children: [
                              OcRating(
                                rating: workshop.avgRating,
                                totalReviews: workshop.totalReviews,
                              ),
                              const Spacer(),
                              OcStatusBadge(
                                label: workshop.isOpenNow ? 'مفتوح الآن' : 'مغلق',
                                color: workshop.isOpenNow
                                    ? OcColors.success
                                    : OcColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: OcSpacing.lg),

                          // Location
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: [workshop.zone, workshop.street, workshop.building]
                                .where((s) => s != null && s.isNotEmpty)
                                .join(', '),
                          ),

                          // Phone
                          if (workshop.phone != null)
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              text: workshop.phone!,
                            ),

                          // Hours
                          _InfoRow(
                            icon: Icons.schedule_outlined,
                            text: '${workshop.workingDays} • ${workshop.workingHours}',
                          ),

                          // Code
                          _InfoRow(
                            icon: Icons.qr_code_rounded,
                            text: 'كود الورشة: ${workshop.code}',
                          ),

                          const SizedBox(height: OcSpacing.xl),

                          // Specialties
                          if (workshop.specialties.isNotEmpty) ...[
                            Text('التخصصات',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: OcSpacing.sm),
                            Wrap(
                              spacing: OcSpacing.sm,
                              runSpacing: OcSpacing.sm,
                              children: workshop.specialties
                                  .map((s) => OcChip(label: s))
                                  .toList(),
                            ),
                            const SizedBox(height: OcSpacing.xl),
                          ],

                          // Stats
                          Row(
                            children: [
                              _StatCard(
                                label: 'التقييم',
                                value: workshop.avgRating.toStringAsFixed(1),
                                icon: Icons.star_rounded,
                                color: OcColors.secondary,
                              ),
                              const SizedBox(width: OcSpacing.md),
                              _StatCard(
                                label: 'التقييمات',
                                value: '${workshop.totalReviews}',
                                icon: Icons.reviews_rounded,
                                color: OcColors.info,
                              ),
                              const SizedBox(width: OcSpacing.md),
                              _StatCard(
                                label: 'أعمال مكتملة',
                                value: '${workshop.totalJobsCompleted}',
                                icon: Icons.check_circle_rounded,
                                color: OcColors.success,
                              ),
                            ],
                          ),

                          const SizedBox(height: OcSpacing.xxl),

                          // Action buttons
                          OcButton(
                            label: 'تواصل مع الورشة',
                            icon: Icons.chat_rounded,
                            onPressed: () {},
                          ),
                          const SizedBox(height: OcSpacing.md),
                          OcButton(
                            label: 'اطلب قطع عبر هذه الورشة',
                            icon: Icons.shopping_cart_rounded,
                            outlined: true,
                            onPressed: () {},
                          ),

                          const SizedBox(height: OcSpacing.xxl),

                          // Reviews
                          Text('التقييمات',
                              style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: OcSpacing.md),
                        ],
                      ),
                    ),
                  ),

                  // Reviews list
                  reviewsAsync.when(
                    data: (reviews) => reviews.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: OcSpacing.xl),
                              child: Text(
                                'لا توجد تقييمات بعد',
                                style: TextStyle(color: OcColors.textSecondary),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OcSpacing.xl,
                                  vertical: OcSpacing.sm,
                                ),
                                child: _ReviewCard(review: reviews[i]),
                              ),
                              childCount: reviews.length,
                            ),
                          ),
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SliverToBoxAdapter(
                      child: SizedBox.shrink(),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => OcErrorState(
          message: 'تعذر تحميل بيانات الورشة',
          onRetry: () => ref.invalidate(workshopDetailProvider(workshopId)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: OcSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: OcColors.textSecondary),
          const SizedBox(width: OcSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OcColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.md),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: OcSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: OcColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.md),
        border: Border.all(color: OcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: OcColors.surfaceLight,
                child: const Icon(Icons.person, size: 16, color: OcColors.textSecondary),
              ),
              const SizedBox(width: OcSpacing.sm),
              Expanded(
                child: Text(
                  review.consumer?['name'] ?? 'مستخدم',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              OcRating(rating: review.rating.toDouble(), starSize: 12),
            ],
          ),
          if (review.commentAr != null) ...[
            const SizedBox(height: OcSpacing.sm),
            Text(
              review.commentAr!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OcColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
