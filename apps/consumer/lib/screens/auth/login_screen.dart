import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';

/// Two-step sign up: 1) Name + car info  2) Phone + terms + OTP
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String? _errorMessage;
  int _step = 0; // 0 = details, 1 = phone
  String _selectedCarType = '';

  final _carTypes = ['سيدان', 'دفع رباعي', 'بيك أب', 'هاتشباك', 'كوبيه', 'أخرى'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToPhoneStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'يجب الموافقة على الشروط والأحكام');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = '+974${_phoneController.text.trim()}';
      final authService = AuthService();
      await authService.signInWithOtp(phone);

      if (!mounted) return;
      context.go('/otp?phone=${Uri.encodeComponent(phone)}&name=${Uri.encodeComponent(_nameController.text.trim())}');
    } catch (e) {
      debugPrint('🔴 OTP error: $e');
      setState(() {
        _errorMessage = 'خطأ: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OcSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: OcLogo(
                    size: 90,
                    assetPath: OcLogoAssets.vertical,
                  ),
                ),

                const SizedBox(height: OcSpacing.xl),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepDot(active: true, label: '1'),
                    Container(width: 40, height: 2, color: _step >= 1 ? OcColors.accent : OcColors.border),
                    _StepDot(active: _step >= 1, label: '2'),
                  ],
                ),

                const SizedBox(height: OcSpacing.lg),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0 ? _buildDetailsStep() : _buildPhoneStep(),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: OcSpacing.md),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: OcColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: OcSpacing.xl),

                // Action button
                OcButton(
                  label: _step == 0 ? 'التالي' : 'إرسال رمز التحقق',
                  onPressed: _step == 0 ? _goToPhoneStep : _sendOtp,
                  isLoading: _isLoading,
                  icon: _step == 0 ? Icons.arrow_back_rounded : Icons.sms_outlined,
                ),

                if (_step == 1) ...[
                  const SizedBox(height: OcSpacing.sm),
                  TextButton(
                    onPressed: () => setState(() {
                      _step = 0;
                      _errorMessage = null;
                    }),
                    child: const Text('رجوع', style: TextStyle(color: OcColors.textSecondary)),
                  ),
                ],

                const SizedBox(height: OcSpacing.md),

                // Dev skip
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text(
                    'تخطي (وضع التطوير)',
                    style: TextStyle(color: OcColors.textSecondary, fontSize: 13),
                  ),
                ),

                const SizedBox(height: OcSpacing.xxl),

                Text(
                  'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OcColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      key: const ValueKey('step_details'),
      children: [
        Text(
          'مرحباً بك! 👋',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: OcSpacing.sm),
        Text(
          'أخبرنا عنك لنقدم لك أفضل خدمة',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: OcSpacing.xxl),

        // Name field
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            hintText: 'الاسم',
            prefixIcon: Icon(Icons.person_outline_rounded, color: OcColors.textMuted),
          ),
          validator: (v) {
            if (v == null || v.trim().length < 2) return 'أدخل اسمك';
            return null;
          },
        ),

        const SizedBox(height: OcSpacing.lg),

        // Car type selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع سيارتك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary)),
            const SizedBox(height: OcSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _carTypes.map((type) => GestureDetector(
                onTap: () => setState(() => _selectedCarType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCarType == type ? OcColors.accent : OcColors.surfaceCard,
                    borderRadius: BorderRadius.circular(OcRadius.pill),
                    border: Border.all(
                      color: _selectedCarType == type ? OcColors.accent : OcColors.border,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _selectedCarType == type ? OcColors.onAccent : OcColors.textPrimary,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      key: const ValueKey('step_phone'),
      children: [
        Text(
          'تأكيد الرقم',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: OcSpacing.sm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: OcColors.textSecondary),
            children: [
              const TextSpan(text: 'مرحباً '),
              TextSpan(
                text: _nameController.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.w700, color: OcColors.accent),
              ),
              const TextSpan(text: '، أدخل رقمك للتحقق'),
            ],
          ),
        ),
        const SizedBox(height: OcSpacing.xxl),

        // Phone input
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 8,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 4),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇶🇦', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 6),
                    Text('+974', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: OcColors.textSecondary)),
                  ],
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              counterText: '',
              hintText: '3XXXXXXX',
              hintStyle: const TextStyle(color: OcColors.textSecondary, letterSpacing: 4),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 8) return 'أدخل رقم هاتف صحيح';
              if (!RegExp(r'^[3-7]\d{7}$').hasMatch(value.trim())) return 'رقم هاتف قطري غير صالح';
              return null;
            },
          ),
        ),

        const SizedBox(height: OcSpacing.lg),

        // Terms & conditions checkbox
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _agreedToTerms ? OcColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreedToTerms ? OcColors.accent : OcColors.border,
                    width: 2,
                  ),
                ),
                child: _agreedToTerms
                    ? const Icon(Icons.check_rounded, size: 16, color: OcColors.onAccent)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/terms'),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: OcColors.textSecondary, height: 1.5),
                      children: [
                        const TextSpan(text: 'أوافق على '),
                        TextSpan(
                          text: 'الشروط والأحكام',
                          style: TextStyle(
                            color: OcColors.accent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' و'),
                        TextSpan(
                          text: 'سياسة الخصوصية',
                          style: TextStyle(
                            color: OcColors.accent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: active ? OcColors.accent : OcColors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: active ? OcColors.accent : OcColors.border, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? OcColors.onAccent : OcColors.textMuted,
          ),
        ),
      ),
    );
  }
}
