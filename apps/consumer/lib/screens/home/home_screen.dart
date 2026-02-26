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
    final ordersAsync = ref.watch(activeOrderCountProvider);
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
            ref.invalidate(activeOrderCountProvider);
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
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.xl)),

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
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.section)),

              // ── Quick Actions ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                  child: _QuickActions(activeOrders: ordersAsync.valueOrNull ?? 0),
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
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                            itemCount: vehicles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.cardGap),
                            itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
                          ),
                        ),
                  loading: () => const SizedBox(
                    height: 130,
                    child: Center(child: CircularProgressIndicator(color: OcColors.accent)),
                  ),
                  error: (e, _) => OcErrorState(
                    message: 'تعذر تحميل السيارات',
                    onRetry: () => ref.invalidate(vehiclesProvider),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.section)),

              // ── Explore Section ────────────────────
              SliverToBoxAdapter(
                child: OcSectionHeader(title: 'خدمات OnlyCars', actionLabel: 'الكل'),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: OcSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                  child: Column(
                    children: [
                      _ServiceCard(
                        icon: Icons.build_circle_rounded,
                        color: OcColors.accent,
                        title: 'ابحث عن ورشة',
                        subtitle: 'اعثر على أفضل الورش القريبة منك',
                        onTap: () => context.push('/workshops'),
                      ),
                      const SizedBox(height: OcSpacing.cardGap),
                      _ServiceCard(
                        icon: Icons.shopping_bag_rounded,
                        color: OcColors.accent,
                        title: 'سوق قطع الغيار',
                        subtitle: 'تصفح آلاف القطع بأفضل الأسعار',
                        onTap: () => context.push('/marketplace'),
                      ),
                      const SizedBox(height: OcSpacing.cardGap),
                      _ServiceCard(
                        icon: Icons.health_and_safety_rounded,
                        color: OcColors.accent,
                        title: 'سجل صحة السيارة',
                        subtitle: 'تابع حالة سيارتك وصيانتها',
                        onTap: () {},
                      ),
                      // Bottom padding for floating nav
                      const SizedBox(height: OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HEADER — Logo + User + Cart/Notifications
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
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: OcColors.accent,
            borderRadius: BorderRadius.circular(OcRadius.md),
          ),
          child: const Center(
            child: Text('OC', style: TextStyle(
              color: OcColors.onAccent,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            )),
          ),
        ),
        const SizedBox(width: OcSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً 👋',
                style: TextStyle(color: OcColors.textMuted, fontSize: 12),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: OcColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Cart
        OcBadge(
          count: 0,
          child: IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: OcColors.textPrimary),
          ),
        ),
        // Notifications
        OcBadge(
          count: unreadCount,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: OcColors.textPrimary),
          ),
        ),
        // Menu
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded, color: OcColors.textPrimary),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// QUICK ACTIONS — 4 icon buttons in a row
// ═══════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  final int activeOrders;
  const _QuickActions({required this.activeOrders});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickAction(icon: Icons.build_circle_rounded, label: 'الورش', color: OcColors.accent),
        _QuickAction(icon: Icons.shopping_bag_rounded, label: 'القطع', color: OcColors.accent),
        _QuickAction(icon: Icons.receipt_long_rounded, label: 'الطلبات', badge: activeOrders, color: OcColors.accent),
        _QuickAction(icon: Icons.chat_rounded, label: 'المحادثات', color: OcColors.accent),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badge;
  const _QuickAction({required this.icon, required this.label, required this.color, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OcBadge(
          count: badge,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(OcRadius.lg),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: OcSpacing.sm),
        Text(
          label,
          style: const TextStyle(color: OcColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// VEHICLE CARD — Horizontal scroll
// ═══════════════════════════════════════════════════════

class _VehicleCard extends StatelessWidget {
  final dynamic vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(OcSpacing.lg),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OcColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(OcRadius.sm),
                ),
                child: const Icon(Icons.directions_car_rounded, color: OcColors.accent, size: 24),
              ),
              const SizedBox(width: OcSpacing.sm),
              Expanded(
                child: Text(
                  '${vehicle.make} ${vehicle.model}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: OcSpacing.sm),
          Text(
            '${vehicle.year}',
            style: const TextStyle(color: OcColors.textSecondary, fontSize: 12),
          ),
          if (vehicle.plateNumber != null)
            Text(
              vehicle.plateNumber,
              style: const TextStyle(color: OcColors.accent, fontWeight: FontWeight.w600, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _EmptyVehicleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(OcSpacing.xl),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.card),
        border: Border.all(color: OcColors.border, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: OcColors.textMuted, size: 32),
            const SizedBox(height: OcSpacing.sm),
            Text(
              'أضف سيارتك الأولى',
              style: TextStyle(color: OcColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SERVICE CARD — Explore section items
// ═══════════════════════════════════════════════════════

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ServiceCard({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.card),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(OcRadius.md),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: OcSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: OcColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: OcColors.textMuted),
          ],
        ),
      ),
    );
  }
}
