import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

/// Workshop Map Screen — split: top real OSM map tiles, bottom workshop list.
class WorkshopListScreen extends ConsumerWidget {
  const WorkshopListScreen({super.key});

  // Doha, Qatar center
  static const _lat = 25.2854;
  static const _lng = 51.5310;
  static const _zoom = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top: Real Map Tiles (≈45%) ───────────
            Expanded(
              flex: 45,
              child: Stack(
                children: [
                  // OSM tile grid
                  const _OsmTileMap(lat: _lat, lng: _lng, zoom: _zoom),
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
                  // My location
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
                  // Center pin
                  Center(
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: OcColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: OcShadows.elevated,
                      ),
                      child: const Icon(Icons.my_location_rounded, color: OcColors.onAccent, size: 20),
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
                  decoration: BoxDecoration(color: OcColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),

            // ── Section header ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ورش قريبة منك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: OcColors.textPrimary)),
                  Text(
                    workshopsAsync.valueOrNull != null ? '${workshopsAsync.valueOrNull!.length} ورشة' : '',
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
                    ? const OcEmptyState(icon: Icons.build_circle_outlined, message: 'لا توجد ورش متاحة حالياً')
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
// OSM TILE MAP — Renders real OpenStreetMap tiles in a grid
// ═══════════════════════════════════════════════════════

class _OsmTileMap extends StatelessWidget {
  final double lat;
  final double lng;
  final int zoom;

  const _OsmTileMap({required this.lat, required this.lng, required this.zoom});

  @override
  Widget build(BuildContext context) {
    // Calculate center tile
    final cx = _lonToTileX(lng, zoom);
    final cy = _latToTileY(lat, zoom);

    // Build a 5x4 grid of tiles centered on the location
    return ClipRect(
      child: OverflowBox(
        maxWidth: 5 * 256.0,
        maxHeight: 4 * 256.0,
        child: SizedBox(
          width: 5 * 256.0,
          height: 4 * 256.0,
          child: Stack(
            children: [
              for (int dx = -2; dx <= 2; dx++)
                for (int dy = -1; dy <= 2; dy++)
                  Positioned(
                    left: (dx + 2) * 256.0,
                    top: (dy + 1) * 256.0,
                    width: 256,
                    height: 256,
                    child: Image.network(
                      'https://tile.openstreetmap.org/$zoom/${cx + dx}/${cy + dy}.png',
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'OnlyCars/1.0'},
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(color: const Color(0xFFE8EEF5));
                      },
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8EEF5)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static int _lonToTileX(double lon, int zoom) =>
      ((lon + 180) / 360 * (1 << zoom)).floor();

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * (1 << zoom)).floor();
  }
}

// ═══════════════════════════════════════════════════════
// WORKSHOP TILE
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
    required this.nameAr, required this.zone, required this.specialties,
    required this.avgRating, required this.totalReviews, required this.isVerified,
    required this.isOpenNow, required this.distance,
    required this.onTap, required this.onChat,
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
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: OcColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(OcRadius.md),
              ),
              child: const Icon(Icons.build_circle_rounded, color: OcColors.accent, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(nameAr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary), overflow: TextOverflow.ellipsis)),
                    if (isVerified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified_rounded, color: Color(0xFF1976D2), size: 16)),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: OcColors.textMuted),
                    const SizedBox(width: 2),
                    Text(zone, style: const TextStyle(fontSize: 11, color: OcColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(color: OcColors.textMuted, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(distance, style: const TextStyle(fontSize: 11, color: OcColors.accent, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 14, color: OcColors.starAmber),
                    const SizedBox(width: 2),
                    Text('${avgRating.toStringAsFixed(1)} ($totalReviews)', style: const TextStyle(fontSize: 11, color: OcColors.textSecondary)),
                    const SizedBox(width: 8),
                    OcStatusBadge(label: isOpenNow ? 'مفتوح' : 'مغلق', color: isOpenNow ? OcColors.success : OcColors.error),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: onChat,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: OcColors.accent, borderRadius: BorderRadius.circular(OcRadius.md)),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: OcColors.onAccent, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
