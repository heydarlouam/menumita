import 'package:admin/screens/orderpaid/components/OrdersKanbanBoardPaid.dart';
import 'package:admin/screens/profile_card.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import '../../widgets/custom_dropdown.dart';
import 'components/order_header_paid.dart';
import 'components/order_list_section_paid.dart';


class OrderScreenPaid extends StatefulWidget {
  const OrderScreenPaid({Key? key}) : super(key: key);

  @override
  State<OrderScreenPaid> createState() => _OrderScreenPaidState();
}


class _OrderScreenPaidState extends State<OrderScreenPaid> {
  bool _kanbanMode = false; // ⬅️ حالت نما

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // هدر
            const OrderHeaderPaid(),
            const SizedBox(height: defaultPadding),

            Expanded(
              child:
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // نوار ابزار بالا: Refresh + Toggle + (فیلتر فقط وقتی جدول است)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: _kanbanMode
                                  ? 'رفرش سفارش‌ها (کانبان)'
                                  : 'دریافت اطلاعات و بازنشانی فیلترها',
                              onPressed: () async {
                                if (await UserSaveHelper.isExpired()) {
                                  DialogHelper.showExpiredDialog(context);
                                  return;
                                }
                                await context.dataProvider.getAllsOrders(showSnack: true);
                                if (!_kanbanMode) {
                                  context.dataProvider.filterAllOrders(ORDER_STATUS_ALL);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                            ),

                            const SizedBox(width: 8),


                            Tooltip(
                              message: _kanbanMode ? 'نمای جدول' : 'نمای کانبان',
                              child: IconButton(
                                onPressed: () {
                                  final goingKanban = !_kanbanMode;     // مقصد بعد از سویچ
                                  setState(() => _kanbanMode = goingKanban);

                                  // ⬅️ اگر رفتیم به کانبان، فیلتر رو روی «همه سفارش‌ها» بگذار
                                  if (goingKanban) {
                                    context.dataProvider.filterAllOrders(ORDER_STATUS_ALL);
                                  }
                                },
                                icon: Icon(_kanbanMode ? Icons.grid_on : Icons.view_kanban),
                              ),
                            ),


                            const SizedBox(width: 12),


                            if (!_kanbanMode)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final screenW = MediaQuery.of(context).size.width;

                                  // 👇 عرض داینامیک فیلتر
                                  double filterWidth;
                                  int maxChars;
                                  if (screenW < 480) {
                                    filterWidth = 140; // موبایل خیلی تنگ
                                    maxChars = 8;
                                  } else if (screenW < 680) {
                                    filterWidth = 170; // موبایل/فبلت
                                    maxChars = 10;
                                  } else if (screenW < 900) {
                                    filterWidth = 200; // تبلت
                                    maxChars = 12;
                                  } else {
                                    filterWidth = 260; // دسکتاپ
                                    maxChars = 14;
                                  }

                                  return SizedBox(
                                    width: filterWidth,
                                    child: CustomDropdown(
                                      hintText: 'فیلتر وضعیت', // کوتاه‌تر از متن طولانی قبلی
                                      initialValue: ORDER_STATUS_ALL,
                                      items: const [
                                        ORDER_STATUS_ALL,
                                        ORDER_STATUS_PENDING,
                                        ORDER_STATUS_PROCESSING,
                                        ORDER_STATUS_SHIPPED,
                                        ORDER_STATUS_DELIVERED,
                                        ORDER_STATUS_CANCELLED,
                                      ],
                                      // 👇 همیشه متن را طوری کوتاه می‌کنیم که از دکمه نزند بیرون

                                      displayItem: _statusLabel,
                                      onChanged: (v) async {
                                        if (v == null) return;
                                        if (await UserSaveHelper.isExpired()) {
                                          DialogHelper.showExpiredDialog(context);
                                          return;
                                        }
                                        context.dataProvider.filterAllOrders(v);
                                      },
                                      validator: (_) => null,
                                    ),
                                  );
                                },
                              ),

                            const SizedBox(width: 12),
                            const Expanded(child: ProfileCard()),
                          ],
                        ),

                        const Gap(defaultPadding),

                        // محتوای اصلی: جدول یا کانبان
                        Expanded(
                          child: _kanbanMode
                              ? const OrdersKanbanBoardPaid()
                              : const OrderListSectionPaid(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  static String _statusLabel(String status) {
    switch (status) {
      case ORDER_STATUS_ALL: return 'همه سفارش‌ها';
      case ORDER_STATUS_PENDING: return 'در انتظار بررسی';
      case ORDER_STATUS_PROCESSING: return 'در حال پردازش';
      case ORDER_STATUS_SHIPPED: return 'ارسال شده';
      case ORDER_STATUS_DELIVERED: return 'تحویل داده شده';
      case ORDER_STATUS_CANCELLED: return 'لغو شده';
      default: return status;
    }
  }
}
