import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('تقييماتي')),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const OcEmptyState(
              icon: Icons.star_border_rounded,
              message: 'لم تضف أي تقييم بعد',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myReviewsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) {
                final review = reviews[i];
                final workshopName = review.consumer?['name_ar'] ?? 'ورشة';

                return Container(
                  padding: const EdgeInsets.all(OcSpacing.lg),
                  decoration: BoxDecoration(
                    color: OcColors.surfaceCard,
                    borderRadius: BorderRadius.circular(OcRadius.lg),
                    border: Border.all(color: OcColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workshop name + rating
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: OcColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(OcRadius.sm),
                            ),
                            child: const Icon(Icons.build_circle_rounded, color: OcColors.secondary, size: 20),
                          ),
                          const SizedBox(width: OcSpacing.md),
                          Expanded(
                            child: Text(workshopName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: OcSpacing.md),

                      // Stars
                      Row(
                        children: List.generate(5, (si) => Icon(
                          si < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: OcColors.secondary,
                          size: 22,
                        )),
                      ),

                      // Comment
                      if (review.commentAr != null && review.commentAr!.isNotEmpty) ...[
                        const SizedBox(height: OcSpacing.md),
                        Text(review.commentAr!, style: Theme.of(context).textTheme.bodyMedium),
                      ],

                      const SizedBox(height: OcSpacing.sm),

                      // Date
                      Text(
                        review.createdAt != null ? '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}' : '',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل التقييمات',
          onRetry: () => ref.invalidate(myReviewsProvider),
        ),
      ),
    );
  }
}
