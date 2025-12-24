

import 'package:admin/screens/order/components/view_order_form.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:admin/utility/functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';

class OrderListSection extends StatelessWidget {
  const OrderListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // فقط فیلدهای لازم رو گوش می‌کنیم تا rebuild کم بشه
    final orders = context.select<DataProvider, List<Order>>((p) => p.orders);
    final isLoading = context.select<DataProvider, bool>((p) => p.isOrdersLoading);
    final hasMore = context.select<DataProvider, bool>((p) => p.hasMoreOrders);

    // ردیف‌ها (شبیه قبل) + ردیف پایانی
    final rows = <DataRow>[
      for (int i = 0; i < orders.length; i++)
        _orderDataRow(context, orders[i], i + 1),
      DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : (!hasMore
                    ? const Text('سفارشی باقی نمانده', style: TextStyle(color: Colors.grey))
                    : const SizedBox.shrink()),
              ),
            ),
          ),
          const DataCell(SizedBox.shrink()),
          const DataCell(SizedBox.shrink()),
          const DataCell(SizedBox.shrink()),
          const DataCell(SizedBox.shrink()),
          const DataCell(SizedBox.shrink()),
          const DataCell(SizedBox.shrink()),
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
            scrollDirection: Axis.horizontal,  // 👈 اسکرول افقی در صورت لزوم
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w), // 👈 حداقل = عرض کارت
              child: NotificationListener<ScrollNotification>(
                onNotification: (sn) {
                  // اسکرول بی‌نهایت (روی اسکرول عمودی)
                  final nearBottom = sn.metrics.pixels >= sn.metrics.maxScrollExtent - 40;
                  if (nearBottom && hasMore && !isLoading) {
                    context.read<DataProvider>().loadMoreOrders();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  // 👈 عمودی مثل قبل
                  child:


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
                Text(orderInfo.shippingAddress?.street ?? 'کاربر نامشخص'),
              ],
            ),
          ),
        ),
        DataCell(
          Center( // 🔽 اضافه شود
            child: Text(money(context, orderInfo.orderTotal?.total) ?? '0.00'),
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
              '${formatToJalali(orderInfo.orderDate.toString())}\n${getTimeAgo(orderInfo.orderDate.toString() ?? '')}',
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
              onPressed: () async {
                if (await UserSaveHelper.isExpired()) {
                  DialogHelper.showExpiredDialog(context);
                  return;
                }
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



              onPressed: () async {
                if (await UserSaveHelper.isExpired()) {
                  DialogHelper.showExpiredDialog(context);
                  return;
                }
                _confirmDelete(context, orderInfo);
              },

              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

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
        content: OrderSubmitForm(order: order),
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
              await context.orderProvider.deleteOrder(order);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// نگاشت وضعیت‌ها برای نمایش فارسی (مقادیر داخلی تغییری ندارند)
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
    case 'Paid':
      return 'پرداخت شده';
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
    case 'Paid':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}
