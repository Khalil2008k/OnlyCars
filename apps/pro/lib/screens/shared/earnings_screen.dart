import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('الأرباح'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OcSpacing.xxl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [OcColors.primary, OcColors.secondary]),
                borderRadius: BorderRadius.circular(OcRadius.xl),
              ),
              child: Column(
                children: [
                  Text('الرصيد الحالي', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                  const SizedBox(height: OcSpacing.md),
                  Text('2,450', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                  Text('ر.ق', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70)),
                  const SizedBox(height: OcSpacing.xl),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.account_balance_rounded, size: 18),
                      label: const Text('سحب للحساب البنكي'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: OcColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Period stats
            Row(
              children: [
                _EarningStat(label: 'اليوم', value: '180 ر.ق', icon: Icons.today_rounded),
                const SizedBox(width: OcSpacing.md),
                _EarningStat(label: 'هذا الأسبوع', value: '720 ر.ق', icon: Icons.date_range_rounded),
                const SizedBox(width: OcSpacing.md),
                _EarningStat(label: 'هذا الشهر', value: '2,450 ر.ق', icon: Icons.calendar_month_rounded),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Recent transactions
            Text('العمليات الأخيرة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            ...[
              _TransactionTile(title: 'طلب #A3F2E1', amount: '+85 ر.ق', date: 'اليوم ١٠:٣٠ ص', isCredit: true),
              _TransactionTile(title: 'طلب #B7C4D9', amount: '+120 ر.ق', date: 'اليوم ٩:١٥ ص', isCredit: true),
              _TransactionTile(title: 'سحب بنكي', amount: '-500 ر.ق', date: 'أمس', isCredit: false),
              _TransactionTile(title: 'طلب #F1E2D3', amount: '+95 ر.ق', date: 'أمس', isCredit: true),
              _TransactionTile(title: 'طلب #C8B9A0', amount: '+220 ر.ق', date: '23 فبراير', isCredit: true),
              _TransactionTile(title: 'عمولة المنصة', amount: '-45 ر.ق', date: '23 فبراير', isCredit: false),
            ],
          ],
        ),
      ),
    );
  }
}

class _EarningStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _EarningStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: OcColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: OcColors.primary),
            const SizedBox(height: OcSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title, amount, date;
  final bool isCredit;
  const _TransactionTile({required this.title, required this.amount, required this.date, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: OcSpacing.sm),
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? OcColors.success : OcColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? OcColors.success : OcColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: OcSpacing.md),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(date, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
            ],
          )),
          Text(amount, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isCredit ? OcColors.success : OcColors.error,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}
