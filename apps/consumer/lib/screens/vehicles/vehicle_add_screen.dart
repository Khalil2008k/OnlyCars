import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class VehicleAddScreen extends ConsumerStatefulWidget {
  const VehicleAddScreen({super.key});

  @override
  ConsumerState<VehicleAddScreen> createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends ConsumerState<VehicleAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: save vehicle to Supabase via UserService
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة السيارة بنجاح')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('إضافة سيارة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Car icon
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: OcColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(OcRadius.xl),
                  ),
                  child: const Icon(Icons.directions_car_rounded, size: 40, color: OcColors.primary),
                ),
              ),
              const SizedBox(height: OcSpacing.xxl),

              _buildField('الشركة المصنعة', _makeCtrl, 'مثال: تويوتا', true),
              const SizedBox(height: OcSpacing.lg),
              _buildField('الموديل', _modelCtrl, 'مثال: كامري', true),
              const SizedBox(height: OcSpacing.lg),

              Row(
                children: [
                  Expanded(child: _buildField('سنة الصنع', _yearCtrl, '2024', true, isNumber: true)),
                  const SizedBox(width: OcSpacing.md),
                  Expanded(child: _buildField('اللون', _colorCtrl, 'أبيض', false)),
                ],
              ),
              const SizedBox(height: OcSpacing.lg),

              _buildField('رقم اللوحة', _plateCtrl, 'مثال: 12345', true),
              const SizedBox(height: OcSpacing.lg),
              _buildField('رقم الهيكل (VIN)', _vinCtrl, '17 حرف/رقم', false),

              const SizedBox(height: OcSpacing.xxxl),

              OcButton(
                label: 'حفظ السيارة',
                onPressed: _save,
                isLoading: _isLoading,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, bool required, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null
          : null,
    );
  }
}
