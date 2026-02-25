import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OcSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الموافقات المعلقة', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: OcSpacing.sm),
          Text('6 طلبات بانتظار الموافقة', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
          const SizedBox(height: OcSpacing.xxl),

          Expanded(
            child: ListView(
              children: const [
                _ApprovalCard(name: 'ورشة المستقبل', type: 'ورشة', phone: '+974 5555 1234', date: '2026-02-24', docs: 3),
                SizedBox(height: OcSpacing.md),
                _ApprovalCard(name: 'متجر الوفاء للقطع', type: 'متجر', phone: '+974 5555 5678', date: '2026-02-23', docs: 2),
                SizedBox(height: OcSpacing.md),
                _ApprovalCard(name: 'عبدالله حسن', type: 'سائق', phone: '+974 5555 9012', date: '2026-02-22', docs: 4),
                SizedBox(height: OcSpacing.md),
                _ApprovalCard(name: 'ورشة الأمل', type: 'ورشة', phone: '+974 5555 3456', date: '2026-02-21', docs: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String name, type, phone, date;
  final int docs;
  const _ApprovalCard({required this.name, required this.type, required this.phone, required this.date, required this.docs});

  @override
  Widget build(BuildContext context) {
    final color = type == 'ورشة' ? OcColors.primary : type == 'متجر' ? OcColors.secondary : OcColors.warning;

    return Container(
      padding: const EdgeInsets.all(OcSpacing.xl),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(OcRadius.lg)),
            child: Icon(
              type == 'ورشة' ? Icons.build_rounded : type == 'متجر' ? Icons.store_rounded : Icons.delivery_dining,
              color: color, size: 24,
            ),
          ),
          const SizedBox(width: OcSpacing.lg),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                OcStatusBadge(label: type),
              ]),
              const SizedBox(height: 4),
              Text('$phone  •  $date  •  $docs مستندات', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
            ],
          )),
          const SizedBox(width: OcSpacing.lg),
          OutlinedButton(onPressed: () {}, child: const Text('عرض المستندات')),
          const SizedBox(width: OcSpacing.sm),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check, size: 18),
            label: const Text('قبول'),
            style: ElevatedButton.styleFrom(backgroundColor: OcColors.success, foregroundColor: Colors.white),
          ),
          const SizedBox(width: OcSpacing.sm),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.close, size: 18),
            label: const Text('رفض'),
            style: ElevatedButton.styleFrom(backgroundColor: OcColors.error, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
