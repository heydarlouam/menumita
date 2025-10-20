

import 'package:admin/screens/order/components/view_order_form.dart';
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
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            final orders = dataProvider.orders;

            // ردیف‌های جدول = دقیقاً همان رندر قبلی
            final rows = <DataRow>[
              for (int i = 0; i < orders.length; i++)
                orderDataRow(
                  context,
                  orders[i],
                  i + 1,
                  delete: () => _showDeleteConfirmation(context, orders[i]),
                  edit: () => _showOrderForm(context, orders[i]),
                ),

              // ردیف لودر/پیام انتها (بدون تغییر ظاهر کلی جدول)
              if (dataProvider.isOrdersLoading || !dataProvider.hasMoreOrders)
                DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: dataProvider.isOrdersLoading
                              ? const CircularProgressIndicator()
                              : const Text('No more orders', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    // برای حفظ ساختار جدول، سلول‌های خالی
                    const DataCell(SizedBox.shrink()),
                    const DataCell(SizedBox.shrink()),
                    const DataCell(SizedBox.shrink()),
                    const DataCell(SizedBox.shrink()),
                    const DataCell(SizedBox.shrink()),
                    const DataCell(SizedBox.shrink()),
                  ],
                ),
            ];

            return NotificationListener<ScrollNotification>(
              onNotification: (sn) {
                final atBottom = sn.metrics.pixels >= sn.metrics.maxScrollExtent - 40;
                if (atBottom && dataProvider.hasMoreOrders && !dataProvider.isOrdersLoading) {
                  dataProvider.loadMoreOrders();
                }
                return false;
              },
              // تنها یک DataTable؛ ظاهر ۱:۱ مثل قبل
              child: SizedBox(
                height: 520, // اگر قبلاً تمام‌قد بود، می‌تونی این را حذف/تغییر دهی
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: const [
                      DataColumn(label: Text("Customer Name")),
                      DataColumn(label: Text("Order Amount")),
                      DataColumn(label: Text("Payment")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Edit")),
                      DataColumn(label: Text("Delete")),
                    ],
                    rows: rows,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderForm(BuildContext context, Order order) {
    context.orderProvider.loadOrderForUpdate(order);


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Center(
            child: Text(
              'Order Details'.toUpperCase(),
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          content: OrderSubmitForm(order: order),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete order ${order.sId}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.orderProvider.deleteOrder(order);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

DataRow orderDataRow(BuildContext context, Order orderInfo, int index,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
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
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(orderInfo.userName ?? 'Unknown User'),
            ),
          ],
        ),
      ),
      DataCell(Text('${orderInfo.orderTotal?.total?.toStringAsFixed(2) ?? '0.00'}')),
      DataCell(Text(orderInfo.paymentMethod ?? '')),
      DataCell(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(orderInfo.orderStatus),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            orderInfo.orderStatus ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      DataCell(Text(formatTimestamp(context, orderInfo.orderDate))),
      DataCell(
        IconButton(
          onPressed: () {
            if (edit != null) edit();
          },
          icon: Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          tooltip: 'Edit Order',
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            if (delete != null) delete();
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          tooltip: 'Delete Order',
        ),
      ),
    ],
  );
}

// تابع کمکی برای رنگ وضعیت سفارش
Color _getStatusColor(String? status) {
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



