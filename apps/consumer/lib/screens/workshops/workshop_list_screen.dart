import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

/// Workshop Map Screen — split view: top real map, bottom workshop list.
class WorkshopListScreen extends ConsumerWidget {
  const WorkshopListScreen({super.key});

  // Doha, Qatar — center lat/lng
  static const _lat = 25.2854;
  static const _lng = 51.5310;
  static const _zoom = 13;

  // OpenStreetMap static tile URL (free, no API key)
  static String get _mapTileUrl =>
      'https://tile.openstreetmap.org/$_zoom/${_lonToTileX(_lng, _zoom)}/${_latToTileY(_lat, _zoom)}.png';

  // Multiple tiles for a larger map area
  static List<String> get _mapTileUrls {
    final cx = _lonToTileX(_lng, _zoom);
    final cy = _latToTileY(_lat, _zoom);
    final tiles = <String>[];
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        tiles.add('https://tile.openstreetmap.org/$_zoom/${cx + dx}/${cy + dy}.png');
      }
    }
    return tiles;
  }

  static int _lonToTileX(double lon, int zoom) =>
      ((lon + 180) / 360 * (1 << zoom)).floor();

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * 3.14159265359 / 180;
    return ((1 - (latRad.abs() < 1.5 ? _log(_tan(latRad) + 1 / _cos(latRad)) : 0) / 3.14159265359) / 2 * (1 << zoom)).floor();
  }

  static double _tan(double x) => x + x * x * x / 3;
  static double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
  static double _log(double x) {
    if (x <= 0) return 0;
    double result = 0;
    double y = (x - 1) / (x + 1);
    double term = y;
    for (int i = 1; i <= 20; i += 2) {
      result += term / i;
      term *= y * y;
    }
    return 2 * result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top: Real Map Area (≈45%) ────────────
            Expanded(
              flex: 45,
              child: Stack(
                children: [
                  // Real OpenStreetMap tiles
                  SizedBox.expand(
                    child: Image.network(
                      // Use a static map image from OpenStreetMap
                      'https://staticmap.openstreetmap.de/staticmap.php?center=$_lat,$_lng&zoom=$_zoom&size=600x400&maptype=mapnik'
                      '&markers=$_lat,$_lng,lightblue'
                      '&markers=25.292,51.520,red'
                      '&markers=25.278,51.540,red'
                      '&markers=25.270,51.518,red'
                      '&markers=25.299,51.535,red'
                      '&markers=25.285,51.505,red',
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFE8EEF5),
                          child: const Center(
                            child: CircularProgressIndicator(color: OcColors.accent),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _FallbackMap(),
                    ),
                  ),
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
                  // My location button
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
// FALLBACK MAP (when network tiles fail)
// ═══════════════════════════════════════════════════════

class _FallbackMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EEF5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: OcColors.textMuted),
            SizedBox(height: 8),
            Text('تحميل الخريطة...', style: TextStyle(color: OcColors.textMuted)),
          ],
        ),
      ),
    );
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
