import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

final billDetailProvider =
    FutureProvider.family<WorkshopBill?, String>((ref, id) async {
  final service = ref.read(billServiceProvider);
  return await service.getBillById(id);
});

class WorkshopBillScreen extends ConsumerWidget {
  final String billId;
  const WorkshopBillScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billDetailProvider(billId));

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('فاتورة الورشة'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: billAsync.when(
        data: (bill) {
          if (bill == null) return const OcErrorState(message: 'الفاتورة غير موجودة');

          final workshopName = bill.workshop?['name_ar'] ?? 'ورشة';
          final isActionable = bill.status == 'submitted';

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(billDetailProvider(billId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Align(
                    alignment: Alignment.centerRight,
                    child: OcStatusBadge(
                      label: _statusLabel(bill.status),
                      color: _statusColor(bill.status),
                    ),
                  ),
                  const SizedBox(height: OcSpacing.lg),

                  // Workshop info card
                  Container(
                    padding: const EdgeInsets.all(OcSpacing.xl),
                    decoration: BoxDecoration(
                      color: OcColors.surfaceCard,
                      borderRadius: BorderRadius.circular(OcRadius.lg),
                      border: Border.all(color: OcColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: OcColors.primary.withValues(alpha: 0.2),
                          child: const Icon(Icons.build_rounded, color: OcColors.primary),
                        ),
                        const SizedBox(width: OcSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(workshopName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                'فاتورة #${billId.substring(0, 8)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textDarkSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (bill.orderId.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.receipt_long_rounded, color: OcColors.primary),
                            onPressed: () => context.push('/order/${bill.orderId}'),
                            tooltip: 'عرض الطلب',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Work description
                  if (bill.descriptionAr != null && bill.descriptionAr!.isNotEmpty) ...[
                    Text('وصف العمل', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: OcSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      decoration: BoxDecoration(
                        color: OcColors.surfaceCard,
                        borderRadius: BorderRadius.circular(OcRadius.lg),
                        border: Border.all(color: OcColors.border),
                      ),
                      child: Text(
                        bill.descriptionAr!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: OcSpacing.xxl),
                  ],

                  // Photos
                  if (bill.photoUrls.isNotEmpty) ...[
                    Text('صور العمل', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: OcSpacing.md),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: bill.photoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.md),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(OcRadius.lg),
                          child: Image.network(
                            bill.photoUrls[i],
                            width: 180,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: OcSpacing.xxl),
                  ],

                  // Amount card
                  Container(
                    padding: const EdgeInsets.all(OcSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [OcColors.primary, OcColors.primaryDark]),
                      borderRadius: BorderRadius.circular(OcRadius.xl),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('مبلغ العمالة', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: OcColors.onAccent)),
                        Text(
                          '${bill.laborAmount.toStringAsFixed(0)} ر.ق',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: OcColors.onAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Date
                  if (bill.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: OcSpacing.xl),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: OcColors.textSecondary),
                          const SizedBox(width: OcSpacing.sm),
                          Text(
                            '${bill.createdAt!.day}/${bill.createdAt!.month}/${bill.createdAt!.year}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textDarkSecondary),
                          ),
                        ],
                      ),
                    ),

                  // Action buttons
                  if (isActionable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OcButton(
                            label: 'الموافقة والدفع',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('تأكيد الموافقة'),
                                  content: Text('هل تريد الموافقة على فاتورة بمبلغ ${bill.laborAmount.toStringAsFixed(0)} ر.ق؟'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم، موافق')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await ref.read(billServiceProvider).approveBill(billId);
                                ref.invalidate(billDetailProvider(billId));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم الموافقة على الفاتورة ✓')),
                                  );
                                }
                              }
                            },
                            icon: Icons.check_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: OcSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDisputeDialog(context, ref),
                            icon: const Icon(Icons.report_problem_outlined),
                            label: const Text('نزاع'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              foregroundColor: OcColors.error,
                              side: const BorderSide(color: OcColors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل الفاتورة',
          onRetry: () => ref.invalidate(billDetailProvider(billId)),
        ),
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, WidgetRef ref) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('سبب النزاع'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اشرح سبب عدم موافقتك...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await ref.read(billServiceProvider).disputeBill(billId, reasonCtrl.text.trim());
              ref.invalidate(billDetailProvider(billId));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال النزاع')),
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'submitted' => 'بانتظار الموافقة',
        'approved' => 'تمت الموافقة',
        'disputed' => 'منازع عليها',
        'paid' => 'مدفوعة',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'submitted' => OcColors.warning,
        'approved' => OcColors.success,
        'disputed' => OcColors.error,
        'paid' => OcColors.info,
        _ => OcColors.textSecondary,
      };
}
