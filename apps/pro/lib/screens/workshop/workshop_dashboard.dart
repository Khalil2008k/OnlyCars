import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class WorkshopDashboard extends StatelessWidget {
  const WorkshopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('لوحة الورشة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/roles'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text('مرحباً 👋', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: OcSpacing.sm),
            Text('ورشة الاصالة', style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: OcColors.primary, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: OcSpacing.xl),

            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(title: 'طلبات نشطة', value: '3', icon: Icons.pending_actions, color: OcColors.primary)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _StatCard(title: 'مكتملة اليوم', value: '7', icon: Icons.check_circle_outline, color: OcColors.success)),
              ],
            ),
            const SizedBox(height: OcSpacing.md),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'أرباح الأسبوع', value: '1,250 ر.ق', icon: Icons.account_balance_wallet_outlined, color: OcColors.secondary)),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: _StatCard(title: 'التقييم', value: '4.8 ⭐', icon: Icons.star_outline, color: OcColors.warning)),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Quick actions
            Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _ActionTile(icon: Icons.person_search_rounded, title: 'بحث عن عميل', subtitle: 'ابحث برقم الهاتف وأنشئ تقرير فحص', color: OcColors.primary, onTap: () {}),
            const SizedBox(height: OcSpacing.sm),
            _ActionTile(icon: Icons.receipt_long_rounded, title: 'إنشاء فاتورة', subtitle: 'أنشئ فاتورة عمل بعد إكمال طلب', color: OcColors.secondary, onTap: () {}),
            const SizedBox(height: OcSpacing.sm),
            _ActionTile(icon: Icons.history_rounded, title: 'سجل الطلبات', subtitle: 'عرض جميع الطلبات السابقة', color: OcColors.warning, onTap: () {}),

            const SizedBox(height: OcSpacing.xxl),

            // Active jobs
            Text('الطلبات النشطة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _JobCard(customerName: 'أحمد محمد', vehicle: 'تويوتا كامري 2022', status: 'بانتظار القطع', time: 'منذ ساعتين'),
            const SizedBox(height: OcSpacing.sm),
            _JobCard(customerName: 'خالد علي', vehicle: 'نيسان باترول 2023', status: 'جاري العمل', time: 'منذ 45 دقيقة'),
            const SizedBox(height: OcSpacing.sm),
            _JobCard(customerName: 'محمد سعيد', vehicle: 'هوندا أكورد 2021', status: 'جاهز للتسليم', time: 'منذ 15 دقيقة'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: OcSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(OcRadius.md)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: OcSpacing.md),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
              ],
            )),
            const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String customerName, vehicle, status, time;
  const _JobCard({required this.customerName, required this.vehicle, required this.status, required this.time});

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
              Expanded(child: Text(customerName, style: Theme.of(context).textTheme.titleSmall)),
              OcStatusBadge(label: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(vehicle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
          const SizedBox(height: 4),
          Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
        ],
      ),
    );
  }
}
