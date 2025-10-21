import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/product_summery_info.dart';
import '../../../utility/constants.dart';
import 'product_summery_card.dart';

class ProductSummerySection extends StatelessWidget {
  const ProductSummerySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

     final w = MediaQuery.of(context).size.width;



    // ✅ موبایل (کمتر از 594px): 2 ستون
    // ✅ تبلت و دسکتاپ (594px به بالا): 4 ستون
    final int crossAxisCount = (w < 594) ? 2 : 4;

    // نسبت ابعاد کارت‌ها؛ می‌تونی کمی تنظیمش کنی
    final double aspect = (w < 594) ? 1.2 : 1.4;

    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        final total =
            context.dataProvider.calculateProductWithQuantity(quantity: null);
        final out =
            context.dataProvider.calculateProductWithQuantity(quantity: 0);
        final lim =
            context.dataProvider.calculateProductWithQuantity(quantity: 1);
        final other = total - out - lim;

        final items = [
          ProductSummeryInfo(
              title: ALL_PRODUCTS,

              productsCount: total,
              svgSrc: "assets/icons/Product1.svg",
              color: primaryColor,
              percentage: total != 0 ? 100 : 0),
          ProductSummeryInfo(
              title: STOCK_OUT_PRODUCTS,
              productsCount: out,
              svgSrc: "assets/icons/Product2.svg",
              color: const Color(0xFFEA3829),
              percentage: total != 0 ? (out / total) * 100 : 0),
          ProductSummeryInfo(
              title: LIMITED_STOCK_PRODUCTS,
              productsCount: lim,
              svgSrc: "assets/icons/Product3.svg",
              color: const Color(0xFFECBE23),
              percentage: total != 0 ? (lim / total) * 100 : 0),
          ProductSummeryInfo(
              title: OTHER_PRODUCTS,
              productsCount: other,
              svgSrc: "assets/icons/Product4.svg",
              color: const Color(0xFF47e228),
              percentage: total != 0 ? (other / total) * 100 : 0),
        ];

        // ⚠️ خودِ ProductSummeryCard تغییر نکرده؛ فقط Grid ریسپانسیو شده.
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
            childAspectRatio: aspect,
          ),
          itemBuilder: (context, i) => ProductSummeryCard(

            info: items[i],
            onTap: (t) =>
                context.dataProvider.filterProductsByQuantity(t ?? ''),
          ),
        );
      },
    );
  }
}
