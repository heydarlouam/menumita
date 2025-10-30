import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'product/add_product_form.dart';
import 'components/dash_board_header.dart';
import 'order/order_details_section.dart';
import 'product/product_list_section.dart';
import 'product/product_summery_section.dart';

import 'product/product_actions_bar.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'product/add_product_form.dart';
import 'components/dash_board_header.dart';
import 'order/order_details_section.dart';
import 'product/product_list_section.dart';
import 'product/product_summery_section.dart';
import 'product/product_actions_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _ordersEnabled = true; // 👈 پیش‌فرض فعال

  @override
  void initState() {
    super.initState();
    _checkMenuType();
  }

  Future<void> _checkMenuType() async {
    final info = await UserSaveHelper.getUserInfo(showError: false);
    final menuType = (info?['menu_type'] ?? '').toString().trim().toLowerCase();
    if (mounted) {
      setState(() {
        _ordersEnabled = menuType != 'menu_one';
      });
    }
  }

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
                  // const OrderDetailsSection(),
                  if (_ordersEnabled) const OrderDetailsSection(),
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
                   // const OrderDetailsSection(),
                  if (_ordersEnabled) const OrderDetailsSection(),
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

                // const SizedBox(width: defaultPadding),

                // ستون راست: جزئیات سفارش با عرض ثابت و پدینگ از بالا
                // const Padding(
                //   padding: EdgeInsets.only(top: defaultPadding),
                //   child: SizedBox(
                //     width: 300,
                //     child: OrderDetailsSection(),
                //   ),
                // ),
                if (_ordersEnabled) ...[
                  const SizedBox(width: defaultPadding),
                  const Padding(
                    padding: EdgeInsets.only(top: defaultPadding),
                    child: SizedBox(
                      width: 300,
                      child: OrderDetailsSection(),
                    ),
                  ),
                ],
              ],
            ),
          );

        },
      ),
    );
  }
}

// class DashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     void _onAdd() => showAddProductForm(context, null);
//     void _onRefresh() => context.dataProvider.filterProductsByQuantity(
//           context.dataProvider.productsType,
//           showSnack: true,
//         );
//
//
//
//     return SafeArea(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final w = constraints.maxWidth;
//
//           // موبایل
//           if (w < 594) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(defaultPadding),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const DashBoardHeader(),
//                   const Gap(defaultPadding),
//                   const ProductSummerySection(),
//                   const Gap(defaultPadding),
//                   ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//                   const ProductListSection(),
//                   const Gap(defaultPadding),
//                   const OrderDetailsSection(),
//                 ],
//               ),
//             );
//           }
//
//           // تبلت
//           if (w < 1024) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(defaultPadding),
//               child: Column(
//                 children: [
//                   const DashBoardHeader(),
//                   const Gap(defaultPadding),
//                   const ProductSummerySection(),
//                   const Gap(defaultPadding),
//                   ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//                   const ProductListSection(),
//                   const Gap(defaultPadding),
//                   const OrderDetailsSection(),
//                 ],
//               ),
//             );
//           }
//
//
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.only(left: defaultPadding),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start, // 👈 از بالا تراز بشن
//               children: [
//                 // ستون چپ: هدر + محتوا
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: defaultPadding), // 👈 پدینگ ملایم از بالا فقط برای ستون چپ
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         const DashBoardHeader(),
//                         const SizedBox(height: defaultPadding),
//
//                         // ⛔️ اگر Consumer داخلشونه، بهتره بدون const باشن
//                         ProductSummerySection(),
//                         const SizedBox(height: defaultPadding),
//
//                         ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//
//                         ProductListSection(),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: defaultPadding),
//
//                 // ستون راست: جزئیات سفارش با عرض ثابت و پدینگ از بالا
//                 const Padding(
//                   padding: EdgeInsets.only(top: defaultPadding),
//                   child: SizedBox(
//                     width: 300,
//                     child: OrderDetailsSection(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//
//         },
//       ),
//     );
//   }
// }


// class DashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     void _onAdd() => showAddProductForm(context, null);
//     void _onRefresh() => context.dataProvider.filterProductsByQuantity(
//       context.dataProvider.productsType,
//       showSnack: true,
//     );
//
//     // 👇 فقط همین FutureBuilder اضافه شد تا menu_type رو چک کنیم
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: UserSaveHelper.getUserInfo(showError: false),
//       builder: (context, snap) {
//         final menuType = (snap.data?['menu_type'] ?? '').toString().trim().toLowerCase();
//         final ordersEnabled = menuType != 'menu_one';
//
//         // می‌تونی تو حالت لود اسکلتی لایت نشون بدی؛ فعلاً همون UI بدون OrderDetailsSection
//         final orderDetailsMobileTablet =
//         ordersEnabled ? const OrderDetailsSection() : const SizedBox.shrink();
//
//         return SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final w = constraints.maxWidth;
//
//               // موبایل
//               if (w < 594) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(defaultPadding),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const DashBoardHeader(),
//                       const Gap(defaultPadding),
//                       const ProductSummerySection(),
//                       const Gap(defaultPadding),
//                       ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//                       const ProductListSection(),
//                       const Gap(defaultPadding),
//                       orderDetailsMobileTablet, // 👈 مشروط
//                     ],
//                   ),
//                 );
//               }
//
//               // تبلت
//               if (w < 1024) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(defaultPadding),
//                   child: Column(
//                     children: [
//                       const DashBoardHeader(),
//                       const Gap(defaultPadding),
//                       const ProductSummerySection(),
//                       const Gap(defaultPadding),
//                       ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//                       const ProductListSection(),
//                       const Gap(defaultPadding),
//                       orderDetailsMobileTablet, // 👈 مشروط
//                     ],
//                   ),
//                 );
//               }
//
//               // دسکتاپ
//               return SingleChildScrollView(
//                 padding: const EdgeInsets.only(left: defaultPadding),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ستون چپ
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: defaultPadding),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             const DashBoardHeader(),
//                             const SizedBox(height: defaultPadding),
//                             // ⛔️ اگر Consumer داخلشونه، بدون const بگذار
//                             ProductSummerySection(),
//                             const SizedBox(height: defaultPadding),
//                             ProductActionsBar(onAdd: _onAdd, onRefresh: _onRefresh),
//                             ProductListSection(),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // فاصله و ستون راست فقط وقتی سفارش‌ها فعاله
//                     if (ordersEnabled) ...[
//                       const SizedBox(width: defaultPadding),
//                       const Padding(
//                         padding: EdgeInsets.only(top: defaultPadding),
//                         child: SizedBox(
//                           width: 300,
//                           child: OrderDetailsSection(), // 👈 مشروط
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
