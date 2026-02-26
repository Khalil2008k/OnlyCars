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
  String _paymentMethod = 'cod';
  String? _selectedAddressId;
  bool _isPlacing = false;

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final cartNotifier = ref.read(cartProvider.notifier);

    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر عنوان التوصيل')),
      );
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final orderService = ref.read(orderServiceProvider);
      final order = await orderService.createOrder(
        items: cartNotifier.toOrderItems(),
        deliveryAddressId: _selectedAddressId,
      );

      // Create payment record
      final paymentService = ref.read(paymentServiceProvider);
      await paymentService.createPayment(
        orderId: order.id,
        amount: order.total,
        type: _paymentMethod,
      );

      cartNotifier.clear();

      if (!mounted) return;
      context.go('/payment/success?order=${order.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء الطلب: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final addressesAsync = ref.watch(addressesProvider);

    final partsTotal = cartNotifier.totalPrice;
    final deliveryFee = 15.0;
    final platformFee = partsTotal * 0.05;
    final grandTotal = partsTotal + deliveryFee + platformFee;

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address selection
            Text('عنوان التوصيل', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            addressesAsync.when(
              data: (addresses) {
                if (addresses.isEmpty) {
                  return OutlinedButton.icon(
                    onPressed: () => context.push('/addresses'),
                    icon: const Icon(Icons.add_location_rounded),
                    label: const Text('أضف عنوان'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  );
                }

                // Auto-select first or default address
                if (_selectedAddressId == null) {
                  final def = addresses.where((a) => a.isDefault).firstOrNull;
                  _selectedAddressId = def?.id ?? addresses.first.id;
                }

                return Column(
                  children: addresses.map((addr) => RadioListTile<String>(
                    value: addr.id,
                    groupValue: _selectedAddressId,
                    onChanged: (v) => setState(() => _selectedAddressId = v),
                    title: Text(addr.label),
                    subtitle: Text([addr.zone, addr.street, addr.building].where((s) => s != null && s.isNotEmpty).join(', ')),
                    contentPadding: EdgeInsets.zero,
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('تعذر تحميل العناوين'),
            ),

            const SizedBox(height: OcSpacing.xl),

            // Order summary
            Text('ملخص الطلب', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            Container(
              padding: const EdgeInsets.all(OcSpacing.lg),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: Column(
                children: [
                  // Items
                  ...cart.values.map((ci) => Padding(
                    padding: const EdgeInsets.only(bottom: OcSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text('${ci.part.nameAr} × ${ci.quantity}', style: Theme.of(context).textTheme.bodyMedium)),
                        Text('${(ci.part.price * ci.quantity).toStringAsFixed(0)} ر.ق', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),

                  const Divider(height: OcSpacing.xl),

                  _SummaryRow(label: 'إجمالي القطع', value: '${partsTotal.toStringAsFixed(0)} ر.ق'),
                  const SizedBox(height: OcSpacing.sm),
                  _SummaryRow(label: 'رسوم التوصيل', value: '${deliveryFee.toStringAsFixed(0)} ر.ق'),
                  const SizedBox(height: OcSpacing.sm),
                  _SummaryRow(label: 'رسوم المنصة (5%)', value: '${platformFee.toStringAsFixed(0)} ر.ق'),

                  const Divider(height: OcSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: Theme.of(context).textTheme.titleMedium),
                      Text('${grandTotal.toStringAsFixed(0)} ر.ق', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: OcColors.primary, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: OcSpacing.xl),

            // Payment method
            Text('طريقة الدفع', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: OcSpacing.md),

            _PaymentOption(
              icon: Icons.money_rounded,
              label: 'الدفع عند الاستلام',
              value: 'cod',
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: OcSpacing.sm),
            _PaymentOption(
              icon: Icons.credit_card_rounded,
              label: 'بطاقة ائتمان',
              value: 'card',
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              subtitle: 'قريباً',
              enabled: false,
            ),

            const SizedBox(height: OcSpacing.xxl),

            // Place order button
            SizedBox(
              width: double.infinity,
              child: OcButton(
                label: 'تأكيد الطلب',
                icon: Icons.check_circle_rounded,
                onPressed: _placeOrder,
                isLoading: _isPlacing,
              ),
            ),

            const SizedBox(height: OcSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final String? subtitle;
  final bool enabled;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: OcColors.surfaceCard,
          borderRadius: BorderRadius.circular(OcRadius.md),
          border: Border.all(color: value == groupValue ? OcColors.primary : OcColors.border),
        ),
        child: RadioListTile<String>(
          value: value,
          groupValue: groupValue,
          onChanged: enabled ? onChanged : null,
          secondary: Icon(icon, color: OcColors.primary),
          title: Text(label),
          subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: OcColors.textSecondary)) : null,
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
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
