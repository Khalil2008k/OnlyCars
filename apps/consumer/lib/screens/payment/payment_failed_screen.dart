import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String? orderId;
  const PaymentFailedScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OcSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: OcColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_rounded, size: 72, color: OcColors.error),
              ),
              const SizedBox(height: OcSpacing.xxl),

              Text('فشل الدفع ❌', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: OcSpacing.md),
              Text(
                'لم يتم إكمال عملية الدفع. لم يتم خصم أي مبلغ. يمكنك المحاولة مرة أخرى.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OcButton(
                  label: 'إعادة المحاولة',
                  onPressed: () {
                    if (orderId != null) {
                      context.go('/checkout');
                    }
                  },
                  icon: Icons.refresh_rounded,
                ),
              ),
              const SizedBox(height: OcSpacing.md),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
