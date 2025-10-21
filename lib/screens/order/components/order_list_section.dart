

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
    // فقط فیلدهای لازم رو گوش می‌کنیم تا rebuild کم بشه
    final orders = context.select<DataProvider, List<Order>>((p) => p.orders);
    final isLoading =
    context.select<DataProvider, bool>((p) => p.isOrdersLoading);
    final hasMore =
    context.select<DataProvider, bool>((p) => p.hasMoreOrders);

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
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : (!hasMore
                    ? const Text('No more orders',
                    style: TextStyle(color: Colors.grey))
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
      child: SizedBox(
        width: double.infinity,
        child: NotificationListener<ScrollNotification>(
          onNotification: (sn) {
            // اسکرول بی‌نهایت با گاردها
            final nearBottom =
                sn.metrics.pixels >= sn.metrics.maxScrollExtent - 40;
            if (nearBottom && hasMore && !isLoading) {
              context.read<DataProvider>().loadMoreOrders();
            }
            return false;
          },
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
      ),
    );
  }

  DataRow _orderDataRow(BuildContext context, Order orderInfo, int index) {
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
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Text(orderInfo.userName ?? 'Unknown User'),
            ],
          ),
        ),
        DataCell(Text(
            orderInfo.orderTotal?.total?.toStringAsFixed(2) ?? '0.00')),
        DataCell(Text(orderInfo.paymentMethod ?? '')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(orderInfo.orderStatus),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              orderInfo.orderStatus ?? '',
              style: const TextStyle(
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
            tooltip: 'Edit Order',
            onPressed: () {
              context.orderProvider.loadOrderForUpdate(orderInfo);
              _showOrderDialog(context, orderInfo);
            },
            icon: const Icon(Icons.edit, color: Colors.blue),
          ),
        ),
        DataCell(
          IconButton(
            tooltip: 'Delete Order',
            onPressed: () => _confirmDelete(context, orderInfo),
            icon: const Icon(Icons.delete, color: Colors.red),
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
            'ORDER DETAILS',
            style: TextStyle(color: Theme.of(ctx).primaryColor),
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
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete order ${order.sId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.orderProvider.deleteOrder(order);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
