import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'components/add_product_form.dart';
import 'components/dash_board_header.dart';
import 'components/order_details_section.dart';
import 'components/product_list_section.dart';
import 'components/product_summery_section.dart';

import 'components/product_actions_bar.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _onAdd() => showAddProductForm(context, null);
    void _onRefresh() => context.dataProvider.filterProductsByQuantity(
          context.dataProvider.productsType,
          showSnack: true,
        );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // موبایل
          if (w < 594) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DashBoardHeader(),
                  const Gap(defaultPadding),
                  const ProductSummerySection(),
                  const Gap(defaultPadding),
                  ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
                  const ProductListSection(),
                  const Gap(defaultPadding),
                  const OrderDetailsSection(),
                ],
              ),
            );
          }

          // تبلت
          if (w < 1024) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  const DashBoardHeader(),
                  const Gap(defaultPadding),
                  const ProductSummerySection(),
                  const Gap(defaultPadding),
                  ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
                  const ProductListSection(),
                  const Gap(defaultPadding),
                  const OrderDetailsSection(),
                ],
              ),
            );
          }



          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 👈 از بالا تراز بشن
              children: [
                // ستون چپ: هدر + محتوا
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: defaultPadding), // 👈 پدینگ ملایم از بالا فقط برای ستون چپ
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DashBoardHeader(),
                        const SizedBox(height: defaultPadding),

                        // ⛔️ اگر Consumer داخلشونه، بهتره بدون const باشن
                        ProductSummerySection(),
                        const SizedBox(height: defaultPadding),

                        ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),

                        ProductListSection(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: defaultPadding),

                // ستون راست: جزئیات سفارش با عرض ثابت و پدینگ از بالا
                const Padding(
                  padding: EdgeInsets.only(top: defaultPadding),
                  child: SizedBox(
                    width: 300,
                    child: OrderDetailsSection(),
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }
}
