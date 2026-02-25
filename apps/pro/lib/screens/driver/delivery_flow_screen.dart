import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class DeliveryFlowScreen extends StatefulWidget {
  final String deliveryId;
  const DeliveryFlowScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryFlowScreen> createState() => _DeliveryFlowScreenState();
}

class _DeliveryFlowScreenState extends State<DeliveryFlowScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _steps = [
    {'title': 'التوجه للمتجر', 'subtitle': 'متجر الخليج للقطع', 'icon': Icons.store_rounded},
    {'title': 'استلام الطلب', 'subtitle': 'التقط صورة للطرد', 'icon': Icons.camera_alt_rounded},
    {'title': 'التوجه للورشة', 'subtitle': 'ورشة الاصالة', 'icon': Icons.build_rounded},
    {'title': 'تأكيد التسليم', 'subtitle': 'التقط صورة عند التسليم', 'icon': Icons.where_to_vote_rounded},
  ];

  Future<void> _nextStep() async {
    if (_currentStep >= _steps.length - 1) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التسليم بنجاح! الأرباح تم تحويلها ✓')));
      context.pop();
      return;
    }
    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: Text('توصيلة #${widget.deliveryId.substring(0, 6)}'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: OcColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation(OcColors.primary),
            minHeight: 4,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(OcSpacing.xl),
              child: Column(
                children: [
                  const Spacer(),

                  // Current step
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: OcColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_steps[_currentStep]['icon'] as IconData, size: 48, color: OcColors.primary),
                  ),
                  const SizedBox(height: OcSpacing.xl),

                  Text(
                    _steps[_currentStep]['title'] as String,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OcSpacing.sm),
                  Text(
                    _steps[_currentStep]['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: OcSpacing.xxl),

                  // Step dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) => Container(
                      width: i == _currentStep ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? OcColors.primary : OcColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),

                  const Spacer(),

                  // Action buttons
                  if (_currentStep == 1 || _currentStep == 3) ...[
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('التقاط صورة'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    ),
                    const SizedBox(height: OcSpacing.md),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OcButton(
                      label: _currentStep < _steps.length - 1 ? 'التالي' : 'تأكيد التسليم',
                      onPressed: _nextStep,
                      isLoading: _isLoading,
                      icon: _currentStep < _steps.length - 1 ? Icons.arrow_back_rounded : Icons.check_circle_rounded,
                    ),
                  ),

                  if (_currentStep == 0) ...[
                    const SizedBox(height: OcSpacing.md),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('فتح الخريطة'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
