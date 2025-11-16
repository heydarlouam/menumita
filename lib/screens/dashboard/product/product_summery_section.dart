import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
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

    return Selector<DataProvider, ({int total, int out, int lim, int other})>(
      selector: (context, dp) {
        final total = dp.calculateProductWithQuantity(quantity: null);
        final out = dp.calculateProductWithQuantity(quantity: 0);
        final lim = dp.calculateProductWithQuantity(quantity: 1);
        final other = total - out - lim;
        return (total: total, out: out, lim: lim, other: other);
      },
      builder: (context, c, _) {
        final items = [
          ProductSummeryInfo(
              title: ALL_PRODUCTS,
              productsCount: c.total,
              svgSrc: "assets/icons/Product1.svg",
              color: primaryColor,
              percentage: c.total != 0 ? 100 : 0),
          ProductSummeryInfo(
              title: STOCK_OUT_PRODUCTS,
              productsCount: c.out,
              svgSrc: "assets/icons/Product2.svg",
              color: const Color(0xFFEA3829),
              percentage: c.total != 0 ? (c.out / c.total) * 100 : 0),
          ProductSummeryInfo(
              title: LIMITED_STOCK_PRODUCTS,
              productsCount: c.lim,
              svgSrc: "assets/icons/Product3.svg",
              color: const Color(0xFFECBE23),
              percentage: c.total != 0 ? (c.lim / c.total) * 100 : 0),
          ProductSummeryInfo(
              title: OTHER_PRODUCTS,
              productsCount: c.other,
              svgSrc: "assets/icons/Product4.svg",
              color: const Color(0xFF47e228),
              percentage: c.total != 0 ? (c.other / c.total) * 100 : 0),
        ];

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
            onTap: (t) async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              context.dataProvider.filterProductsByQuantity(t ?? '');
            },
          ),
        );
      },
    );
  }
}
