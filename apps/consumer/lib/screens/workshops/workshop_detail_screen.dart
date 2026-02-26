import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

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
                  // Cover photo with gradient overlay
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: OcColors.surface,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      // Favorite button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.white),
                        ),
                        onPressed: () async {
                          final favService = ref.read(favoritesServiceProvider);
                          final isFav = await favService.toggleFavorite(workshopId: workshopId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isFav ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة')),
                            );
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          workshop.coverPhotoUrl != null
                              ? Image.network(workshop.coverPhotoUrl!, fit: BoxFit.cover)
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [OcColors.primary, OcColors.primary.withValues(alpha: 0.6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(child: Icon(Icons.build_circle_rounded, size: 64, color: Colors.white54)),
                                ),
                          // Gradient overlay for text readability
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                          // Workshop name at bottom
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    workshop.nameAr,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (workshop.isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: OcColors.info,
                                      borderRadius: BorderRadius.circular(OcRadius.pill),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('موثقة', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(OcSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating + Status
                          Row(
                            children: [
                              OcRating(
                                rating: workshop.avgRating,
                                totalReviews: workshop.totalReviews,
                              ),
                              const Spacer(),
                              OcStatusBadge(
                                label: workshop.isOpenNow ? 'مفتوح الآن' : 'مغلق',
                                color: workshop.isOpenNow ? OcColors.success : OcColors.error,
                              ),
                            ],
                          ),

                          const SizedBox(height: OcSpacing.xl),

                          // Description
                          if (workshop.descriptionAr != null && workshop.descriptionAr!.isNotEmpty) ...[
                            Text('عن الورشة', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: OcSpacing.sm),
                            Text(
                              workshop.descriptionAr!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: OcColors.textDarkSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: OcSpacing.xl),
                          ],

                          // Info rows
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: [workshop.zone, workshop.street, workshop.building]
                                .where((s) => s != null && s.isNotEmpty)
                                .join(', '),
                          ),
                          if (workshop.phone != null)
                            _InfoRow(icon: Icons.phone_outlined, text: workshop.phone!),
                          _InfoRow(
                            icon: Icons.schedule_outlined,
                            text: '${workshop.workingDays} • ${workshop.workingHours}',
                          ),
                          _InfoRow(icon: Icons.qr_code_rounded, text: 'كود الورشة: ${workshop.code}'),

                          const SizedBox(height: OcSpacing.xl),

                          // Specialties
                          if (workshop.specialties.isNotEmpty) ...[
                            Text('التخصصات', style: Theme.of(context).textTheme.titleLarge),
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

                          // Stats row
                          Row(
                            children: [
                              _StatCard(
                                label: 'التقييم',
                                value: workshop.avgRating.toStringAsFixed(1),
                                icon: Icons.star_rounded,
                                color: OcColors.starAmber,
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

                          // Gallery / Portfolio
                          if (workshop.galleryUrls.isNotEmpty) ...[
                            Text('معرض الأعمال', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: OcSpacing.sm),
                            Text(
                              'صور لسيارات تم إصلاحها في الورشة',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary),
                            ),
                            const SizedBox(height: OcSpacing.md),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: workshop.galleryUrls.length,
                                separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.md),
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () => _showGalleryDialog(context, workshop.galleryUrls, i),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(OcRadius.lg),
                                    child: Image.network(
                                      workshop.galleryUrls[i],
                                      width: 240,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: OcSpacing.xxl),
                          ],

                          // Action buttons
                          OcButton(
                            label: 'تواصل مع الورشة',
                            icon: Icons.chat_rounded,
                            onPressed: () async {
                              try {
                                final chatService = ref.read(chatServiceProvider);
                                final room = await chatService.getOrCreateRoom(otherUserId: workshop.userId);
                                if (context.mounted) context.push('/chat/${room.id}');
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('خطأ: $e')),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: OcSpacing.md),
                          OcButton(
                            label: 'اطلب قطع عبر هذه الورشة',
                            icon: Icons.shopping_cart_rounded,
                            outlined: true,
                            onPressed: () => context.push('/marketplace'),
                          ),

                          const SizedBox(height: OcSpacing.xxl),

                          // Reviews header
                          Row(
                            children: [
                              Text('التقييمات', style: Theme.of(context).textTheme.headlineMedium),
                              const Spacer(),
                              Text(
                                '${workshop.totalReviews} تقييم',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary),
                              ),
                            ],
                          ),
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
                              padding: const EdgeInsets.symmetric(horizontal: OcSpacing.xl),
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

  void _showGalleryDialog(BuildContext context, List<String> urls, int initial) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          width: double.infinity,
          height: 400,
          child: PageView.builder(
            controller: PageController(initialPage: initial),
            itemCount: urls.length,
            itemBuilder: (_, i) => Stack(
              children: [
                Center(child: Image.network(urls[i], fit: BoxFit.contain)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${i + 1} / ${urls.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
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
          Icon(icon, size: 16, color: OcColors.textDarkSecondary),
          const SizedBox(width: OcSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OcColors.textDarkSecondary,
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
                    color: OcColors.textDarkSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
