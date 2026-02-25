import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String? orderId;
  const PaymentSuccessScreen({super.key, this.orderId});

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

              // Success animation
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: OcColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 72, color: OcColors.success),
              ),
              const SizedBox(height: OcSpacing.xxl),

              Text('تم الدفع بنجاح! ✅', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: OcSpacing.md),
              Text(
                'شكراً لك. تم تأكيد طلبك وسيتم تجهيزه في أقرب وقت.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),

              if (orderId != null) ...[
                const SizedBox(height: OcSpacing.xl),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: OcColors.surfaceCard,
                    borderRadius: BorderRadius.circular(OcRadius.lg),
                    border: Border.all(color: OcColors.border),
                  ),
                  child: Text(
                    'رقم الطلب: #${orderId!.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: OcButton(
                  label: 'تتبع الطلب',
                  onPressed: () {
                    if (orderId != null) {
                      Navigator.of(context).pushReplacementNamed('/order/$orderId');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/orders');
                    }
                  },
                  icon: Icons.local_shipping_rounded,
                ),
              ),
              const SizedBox(height: OcSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
