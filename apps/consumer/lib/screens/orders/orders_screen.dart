import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

/// Orders screen with demo order data
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static final _demoOrders = [
    _OrderItem(
      id: 'ORD-2026-001',
      type: 'صيانة',
      title: 'تغيير زيت + فلتر',
      workshop: 'ورشة الخليج للسيارات',
      status: 'مكتمل',
      statusColor: OcColors.success,
      total: '145.00',
      date: '25 فبراير 2026',
      items: 2,
    ),
    _OrderItem(
      id: 'ORD-2026-002',
      type: 'قطع غيار',
      title: 'بطارية فارتا 70 أمبير',
      workshop: 'قطع غيار الدوحة',
      status: 'قيد التوصيل',
      statusColor: OcColors.accent,
      total: '280.00',
      date: '24 فبراير 2026',
      items: 1,
    ),
    _OrderItem(
      id: 'ORD-2026-003',
      type: 'صيانة',
      title: 'فحص شامل 52 نقطة',
      workshop: 'مركز الريان للصيانة',
      status: 'قيد التنفيذ',
      statusColor: const Color(0xFFF57C00),
      total: '99.00',
      date: '23 فبراير 2026',
      items: 1,
    ),
    _OrderItem(
      id: 'ORD-2026-004',
      type: 'قطع غيار',
      title: 'تيل فرامل + أقراص فرامل',
      workshop: 'متجر كفرات قطر',
      status: 'مكتمل',
      statusColor: OcColors.success,
      total: '320.00',
      date: '20 فبراير 2026',
      items: 3,
    ),
    _OrderItem(
      id: 'ORD-2026-005',
      type: 'صيانة',
      title: 'تغيير كفرات (4 كفرات)',
      workshop: 'ورشة السرعة',
      status: 'ملغي',
      statusColor: OcColors.error,
      total: '1,200.00',
      date: '15 فبراير 2026',
      items: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(OcSpacing.page, OcSpacing.lg, OcSpacing.page, 0),
              child: const Text(
                'طلباتي',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
              ),
            ),
            const SizedBox(height: OcSpacing.md),

            // Filter tabs
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OcSpacing.page),
                children: const [
                  _FilterChip(label: 'الكل', selected: true),
                  SizedBox(width: 8),
                  _FilterChip(label: 'قيد التنفيذ'),
                  SizedBox(width: 8),
                  _FilterChip(label: 'مكتمل'),
                  SizedBox(width: 8),
                  _FilterChip(label: 'ملغي'),
                ],
              ),
            ),
            const SizedBox(height: OcSpacing.md),

            // Orders list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  OcSpacing.page, 0, OcSpacing.page,
                  OcSizes.navBarHeight + OcSizes.navBarBottomMargin + OcSpacing.lg,
                ),
                itemCount: _demoOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.sm),
                itemBuilder: (_, i) => _OrderCard(order: _demoOrders[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem {
  final String id, type, title, workshop, status, total, date;
  final Color statusColor;
  final int items;

  const _OrderItem({
    required this.id, required this.type, required this.title,
    required this.workshop, required this.status, required this.statusColor,
    required this.total, required this.date, required this.items,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? OcColors.accent : OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.pill),
        border: Border.all(color: selected ? OcColors.accent : OcColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? OcColors.onAccent : OcColors.textPrimary,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderItem order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: order ID + status
          Row(
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.type == 'صيانة'
                      ? OcColors.accent.withValues(alpha: 0.12)
                      : const Color(0xFF1976D2).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(OcRadius.sm),
                ),
                child: Text(
                  order.type,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: order.type == 'صيانة' ? OcColors.accent : const Color(0xFF1976D2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(order.id, style: const TextStyle(fontSize: 12, color: OcColors.textMuted, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(OcRadius.sm),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: order.statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            order.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
          ),
          const SizedBox(height: 6),

          // Workshop + items
          Row(
            children: [
              const Icon(Icons.build_circle_rounded, size: 14, color: OcColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.workshop,
                  style: const TextStyle(fontSize: 12, color: OcColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${order.items} عنصر',
                style: const TextStyle(fontSize: 12, color: OcColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Divider
          Container(height: 1, color: OcColors.border),
          const SizedBox(height: 10),

          // Footer: date + total
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: OcColors.textMuted),
              const SizedBox(width: 4),
              Text(
                order.date,
                style: const TextStyle(fontSize: 12, color: OcColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${order.total} ر.ق',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
