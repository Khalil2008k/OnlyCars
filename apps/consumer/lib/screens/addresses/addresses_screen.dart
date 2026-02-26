import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_models/oc_models.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('عناويني')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: OcColors.primary,
        child: const Icon(Icons.add, color: OcColors.textOnPrimary),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const OcEmptyState(
              icon: Icons.location_off_outlined,
              message: 'لا توجد عناوين\nأضف عنوان التوصيل',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(addressesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) => _AddressCard(
                address: addresses[i],
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف العنوان'),
                      content: const Text('هل تريد حذف هذا العنوان؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: OcColors.error))),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final service = ref.read(userServiceProvider);
                    await service.deleteAddress(addresses[i].id);
                    ref.invalidate(addressesProvider);
                  }
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => OcErrorState(
          message: 'تعذر تحميل العناوين',
          onRetry: () => ref.invalidate(addressesProvider),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController(text: 'بيت');
    final zoneCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final buildingCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OcColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(OcSpacing.xl, OcSpacing.xl, OcSpacing.xl, MediaQuery.of(ctx).viewInsets.bottom + OcSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('إضافة عنوان جديد', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: OcSpacing.lg),
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'الاسم (مثل: بيت، مكتب)', prefixIcon: Icon(Icons.label_outline))),
            const SizedBox(height: OcSpacing.md),
            TextField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'المنطقة', prefixIcon: Icon(Icons.location_city))),
            const SizedBox(height: OcSpacing.md),
            TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'الشارع', prefixIcon: Icon(Icons.route))),
            const SizedBox(height: OcSpacing.md),
            TextField(controller: buildingCtrl, decoration: const InputDecoration(labelText: 'المبنى', prefixIcon: Icon(Icons.apartment))),
            const SizedBox(height: OcSpacing.xl),
            OcButton(
              label: 'حفظ العنوان',
              icon: Icons.check_rounded,
              onPressed: () async {
                if (labelCtrl.text.trim().isEmpty) return;
                final service = ref.read(userServiceProvider);
                await service.addAddress(
                  label: labelCtrl.text.trim(),
                  zone: zoneCtrl.text.trim(),
                  street: streetCtrl.text.trim(),
                  building: buildingCtrl.text.trim(),
                );
                ref.invalidate(addressesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onDelete;
  const _AddressCard({required this.address, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final subtitle = [address.zone, address.street, address.building]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: address.isDefault ? OcColors.primary : OcColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OcColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: const Icon(Icons.location_on_rounded, color: OcColors.primary),
          ),
          const SizedBox(width: OcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    if (address.isDefault) ...[
                      const SizedBox(width: OcSpacing.sm),
                      OcStatusBadge(label: 'افتراضي', color: OcColors.primary),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                ],
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: OcColors.error, size: 20), onPressed: onDelete),
        ],
      ),
    );
  }
}
