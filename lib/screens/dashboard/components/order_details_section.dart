
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../utility/constants.dart';
import 'chart.dart';
import 'order_info_card.dart';

class OrderDetailsSection extends StatelessWidget {
  const OrderDetailsSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        int totalOrder = dataProvider.calculateOrdersWithStatus();
        int pendingOrder = dataProvider.calculateOrdersWithStatus(
            status: ORDER_STATUS_PENDING);
        int processingOrder = dataProvider.calculateOrdersWithStatus(
            status: ORDER_STATUS_PROCESSING);
        int cancelledOrder = dataProvider.calculateOrdersWithStatus(
            status: ORDER_STATUS_CANCELLED);
        int shippedOrder = dataProvider.calculateOrdersWithStatus(
            status: ORDER_STATUS_SHIPPED);
        int deliveredOrder = dataProvider.calculateOrdersWithStatus(
            status: ORDER_STATUS_DELIVERED);

        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "جزئیات سفارش‌ها",
                style: TextStyle(
         fontFamily: FONTS_STYLE_FAMILY,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: defaultPadding),
              Chart(),
              SizedBox(height: defaultPadding),

              OrderInfoCard(
                svgSrc: "assets/icons/delivery1.svg",
                title: "همهٔ سفارش‌ها",
                totalOrder: totalOrder,
              ),
              OrderInfoCard(
                svgSrc: "assets/icons/delivery5.svg",
                title: "سفارش‌های در انتظار بررسی",
                totalOrder: pendingOrder,
              ),
              OrderInfoCard(
                svgSrc: "assets/icons/delivery6.svg",
                title: "سفارش‌های در حال پردازش",
                totalOrder: processingOrder,
              ),
              OrderInfoCard(
                svgSrc: "assets/icons/delivery2.svg",
                title: "سفارش‌های لغوشده",
                totalOrder: cancelledOrder,
              ),
              OrderInfoCard(
                svgSrc: "assets/icons/delivery4.svg",
                title: "سفارش‌های ارسال‌شده",
                totalOrder: shippedOrder,
              ),
              OrderInfoCard(
                svgSrc: "assets/icons/delivery3.svg",
                title: "سفارش‌های تحویل‌داده‌شده",
                totalOrder: deliveredOrder,
              ),
            ],
          ),
        );
      },
    );
  }
}
