import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OcSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('المستخدمون', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: 280,
                child: TextField(decoration: const InputDecoration(hintText: 'بحث بالاسم أو الهاتف...', prefixIcon: Icon(Icons.search))),
              ),
            ],
          ),
          const SizedBox(height: OcSpacing.xl),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: OcColors.surfaceCard,
                borderRadius: BorderRadius.circular(OcRadius.lg),
                border: Border.all(color: OcColors.border),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(OcColors.surfaceLight),
                  columns: const [
                    DataColumn(label: Text('الاسم')),
                    DataColumn(label: Text('الهاتف')),
                    DataColumn(label: Text('الأدوار')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('تاريخ الانضمام')),
                    DataColumn(label: Text('إجراء')),
                  ],
                  rows: [
                    _userRow('أحمد محمد', '+974 5000 1234', 'مستهلك', true, '2026-01-15', context),
                    _userRow('خالد علي', '+974 5000 5678', 'مستهلك، صاحب ورشة', true, '2026-01-20', context),
                    _userRow('فهد سالم', '+974 5000 9012', 'سائق', true, '2026-02-01', context),
                    _userRow('ناصر حمد', '+974 5000 3456', 'صاحب متجر', false, '2026-02-10', context),
                    _userRow('محمد سعيد', '+974 5000 7890', 'مستهلك', true, '2026-02-20', context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _userRow(String name, String phone, String roles, bool active, String date, BuildContext ctx) {
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(phone)),
      DataCell(Text(roles, style: TextStyle(color: OcColors.textSecondary, fontSize: 13))),
      DataCell(OcStatusBadge(label: active ? 'نشط' : 'موقوف')),
      DataCell(Text(date)),
      DataCell(Row(children: [
        IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () {}),
        IconButton(icon: Icon(active ? Icons.block : Icons.check_circle_outline, size: 18, color: active ? OcColors.error : OcColors.success), onPressed: () {}),
      ])),
    ]);
  }
}
