import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oc_ui/oc_ui.dart';

class FindCustomerScreen extends StatefulWidget {
  const FindCustomerScreen({super.key});

  @override
  State<FindCustomerScreen> createState() => _FindCustomerScreenState();
}

class _FindCustomerScreenState extends State<FindCustomerScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _customer;

  Future<void> _search() async {
    if (_phoneCtrl.text.trim().length < 8) return;
    setState(() => _isSearching = true);

    // Mock — in production, call UserService.findByPhone
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSearching = false;
      _customer = {
        'name': 'أحمد محمد',
        'phone': '+974${_phoneCtrl.text.trim()}',
        'vehicles': [
          {'make': 'تويوتا', 'model': 'كامري', 'year': '2022', 'plate': '12345'},
          {'make': 'نيسان', 'model': 'باترول', 'year': '2023', 'plate': '67890'},
        ],
      };
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(
        title: const Text('بحث عن عميل'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(OcSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'رقم هاتف العميل',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
                const SizedBox(width: OcSpacing.md),
                OcButton(
                  label: 'بحث',
                  onPressed: _search,
                  isLoading: _isSearching,
                  icon: Icons.search,
                ),
              ],
            ),

            const SizedBox(height: OcSpacing.xxl),

            if (_customer != null) ...[
              // Customer info
              Container(
                padding: const EdgeInsets.all(OcSpacing.xl),
                decoration: BoxDecoration(
                  color: OcColors.surfaceCard,
                  borderRadius: BorderRadius.circular(OcRadius.lg),
                  border: Border.all(color: OcColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: OcColors.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: OcColors.primary),
                    ),
                    const SizedBox(width: OcSpacing.lg),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_customer!['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(_customer!['phone'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: OcColors.textSecondary)),
                      ],
                    )),
                    const Icon(Icons.check_circle, color: OcColors.success),
                  ],
                ),
              ),

              const SizedBox(height: OcSpacing.xl),
              Text('اختر السيارة', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: OcSpacing.md),

              // Vehicle list
              ...(_customer!['vehicles'] as List).map((v) => Padding(
                padding: const EdgeInsets.only(bottom: OcSpacing.sm),
                child: GestureDetector(
                  onTap: () => context.push('/workshop/diagnosis'),
                  child: Container(
                    padding: const EdgeInsets.all(OcSpacing.lg),
                    decoration: BoxDecoration(
                      color: OcColors.surfaceCard,
                      borderRadius: BorderRadius.circular(OcRadius.lg),
                      border: Border.all(color: OcColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car_rounded, color: OcColors.primary),
                        const SizedBox(width: OcSpacing.md),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${v['make']} ${v['model']} ${v['year']}', style: Theme.of(context).textTheme.titleSmall),
                            Text('اللوحة: ${v['plate']}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
                          ],
                        )),
                        const Icon(Icons.chevron_left_rounded, color: OcColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
