import 'package:admin/screens/orderpaid/components/view_order_form_paid.dart';
import 'package:admin/utility/extensions.dart';
import 'package:admin/utility/functions.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';

class OrderListSectionPaid extends StatelessWidget {
  const OrderListSectionPaid({Key? key}) : super(key: key);

  String _money(BuildContext ctx, double? v) =>
      v == null ? '-' : formatCurrencyReal(ctx, v);

  @override
  Widget build(BuildContext context) {
    // ✅ فقط لیست allsOrders استفاده میشه
    final orders =
        context.select<DataProvider, List<Order>>((p) => p.allsOrders);

    final rows = <DataRow>[
      for (int i = 0; i < orders.length; i++)
        _orderDataRow(context, orders[i], i + 1),

      // ✅ ردیف انتهایی فقط پیام ساده، بدون لودینگ یا hasMore
      // const DataRow(
      //   cells: [
      //     DataCell(
      //       Padding(
      //         padding: EdgeInsets.symmetric(vertical: 12.0),
      //         child: Center(
      //           child: Text(
      //             'پایان لیست سفارشات',
      //             style: TextStyle(color: Colors.grey),
      //           ),
      //         ),
      //       ),
      //     ),
      //     DataCell(SizedBox.shrink()),
      //     DataCell(SizedBox.shrink()),
      //     DataCell(SizedBox.shrink()),
      //     DataCell(SizedBox.shrink()),
      //     DataCell(SizedBox.shrink()),
      //     DataCell(SizedBox.shrink()),
      //   ],
      // ),
      // ✅ ردیف انتهایی فقط پیام ساده، بدون لودینگ یا hasMore
      const

      DataRow(
        cells: [
          DataCell(
            Center( // 🔽 اضافه شود
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'پایان لیست سفارشات',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
          DataCell(Center(child: SizedBox.shrink())), // 🔽 اضافه شود
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth; // عرض واقعی همین کارت
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 👈 اسکرول افقی در صورت لزوم
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w), // 👈 حداقل = عرض کارت
              child: SingleChildScrollView(
                // 👈 اسکرول عمودی مثل قبل
                child:

                // DataTable(
                //   columnSpacing: defaultPadding,
                //   columns: const [
                //     DataColumn(label: Text("نام مشتری")),
                //     DataColumn(label: Text("مبلغ سفارش")),
                //     DataColumn(label: Text("نوع سفارش")),
                //     // 🔽 تغییر از "پرداخت" به "نوع سفارش"
                //
                //     DataColumn(label: Text("وضعیت")),
                //     DataColumn(label: Text("تاریخ")),
                //     DataColumn(label: Text("ویرایش")),
                //     DataColumn(label: Text("حذف")),
                //   ],
                //   rows: rows,
                // ),
                DataTable(
                  columnSpacing: defaultPadding,
                  columns: [
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("نام مشتری"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("مبلغ سفارش"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("نوع سفارش"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("وضعیت"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("تاریخ"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("ویرایش"),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Center(
                          child: Text("حذف"),
                        ),
                      ),
                    ),
                  ],
                  rows: rows,
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  DataRow _orderDataRow(BuildContext context, Order orderInfo, int index) {
    return DataRow(
      cells: [
        DataCell(
          Center( // 🔽 اضافه شود
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 🔽 اضافه شود
              children: [
                Container(
                  height: 24,
                  width: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    index.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Text(orderInfo.userName ?? 'کاربر نامشخص'),
              ],
            ),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: Text(_money(context, orderInfo.orderTotal?.total) ?? '0.00'),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: _buildOrderModeCell(orderInfo),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(orderInfo.orderStatus),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _statusFa(orderInfo.orderStatus ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: Text(
              '${formatToJalali(orderInfo.orderDate.toString())}\n${getTimeAgo(orderInfo.orderDate ?? '')}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center, // 🔽 اضافه شود
            ),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: IconButton(
              tooltip: 'ویرایش سفارش',
              onPressed: () {
                context.orderPaidProvider.loadOrderForUpdate(orderInfo);
                _showOrderDialog(context, orderInfo);
              },
              icon: const Icon(Icons.edit, color: Colors.blue),
            ),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: IconButton(
              tooltip: 'حذف سفارش',
              onPressed: () => _confirmDelete(context, orderInfo),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
  void _showOrderDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
        title: Center(
          child: Text(
            'جزئیات سفارش'.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        content: OrderSubmitFormPaid(order: order),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأیید حذف'),
        content: Text('آیا از حذف سفارش ${order.sId} مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.orderPaidProvider.deleteOrder(order);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

String _statusFa(String status) {
  switch (status) {
    case 'Pending':
      return 'در انتظار بررسی';
    case 'Processing':
      return 'در حال پردازش';
    case 'Shipped':
      return 'ارسال شده';
    case 'Delivered':
      return 'تحویل داده شده';
    case 'Cancelled':
      return 'لغو شده';

    default:
      return status;
  }
}

Color _statusColor(String? status) {
  switch (status) {
    case 'Pending':
      return Colors.orange;
    case 'Processing':
      return Colors.blue;
    case 'Shipped':
      return Colors.purple;
    case 'Delivered':
      return Colors.green;
    case 'Cancelled':
      return Colors.red;

    default:
      return Colors.grey;
  }
}

// 🔽 تابع جدید برای نمایش نوع سفارش
// Widget _buildOrderModeCell(Order orderInfo) {
//   final orderMode = orderInfo.orderMode ?? '';
//   final tableNumber = orderInfo.tableNumber?.toString() ?? '';
//
//   if (orderMode == 'in_person') {
//     return Text(
//       tableNumber.isNotEmpty ? 'حضوری - میز: $tableNumber' : 'حضوری',
//       style: TextStyle(
//         color: Colors.blue[700],
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   } else if (orderMode == 'online') {
//     return Text(
//       'سفارش آنلاین',
//       style: TextStyle(
//         color: Colors.green[700],
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   } else {
//     return Text(
//       orderMode.isNotEmpty ? orderMode : 'نامشخص',
//       style: const TextStyle(color: Colors.grey),
//     );
//   }
// }

Widget _buildOrderModeCell(Order orderInfo) {
  final orderMode = orderInfo.orderMode ?? '';
  final tableNumber = orderInfo.tableNumber?.toString() ?? '';

  Widget textWidget;

  if (orderMode == 'in_person') {
    textWidget = Text(
      tableNumber.isNotEmpty ? 'حضوری - میز: $tableNumber' : 'حضوری',
      style: TextStyle(
        color: Colors.blue[700],
        fontWeight: FontWeight.bold,
      ),
    );
  } else if (orderMode == 'online') {
    textWidget = Text(
      'سفارش آنلاین',
      style: TextStyle(
        color: Colors.green[700],
        fontWeight: FontWeight.bold,
      ),
    );
  } else {
    textWidget = Text(
      orderMode.isNotEmpty ? orderMode : 'نامشخص',
      style: const TextStyle(color: Colors.grey),
    );
  }

  return Center(child: textWidget); // 🔽 اضافه شود
}
