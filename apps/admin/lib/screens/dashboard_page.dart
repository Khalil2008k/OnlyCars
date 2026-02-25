import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OcSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لوحة التحكم', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: OcSpacing.sm),
          Text('آخر تحديث: منذ دقيقة', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
          const SizedBox(height: OcSpacing.xxl),

          // KPI cards
          Wrap(
            spacing: OcSpacing.lg,
            runSpacing: OcSpacing.lg,
            children: const [
              _KpiCard(title: 'إجمالي المستخدمين', value: '1,234', change: '+12%', icon: Icons.people_rounded, color: OcColors.primary),
              _KpiCard(title: 'طلبات اليوم', value: '47', change: '+8%', icon: Icons.shopping_cart_rounded, color: OcColors.secondary),
              _KpiCard(title: 'إيرادات اليوم', value: '12,500 ر.ق', change: '+15%', icon: Icons.payments_rounded, color: OcColors.success),
              _KpiCard(title: 'موافقات معلقة', value: '6', change: '', icon: Icons.pending_actions_rounded, color: OcColors.warning),
              _KpiCard(title: 'نزاعات نشطة', value: '2', change: '', icon: Icons.gavel_rounded, color: OcColors.error),
              _KpiCard(title: 'الورش النشطة', value: '28', change: '+3', icon: Icons.build_rounded, color: OcColors.primary),
            ],
          ),

          const SizedBox(height: OcSpacing.xxxl),

          // Recent orders table
          Text('أحدث الطلبات', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: OcSpacing.lg),

          Container(
            decoration: BoxDecoration(
              color: OcColors.surfaceCard,
              borderRadius: BorderRadius.circular(OcRadius.lg),
              border: Border.all(color: OcColors.border),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(OcColors.surfaceLight),
              columns: const [
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('العميل')),
                DataColumn(label: Text('المبلغ')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('التاريخ')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('ORD-4F2A')),
                  DataCell(Text('أحمد محمد')),
                  DataCell(Text('340 ر.ق')),
                  DataCell(OcStatusBadge(label: 'جديد')),
                  DataCell(Text('2026-02-25')),
                ]),
                DataRow(cells: [
                  DataCell(Text('ORD-8B1C')),
                  DataCell(Text('خالد علي')),
                  DataCell(Text('175 ر.ق')),
                  DataCell(OcStatusBadge(label: 'قيد التجهيز')),
                  DataCell(Text('2026-02-25')),
                ]),
                DataRow(cells: [
                  DataCell(Text('ORD-3E7D')),
                  DataCell(Text('فهد سالم')),
                  DataCell(Text('890 ر.ق')),
                  DataCell(OcStatusBadge(label: 'مكتمل')),
                  DataCell(Text('2026-02-24')),
                ]),
                DataRow(cells: [
                  DataCell(Text('ORD-9C4E')),
                  DataCell(Text('محمد ناصر')),
                  DataCell(Text('520 ر.ق')),
                  DataCell(OcStatusBadge(label: 'تم التوصيل')),
                  DataCell(Text('2026-02-24')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value, change;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.title, required this.value, required this.change, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(OcSpacing.xl),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(OcRadius.md)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (change.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: OcColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(OcRadius.sm),
                  ),
                  child: Text(change, style: const TextStyle(color: OcColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: OcSpacing.lg),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
        ],
      ),
    );
  }
}
