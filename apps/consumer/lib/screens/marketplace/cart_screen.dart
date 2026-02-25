import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_ui/oc_ui.dart';
import '../../providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: OcColors.background,
        appBar: AppBar(title: const Text('السلة')),
        body: const OcEmptyState(
          icon: Icons.shopping_cart_outlined,
          message: 'سلتك فارغة\nابدأ بإضافة قطع غيار من المتجر',
        ),
      );
    }

    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: Text('السلة (${cartNotifier.totalItems})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              cartNotifier.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تفريغ السلة')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(OcSpacing.lg),
              itemCount: cart.length,
              separatorBuilder: (_, _) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) {
                final partId = cart.keys.elementAt(i);
                final qty = cart[partId]!;
                return _CartItemCard(
                  partId: partId,
                  quantity: qty,
                  onAdd: () => cartNotifier.add(partId),
                  onRemove: () => cartNotifier.remove(partId),
                );
              },
            ),
          ),

          // Workshop code + checkout
          _CheckoutBar(cart: cart),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final String partId;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.partId,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.md),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OcColors.surfaceLight,
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: const Icon(Icons.image_outlined, color: OcColors.textSecondary),
          ),
          const SizedBox(width: OcSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قطعة #${partId.substring(0, 6)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '-- ر.ق',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: OcColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: OcColors.surfaceLight,
              borderRadius: BorderRadius.circular(OcRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: onRemove,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: onAdd,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatefulWidget {
  final Map<String, int> cart;
  const _CheckoutBar({required this.cart});

  @override
  State<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<_CheckoutBar> {
  final _codeCtrl = TextEditingController();
  bool _isValidCode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OcSpacing.lg),
      decoration: const BoxDecoration(
        color: OcColors.surfaceCard,
        border: Border(top: BorderSide(color: OcColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Workshop code
            TextField(
              controller: _codeCtrl,
              decoration: InputDecoration(
                hintText: 'كود الورشة (اختياري)',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                suffixIcon: _isValidCode
                    ? const Icon(Icons.check_circle, color: OcColors.success)
                    : null,
              ),
              onChanged: (val) {
                setState(() => _isValidCode = val.length == 6);
              },
            ),
            const SizedBox(height: OcSpacing.md),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '-- ر.ق',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: OcColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: OcSpacing.md),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: OcButton(
                label: 'إتمام الطلب',
                icon: Icons.payment_rounded,
                onPressed: () {
                  // TODO: checkout flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سيتم ربط الدفع قريباً')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
