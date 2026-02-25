import 'package:flutter/material.dart';
import 'package:oc_ui/oc_ui.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OcSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('الطلبات', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              // Status filter chips
              ...[('الكل', true), ('جديد', false), ('قيد التجهيز', false), ('مكتمل', false)].map((e) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OcChip(label: e.$1, selected: e.$2),
              )),
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
                    DataColumn(label: Text('رقم')),
                    DataColumn(label: Text('العميل')),
                    DataColumn(label: Text('المتجر')),
                    DataColumn(label: Text('الورشة')),
                    DataColumn(label: Text('المبلغ')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('إجراء')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('ORD-4F2A')),
                      DataCell(Text('أحمد محمد')),
                      DataCell(Text('متجر الخليج')),
                      DataCell(Text('ورشة الاصالة')),
                      DataCell(Text('340 ر.ق')),
                      DataCell(OcStatusBadge(label: 'جديد')),
                      DataCell(Icon(Icons.visibility_outlined, size: 18)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('ORD-8B1C')),
                      DataCell(Text('خالد علي')),
                      DataCell(Text('قطع متحدة')),
                      DataCell(Text('ورشة النجم')),
                      DataCell(Text('175 ر.ق')),
                      DataCell(OcStatusBadge(label: 'قيد التجهيز')),
                      DataCell(Icon(Icons.visibility_outlined, size: 18)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('ORD-3E7D')),
                      DataCell(Text('فهد سالم')),
                      DataCell(Text('متجر الخليج')),
                      DataCell(Text('ورشة الفجر')),
                      DataCell(Text('890 ر.ق')),
                      DataCell(OcStatusBadge(label: 'مكتمل')),
                      DataCell(Icon(Icons.visibility_outlined, size: 18)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
