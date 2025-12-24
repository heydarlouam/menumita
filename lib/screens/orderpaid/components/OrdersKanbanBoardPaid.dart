import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/functions.dart';
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
     map[s]!.sort((a, b) => (a.orderDate.toString() ?? '').compareTo(b.orderDate.toString() ?? ''));
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
                if (await UserSaveHelper.isExpired()) {
                  DialogHelper.showExpiredDialog(context);
                  return;
                }
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




class _OrderCard extends StatefulWidget {
  final Order order;
  final bool dimmed;
  const _OrderCard({Key? key, required this.order, this.dimmed = false}) : super(key: key);

  @override
  State<_OrderCard> createState() => __OrderCardState();
}

class __OrderCardState extends State<_OrderCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color labelColor = statusColor(widget.order.orderStatus);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInSine,
      builder: (context, scale, child) {
        return Opacity(
          opacity: 1 - (1 - scale) * 3,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Card(
        color: surface,
        elevation: widget.dimmed ? 1.5 : 3,
        shadowColor: labelColor.withOpacity(.2),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ردیف اول: اطلاعات اصلی
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.order.userID ?? 'کاربر نامشخص',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    // 🔽 بج نوع سفارش و وضعیت در یک ردیف
                    _buildOrderTypeBadge(widget.order),
                    const SizedBox(width: 4),
                    _buildStatusBadge(widget.order, labelColor),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down, size: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // اطلاعات سفارش
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (widget.order.orderDate != null) ...[
                     Row(children: [ Text(
                       '${formatToJalali(widget.order.orderDate!.toString())}',
                     ),
                      Text(' && '),
                       Text(
                       '${getTimeAgo(widget.order.orderDate.toString()! ?? '')}',
                     ),],),
                      const SizedBox(height: 4),
                    ],
                    if (widget.order.totalPrice != null) ...[
                      Text('مبلغ: ${money(context, widget.order.totalPrice!)}'),
                      const SizedBox(height: 4),
                    ],
                  ],
                ),

                // === ناحیه‌ی کشوییِ آیتم‌ها ===
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _open
                      ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: [
                        const Divider(),
                        const Align(
                          alignment: Alignment.center,
                          child: Text('جزئیات محصولات',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),

                        // لیست آیتم‌ها
                        ..._buildItemsList(widget.order, context),
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔽 تابع برای نمایش نوع سفارش
  Widget _buildOrderTypeBadge(Order order) {
    final orderMode = order.orderMode?.toLowerCase().trim() ?? '';
    final tableNumber = order.tableNumber?.toString().trim() ?? '';

    Color badgeColor;
    String badgeText;

    if (orderMode == 'in_person') {
      badgeColor = Colors.blue;
      badgeText = tableNumber.isNotEmpty ? 'میز: $tableNumber' : 'حضوری';
    } else if (orderMode == 'online') {
      badgeColor = Colors.green;
      badgeText = 'آنلاین';
    } else {
      badgeColor = Colors.grey;
      badgeText = orderMode.isNotEmpty ? orderMode : 'نامشخص';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            orderMode == 'in_person' ? Icons.table_restaurant : Icons.shopping_cart,
            size: 10,
            color: badgeColor,
          ),
          const SizedBox(width: 2),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  // 🔽 تابع برای نمایش وضعیت
  Widget _buildStatusBadge(Order order, Color labelColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: labelColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusFa(order.orderStatus ?? ''),
        style: TextStyle(
            color: labelColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 🔽 تابع برای ساخت لیست آیتم‌ها
  List<Widget> _buildItemsList(Order order, BuildContext ctx) {
    if (order.items == null || order.items!.isEmpty) {
      return [
        const Text('آیتمی موجود نیست',
            style: TextStyle(fontSize: 12, color: Colors.grey))
      ];
    }

    return order.items!.map((item) => _buildItemRow(item as Items, ctx)).toList();
  }

  // 🔽 تابع برای نمایش هر آیتم
  Widget _buildItemRow(Items item, BuildContext ctx) {
    final lineTotal = (item.quantity ?? 0) * (item.price ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نام محصول و مجموع خط
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName ?? '—',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                money(ctx, lineTotal as double?),
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // تعداد × قیمت واحد
          Text(
            'تعداد : ${item.quantity ?? 0}  ×  ${money(ctx, item.price)}',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          if ((item.note ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'یادداشت : ${item.note!.trim()}',
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
        ],
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
