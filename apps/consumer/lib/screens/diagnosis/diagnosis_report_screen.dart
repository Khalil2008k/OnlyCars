import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

final diagnosisDetailProvider =
    FutureProvider.family<DiagnosisReport?, String>((ref, id) async {
  final service = ref.read(diagnosisServiceProvider);
  return await service.getReportById(id);
});

class DiagnosisReportScreen extends ConsumerWidget {
  final String reportId;
  const DiagnosisReportScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(diagnosisDetailProvider(reportId));

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('تقرير الفحص'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: reportAsync.when(
        data: (report) {
          if (report == null) return const OcErrorState(message: 'التقرير غير موجود');

          final workshopName = report.workshop?['name_ar'] ?? 'ورشة';
          final vehicle = report.vehicle;
          final vehicleMake = vehicle?['make'] ?? '';
          final vehicleModel = vehicle?['model'] ?? '';
          final vehicleYear = vehicle?['year']?.toString() ?? '';
          final vehiclePlate = vehicle?['plate_number'] ?? '';
          final diagnosisParts = report.parts ?? [];

          // Calculate parts cost estimate
          double partsEstimate = 0;
          // Note: DiagnosisPart doesn't have price, just names + quantities

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(diagnosisDetailProvider(reportId)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(OcSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [OcColors.primary, OcColors.primaryDark]),
                      borderRadius: BorderRadius.circular(OcRadius.xl),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_outlined, size: 40, color: OcColors.onAccent),
                        const SizedBox(height: OcSpacing.md),
                        Text(
                          'تقرير فحص #${reportId.substring(0, 6)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: OcColors.onAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (report.createdAt != null)
                          Text(
                            '${report.createdAt!.day}/${report.createdAt!.month}/${report.createdAt!.year}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        const SizedBox(height: OcSpacing.sm),
                        OcStatusBadge(
                          label: _statusLabel(report.status),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Workshop
                  _SectionCard(title: 'الورشة', icon: Icons.build_rounded, children: [
                    Padding(
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      child: GestureDetector(
                        onTap: () => context.push('/workshop/${report.workshopId}'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: OcColors.primary.withValues(alpha: 0.15),
                              child: const Icon(Icons.build_rounded, size: 16, color: OcColors.primary),
                            ),
                            const SizedBox(width: OcSpacing.md),
                            Expanded(child: Text(workshopName, style: Theme.of(context).textTheme.titleSmall)),
                            const Icon(Icons.chevron_left_rounded, size: 20, color: OcColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: OcSpacing.lg),

                  // Vehicle
                  if (vehicle != null)
                    _SectionCard(title: 'السيارة', icon: Icons.directions_car_rounded, children: [
                      _DetailRow(label: 'الشركة/الموديل', value: '$vehicleMake $vehicleModel $vehicleYear'),
                      if (vehiclePlate.isNotEmpty)
                        _DetailRow(label: 'رقم اللوحة', value: vehiclePlate),
                    ]),

                  const SizedBox(height: OcSpacing.lg),

                  // Issue description
                  _SectionCard(title: 'المشكلة', icon: Icons.report_problem_outlined, children: [
                    Padding(
                      padding: const EdgeInsets.all(OcSpacing.lg),
                      child: Text(
                        report.issueDescriptionAr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ),
                  ]),

                  const SizedBox(height: OcSpacing.lg),

                  // Required parts
                  if (diagnosisParts.isNotEmpty)
                    _SectionCard(
                      title: 'القطع المطلوبة (${diagnosisParts.length})',
                      icon: Icons.inventory_2_outlined,
                      children: diagnosisParts.map((p) => _PartRow(
                        name: p.partNameAr,
                        qty: p.quantity,
                        partNumber: p.partNumber,
                      )).toList(),
                    ),

                  const SizedBox(height: OcSpacing.lg),

                  // Photos
                  if (report.photoUrls.isNotEmpty) ...[
                    Text('صور الفحص', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: OcSpacing.md),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: report.photoUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: OcSpacing.sm),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(OcRadius.md),
                          child: Image.network(
                            report.photoUrls[i],
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: OcSpacing.xxl),
                  ],

                  // Labor estimate
                  if (report.laborQuote != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(OcSpacing.xl),
                      decoration: BoxDecoration(
                        color: OcColors.surfaceCard,
                        borderRadius: BorderRadius.circular(OcRadius.lg),
                        border: Border.all(color: OcColors.border),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(label: 'تكلفة العمالة (تقديري)', value: '${report.laborQuote!.toStringAsFixed(0)} ر.ق'),
                        ],
                      ),
                    ),
                    const SizedBox(height: OcSpacing.xxl),
                  ],

                  // Action buttons
                  if (report.status == 'draft' || report.status == 'sent') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OcButton(
                            label: 'طلب القطع',
                            onPressed: () => context.push('/marketplace'),
                            icon: Icons.shopping_cart_rounded,
                          ),
                        ),
                        const SizedBox(width: OcSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ref.read(diagnosisServiceProvider).updateReportStatus(reportId, 'approved');
                              ref.invalidate(diagnosisDetailProvider(reportId));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تمت الموافقة على التقرير ✓')),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('موافقة'),
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
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
          message: 'تعذر تحميل التقرير',
          onRetry: () => ref.invalidate(diagnosisDetailProvider(reportId)),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'draft' => 'مسودة',
        'sent' => 'مرسل',
        'approved' => 'تمت الموافقة',
        'rejected' => 'مرفوض',
        _ => status,
      };
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(OcSpacing.lg),
            child: Row(children: [
              Icon(icon, size: 20, color: OcColors.primary),
              const SizedBox(width: OcSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
          const Divider(height: 1, color: OcColors.border),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg, vertical: OcSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textDarkSecondary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final String name;
  final int qty;
  final String? partNumber;
  const _PartRow({required this.name, required this.qty, this.partNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OcSpacing.lg, vertical: OcSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                if (partNumber != null && partNumber!.isNotEmpty)
                  Text(partNumber!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
              ],
            ),
          ),
          Text('×$qty', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textDarkSecondary)),
        ],
      ),
    );
  }
}
