import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/coupon.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import 'add_coupon_form.dart';

// class CouponListSection extends StatelessWidget {
//   const CouponListSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final coupons = context.select<DataProvider, List<Coupon>>((p) => p.coupons);
//
//     final rows = List<DataRow>.generate(
//       coupons.length,
//           (index) => _couponDataRow(context, coupons[index], index + 1),
//     );
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth; // عرض کارت
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal, // ✅ افقی
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: w), // ✅ حداقل = عرض کارت
//               child: SingleChildScrollView(
//                 // ✅ عمودی
//                 child: DataTable(
//                   columnSpacing: defaultPadding,
//                   columns: const [
//                     DataColumn(label: Text("کد کوپن")),
//                     DataColumn(label: Text("وضعیت")),
//                     DataColumn(label: Text("نوع تخفیف")),
//                     DataColumn(label: Text("مقدار تخفیف")),
//                     DataColumn(label: Text("ویرایش")),
//                     DataColumn(label: Text("حذف")),
//                   ],
//                   rows: rows,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               Container(
//                 height: 24,
//                 width: 24,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: colors[index % colors.length],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   '$index',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               const SizedBox(width: defaultPadding),
//               Text(coupon.couponCode ?? ''),
//             ],
//           ),
//         ),
//         DataCell(Text(coupon.status ?? '')),
//         DataCell(Text(coupon.discountType ?? '')),
//         DataCell(Text('${coupon.discountAmount ?? ''}')),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               showAddCouponForm(context, coupon);
//             },
//             tooltip: 'ویرایش کوپن',
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               context.couponCodeProvider.deleteCoupon(coupon);
//             },
//             tooltip: 'حذف کوپن',
//             icon: const Icon(Icons.delete, color: Colors.red),
//           ),
//         ),
//       ],
//     );
//   }
// }

//
// class CouponListSection extends StatelessWidget {
//   const CouponListSection({Key? key}) : super(key: key);
//
//   Widget _shimmerBox({double w = 120, double h = 14, BorderRadius? r}) {
//     return Shimmer(
//       child: Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: r ?? BorderRadius.circular(6),
//         ),
//       ),
//     );
//   }
//
//   List<DataRow> _buildShimmerRows(int count) {
//     return List.generate(count, (i) {
//       return DataRow(
//         cells: [
//           DataCell(Row(children: [
//             _shimmerBox(w: 24, h: 24, r: BorderRadius.circular(999)),
//             const SizedBox(width: defaultPadding),
//             _shimmerBox(w: 120, h: 14),
//           ])),
//           DataCell(_shimmerBox(w: 70, h: 14)),
//           DataCell(_shimmerBox(w: 90, h: 14)),
//           DataCell(_shimmerBox(w: 70, h: 14)),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//         ],
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final coupons = context.select<DataProvider, List<Coupon>>((p) => p.coupons);
//     final loading = context.select<DataProvider, bool>((p) => p.isCouponsLoading);
//     final loadingMore = context.select<DataProvider, bool>((p) => p.isCouponsLoadingMore);
//     final hasMore = context.select<DataProvider, bool>((p) => p.hasMoreCoupons);
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth;
//
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: w),
//               child: NotificationListener<ScrollNotification>(
//                 onNotification: (n) {
//                   if (n.metrics.axis != Axis.vertical) return false;
//
//                   if (hasMore &&
//                       !loading &&
//                       !loadingMore &&
//                       n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
//                     context.read<DataProvider>().loadMoreCoupons();
//                   }
//                   return false;
//                 },
//                 child: SizedBox(
//                   height: 520, // ✅ فعال شدن اسکرول داخلی جدول
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: DataTable(
//                       columnSpacing: defaultPadding,
//                       columns: const [
//                         DataColumn(label: Text("کد کوپن")),
//                         DataColumn(label: Text("وضعیت")),
//                         DataColumn(label: Text("نوع تخفیف")),
//                         DataColumn(label: Text("مقدار تخفیف")),
//                         DataColumn(label: Text("ویرایش")),
//                         DataColumn(label: Text("حذف")),
//                       ],
//                       rows: [
//                         if (loading && coupons.isEmpty) ..._buildShimmerRows(10),
//
//                         if (!(loading && coupons.isEmpty))
//                           ...List<DataRow>.generate(
//                             coupons.length,
//                                 (index) => _couponDataRow(context, coupons[index], index + 1),
//                           ),
//
//                         if (loadingMore)
//                           DataRow(cells: [
//                             DataCell(_shimmerBox(w: 160, h: 14)),
//                             DataCell(_shimmerBox(w: 80, h: 14)),
//                             DataCell(_shimmerBox(w: 100, h: 14)),
//                             DataCell(_shimmerBox(w: 80, h: 14)),
//                             DataCell(_shimmerBox(w: 28, h: 28)),
//                             DataCell(_shimmerBox(w: 28, h: 28)),
//                           ]),
//
//                         if (!hasMore && !loading && coupons.isNotEmpty)
//                           const DataRow(
//                             cells: [
//                               DataCell(Text('')),
//                               DataCell(Center(child: Text('پایان لیست'))),
//                               DataCell(Text('')),
//                               DataCell(Text('')),
//                               DataCell(Text('')),
//                               DataCell(Text('')),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               Container(
//                 height: 24,
//                 width: 24,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: colors[index % colors.length],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text('$index', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
//               ),
//               const SizedBox(width: defaultPadding),
//               Text(coupon.couponCode ?? ''),
//             ],
//           ),
//         ),
//         DataCell(Text(coupon.status ?? '')),
//         DataCell(Text(coupon.discountType ?? '')),
//         DataCell(Text('${coupon.discountAmount ?? ''}')),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               showAddCouponForm(context, coupon);
//             },
//             tooltip: 'ویرایش کوپن',
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               context.couponCodeProvider.deleteCoupon(coupon);
//             },
//             tooltip: 'حذف کوپن',
//             icon: const Icon(Icons.delete, color: Colors.red),
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'package:admin/utility/User_helper.dart';
// import 'package:admin/utility/dialog_helper.dart';
// import 'package:admin/utility/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
//
// import '../../../core/data/data_provider.dart';
// import '../../../models/coupon.dart';
// import '../../../utility/color_list.dart';
// import '../../../utility/constants.dart';
// import 'add_coupon_form.dart';
//
// class CouponListSection extends StatelessWidget {
//   const CouponListSection({Key? key}) : super(key: key);
//
//   Widget _shimmerBox({double w = 120, double h = 14, BorderRadius? r}) {
//     return Shimmer(
//       child: Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: r ?? BorderRadius.circular(6),
//         ),
//       ),
//     );
//   }
//
//   List<DataRow> _buildShimmerRows(int count) {
//     return List.generate(count, (i) {
//       final idx = i + 1;
//       return DataRow(
//         cells: [
//           DataCell(Row(children: [
//             _shimmerBox(w: 24, h: 24, r: BorderRadius.circular(999)),
//             const SizedBox(width: defaultPadding),
//             _shimmerBox(w: 120, h: 14),
//           ])),
//           DataCell(_shimmerBox(w: 70, h: 14)),
//           DataCell(_shimmerBox(w: 90, h: 14)),
//           DataCell(_shimmerBox(w: 70, h: 14)),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//           DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
//         ],
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final coupons = context.select<DataProvider, List<Coupon>>((p) => p.coupons);
//     final loading = context.select<DataProvider, bool>((p) => p.isCouponsLoading);
//     final loadingMore =
//     context.select<DataProvider, bool>((p) => p.isCouponsLoadingMore);
//     final hasMore =
//     context.select<DataProvider, bool>((p) => p.hasMoreCoupons);
//
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: LayoutBuilder(
//         builder: (_, cons) {
//           final w = cons.maxWidth;
//
//           return NotificationListener<ScrollNotification>(
//             onNotification: (n) {
//               // اینجا اسکرول والد هم میتونه نوتیف بده (bubble میشه)
//               if (n.metrics.axis != Axis.vertical) return false;
//
//               if (hasMore &&
//                   !loading &&
//                   !loadingMore &&
//                   n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
//                 context.read<DataProvider>().loadMoreCoupons();
//               }
//               return false;
//             },
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minWidth: w),
//                 child: DataTable(
//                   columnSpacing: defaultPadding,
//                   columns: const [
//                     DataColumn(label: Text("کد کوپن")),
//                     DataColumn(label: Text("وضعیت")),
//                     DataColumn(label: Text("نوع تخفیف")),
//                     DataColumn(label: Text("مقدار تخفیف")),
//                     DataColumn(label: Text("ویرایش")),
//                     DataColumn(label: Text("حذف")),
//                   ],
//                   rows: [
//                     // حالت لود اولیه
//                     if (loading && coupons.isEmpty) ..._buildShimmerRows(10),
//
//                     // لیست اصلی
//                     if (!(loading && coupons.isEmpty))
//                       ...List<DataRow>.generate(
//                         coupons.length,
//                             (index) =>
//                             _couponDataRow(context, coupons[index], index + 1),
//                       ),
//
//                     // لود بیشتر
//                     if (loadingMore)
//                       DataRow(cells: [
//                         DataCell(_shimmerBox(w: 160, h: 14)),
//                         DataCell(_shimmerBox(w: 80, h: 14)),
//                         DataCell(_shimmerBox(w: 100, h: 14)),
//                         DataCell(_shimmerBox(w: 80, h: 14)),
//                         DataCell(_shimmerBox(w: 28, h: 28)),
//                         DataCell(_shimmerBox(w: 28, h: 28)),
//                       ]),
//
//                     // پایان لیست
//                     if (!hasMore && !loading && coupons.isNotEmpty)
//                       const DataRow(
//                         cells: [
//                           DataCell(Text('')),
//                           DataCell(Center(child: Text('پایان لیست'))),
//                           DataCell(Text('')),
//                           DataCell(Text('')),
//                           DataCell(Text('')),
//                           DataCell(Text('')),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Row(
//             children: [
//               Container(
//                 height: 24,
//                 width: 24,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: colors[index % colors.length],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   '$index',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//               const SizedBox(width: defaultPadding),
//               Text(coupon.couponCode ?? ''),
//             ],
//           ),
//         ),
//         DataCell(Text(coupon.status ?? '')),
//         DataCell(Text(coupon.discountType ?? '')),
//         DataCell(Text('${coupon.discountAmount ?? ''}')),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               showAddCouponForm(context, coupon);
//             },
//             tooltip: 'ویرایش کوپن',
//             icon: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ),
//         DataCell(
//           IconButton(
//             onPressed: () async {
//               if (await UserSaveHelper.isExpired()) {
//                 DialogHelper.showExpiredDialog(context);
//                 return;
//               }
//               context.couponCodeProvider.deleteCoupon(coupon);
//             },
//             tooltip: 'حذف کوپن',
//             icon: const Icon(Icons.delete, color: Colors.red),
//           ),
//         ),
//       ],
//     );
//   }
// }
//


import 'package:admin/utility/User_helper.dart';
import 'package:admin/utility/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/coupon.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import 'add_coupon_form.dart';

class CouponListSection extends StatefulWidget {
  const CouponListSection({Key? key}) : super(key: key);

  @override
  State<CouponListSection> createState() => _CouponListSectionState();
}

class _CouponListSectionState extends State<CouponListSection> {
  ScrollPosition? _outerScrollPos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ نزدیک‌ترین اسکرول والد (اسکرول عمودی صفحه)
    final pos = Scrollable.of(context)?.position;

    if (pos != null && pos != _outerScrollPos) {
      _outerScrollPos?.removeListener(_onOuterScroll);
      _outerScrollPos = pos;
      _outerScrollPos?.addListener(_onOuterScroll);
    }
  }

  @override
  void dispose() {
    _outerScrollPos?.removeListener(_onOuterScroll);
    super.dispose();
  }

  void _onOuterScroll() {
    if (!mounted) return;

    final dp = context.read<DataProvider>();

    // اگر پیجینگ در حال انجامه یا بیشتر نداریم، هیچی
    if (!dp.hasMoreCoupons || dp.isCouponsLoading || dp.isCouponsLoadingMore) {
      return;
    }

    final pos = _outerScrollPos;
    if (pos == null) return;

    // ✅ نزدیک انتهای اسکرول صفحه
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      dp.loadMoreCoupons();
    }
  }

  Widget _shimmerBox({double w = 120, double h = 14, BorderRadius? r}) {
    return Shimmer(
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: r ?? BorderRadius.circular(6),
        ),
      ),
    );
  }

  List<DataRow> _buildShimmerRows(int count) {
    return List.generate(count, (_) {
      return DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                _shimmerBox(w: 24, h: 24, r: BorderRadius.circular(999)),
                const SizedBox(width: defaultPadding),
                _shimmerBox(w: 120, h: 14),
              ],
            ),
          ),
          DataCell(_shimmerBox(w: 70, h: 14)),
          DataCell(_shimmerBox(w: 90, h: 14)),
          DataCell(_shimmerBox(w: 70, h: 14)),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
          DataCell(_shimmerBox(w: 28, h: 28, r: BorderRadius.circular(6))),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DataProvider>();
    final coupons = dp.coupons;

    final loading = dp.isCouponsLoading;
    final loadingMore = dp.isCouponsLoadingMore;
    final hasMore = dp.hasMoreCoupons;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: LayoutBuilder(
        builder: (_, cons) {
          final w = cons.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: w),
              child: DataTable(
                columnSpacing: defaultPadding,
                columns: const [
                  DataColumn(label: Text("کد کوپن")),
                  DataColumn(label: Text("وضعیت")),
                  DataColumn(label: Text("نوع تخفیف")),
                  DataColumn(label: Text("مقدار تخفیف")),
                  DataColumn(label: Text("ویرایش")),
                  DataColumn(label: Text("حذف")),
                ],
                rows: [
                  // ✅ لود اولیه
                  if (loading && coupons.isEmpty) ..._buildShimmerRows(10),

                  // ✅ دیتا
                  if (!(loading && coupons.isEmpty))
                    ...List<DataRow>.generate(
                      coupons.length,
                          (index) => _couponDataRow(context, coupons[index], index + 1),
                    ),

                  // ✅ لود بیشتر (ردیف پایین جدول)
                  if (loadingMore)
                    DataRow(
                      cells: [
                        DataCell(_shimmerBox(w: 160, h: 14)),
                        DataCell(_shimmerBox(w: 80, h: 14)),
                        DataCell(_shimmerBox(w: 100, h: 14)),
                        DataCell(_shimmerBox(w: 80, h: 14)),
                        DataCell(_shimmerBox(w: 28, h: 28)),
                        DataCell(_shimmerBox(w: 28, h: 28)),
                      ],
                    ),

                  // ✅ پایان لیست
                  if (!hasMore && !loading && coupons.isNotEmpty)
                    const DataRow(
                      cells: [
                        DataCell(Text('')),
                        DataCell(Center(child: Text('پایان لیست'))),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _couponDataRow(BuildContext context, Coupon coupon, int index) {
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
                  '$index',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Text(coupon.couponCode ?? ''),
            ],
          ),
        ),
        DataCell(Text(coupon.status ?? '')),
        DataCell(Text(coupon.discountType ?? '')),
        DataCell(Text('${coupon.discountAmount ?? ''}')),
        DataCell(
          IconButton(
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              showAddCouponForm(context, coupon);
            },
            tooltip: 'ویرایش کوپن',
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () async {
              if (await UserSaveHelper.isExpired()) {
                DialogHelper.showExpiredDialog(context);
                return;
              }
              context.couponCodeProvider.deleteCoupon(coupon);
            },
            tooltip: 'حذف کوپن',
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
    );
  }
}



