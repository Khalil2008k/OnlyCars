import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('لوحة السائق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/roles'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability toggle
            Container(
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isAvailable
                      ? [OcColors.success, OcColors.success.withValues(alpha: 0.7)]
                      : [OcColors.textSecondary, OcColors.textSecondary.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAvailable ? 'متاح للتوصيل' : 'غير متاح',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: OcColors.textOnPrimary, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isAvailable ? 'ستصلك طلبات التوصيل القريبة' : 'لن تتلقى طلبات جديدة',
                        style: TextStyle(color: OcColors.textOnPrimary.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  )),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xl),

            // Stats
            Row(
              children: [
                Expanded(child: _DriverStat(title: 'توصيلات اليوم', value: '5', icon: Icons.local_shipping_rounded)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _DriverStat(title: 'أرباح اليوم', value: '185 ر.ق', icon: Icons.payments_rounded)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _DriverStat(title: 'التقييم', value: '4.9', icon: Icons.star_rounded)),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            Text('طلبات التوصيل المعلقة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _DeliveryCard(
              shopName: 'متجر الخليج للقطع',
              workshopName: 'ورشة الاصالة',
              items: 3,
              distance: '4.2 كم',
              fee: '25 ر.ق',
            ),
            const SizedBox(height: OcSpacing.sm),
            _DeliveryCard(
              shopName: 'قطع السيارات المتحدة',
              workshopName: 'ورشة النجم',
              items: 1,
              distance: '7.8 كم',
              fee: '35 ر.ق',
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverStat extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _DriverStat({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.md),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: OcColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final String shopName, workshopName, distance, fee;
  final int items;
  const _DeliveryCard({required this.shopName, required this.workshopName, required this.items, required this.distance, required this.fee});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.store_rounded, size: 16, color: OcColors.secondary),
              const SizedBox(width: 6),
              Expanded(child: Text(shopName, style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.build_rounded, size: 16, color: OcColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(workshopName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary))),
            ],
          ),
          const SizedBox(height: OcSpacing.md),
          Row(
            children: [
              OcStatusBadge(label: '$items قطع'),
              const SizedBox(width: OcSpacing.sm),
              OcStatusBadge(label: distance),
              const Spacer(),
              Text(fee, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: OcSpacing.md),
          SizedBox(width: double.infinity, child: OcButton(label: 'قبول التوصيلة', onPressed: () {}, icon: Icons.check_rounded)),
        ],
      ),
    );
  }
}
