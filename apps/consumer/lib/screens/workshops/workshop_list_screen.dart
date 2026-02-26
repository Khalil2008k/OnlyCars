import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

/// Workshop Map Screen — split view: top map, bottom list.
class WorkshopListScreen extends ConsumerWidget {
  const WorkshopListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top: Map Area (≈45% of screen) ──────
            Expanded(
              flex: 45,
              child: Stack(
                children: [
                  // Map placeholder
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://api.mapbox.com/styles/v1/mapbox/light-v11/static/51.53,25.29,12,0/600x400?access_token=pk.placeholder',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Map background pattern
                        CustomPaint(
                          painter: _MapGridPainter(),
                          size: Size.infinite,
                        ),
                        // Map pins (mock)
                        ..._buildMapPins(),
                        // Search overlay
                        Positioned(
                          top: OcSpacing.md,
                          left: OcSpacing.page,
                          right: OcSpacing.page,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(OcRadius.searchBar),
                              boxShadow: OcShadows.elevated,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: OcColors.textMuted, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('ابحث عن ورشة...', style: TextStyle(color: OcColors.textMuted, fontSize: 14)),
                                ),
                                GestureDetector(
                                  onTap: () => _showFilters(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: OcColors.accent,
                                      borderRadius: BorderRadius.circular(OcRadius.sm),
                                    ),
                                    child: const Icon(Icons.tune_rounded, color: OcColors.onAccent, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Current location button
                        Positioned(
                          bottom: OcSpacing.lg,
                          right: OcSpacing.page,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: OcShadows.elevated,
                            ),
                            child: const Icon(Icons.my_location_rounded, color: OcColors.accent, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Drag handle ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: OcColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(OcRadius.xl)),
              ),
              child: Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: OcColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // ── Section header ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ورش قريبة منك',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
                  ),
                  Text(
                    workshopsAsync.valueOrNull != null
                        ? '${workshopsAsync.valueOrNull!.length} ورشة'
                        : '',
                    style: const TextStyle(fontSize: 13, color: OcColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OcSpacing.sm),

            // ── Bottom: Workshop List (≈55%) ─────────
            Expanded(
              flex: 55,
              child: workshopsAsync.when(
                data: (workshops) => workshops.isEmpty
                    ? const OcEmptyState(
                        icon: Icons.build_circle_outlined,
                        message: 'لا توجد ورش متاحة حالياً',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          OcSpacing.page, 0, OcSpacing.page,
                          OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.lg,
                        ),
                        itemCount: workshops.length,
                        separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.sm),
                        itemBuilder: (_, index) {
                          final w = workshops[index];
                          return _WorkshopTile(
                            nameAr: w.nameAr,
                            zone: w.zone ?? '',
                            specialties: w.specialties,
                            avgRating: w.avgRating,
                            totalReviews: w.totalReviews,
                            isVerified: w.isVerified,
                            isOpenNow: w.isOpenNow,
                            distance: '${(index * 0.8 + 0.5).toStringAsFixed(1)} كم',
                            onTap: () => context.push('/workshop/${w.id}'),
                            onChat: () => context.push('/chat/${w.id}'),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator(color: OcColors.accent)),
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

  static List<Widget> _buildMapPins() {
    final pins = [
      (x: 120.0, y: 80.0, active: true),
      (x: 250.0, y: 120.0, active: false),
      (x: 180.0, y: 200.0, active: false),
      (x: 350.0, y: 150.0, active: false),
      (x: 80.0, y: 180.0, active: false),
    ];
    return pins.map((p) => Positioned(
      left: p.x,
      top: p.y,
      child: Container(
        width: p.active ? 36 : 28,
        height: p.active ? 36 : 28,
        decoration: BoxDecoration(
          color: p.active ? OcColors.accent : OcColors.navBar,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: OcShadows.card,
        ),
        child: Icon(
          Icons.build_rounded,
          color: p.active ? OcColors.onAccent : Colors.white,
          size: p.active ? 18 : 14,
        ),
      ),
    )).toList();
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OcColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OcRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: OcColors.border, borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: OcSpacing.xl),
            Text('التخصصات', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: OcSpacing.md),
            const Wrap(spacing: OcSpacing.sm, children: [
              OcChip(label: 'ميكانيكا'), OcChip(label: 'كهرباء'),
              OcChip(label: 'سمكرة وبودي'), OcChip(label: 'تكييف'),
              OcChip(label: 'عفشة'), OcChip(label: 'برمجة'),
            ]),
            const SizedBox(height: OcSpacing.xl),
            Text('الترتيب', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: OcSpacing.md),
            const Wrap(spacing: OcSpacing.sm, children: [
              OcChip(label: 'الأقرب', selected: true),
              OcChip(label: 'الأعلى تقييماً'),
              OcChip(label: 'مفتوح الآن'),
            ]),
            const SizedBox(height: OcSpacing.xxl),
            const OcButton(label: 'تطبيق الفلتر'),
            const SizedBox(height: OcSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WORKSHOP TILE — Compact list item with chat button
// ═══════════════════════════════════════════════════════

class _WorkshopTile extends StatelessWidget {
  final String nameAr;
  final String zone;
  final List<String> specialties;
  final double avgRating;
  final int totalReviews;
  final bool isVerified;
  final bool isOpenNow;
  final String distance;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const _WorkshopTile({
    required this.nameAr,
    required this.zone,
    required this.specialties,
    required this.avgRating,
    required this.totalReviews,
    required this.isVerified,
    required this.isOpenNow,
    required this.distance,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.card),
        ),
        child: Row(
          children: [
            // Workshop icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: OcColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(OcRadius.md),
              ),
              child: const Icon(Icons.build_circle_rounded, color: OcColors.accent, size: 26),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nameAr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_rounded, color: Color(0xFF1976D2), size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: OcColors.textMuted),
                      const SizedBox(width: 2),
                      Text(zone, style: const TextStyle(fontSize: 11, color: OcColors.textSecondary)),
                      const SizedBox(width: 8),
                      Container(
                        width: 3, height: 3,
                        decoration: const BoxDecoration(color: OcColors.textMuted, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(distance, style: const TextStyle(fontSize: 11, color: OcColors.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: OcColors.starAmber),
                      const SizedBox(width: 2),
                      Text(
                        '${avgRating.toStringAsFixed(1)} ($totalReviews)',
                        style: const TextStyle(fontSize: 11, color: OcColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      OcStatusBadge(
                        label: isOpenNow ? 'مفتوح' : 'مغلق',
                        color: isOpenNow ? OcColors.success : OcColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chat button
            GestureDetector(
              onTap: onChat,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: OcColors.accent,
                  borderRadius: BorderRadius.circular(OcRadius.md),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: OcColors.onAccent, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// MAP GRID PAINTER — Visual map pattern
// ═══════════════════════════════════════════════════════

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D5D5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Grid lines (road-like pattern)
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Block fills (buildings)
    final blockPaint = Paint()..color = const Color(0xFFE0E0E0);
    for (double x = 10; x < size.width - 60; x += 120) {
      for (double y = 10; y < size.height - 60; y += 120) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 50, 50), const Radius.circular(4)),
          blockPaint,
        );
      }
    }

    // Major road
    final roadPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.35, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
