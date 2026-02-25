import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class ProviderOnboardingScreen extends ConsumerStatefulWidget {
  final String role; // 'workshop' | 'driver' | 'shop'
  const ProviderOnboardingScreen({super.key, required this.role});

  @override
  ConsumerState<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends ConsumerState<ProviderOnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _crNumberCtrl = TextEditingController();
  int _uploadedDocs = 0;

  String get _roleTitle {
    switch (widget.role) {
      case 'workshop': return 'تسجيل ورشة';
      case 'driver': return 'تسجيل سائق';
      case 'shop': return 'تسجيل متجر';
      default: return 'تسجيل';
    }
  }

  String get _roleIcon {
    switch (widget.role) {
      case 'workshop': return '🔧';
      case 'driver': return '🚗';
      case 'shop': return '🏪';
      default: return '📋';
    }
  }

  Future<void> _submit() async {
    if (_businessNameCtrl.text.trim().isEmpty || _ownerNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')));
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

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
              decoration: BoxDecoration(color: OcColors.warning.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.schedule_rounded, color: OcColors.warning, size: 40),
            ),
            const SizedBox(height: OcSpacing.xl),
            Text('تم إرسال طلبك', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: OcSpacing.sm),
            Text(
              'طلبك قيد المراجعة من فريق الإدارة.\nسيتم إشعارك خلال ٢٤-٤٨ ساعة.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OcSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: OcButton(label: 'حسناً', onPressed: () {
                Navigator.of(context).pop();
                context.go('/roles');
              }, icon: Icons.check_rounded),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _crNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: Text(_roleTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          // Progress dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: OcSpacing.lg, horizontal: OcSpacing.xl),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _currentPage ? OcColors.primary : OcColors.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: [
                // Page 1: Business info
                _buildPage1(),
                // Page 2: Documents
                _buildPage2(),
                // Page 3: Review & confirm
                _buildPage3(),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(OcSpacing.xl),
            decoration: const BoxDecoration(
              color: OcColors.surfaceCard,
              border: Border(top: BorderSide(color: OcColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                        child: const Text('السابق'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: OcSpacing.md),
                  Expanded(
                    child: OcButton(
                      label: _currentPage < 2 ? 'التالي' : 'إرسال الطلب',
                      onPressed: _currentPage < 2
                          ? () => _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                          : _submit,
                      isLoading: _isSubmitting,
                      icon: _currentPage < 2 ? Icons.arrow_back_rounded : Icons.send_rounded,
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

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OcSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text(_roleIcon, style: const TextStyle(fontSize: 48))),
          const SizedBox(height: OcSpacing.lg),
          Center(child: Text('معلومات ${widget.role == 'driver' ? 'السائق' : 'النشاط'}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(height: OcSpacing.xxl),

          if (widget.role != 'driver') ...[
            TextField(controller: _businessNameCtrl, decoration: const InputDecoration(labelText: 'اسم النشاط التجاري *', prefixIcon: Icon(Icons.business_rounded))),
            const SizedBox(height: OcSpacing.lg),
          ],
          TextField(controller: _ownerNameCtrl, decoration: InputDecoration(labelText: widget.role == 'driver' ? 'الاسم الكامل *' : 'اسم المالك *', prefixIcon: const Icon(Icons.person_rounded))),
          const SizedBox(height: OcSpacing.lg),
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف *', prefixIcon: Icon(Icons.phone_rounded), prefixText: '+974 ')),
          const SizedBox(height: OcSpacing.lg),
          TextField(controller: _addressCtrl, decoration: InputDecoration(labelText: widget.role == 'driver' ? 'المنطقة *' : 'العنوان *', prefixIcon: const Icon(Icons.location_on_rounded))),
          if (widget.role != 'driver') ...[
            const SizedBox(height: OcSpacing.lg),
            TextField(controller: _crNumberCtrl, decoration: const InputDecoration(labelText: 'رقم السجل التجاري *', prefixIcon: Icon(Icons.badge_rounded))),
          ],
        ],
      ),
    );
  }

  Widget _buildPage2() {
    final docs = widget.role == 'driver'
        ? ['رخصة القيادة', 'بطاقة الهوية', 'تأمين السيارة']
        : ['السجل التجاري', 'بطاقة الهوية', 'رخصة النشاط', 'عقد الإيجار'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OcSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('📄', style: TextStyle(fontSize: 48))),
          const SizedBox(height: OcSpacing.lg),
          Center(child: Text('المستندات المطلوبة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(height: OcSpacing.xxl),

          ...docs.asMap().entries.map((e) {
            final uploaded = e.key < _uploadedDocs;
            return Container(
              margin: const EdgeInsets.only(bottom: OcSpacing.md),
              padding: const EdgeInsets.all(OcSpacing.lg),
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: uploaded ? OcColors.success : OcColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                    color: uploaded ? OcColors.success : OcColors.textSecondary,
                  ),
                  const SizedBox(width: OcSpacing.md),
                  Expanded(child: Text(e.value, style: Theme.of(context).textTheme.titleSmall)),
                  if (!uploaded)
                    TextButton(
                      onPressed: () => setState(() => _uploadedDocs = e.key + 1),
                      child: const Text('رفع'),
                    )
                  else
                    Text('✓ تم', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.success)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OcSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('✅', style: TextStyle(fontSize: 48))),
          const SizedBox(height: OcSpacing.lg),
          Center(child: Text('مراجعة البيانات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(height: OcSpacing.xxl),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(OcSpacing.xl),
            decoration: BoxDecoration(color: OcColors.surfaceCard, borderRadius: BorderRadius.circular(OcRadius.lg), border: Border.all(color: OcColors.border)),
            child: Column(
              children: [
                if (widget.role != 'driver') _ReviewRow(label: 'اسم النشاط', value: _businessNameCtrl.text.isEmpty ? '—' : _businessNameCtrl.text),
                _ReviewRow(label: widget.role == 'driver' ? 'الاسم' : 'المالك', value: _ownerNameCtrl.text.isEmpty ? '—' : _ownerNameCtrl.text),
                _ReviewRow(label: 'الهاتف', value: _phoneCtrl.text.isEmpty ? '—' : '+974 ${_phoneCtrl.text}'),
                _ReviewRow(label: widget.role == 'driver' ? 'المنطقة' : 'العنوان', value: _addressCtrl.text.isEmpty ? '—' : _addressCtrl.text),
                if (widget.role != 'driver') _ReviewRow(label: 'السجل التجاري', value: _crNumberCtrl.text.isEmpty ? '—' : _crNumberCtrl.text),
                _ReviewRow(label: 'المستندات', value: '$_uploadedDocs مرفوعة'),
              ],
            ),
          ),

          const SizedBox(height: OcSpacing.xl),
          Container(
            padding: const EdgeInsets.all(OcSpacing.lg),
            decoration: BoxDecoration(
              color: OcColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(OcRadius.lg),
              border: Border.all(color: OcColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: OcColors.warning),
                const SizedBox(width: OcSpacing.md),
                Expanded(child: Text(
                  'بالضغط على "إرسال الطلب"، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OcSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: OcColors.textSecondary)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
