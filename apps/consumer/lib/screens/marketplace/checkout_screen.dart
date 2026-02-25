import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);

    // TODO: call place-order Edge Function
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Clear cart
    ref.read(cartProvider.notifier).clear();

    // Show success
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: OcColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.xl)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: OcSpacing.lg),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: OcColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: OcColors.success, size: 48),
            ),
            const SizedBox(height: OcSpacing.xl),
            Text('تم تأكيد الطلب', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: OcSpacing.sm),
            Text('سيتم إشعارك بتحديثات الطلب', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
            const SizedBox(height: OcSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: OcButton(
                label: 'تتبع الطلب',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/orders');
                },
                icon: Icons.local_shipping_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery address
            Text('عنوان التوصيل', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),
            Container(
              padding: const EdgeInsets.all(OcSpacing.lg),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: OcColors.primary),
                  const SizedBox(width: OcSpacing.md),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الدوحة — المنطقة الصناعية', style: Theme.of(context).textTheme.titleSmall),
                      Text('شارع 10، مبنى 45', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                    ],
                  )),
                  TextButton(onPressed: () {}, child: const Text('تغيير')),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Payment method
            Text('طريقة الدفع', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _PaymentOption(
              icon: Icons.payments_rounded,
              title: 'الدفع عند الاستلام',
              subtitle: 'ادفع نقداً للسائق',
              value: 'cash',
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),
            const SizedBox(height: OcSpacing.sm),
            _PaymentOption(
              icon: Icons.credit_card_rounded,
              title: 'Sadad',
              subtitle: 'البطاقة البنكية — خدمة سداد',
              value: 'sadad',
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Order summary
            Text('ملخص الطلب', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            Container(
              padding: const EdgeInsets.all(OcSpacing.xl),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'المجموع الفرعي', value: '265 ر.ق'),
                  const SizedBox(height: OcSpacing.sm),
                  _SummaryRow(label: 'رسوم التوصيل', value: '25 ر.ق'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: OcSpacing.md),
                    child: Divider(color: OcColors.border),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('290 ر.ق', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: OcButton(
                label: 'تأكيد الطلب',
                onPressed: _placeOrder,
                isLoading: _isLoading,
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, value, groupValue;
  final ValueChanged<String> onChanged;
  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(OcSpacing.lg),
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.lg),
          border: Border.all(color: isSelected ? OcColors.primary : OcColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? OcColors.primary : OcColors.textSecondary),
            const SizedBox(width: OcSpacing.md),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
              ],
            )),
            Radio<String>(value: value, groupValue: groupValue, onChanged: (v) => onChanged(v!)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
