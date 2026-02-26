import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final unreadAsync = ref.watch(unreadNotifCountProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: OcColors.accent,
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(vehiclesProvider);
            ref.invalidate(unreadNotifCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OcSpacing.page, OcSpacing.lg, OcSpacing.page, OcSpacing.md,
                  ),
                  child: profileAsync.when(
                    data: (user) => _Header(
                      name: user?.name ?? 'مرحباً',
                      unreadCount: unreadAsync.valueOrNull ?? 0,
                    ),
                    loading: () => const _Header(name: '...', unreadCount: 0),
                    error: (_, __) => const _Header(name: 'مرحباً', unreadCount: 0),
                  ),
                ),
              ),

              // ── Hero Banner ─────────────────────────
              SliverToBoxAdapter(
                child: OcHeroBanner(
                  items: const [
                    OcBannerItem(
                      title: 'اكتشف أفضل الورش',
                      subtitle: 'ورش معتمدة بأسعار منافسة وخدمة مميزة',
                      buttonLabel: 'تصفح الآن',
                    ),
                    OcBannerItem(
                      title: 'سوق قطع الغيار',
                      subtitle: 'آلاف القطع الأصلية بتوصيل سريع',
                      buttonLabel: 'تسوق الآن',
                    ),
                    OcBannerItem(
                      title: 'تشخيص ذكي',
                      subtitle: 'احصل على تقرير شامل لحالة سيارتك',
                      buttonLabel: 'ابدأ التشخيص',
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.lg)),

              // ── Search Bar ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                  child: OcSearchBar(
                    hint: 'ابحث عن ورشة أو قطعة...',
                    readOnly: true,
                    onTap: () => context.push('/marketplace'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.lg)),

              // ── 3 Compact Service Buttons ───────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniServiceCard(
                          icon: Icons.build_circle_rounded,
                          label: 'الورش',
                          color: const Color(0xFF1976D2),
                          onTap: () => context.push('/workshops'),
                        ),
                      ),
                      const SizedBox(width: OcSpacing.sm),
                      Expanded(
                        child: _MiniServiceCard(
                          icon: Icons.shopping_bag_rounded,
                          label: 'قطع الغيار',
                          color: const Color(0xFFE65100),
                          onTap: () => context.push('/marketplace'),
                        ),
                      ),
                      const SizedBox(width: OcSpacing.sm),
                      Expanded(
                        child: _MiniServiceCard(
                          icon: Icons.health_and_safety_rounded,
                          label: 'التشخيص',
                          color: const Color(0xFF2E7D32),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.section)),

              // ── My Vehicles ─────────────────────────
              SliverToBoxAdapter(
                child: OcSectionHeader(
                  title: 'سياراتي',
                  actionLabel: 'إضافة',
                  onAction: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.md)),
              SliverToBoxAdapter(
                child: vehiclesAsync.when(
                  data: (vehicles) => vehicles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                          child: _EmptyVehicleCard(),
                        )
                      : SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                            itemCount: vehicles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.cardGap),
                            itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
                          ),
                        ),
                  loading: () => const SizedBox(
                    height: 110,
                    child: Center(child: CircularProgressIndicator(color: OcColors.accent)),
                  ),
                  error: (e, _) => OcErrorState(
                    message: 'تعذر تحميل السيارات',
                    onRetry: () => ref.invalidate(vehiclesProvider),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.section)),

              // ── Car Parts For Sale ──────────────────
              SliverToBoxAdapter(
                child: OcSectionHeader(
                  title: 'قطع غيار مميزة',
                  actionLabel: 'عرض الكل',
                  onAction: () => context.push('/marketplace'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.md)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildListDelegate([
                    OcProductCard(
                      name: 'فلتر زيت تويوتا كامري',
                      price: '٤٥ ر.ق',
                      category: 'فلاتر',
                      rating: 4.8,
                      discount: 15,
                      stockLeft: 12,
                      onTap: () => context.push('/marketplace'),
                    ),
                    OcProductCard(
                      name: 'بطارية فارتا ٧٠ أمبير',
                      price: '٢٨٠ ر.ق',
                      category: 'بطاريات',
                      rating: 4.9,
                      discount: 10,
                      stockLeft: 5,
                      onTap: () => context.push('/marketplace'),
                    ),
                    OcProductCard(
                      name: 'تيل فرامل نيسان سنترا',
                      price: '١٢٠ ر.ق',
                      category: 'فرامل',
                      rating: 4.5,
                      stockLeft: 8,
                      onTap: () => context.push('/marketplace'),
                    ),
                    OcProductCard(
                      name: 'زيت محرك موبيل 5W-30',
                      price: '٨٥ ر.ق',
                      category: 'زيوت',
                      rating: 5.0,
                      discount: 20,
                      stockLeft: 25,
                      onTap: () => context.push('/marketplace'),
                    ),
                  ]),
                ),
              ),

              // Bottom padding for floating nav
              SliverToBoxAdapter(
                child: SizedBox(height: OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.xl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String name;
  final int unreadCount;
  const _Header({required this.name, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand logo
        const OcLogo(size: 36, showText: true),
        const Spacer(),
        OcBadge(
          count: 0,
          child: IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: OcColors.textPrimary),
          ),
        ),
        OcBadge(
          count: unreadCount,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: OcColors.textPrimary),
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: OcColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: OcColors.border),
            ),
            child: const Icon(Icons.person_outlined, size: 20, color: OcColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// MINI SERVICE CARD — Compact 3-up row
// ═══════════════════════════════════════════════════════

class _MiniServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MiniServiceCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(OcRadius.card),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// VEHICLE CARD
// ═══════════════════════════════════════════════════════

class _VehicleCard extends StatelessWidget {
  final dynamic vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(OcSpacing.md),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: OcColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(OcRadius.sm),
                ),
                child: const Icon(Icons.directions_car_rounded, color: OcColors.accent, size: 20),
              ),
              const SizedBox(width: OcSpacing.sm),
              Expanded(
                child: Text(
                  '${vehicle.make} ${vehicle.model}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${vehicle.year}', style: const TextStyle(color: OcColors.textSecondary, fontSize: 11)),
          if (vehicle.plateNumber != null)
            Text(vehicle.plateNumber, style: const TextStyle(color: OcColors.accent, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}

class _EmptyVehicleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.card),
        border: Border.all(color: OcColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: OcColors.textMuted, size: 28),
            const SizedBox(height: 6),
            Text('أضف سيارتك الأولى', style: TextStyle(color: OcColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
