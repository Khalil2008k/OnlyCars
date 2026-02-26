import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              separatorBuilder: (_, __) => const SizedBox(height: OcSpacing.md),
              itemBuilder: (_, i) {
                final entry = cart.entries.elementAt(i);
                final ci = entry.value;
                return _CartItemCard(
                  cartItem: ci,
                  onAdd: () => cartNotifier.add(ci.part),
                  onRemove: () => cartNotifier.remove(ci.part.id),
                );
              },
            ),
          ),

          // Checkout bar
          Container(
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
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${cartNotifier.totalPrice.toStringAsFixed(0)} ر.ق',
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
                      onPressed: () => context.push('/checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final part = cartItem.part;
    final imageUrl = part.imageUrls.isNotEmpty ? part.imageUrls.first : null;

    return Container(
      padding: const EdgeInsets.all(OcSpacing.md),
      decoration: BoxDecoration(
        color: OcColors.surfaceCard,
        borderRadius: BorderRadius.circular(OcRadius.lg),
        border: Border.all(color: OcColors.border),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OcColors.surfaceLight,
              borderRadius: BorderRadius.circular(OcRadius.md),
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null
                ? const Icon(Icons.image_outlined, color: OcColors.textSecondary)
                : null,
          ),
          const SizedBox(width: OcSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.nameAr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${part.price.toStringAsFixed(0)} ر.ق',
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
                  '${cartItem.quantity}',
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
