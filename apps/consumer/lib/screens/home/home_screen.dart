import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
            ref.invalidate(vehiclesProvider);
            ref.invalidate(activeOrderCountProvider);
            ref.invalidate(unreadNotifCountProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(OcSpacing.xl),
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

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.xl),
                  child: _QuickActions(
                    activeOrders: ordersAsync.valueOrNull ?? 0,
                  ),
                ),
              ),

              // My Vehicles
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(OcSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'سياراتي',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('إضافة'),
                          ),
                        ],
                      ),
                      const SizedBox(height: OcSpacing.md),
                      vehiclesAsync.when(
                        data: (vehicles) => vehicles.isEmpty
                            ? _EmptyVehicleCard()
                            : SizedBox(
                                height: 130,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: vehicles.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: OcSpacing.md),
                                  itemBuilder: (_, i) =>
                                      _VehicleCard(vehicle: vehicles[i]),
                                ),
                              ),
                        loading: () => const SizedBox(
                          height: 130,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => OcErrorState(
                          message: 'تعذر تحميل السيارات',
                          onRetry: () => ref.invalidate(vehiclesProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activity placeholder
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OcSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النشاط الأخير',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: OcSpacing.md),
                      _ActivityCard(
                        icon: Icons.build_circle_rounded,
                        color: OcColors.info,
                        title: 'ابحث عن ورشة',
                        subtitle: 'اعثر على أفضل الورش القريبة منك',
                      ),
                      const SizedBox(height: OcSpacing.md),
                      _ActivityCard(
                        icon: Icons.shopping_bag_rounded,
                        color: OcColors.secondary,
                        title: 'سوق قطع الغيار',
                        subtitle: 'تصفح آلاف القطع بأفضل الأسعار',
                      ),
                      const SizedBox(height: OcSpacing.md),
                      _ActivityCard(
                        icon: Icons.health_and_safety_rounded,
                        color: OcColors.success,
                        title: 'سجل صحة السيارة',
                        subtitle: 'تابع حالة سيارتك وصيانتها',
                      ),
                      const SizedBox(height: OcSpacing.xxxl),
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

// ===== HEADER =====
class _Header extends StatelessWidget {
  final String name;
  final int unreadCount;
  const _Header({required this.name, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: OcColors.primary,
            borderRadius: BorderRadius.circular(OcRadius.md),
          ),
          child: const Center(
            child: Text('OC', style: TextStyle(
              color: OcColors.textOnPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: OcColors.textSecondary,
                    ),
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        OcBadge(
          count: unreadCount,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }
}

// ===== QUICK ACTIONS =====
class _QuickActions extends StatelessWidget {
  final int activeOrders;
  const _QuickActions({required this.activeOrders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OcColors.primary.withValues(alpha: 0.15),
            OcColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Icons.build_circle_rounded,
            label: 'الورش',
            color: OcColors.primary,
          ),
          _QuickAction(
            icon: Icons.shopping_bag_rounded,
            label: 'القطع',
            color: OcColors.secondary,
          ),
          _QuickAction(
            icon: Icons.receipt_long_rounded,
            label: 'الطلبات',
            badge: activeOrders,
            color: OcColors.info,
          ),
          _QuickAction(
            icon: Icons.chat_rounded,
            label: 'المحادثات',
            color: OcColors.success,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badge;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OcBadge(
          count: badge,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: OcSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: OcColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

// ===== VEHICLE CARD =====
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
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded,
                  color: OcColors.primary, size: 28),
              const SizedBox(width: OcSpacing.sm),
              Expanded(
                child: Text(
                  '${vehicle.make} ${vehicle.model}',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: OcSpacing.sm),
          Text(
            '${vehicle.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OcColors.textSecondary,
                ),
          ),
          if (vehicle.plateNumber != null)
            Text(
              vehicle.plateNumber,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OcColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
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
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: OcColors.textSecondary, size: 32),
            const SizedBox(height: OcSpacing.sm),
            Text(
              'أضف سيارتك الأولى',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OcColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== ACTIVITY CARD =====
class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: OcSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OcColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
        ],
      ),
    );
  }
}
