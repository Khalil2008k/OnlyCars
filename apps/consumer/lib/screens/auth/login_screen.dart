import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_api/oc_api.dart';
import 'package:oc_ui/oc_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = '+974${_phoneController.text.trim()}';
      final authService = AuthService();
      await authService.signInWithOtp(phone);

      if (!mounted) return;
      context.go('/otp?phone=${Uri.encodeComponent(phone)}');
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ. تأكد من الرقم وحاول مرة أخرى';
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
        child: Padding(
          padding: const EdgeInsets.all(OcSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: OcColors.primary,
                      borderRadius: BorderRadius.circular(OcRadius.lg),
                    ),
                    child: const Center(
                      child: Text(
                        'OC',
                        style: TextStyle(
                          color: OcColors.textOnPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: OcSpacing.xxl),

                Text(
                  'تسجيل الدخول',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: OcSpacing.sm),

                Text(
                  'أدخل رقم هاتفك القطري',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OcColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: OcSpacing.xxxl),

                // Phone input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🇶🇦',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '+974',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: OcColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      counterText: '',
                      hintText: '3XXXXXXX',
                      hintStyle: const TextStyle(
                        color: OcColors.textSecondary,
                        letterSpacing: 4,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length != 8) {
                        return 'أدخل رقم هاتف صحيح';
                      }
                      if (!RegExp(r'^[3-7]\d{7}$').hasMatch(value.trim())) {
                        return 'رقم هاتف قطري غير صالح';
                      }
                      return null;
                    },
                  ),
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

                OcButton(
                  label: 'إرسال الرمز',
                  onPressed: _sendOtp,
                  isLoading: _isLoading,
                  icon: Icons.sms_outlined,
                ),

                const Spacer(flex: 3),

                // Terms
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
}
