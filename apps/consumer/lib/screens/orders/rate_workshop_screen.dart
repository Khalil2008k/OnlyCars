import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class RateWorkshopScreen extends StatefulWidget {
  final String orderId;
  const RateWorkshopScreen({super.key, required this.orderId});

  @override
  State<RateWorkshopScreen> createState() => _RateWorkshopScreenState();
}

class _RateWorkshopScreenState extends State<RateWorkshopScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تقييماً من 1 إلى 5')),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: submit review to Supabase
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شكراً! تم إرسال التقييم')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('تقييم الورشة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: OcSpacing.xxl),

            // Stars
            Text(
              'كيف كانت تجربتك؟',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OcSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: starIndex <= _rating ? OcColors.warning : OcColors.textSecondary,
                      size: 44,
                    ),
                  ),
                );
              }),
            ),

            if (_rating > 0) ...[
              const SizedBox(height: OcSpacing.sm),
              Text(
                _ratingLabel(_rating),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: OcColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],

            const SizedBox(height: OcSpacing.xxxl),

            // Comment
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'أضف تعليقاً (اختياري)...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: OcSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: OcButton(
                label: 'إرسال التقييم',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'سيء';
      case 2: return 'مقبول';
      case 3: return 'جيد';
      case 4: return 'جيد جداً';
      case 5: return 'ممتاز';
      default: return '';
    }
  }
}
