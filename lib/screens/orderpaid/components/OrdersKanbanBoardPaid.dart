import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../utility/constants.dart';
import '../provider/order_provider_paid.dart';

class OrdersKanbanBoardPaid extends StatelessWidget {
  const OrdersKanbanBoardPaid({Key? key}) : super(key: key);

  Map<String, List<Order>> _group(List<Order> orders) {
    final map = { for (final s in kOrderedStatuses) s: <Order>[] };
    for (final o in orders) {
      final s = o.orderStatus ?? ORDER_STATUS_PENDING;
      (map[s] ??= <Order>[]).add(o);
    }
    // مرتب‌سازی داخل هر ستون
    for (final s in map.keys) {
      map[s]!.sort((a, b) => (a.orderDate ?? '').compareTo(b.orderDate ?? ''));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // ⬅️ گوش دادن به تغییرات Provider (رفرش/جستجو/فیلتر)
    final orders = context.select<DataProvider, List<Order>>((p) => p.allsOrders);
    final grouped = _group(orders);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: kOrderedStatuses.map((status) {
            final items = grouped[status] ?? const <Order>[];
            return _KanbanColumn(
              status: status,
              orders: items,

              onAccept: (order) async {
                if ((order.orderStatus ?? ORDER_STATUS_PENDING) == status) {
                  return; // همون ستون بود → هیچ کاری نکن
                }
                await context.read<OrderPaidProvider>()
                    .updateOrderStatus(order.sId ?? '', status);
              },

            );
          }).toList(),
        ),
      ),
    );
  }
}



class _KanbanColumn extends StatelessWidget {
  final String status;
  final List<Order> orders;
  final ValueChanged<Order> onAccept;

  const _KanbanColumn({
    Key? key,
    required this.status,
    required this.orders,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colBg = statusColor(status).withOpacity(.06);   // بک‌گراند لطیف ستون
    final colBorder = statusColor(status).withOpacity(.25);

    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // فاصله ستون از ستون کناری
        child: DragTarget<Order>(
          onWillAccept: (o) {
            // اگر از همین وضعیت اومده باشد، اصلاً قبول نکن (نه هایلایت، نه onAccept)
            return (o?.orderStatus ?? ORDER_STATUS_PENDING) != status;
          },
          onAccept: onAccept,
          builder: (context, candidate, rejected) {
            final hovering = candidate.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                color: colBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colBorder),
                boxShadow: hovering
                    ? [BoxShadow(color: colBorder.withOpacity(.25), blurRadius: 8, spreadRadius: 1)]
                    : null,
              ),
              child: Column(
                children: [
                  // هدر ستون
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(.14),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: colBorder)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(color: statusColor(status), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${statusFa(status)}  •  ${orders.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // لیست کارت‌ها با پدینگ چهار طرف
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      itemCount: orders.length,
                      // itemBuilder: (_, i) => _DraggableOrderCard(order: orders[i]),
                      itemBuilder: (_, i) => KeyedSubtree(
                        key: ValueKey(orders[i].sId ?? orders[i].hashCode),
                        child: _DraggableOrderCard(order: orders[i]),
                      ),

                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}



class _DraggableOrderCard extends StatelessWidget {
  final Order order;
  const _DraggableOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Order>(
      data: order,
      feedback: SizedBox(       // ⬅️ عرض مشخص برای جلوگیری از خطای BoxConstraints
        width: 300,            // متناسب با عرض ستونت تنظیم کن (مثلاً 300–304)
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: _OrderCard(order: order, dimmed: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _OrderCard(order: order)),
      child: _OrderCard(order: order),
    );
  }
}


class _OrderCard extends StatelessWidget {
  final Order order;
  final bool dimmed;
  const _OrderCard({Key? key, required this.order, this.dimmed = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color labelColor = statusColor(order.orderStatus);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 450), // ⬅️ اگر خواستی واضح‌تر: 320–360ms
      curve: Curves.easeInSine,
      builder: (context, scale, child) {
        return Opacity(
          opacity: 1 - (1 - scale) * 3,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Card(
        color: surface,
        elevation: dimmed ? 1.5 : 3,
        shadowColor: labelColor.withOpacity(.2),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            title: Text(
              order.userName ?? 'کاربر نامشخص',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.totalPrice != null) ...[
                    Text('مبلغ: ${order.totalPrice!.toStringAsFixed(0)}'),
                    const SizedBox(height: 4),
                  ],
                  if (order.orderDate != null) ...[
                    Text(order.orderDate!),
                    const SizedBox(height: 4),
                  ],
                  if (order.trackingUrl?.isNotEmpty == true)
                    Text('پیگیری: ${order.trackingUrl!}', maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: labelColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusFa(order.orderStatus ?? ''),
                style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




const List<String> kOrderedStatuses = [
  ORDER_STATUS_PENDING,
  ORDER_STATUS_PROCESSING,
  ORDER_STATUS_SHIPPED,
  ORDER_STATUS_DELIVERED,
  ORDER_STATUS_CANCELLED,
];

String statusFa(String s) {
  switch (s) {
    case ORDER_STATUS_PENDING: return   'انتظار تأیید';
    case ORDER_STATUS_PROCESSING: return 'در حال آماده‌سازی';
    case ORDER_STATUS_SHIPPED: return  'ارسال شده';
    case ORDER_STATUS_DELIVERED: return 'تحویل‌داده‌شده';
    case ORDER_STATUS_CANCELLED: return 'لغو شده';

    default: return s;
  }
}

Color statusColor(String? s) {
  switch (s) {
    case ORDER_STATUS_PENDING: return Colors.orange;
    case ORDER_STATUS_PROCESSING: return Colors.blue;
    case ORDER_STATUS_SHIPPED: return Colors.purple;
    case ORDER_STATUS_DELIVERED: return Colors.green;
    case ORDER_STATUS_CANCELLED: return Colors.red;
    default: return Colors.grey;
  }
}
