import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

/// Terms of Service & Privacy Policy screen
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('الشروط والأحكام')),
      body: ListView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        children: [
          // Logo
          Center(
            child: OcLogo(size: 60, assetPath: OcLogoAssets.horizontal),
          ),
          const SizedBox(height: OcSpacing.xxl),

          _SectionTitle('شروط الاستخدام'),
          const SizedBox(height: OcSpacing.md),
          _Paragraph('باستخدامك لتطبيق OnlyCars، فإنك توافق على الالتزام بهذه الشروط والأحكام. يرجى قراءتها بعناية قبل استخدام التطبيق.'),
          const SizedBox(height: OcSpacing.lg),

          _BulletPoint('يجب أن يكون عمرك 18 عاماً أو أكثر لاستخدام التطبيق'),
          _BulletPoint('أنت مسؤول عن الحفاظ على سرية بيانات حسابك'),
          _BulletPoint('يحق لنا تعليق أو إلغاء حسابك في حال مخالفة الشروط'),
          _BulletPoint('جميع الأسعار المعروضة بالريال القطري وقابلة للتغيير'),
          _BulletPoint('الورش المعتمدة هي المسؤولة عن جودة خدماتها'),
          _BulletPoint('التطبيق ليس بديلاً عن الاستشارة الفنية المتخصصة'),

          const SizedBox(height: OcSpacing.xxl),

          _SectionTitle('سياسة الخصوصية'),
          const SizedBox(height: OcSpacing.md),
          _Paragraph('نحن نأخذ خصوصيتك على محمل الجد. تشرح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك الشخصية.'),
          const SizedBox(height: OcSpacing.lg),

          _SubTitle('البيانات التي نجمعها'),
          _BulletPoint('الاسم ورقم الهاتف وعنوان البريد الإلكتروني'),
          _BulletPoint('بيانات السيارة (النوع، الموديل، سنة الصنع)'),
          _BulletPoint('الموقع الجغرافي (للعثور على ورش قريبة)'),
          _BulletPoint('سجل الطلبات والمحادثات'),

          const SizedBox(height: OcSpacing.lg),

          _SubTitle('كيف نستخدم بياناتك'),
          _BulletPoint('تقديم وتحسين خدماتنا'),
          _BulletPoint('إرسال إشعارات حول طلباتك وعروض مخصصة'),
          _BulletPoint('ضمان أمان التطبيق ومنع الاحتيال'),
          _BulletPoint('تحليل الاستخدام لتحسين تجربة المستخدم'),

          const SizedBox(height: OcSpacing.lg),

          _SubTitle('حقوقك'),
          _BulletPoint('يمكنك طلب حذف بياناتك في أي وقت'),
          _BulletPoint('يمكنك تعديل معلوماتك الشخصية من إعدادات الحساب'),
          _BulletPoint('يمكنك إلغاء اشتراكك في الإشعارات التسويقية'),

          const SizedBox(height: OcSpacing.xxl),

          _SectionTitle('سياسة الاسترجاع'),
          const SizedBox(height: OcSpacing.md),
          _BulletPoint('يمكن إرجاع قطع الغيار خلال 7 أيام من الاستلام'),
          _BulletPoint('يجب أن تكون القطعة في حالتها الأصلية وبدون استخدام'),
          _BulletPoint('رسوم خدمات الورش غير قابلة للاسترجاع بعد البدء بالعمل'),
          _BulletPoint('يتم معالجة طلبات الاسترجاع خلال 3-5 أيام عمل'),

          const SizedBox(height: OcSpacing.xxl),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OcColors.surfaceCard,
              borderRadius: BorderRadius.circular(OcRadius.card),
            ),
            child: Column(
              children: [
                Text(
                  'آخر تحديث: فبراير 2026',
                  style: TextStyle(fontSize: 12, color: OcColors.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  'للاستفسار: support@onlycars.qa',
                  style: TextStyle(fontSize: 12, color: OcColors.accent),
                ),
              ],
            ),
          ),

          const SizedBox(height: OcSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: OcColors.textPrimary));
  }
}

class _SubTitle extends StatelessWidget {
  final String text;
  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: OcColors.textPrimary)),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, color: OcColors.textSecondary, height: 1.7));
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 7, left: 8),
            decoration: BoxDecoration(color: OcColors.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: OcColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
