import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oc_ui/oc_ui.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _orders = true;
  bool _chat = true;
  bool _promos = true;
  bool _diagnosis = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orders = prefs.getBool('notif_orders') ?? true;
      _chat = prefs.getBool('notif_chat') ?? true;
      _promos = prefs.getBool('notif_promos') ?? true;
      _diagnosis = prefs.getBool('notif_diagnosis') ?? true;
      _loaded = true;
    });
  }

  Future<void> _save(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OcColors.background,
      appBar: AppBar(title: const Text('إعدادات الإشعارات')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(OcSpacing.xl),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: OcColors.surfaceCard,
                    borderRadius: BorderRadius.circular(OcRadius.lg),
                    border: Border.all(color: OcColors.border),
                  ),
                  child: Column(
                    children: [
                      _NotifToggle(
                        icon: Icons.receipt_long_rounded,
                        label: 'تحديثات الطلبات',
                        subtitle: 'حالة الطلب، التوصيل، التأكيد',
                        value: _orders,
                        onChanged: (v) { setState(() => _orders = v); _save('notif_orders', v); },
                      ),
                      const Divider(height: 1, indent: 52),
                      _NotifToggle(
                        icon: Icons.chat_rounded,
                        label: 'رسائل المحادثة',
                        subtitle: 'رسائل جديدة من الورش والمتاجر',
                        value: _chat,
                        onChanged: (v) { setState(() => _chat = v); _save('notif_chat', v); },
                      ),
                      const Divider(height: 1, indent: 52),
                      _NotifToggle(
                        icon: Icons.local_offer_rounded,
                        label: 'العروض والتخفيضات',
                        subtitle: 'عروض خاصة وتخفيضات موسمية',
                        value: _promos,
                        onChanged: (v) { setState(() => _promos = v); _save('notif_promos', v); },
                      ),
                      const Divider(height: 1, indent: 52),
                      _NotifToggle(
                        icon: Icons.assignment_rounded,
                        label: 'تقارير الفحص',
                        subtitle: 'تقارير فحص جديدة من الورشة',
                        value: _diagnosis,
                        onChanged: (v) { setState(() => _diagnosis = v); _save('notif_diagnosis', v); },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotifToggle({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: OcColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(OcRadius.sm)),
        child: Icon(icon, size: 18, color: OcColors.primary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: OcColors.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeColor: OcColors.primary,
    );
  }
}
